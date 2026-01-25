import { useState, useCallback, useEffect, useRef } from 'react';
import { Sidebar } from '@components/Sidebar';
import { ConnectionInput } from '@components/ConnectionInput';
import { Matrix } from '@components/Matrix';
import { useShaders } from './hooks/useShaders';
import { useWebSocket } from './hooks/useWebSocket';
import type { ShaderFile, WebSocketConnection } from './types';
import './styles/App.css';

const STORAGE_KEY = 'ovj-config';
const BPM_STORAGE_KEY = 'ovj-bpm';

interface StoredConfig {
  addedShaders: ShaderFile[];
  connections: { id: string; url: string }[];
  activeShaders: [string, string][];
}

function loadConfig(): StoredConfig | null {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (stored) {
      return JSON.parse(stored);
    }
  } catch {
    // Ignore parse errors
  }
  return null;
}

function saveConfig(config: StoredConfig) {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(config));
}

/**
 * Builds the WebSocket message payload for sending a shader.
 */
function buildShaderMessage(code: string): string {
  return JSON.stringify({
    Data: {
      Anchor: 0,
      Caret: 0,
      Code: code,
      Compile: true,
      FirstVisibleLine: 0,
      NickName: 'ovj',
      RoomName: 'ovj',
      ShaderTime: 0,
    },
  }) + '\0';
}

function App() {
  const { shaders, loading, error } = useShaders();
  const [selected, setSelected] = useState<ShaderFile | null>(null);

  // Cache config loading to avoid parsing localStorage multiple times during initialization
  let _cachedInitialConfig: StoredConfig | null | undefined;
  const getInitialConfig = () => {
    if (_cachedInitialConfig === undefined) {
      _cachedInitialConfig = loadConfig();
    }
    return _cachedInitialConfig;
  };

  const [addedShaders, setAddedShaders] = useState<ShaderFile[]>(() => {
    return getInitialConfig()?.addedShaders || [];
  });
  const [connections, setConnections] = useState<WebSocketConnection[]>([]);
  const [activeShaders, setActiveShaders] = useState<Map<string, string>>(() => {
    const config = getInitialConfig();
    return config?.activeShaders ? new Map(config.activeShaders) : new Map();
  });
  const [bpm, setBpm] = useState<number>(() => {
    const stored = localStorage.getItem(BPM_STORAGE_KEY);
    return stored ? Number(stored) : 120;
  });
  const [playingConnections, setPlayingConnections] = useState<Set<string>>(new Set());
  const [playModes, setPlayModes] = useState<Map<string, 'sequential' | 'random'>>(new Map());
  const [bpmModifiers, setBpmModifiers] = useState<Map<string, '*2' | '*4' | '/2' | '/4' | null>>(new Map());
  const initializedRef = useRef(false);
  const intervalsRef = useRef<Map<string, number>>(new Map());
  const shuffleBagsRef = useRef<Map<string, string[]>>(new Map()); // connectionId -> remaining shader IDs
  const shaderCacheRef = useRef<Map<string, string>>(new Map()); // shader path -> code

  const handleStatusChange = useCallback((id: string, status: WebSocketConnection['status']) => {
    setConnections((prev) =>
      prev.map((c) => (c.id === id ? { ...c, status } : c))
    );
  }, []);

  const { connect, disconnect, disconnectAll, send } = useWebSocket(handleStatusChange);

  // Fetch shader code with caching
  const fetchShaderCode = useCallback(async (shader: ShaderFile): Promise<string> => {
    const cached = shaderCacheRef.current.get(shader.path);
    if (cached !== undefined) {
      return cached;
    }
    const response = await fetch(shader.path);
    if (!response.ok) throw new Error('Failed to fetch shader');
    const code = await response.text();
    shaderCacheRef.current.set(shader.path, code);
    return code;
  }, []);

  // Restore connections on mount
  useEffect(() => {
    if (initializedRef.current) return;
    initializedRef.current = true;
    
    const config = getInitialConfig();
    if (config?.connections && config.connections.length > 0) {
      const restoredConnections: WebSocketConnection[] = config.connections.map((conn) => ({
        id: conn.id,
        url: conn.url,
        status: 'connecting' as const,
      }));
      setConnections(restoredConnections);
      for (const conn of config.connections) {
        connect(conn.id, conn.url);
      }
    }
  }, [connect]);

  // Save config when state changes
  useEffect(() => {
    if (initializedRef.current) {
      saveConfig({
        addedShaders,
        connections: connections.map((c) => ({ id: c.id, url: c.url })),
        activeShaders: Array.from(activeShaders.entries()),
      });
    }
  }, [addedShaders, connections, activeShaders]);

  // Save BPM when it changes
  useEffect(() => {
    localStorage.setItem(BPM_STORAGE_KEY, String(bpm));
  }, [bpm]);

  // Send shader helper for sequencing (doesn't rely on connection object lookup)
  const sendShaderToConnection = useCallback(async (shader: ShaderFile, connectionId: string) => {
    try {
      const code = await fetchShaderCode(shader);
      const message = buildShaderMessage(code);
      send(connectionId, message);
      setActiveShaders((prev) => new Map(prev).set(connectionId, shader.id));
    } catch (err) {
      console.error('Failed to send shader:', err);
    }
  }, [send, fetchShaderCode]);

  // Manage play intervals
  useEffect(() => {
    const baseIntervalMs = 60000 / bpm; // ms per beat

    // Clear all existing intervals and restart for playing connections
    for (const [, intervalId] of intervalsRef.current) {
      clearInterval(intervalId);
    }
    intervalsRef.current.clear();

    for (const connId of playingConnections) {
      const conn = connections.find((c) => c.id === connId);
      if (!conn || conn.status !== 'connected' || addedShaders.length === 0) {
        continue;
      }

      const mode = playModes.get(connId) || 'sequential';
      const modifier = bpmModifiers.get(connId);
      
      // Apply BPM modifier
      let intervalMs = baseIntervalMs;
      if (modifier === '*2') intervalMs = baseIntervalMs / 2;
      else if (modifier === '*4') intervalMs = baseIntervalMs / 4;
      else if (modifier === '/2') intervalMs = baseIntervalMs * 2;
      else if (modifier === '/4') intervalMs = baseIntervalMs * 4;

      const intervalId = window.setInterval(() => {
        setActiveShaders((prev) => {
          let nextShader: ShaderFile | undefined;

          if (mode === 'random') {
            // Random bag mode: pick and remove a random shader from bag, refill when empty
            let bag = shuffleBagsRef.current.get(connId);
            
            // Refill bag if empty or doesn't exist
            if (!bag || bag.length === 0) {
              bag = addedShaders.map((s) => s.id);
              shuffleBagsRef.current.set(connId, bag);
            }
            
            // Pick random item from bag and remove it
            const randomIndex = Math.floor(Math.random() * bag.length);
            const shaderId = bag.splice(randomIndex, 1)[0];
            nextShader = addedShaders.find((s) => s.id === shaderId);
          } else {
            // Sequential mode: go to next shader
            const currentShaderId = prev.get(connId);
            const currentIndex = addedShaders.findIndex((s) => s.id === currentShaderId);
            const nextIndex = currentIndex === -1 ? 0 : (currentIndex + 1) % addedShaders.length;
            nextShader = addedShaders[nextIndex];
          }
          
          if (nextShader) {
            sendShaderToConnection(nextShader, connId);
          }
          
          return prev;
        });
      }, intervalMs);

      intervalsRef.current.set(connId, intervalId);
    }

    return () => {
      for (const intervalId of intervalsRef.current.values()) {
        clearInterval(intervalId);
      }
    };
  }, [playingConnections, bpm, connections, addedShaders, playModes, bpmModifiers, sendShaderToConnection]);

  // Stop playing when connection is removed or disconnected
  useEffect(() => {
    setPlayingConnections((prev) => {
      const next = new Set(prev);
      for (const connId of prev) {
        const conn = connections.find((c) => c.id === connId);
        if (!conn || conn.status !== 'connected') {
          next.delete(connId);
        }
      }
      return next.size !== prev.size ? next : prev;
    });
  }, [connections]);

  const handleTogglePlay = useCallback((connectionId: string) => {
    setPlayingConnections((prev) => {
      const next = new Set(prev);
      if (next.has(connectionId)) {
        next.delete(connectionId);
        // Clear shuffle bag when stopping
        shuffleBagsRef.current.delete(connectionId);
      } else {
        next.add(connectionId);
      }
      return next;
    });
  }, []);

  const handleTogglePlayMode = useCallback((connectionId: string) => {
    // Clear shuffle bag when changing mode so it starts fresh
    shuffleBagsRef.current.delete(connectionId);
    setPlayModes((prev) => {
      const next = new Map(prev);
      const currentMode = prev.get(connectionId) || 'sequential';
      next.set(connectionId, currentMode === 'sequential' ? 'random' : 'sequential');
      return next;
    });
  }, []);

  const handleToggleBpmModifier = useCallback((connectionId: string, modifier: '*2' | '*4' | '/2' | '/4') => {
    setBpmModifiers((prev) => {
      const next = new Map(prev);
      const current = prev.get(connectionId);
      // Toggle: if same modifier, turn off; otherwise set new modifier
      if (current === modifier) {
        next.delete(connectionId);
      } else {
        next.set(connectionId, modifier);
      }
      return next;
    });
  }, []);

  const handleClearStorage = useCallback(() => {
    localStorage.removeItem(STORAGE_KEY);
    // Disconnect all connections
    disconnectAll();
    setAddedShaders([]);
    setConnections([]);
    setActiveShaders(new Map());
    setPlayingConnections(new Set());
    setPlayModes(new Map());
    setBpmModifiers(new Map());
    shuffleBagsRef.current.clear();
  }, [disconnectAll]);

  const handleAddShader = useCallback((shader: ShaderFile) => {
    setAddedShaders((prev) => {
      if (prev.find((s) => s.id === shader.id)) {
        return prev;
      }
      return [...prev, shader];
    });
  }, []);

  const handleRemoveShader = useCallback((shader: ShaderFile) => {
    setAddedShaders((prev) => prev.filter((s) => s.id !== shader.id));
    setActiveShaders((prev) => {
      const next = new Map(prev);
      for (const [connId, shaderId] of next) {
        if (shaderId === shader.id) {
          next.delete(connId);
        }
      }
      return next;
    });
    // Clear all shuffle bags so they refresh with updated shader list
    shuffleBagsRef.current.clear();
  }, []);

  const handleAddConnection = useCallback((url: string) => {
    const id = crypto.randomUUID();
    const newConnection: WebSocketConnection = {
      id,
      url,
      status: 'connecting',
    };
    setConnections((prev) => [...prev, newConnection]);
    connect(id, url);
  }, [connect]);

  const handleRemoveConnection = useCallback((connection: WebSocketConnection) => {
    disconnect(connection.id);
    setConnections((prev) => prev.filter((c) => c.id !== connection.id));
    setActiveShaders((prev) => {
      const next = new Map(prev);
      next.delete(connection.id);
      return next;
    });
    setPlayingConnections((prev) => {
      const next = new Set(prev);
      next.delete(connection.id);
      return next;
    });
    setPlayModes((prev) => {
      const next = new Map(prev);
      next.delete(connection.id);
      return next;
    });
    setBpmModifiers((prev) => {
      const next = new Map(prev);
      next.delete(connection.id);
      return next;
    });
    shuffleBagsRef.current.delete(connection.id);
  }, [disconnect]);

  const handleReconnect = useCallback((connection: WebSocketConnection) => {
    disconnect(connection.id);
    setConnections((prev) =>
      prev.map((c) => (c.id === connection.id ? { ...c, status: 'connecting' } : c))
    );
    connect(connection.id, connection.url);
  }, [disconnect, connect]);

  const handleSend = useCallback(async (shader: ShaderFile, connection: WebSocketConnection) => {
    try {
      const code = await fetchShaderCode(shader);
      const message = buildShaderMessage(code);
      send(connection.id, message);
      setActiveShaders((prev) => new Map(prev).set(connection.id, shader.id));
    } catch (err) {
      console.error('Failed to send shader:', err);
    }
  }, [send, fetchShaderCode]);

  return (
    <div className="app">
      <Sidebar
        shaders={shaders}
        onSelect={setSelected}
        onAdd={handleAddShader}
        selected={selected}
      />
      <div className="app__main">
        <div className="app__toolbar">
          <ConnectionInput onAdd={handleAddConnection} />
          <button className="app__clear-btn" onClick={handleClearStorage}>
            Clear All
          </button>
          <div className="app__bpm">
            <label htmlFor="bpm-input">BPM</label>
            <input
              id="bpm-input"
              type="number"
              min="1"
              max="999"
              value={bpm}
              onChange={(e) => setBpm(Number(e.target.value))}
              className="app__bpm-input"
            />
          </div>
        </div>
        <Matrix
          shaders={addedShaders}
          connections={connections}
          activeShaders={activeShaders}
          playingConnections={playingConnections}
          playModes={playModes}
          bpmModifiers={bpmModifiers}
          onRemoveShader={handleRemoveShader}
          onRemoveConnection={handleRemoveConnection}
          onReconnect={handleReconnect}
          onSend={handleSend}
          onTogglePlay={handleTogglePlay}
          onTogglePlayMode={handleTogglePlayMode}
          onToggleBpmModifier={handleToggleBpmModifier}
        />
        {loading && <p className="app__status">Loading shaders...</p>}
        {error && <p className="app__status app__status--error">Error: {error}</p>}
      </div>
    </div>
  );
}

export default App;

import { Fragment, memo, useMemo } from 'react';
import type { ShaderFile, WebSocketConnection } from '../../types';
import './Matrix.css';

function getShortUrl(url: string): string {
  try {
    const parsed = new URL(url);
    const parts = parsed.pathname.split('/').filter(Boolean);
    return parts.slice(-2).join('/') || parsed.host;
  } catch {
    return url;
  }
}

type BpmModifier = '*2' | '*4' | '/2' | '/4';

interface MatrixProps {
  shaders: ShaderFile[];
  connections: WebSocketConnection[];
  activeShaders: Map<string, string>; // connectionId -> shaderId
  playingConnections: Set<string>; // connectionIds that are in play mode
  playModes: Map<string, 'sequential' | 'random'>; // connectionId -> play mode
  bpmModifiers: Map<string, BpmModifier | null>; // connectionId -> BPM modifier
  onRemoveShader: (shader: ShaderFile) => void;
  onRemoveConnection: (connection: WebSocketConnection) => void;
  onReconnect: (connection: WebSocketConnection) => void;
  onSend: (shader: ShaderFile, connection: WebSocketConnection) => void;
  onTogglePlay: (connectionId: string) => void;
  onTogglePlayMode: (connectionId: string) => void;
  onToggleBpmModifier: (connectionId: string, modifier: BpmModifier) => void;
}

export const Matrix = memo(function Matrix({ shaders, connections, activeShaders, playingConnections, playModes, bpmModifiers, onRemoveShader, onRemoveConnection, onReconnect, onSend, onTogglePlay, onTogglePlayMode, onToggleBpmModifier }: MatrixProps) {
  // Memoize shortened URLs to avoid URL parsing on every render
  const shortUrls = useMemo(() => {
    const urls = new Map<string, string>();
    for (const conn of connections) {
      urls.set(conn.id, getShortUrl(conn.url));
    }
    return urls;
  }, [connections]);

  return (
    <div className="matrix">
      <div
        className="matrix__grid"
        style={{ '--cols': connections.length } as React.CSSProperties}
      >
        {/* Empty top-left corner */}
        <div className="matrix__corner" />

        {/* Connection headers (columns) */}
        {connections.map((conn) => {
          const isPlaying = playingConnections.has(conn.id);
          const playMode = playModes.get(conn.id) || 'sequential';
          const isRandom = playMode === 'random';
          const currentModifier = bpmModifiers.get(conn.id);
          return (
            <div key={conn.id} className="matrix__col-header">
              <div className="matrix__col-actions">
                <button
                  className={`matrix__play ${isPlaying ? 'matrix__play--active' : ''}`}
                  onClick={() => onTogglePlay(conn.id)}
                  title={isPlaying ? 'Stop sequence' : 'Play sequence'}
                  disabled={conn.status !== 'connected' || shaders.length === 0}
                >
                  {isPlaying ? '■' : '▶'}
                </button>
                <button
                  className={`matrix__mode ${isRandom ? 'matrix__mode--random' : ''}`}
                  onClick={() => onTogglePlayMode(conn.id)}
                  title={isRandom ? 'Random mode (click for sequential)' : 'Sequential mode (click for random)'}
                >
                  {isRandom ? '🔀' : '↓'}
                </button>
                <button
                  className="matrix__reconnect"
                  onClick={() => onReconnect(conn)}
                  title="Reconnect"
                >
                  ↻
                </button>
                <button
                  className="matrix__remove"
                  onClick={() => onRemoveConnection(conn)}
                  title="Remove"
                >
                  ×
                </button>
              </div>
              <div className="matrix__col-actions">
                <button
                  className={`matrix__bpm-mod ${currentModifier === '*2' ? 'matrix__bpm-mod--active' : ''}`}
                  onClick={() => onToggleBpmModifier(conn.id, '*2')}
                  title="Double speed (×2)"
                >
                  ×2
                </button>
                <button
                  className={`matrix__bpm-mod ${currentModifier === '*4' ? 'matrix__bpm-mod--active' : ''}`}
                  onClick={() => onToggleBpmModifier(conn.id, '*4')}
                  title="Quadruple speed (×4)"
                >
                  ×4
                </button>
                <button
                  className={`matrix__bpm-mod ${currentModifier === '/2' ? 'matrix__bpm-mod--active' : ''}`}
                  onClick={() => onToggleBpmModifier(conn.id, '/2')}
                  title="Half speed (÷2)"
                >
                  ÷2
                </button>
                <button
                  className={`matrix__bpm-mod ${currentModifier === '/4' ? 'matrix__bpm-mod--active' : ''}`}
                  onClick={() => onToggleBpmModifier(conn.id, '/4')}
                  title="Quarter speed (÷4)"
                >
                  ÷4
                </button>
              </div>
              <span className={`matrix__status matrix__status--${conn.status}`} />
              <span className="matrix__col-url" title={conn.url}>{shortUrls.get(conn.id)}</span>
            </div>
          );
        })}

        {/* Shader rows */}
        {shaders.map((shader) => (
          <Fragment key={shader.id}>
            {/* Row header (shader info) */}
            <div className="matrix__row-header">
              <img
                src={shader.image || ''}
                alt={shader.name}
                className="matrix__thumb"
              />
              <button
                className="matrix__remove"
                onClick={() => onRemoveShader(shader)}
              >
                ×
              </button>
            </div>

            {/* Cells for each connection */}
            {connections.map((conn) => {
              const isActive = activeShaders.get(conn.id) === shader.id;
              
              return (
                <div
                  key={`${shader.id}-${conn.id}`}
                  className="matrix__cell"
                >
                  <button
                    className={`matrix__cell-btn ${isActive ? 'matrix__cell-btn--active' : ''}`}
                    onClick={() => onSend(shader, conn)}
                    disabled={conn.status !== 'connected'}
                  >
                    Send
                  </button>
                </div>
              );
            })}
          </Fragment>
        ))}
      </div>

      {shaders.length === 0 && connections.length === 0 && (
        <div className="matrix__empty">
          Add shaders from the sidebar and WebSocket connections above
        </div>
      )}
    </div>
  );
});

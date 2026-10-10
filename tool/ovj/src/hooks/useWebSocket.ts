import { useRef, useCallback } from 'react';
import type { WebSocketConnection } from '../types';

type ConnectionMap = Map<string, WebSocket>;
type StatusCallback = (id: string, status: WebSocketConnection['status']) => void;

export function useWebSocket(onStatusChange: StatusCallback) {
  const socketsRef = useRef<ConnectionMap>(new Map());

  const connect = useCallback((id: string, url: string) => {
    onStatusChange(id, 'connecting');

    try {
      const ws = new WebSocket(url);

      ws.onopen = () => {
        onStatusChange(id, 'connected');
      };

      ws.onclose = () => {
        onStatusChange(id, 'disconnected');
        socketsRef.current.delete(id);
      };

      ws.onerror = () => {
        onStatusChange(id, 'error');
      };

      socketsRef.current.set(id, ws);
    } catch {
      onStatusChange(id, 'error');
    }
  }, [onStatusChange]);

  const disconnect = useCallback((id: string) => {
    const ws = socketsRef.current.get(id);
    if (ws) {
      ws.close();
      socketsRef.current.delete(id);
    }
  }, []);

  const disconnectAll = useCallback(() => {
    for (const [id, ws] of socketsRef.current) {
      ws.close();
      socketsRef.current.delete(id);
    }
  }, []);

  const send = useCallback((id: string, data: string) => {
    const ws = socketsRef.current.get(id);
    if (ws && ws.readyState === WebSocket.OPEN) {
      ws.send(data);
    }
  }, []);

  return { connect, disconnect, disconnectAll, send };
}

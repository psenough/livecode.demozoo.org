export interface ShaderFile {
  id: string;
  name: string;
  path: string;
  event: string;
  image: string | null;
}

export interface WebSocketConnection {
  id: string;
  url: string;
  status: 'connecting' | 'connected' | 'disconnected' | 'error';
}

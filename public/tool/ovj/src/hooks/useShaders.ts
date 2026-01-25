import { useState, useEffect } from 'react';
import type { ShaderFile } from '../types';

export function useShaders() {
  const [shaders, setShaders] = useState<ShaderFile[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadShaders() {
      try {
        const res = await fetch('/shaders.json');
        if (!res.ok) throw new Error('Failed to load shader index');
        const data: ShaderFile[] = await res.json();
        setShaders(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    }
    loadShaders();
  }, []);

  return { shaders, loading, error };
}

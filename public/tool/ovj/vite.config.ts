import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';
import { readFileSync, existsSync, statSync } from 'fs';

export default defineConfig({
  plugins: [
    react(),
    {
      name: 'serve-parent-public',
      configureServer(server) {
        server.middlewares.use((req, res, next) => {
          const publicRoot = resolve(__dirname, '../../');
          const filePath = resolve(publicRoot, req.url?.slice(1) || '');
          
          if (existsSync(filePath) && !filePath.includes('/tool/ovj/') && statSync(filePath).isFile()) {
            try {
              const content = readFileSync(filePath);
              const ext = filePath.split('.').pop()?.toLowerCase();
              const mimeTypes: Record<string, string> = {
                jpg: 'image/jpeg',
                jpeg: 'image/jpeg',
                png: 'image/png',
                gif: 'image/gif',
                glsl: 'text/plain',
                lua: 'text/plain',
                json: 'application/json',
              };
              res.setHeader('Content-Type', mimeTypes[ext || ''] || 'application/octet-stream');
              res.end(content);
              return;
            } catch {
              // Fall through to next handler
            }
          }
          next();
        });
      },
    },
  ],
  resolve: {
    alias: {
      '@': resolve(__dirname, './src'),
      '@components': resolve(__dirname, './src/components'),
      '@types': resolve(__dirname, './src/types'),
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  },
  server: {
    port: 3000,
    open: true,
  },
});

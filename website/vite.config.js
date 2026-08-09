import { defineConfig } from 'vite';

export default defineConfig({
  // Custom domain (map_dev.com) — site is served from domain apex
  base: '/',
  root: '.',
  publicDir: 'public',
  server: {
    port: 5173,
    open: true,
  },
  build: {
    outDir: 'dist',
    emptyOutDir: true,
  },
});

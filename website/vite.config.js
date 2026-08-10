import { defineConfig } from 'vite';

// Firebase Hosting uses root `/`. GitHub Pages sets VITE_BASE=/map_dev/ in CI.
export default defineConfig({
  base: process.env.VITE_BASE || '/',
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

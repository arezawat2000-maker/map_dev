import { defineConfig } from 'vite';

export default defineConfig({
  // Project Pages URL: https://arezawat2000-maker.github.io/map_dev/
  base: '/map_dev/',
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

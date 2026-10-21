# Front-end Build Recipes

## Vite config skeleton
```ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
export default defineConfig({
  plugins: [react()],
  base: './',                 // relative for static hosts; '/sub/' for subpath
  server: { port: 5173, proxy: { '/api': 'http://localhost:8080' } },
  build: {
    target: 'es2020',
    sourcemap: false,
    chunkSizeWarningLimit: 600,
    rollupOptions: {
      output: {
        manualChunks: { vendor: ['react', 'react-dom', '@tanstack/react-query'] },
      },
    },
  },
});
```

## size-limit config (CI budget)
```json
// package.json
"size-limit": [
  { "path": "dist/assets/index-*.js", "limit": "200 kB" },
  { "path": "dist/assets/*.css", "limit": "50 kB" }
]
```

## Bundle analysis
```ts
import { visualizer } from 'rollup-plugin-visualizer';
plugins: [react(), visualizer({ open: false, filename: 'stats.html' })]
```

## "sideEffects" for tree-shaking
```json
// package.json
{ "sideEffects": ["*.css", "./src/polyfills.ts"] }
```

## Named import (avoid barrel bloat)
- Good: `import { debounce } from 'lodash-es'`
- Bad:  `import _ from 'lodash'; _.debounce(...)`

## Deploy gotchas
- White screen → wrong `base`; use `base: './'` for file-hosted SPA.
- Use `<base href="/sub/">` when serving under a subpath.
- Long-cache `/assets/*` with `Cache-Control: public, max-age=31536000, immutable`.

## CI build + budget
```
- npm ci
- npm run build
- npx size-limit
- upload dist as artifact
```

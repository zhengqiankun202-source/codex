---
name: frontend-build
description: Front-end build & bundling optimization specialist. Use when setting up, tuning, or debugging a Vite / Rollup / webpack build — code splitting, lazy loading, tree shaking, dependency pre-bundling, bundle-size budgets, and CI build caching. Targets fast dev start and small production bundles.
---

# Front-end Build Optimization

Practical guidance for Vite (default for new React/Vue/TS projects) plus Rollup/webpack notes. Goal: fast `dev` start, small and cacheable `dist`, no white screen on deploy.

## 1. Default to Vite

- Vite uses native ESM in dev (no bundling → instant start) and Rollup in build (great tree-shaking).
- Config lives in `vite.config.ts`. For React add `@vitejs/plugin-react`; for Vue `@vitejs/plugin-vue`.
- `server.proxy` to avoid CORS in dev; never call prod API base directly in dev with credentials.

## 2. Code splitting — load only what's needed

- **Route-level lazy loading** (biggest win):

```tsx
// React
const Settings = lazy(() => import('./Settings'));
<Suspense fallback={<Spinner />}><Routes>…<Route path="/settings" element={<Settings />} /></Routes></Suspense>
```
```ts
// Vue 3 (router)
{ path: '/settings', component: () => import('./Settings.vue') }
```
- **Manual chunks** to split vendor libs that change rarely from app code (better caching):

```ts
// vite.config.ts
build: {
  rollupOptions: {
    output: {
      manualChunks: {
        'react-vendor': ['react', 'react-dom'],
        'query-vendor': ['@tanstack/react-query'],
      },
    },
  },
}
```
- Always set `build.chunkSizeWarningLimit` and add a **bundle-size budget** check in CI (e.g. `size-limit` or `bundlesize`).

## 3. Tree shaking & dead code

- Ship **ESM**, set `"sideEffects"` correctly in `package.json` (false for pure CSS, list CSS/side-effectful files).
- Import **named**, not barrel, when a lib supports it: `import { debounce } from 'lodash-es'` not `import _ from 'lodash'`.
- Avoid `export * from` barrels that defeat tree-shaking in some setups; use explicit re-exports.
- Check `vite build --sourcemap` + `rollup-plugin-visualizer` to find the heavy module.

## 4. Dependency pre-bundling & caching

- Vite pre-bundles deps (esbuild) on first run into `node_modules/.vite`. If a dep misbehaves, add to `optimizeDeps.include` or `exclude`.
- For CJS-only deps, `optimizeDeps.include: ['some-cjs-pkg']` avoids runtime transform cost.
- CI: cache `~/.npm` and `node_modules`; Vite has no extra cache dir to persist.

## 5. Asset optimization

- Configure `build.assetsInlineLimit` (small assets → data URI). Use `?url` / `new URL(..., import.meta.url)` for asset URLs.
- Let the build hash filenames (`[name].[hash].js`) and set long `Cache-Control: immutable` on `/assets/*`.
- Compress in the host/CDN (brotli > gzip); don't gzip at build time unless required.
- Use `vite-imagetools` / `sharp` for responsive images; serve `avif`/`webp` with `<picture>`.

## 6. Modern target & polyfills

- `build.target: 'es2020'` (or `esnext` behind modern browserslist); drop legacy IE support unless required.
- Use `vite-plugin-legacy` only if you must support old browsers — it doubles output size.
- Load polyfills on demand (e.g. `core-js` per feature), not the whole bundle.

## 7. Dev experience

- `esbuild` minify (default). For terser-level compression (comments/license), switch `build.minify: 'termet'` only if needed.
- Enable `server.hmr` overlay; keep `deps` cache warm.
- Use `vite preview` to test the **real** production bundle locally before deploy.

## 8. Common build failures

- **White screen after deploy**: wrong `base` (set `base: '/subpath/'`), or absolute asset paths. Use relative `base: './'` for static hosts.
- **`process is not defined`**: replace Node globals; use `import.meta.env` (Vite exposes `MODE`, `BASE_URL`, custom `VITE_*`).
- **Circular chunk / `Invalid value used for the "chunk"`**: manualChunks function returned unstable names — make it pure/deterministic.
- **Dynamic import returns a string**: ensure target supports dynamic import; check `build.target`.

## 9. CI build recipe

```yaml
- run: npm ci
- run: npm run build
- run: npx size-limit   # fail if over budget
- uses: actions/upload-artifact@v4
  with: { path: dist }
```

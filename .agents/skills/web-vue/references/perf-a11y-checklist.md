# Performance & Accessibility Checklist

## Images (CLS + LCP)
- Always set `width` + `height` (or `aspect-ratio`) → no layout shift.
- Above-the-fold hero: `fetchpriority="high"` + `<link rel="preload" as="image">`.
- Below-the-fold: `loading="lazy"` + `decoding="async"`.
- Format: `avif` → `webp` → `jpg`; use `<picture>` with sources.
- Never ship full-res as thumbnail; serve sized variants.

## Fonts (no FOIT)
- `font-display: swap`; `preconnect` to font host.
- Subset with `unicode-range`; self-host critical fonts when possible.

## JS (INP + bundle)
- Route-level `lazy()` / `() => import()` for every non-landing route.
- `manualChunks` to separate slow-changing vendor from app.
- `startTransition` / `useDeferredValue` for non-urgent React updates.
- Break >50ms work: `await scheduler.yield()` or Web Worker.
- Avoid layout thrash: read all measurements, then write.

## CSS
- Inline critical CSS for first paint; defer the rest.
- Don't `@import` (blocks); bundle instead.
- Respect `prefers-reduced-motion: reduce`.

## a11y — semantics
- Real elements: `<button>`, `<nav>`, `<main>`, `<table>`. Headings in order.
- One `<h1>` per page/region; don't skip levels.

## a11y — keyboard & focus
- All interactive elements `Tab`-reachable + visible focus (no bare `outline:none`).
- Modals: focus moves in, traps, returns to trigger on close.
- Skip-link to main content.

## a11y — labels & roles
- Every input has `<label>` or `aria-label`/`aria-labelledby`.
- Errors in `aria-live="polite"` region; `aria-invalid` on bad field.
- Decorative images `alt=""`; meaningful images descriptive `alt`.
- Status not conveyed by color alone.

## a11y — contrast
- Body text ≥ 4.5:1; large text (≥18px bold / 24px) ≥ 3:1.
- Test with simulators (color-blind) + a contrast checker.

## Automated gates (CI)
- `vitest-axe` in smoke tests; `eslint-plugin-jsx-a11y` / `vuejs-accessibility` in lint.
- Lighthouse CI: perf ≥ 90, a11y ≥ 90.

## Field monitoring
- Wire `web-vitals` RUM: track LCP/INP/CLS p75.
- Alert when p75 regresses past budget.

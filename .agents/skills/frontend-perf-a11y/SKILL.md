---
name: frontend-perf-a11y
description: Web performance & accessibility (a11y) specialist. Use when auditing or improving a front-end app's speed (Core Web Vitals: LCP, INP, CLS) and inclusivity (WCAG, keyboard nav, screen readers, color contrast). Covers measurement, common regressions, and a shipping checklist.
---

# Web Performance & Accessibility

Two sides of "does it work for the user": it must be **fast** and **usable by everyone**. Pair with `frontend-build` (bundling) and `frontend-testing` (axe in tests).

## 1. Core Web Vitals (the metrics that matter)

| Metric | Target | What it measures | Top fix |
|---|---|---|---|
| **LCP** (Largest Contentful Paint) | < 2.5s | Loading speed | preload hero image, reduce TTFB, remove render-blocking CSS/JS |
| **INP** (Interaction to Next Paint) | < 200ms | Responsiveness | break long tasks, defer hydration, use `transition`/`startTransition` |
| **CLS** (Cumulative Layout Shift) | < 0.1 | Visual stability | set `width`/`height` on images, reserve space for async UI |

Measure with **Lighthouse CI** in the pipeline and **RUM** (web-vitals JS lib) in prod. Lab numbers lie; trust field/RUM.

## 2. Loading performance

- **Image**: `width`+`height` (no CLS), `loading="lazy"` (below fold), `fetchpriority="high"` on hero, serve `avif`/`webp`, use `srcset`. Never ship a 2MB JPEG as a thumbnail.
- **Fonts**: `font-display: swap`, `preconnect` to font CDN, subset with `@font-face` + `unicode-range`; avoid invisible-text (FOIT).
- **JS**: ship less (see `frontend-build`); defer non-critical (`type="module"` is deferred by default), hydrate lazily, use `<link rel="modulepreload">` for the next route.
- **Render-blocking**: inline critical CSS, load analytics/third-party with `defer`/`async`, avoid synchronous XHR.
- **TTFB**: cache at CDN/edge, use streaming SSR (RSC / `renderToPipeableStream`) for big pages.

## 3. Runtime responsiveness (INP)

- **Break long tasks**: split work with `await scheduler.yield()` / `MessageChannel`, or move to a Web Worker for parsing/crypto/heavy transforms.
- **Avoid layout thrash**: batch DOM reads then writes; don't interleave `getBoundingClientRect` + `style` in a loop.
- **React**: wrap non-urgent updates in `startTransition` / `useDeferredValue`; memoize expensive children (`React.memo`/`useMemo`) but don't over-memoize.
- **Vue**: keep computed cheap, avoid deep reactive watchers on huge objects.

## 4. Accessibility (WCAG 2.1 AA baseline)

- **Semantics first**: use real `<button>`, `<nav>`, `<main>`, `<table>`, headings in order (`h1`→`h2`). ARIA is a patch, not a substitute.
- **Keyboard**: every interactive element reachable via `Tab`, operable, with a visible focus ring (never `outline: none` without replacement). Custom widgets need `role` + arrow-key handling (e.g. menu, combobox).
- **Focus management**: move focus to modals/dialogs on open, trap inside, return to trigger on close; restore focus after route change to main content.
- **Labels**: every input has `<label>` or `aria-label`/`aria-labelledby`; groups use `<fieldset><legend>`.
- **Contrast**: text ≥ 4.5:1, large text ≥ 3:1; don't rely on color alone (add text/icon for errors/status).
- **Images**: meaningful `alt`; decorative `alt=""` (and `aria-hidden` for pure decoration).
- **Live regions**: announce async changes with `aria-live="polite"` (toasts, counts).
- **Reduced motion**: respect `@media (prefers-reduced-motion: reduce)` — disable autoplay/parallax.

## 5. Automated checks (cheap, run in CI)

- `axe-core` / `vitest-axe` in component tests (see `frontend-testing`).
- `eslint-plugin-jsx-a11y` (React) / `vuejs-accessibility` (Vue) in lint.
- Lighthouse CI score gate (perf + a11y + best-practices).
- Automatable items catch ~30% of issues; the rest need manual keyboard + screen-reader passes (NVDA/VoiceOver).

## 6. Shipping checklist (perf + a11y)

- [ ] LCP hero image preloaded, sized; LCP < 2.5s (RUM p75)
- [ ] INP < 200ms; no task > 50ms on main path
- [ ] CLS < 0.1; all media has dimensions
- [ ] Keyboard-only walkthrough passes; focus visible
- [ ] All forms labeled; errors announced via `aria-live`
- [ ] Color contrast ≥ 4.5:1; status not color-only
- [ ] `prefers-reduced-motion` respected
- [ ] Lighthouse a11y ≥ 90 in CI
- [ ] No `console` errors; RUM wired for post-launch watch

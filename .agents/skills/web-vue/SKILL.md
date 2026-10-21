---
name: web-vue
description: Unified frontend engineering guidance for React, Vue 3, TypeScript, CSS/Tailwind, client and server state, Vite/Rollup/Webpack builds, testing, performance, and accessibility. Use when building, debugging, refactoring, testing, or reviewing a frontend application; do not use for backend-only, data-only, or CLI-only work.
metadata:
  short-description: Unified React/Vue frontend engineering
---

# Web Frontend Engineering

Use this as the frontend entrypoint. Inspect first, then load one primary reference only when needed and at most one secondary for a clear cross-boundary concern. Never load every reference by default.

## Route by signal

| Task signals | Primary reference | Optional secondary |
|---|---|---|
| React, hook, effect, cleanup, form, component pattern | [react-hooks.md](references/react-hooks.md) | TypeScript utilities for type-boundary work |
| Vue, SFC, `<script setup>`, `ref`, `computed`, Pinia, composable | [vue-quickref.md](references/vue-quickref.md) | state recipes for store/query design |
| CSS, layout, Grid, Flexbox, Tailwind, theme, responsive | [css-recipes.md](references/css-recipes.md) | performance/a11y for visual regressions |
| TypeScript, `unknown`, narrowing, generics, props/types | [ts-utilities.md](references/ts-utilities.md) | framework reference when component types are involved |
| state, store, Pinia, Redux, Zustand, query/cache, server data | [state-recipes.md](references/state-recipes.md) | Vue or React reference for framework wiring |
| Vite, Rollup, Webpack, bundle, chunk, tree-shaking, build | [build-recipes.md](references/build-recipes.md) | performance/a11y for Core Web Vitals impact |
| Vitest, Playwright, Cypress, RTL, component/E2E test | [testing-recipes.md](references/testing-recipes.md) | performance/a11y for accessibility assertions |
| performance, Core Web Vitals, accessibility, keyboard, focus, contrast | [perf-a11y-checklist.md](references/perf-a11y-checklist.md) | CSS or testing reference when implementation-specific |

For a simple component or style edit, use repository conventions without loading an unrelated reference. Do not combine framework quickrefs with state recipes unless the task changes both wiring and state ownership.

## Working rules

1. Inspect framework/version, package manager, routing, styling, state/data libraries, test runner, build scripts, and existing component conventions.
2. Reuse existing components, hooks/composables, tokens, stores, query helpers, validators, and fixtures before adding a parallel abstraction or dependency.
3. Keep server data in a query/cache layer when available, local UI state near its component, and global state only for genuinely shared client state.
4. Type public data and component interfaces; prefer narrowing and `unknown` over `any`. Cover loading, empty, error, disabled, success, responsive, keyboard, and reduced-motion states when relevant.
5. Verify proportionally with the repository's lint, typecheck, unit/component/E2E, build, and preview commands. Check focus, labels, contrast, breakpoints, and layout stability for UI changes.

## Token contract

- Read only the selected primary reference; add the secondary only when its condition is present.
- Do not load framework, state, testing, and performance references together unless the task explicitly spans all of them.

## Boundary

Do not activate for backend-only services, database-only work, generic shell scripting, or unrelated documentation. For cross-stack work, apply this skill only to frontend code and preserve the existing API contract.

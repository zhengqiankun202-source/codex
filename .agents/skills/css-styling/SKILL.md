---
name: css-styling
description: Practical CSS assistant. Use when writing layout/styles — Flexbox, Grid, responsive design, custom properties (CSS variables), modern selectors, and the Tailwind utility-first workflow. Covers centering, spacing systems, theming, and common layout pitfalls.
metadata:
  short-description: CSS layout, responsive & Tailwind
---

# CSS & Styling

Practical CSS for layout and theming. A recipe sheet is in `references/css-recipes.md`.

## When to use

- Building layouts (centering, navbars, cards, grids) or responsive breakpoints.
- Theming with CSS variables, or adopting Tailwind utility classes.
- Debugging overflow, collapsed height, or specificity conflicts.

## Layout primitives

- **Flexbox** for 1D (row/column) alignment:
  ```css
  .row { display: flex; align-items: center; justify-content: space-between; gap: 12px; }
  .center { display: flex; align-items: center; justify-content: center; }
  ```
- **Grid** for 2D layouts:
  ```css
  .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; }
  ```

## Responsive

- Mobile-first; use `min-width` media queries to enhance upward.
- Fluid sizing with `clamp()`: `font-size: clamp(14px, 1vw + 12px, 18px);`
- Center containers with `max-width` (e.g. 1200px) + `margin-inline: auto`.

## Custom properties (theming)

```css
:root { --bg: #fff; --fg: #111; --radius: 8px; }
.card { background: var(--bg); color: var(--fg); border-radius: var(--radius); }
@media (prefers-color-scheme: dark) { :root { --bg: #111; --fg: #eee; } }
```

## Modern selectors

- `:has()`, `:is()`, `:where()` for conditionals/grouping; `gap` works in flex & grid.
- Prefer `class` over deep descendant selectors; avoid `!important`.

## Tailwind (utility-first)

- Compose classes: `flex items-center justify-between gap-3 rounded-lg p-4 bg-white`.
- Configure theme in `tailwind.config.js`; extend colors/spacing; use `dark:` variant for themes.
- Extract repeated patterns into `@apply` components, not giant inline class soup.

## Pitfalls

- Forgetting `box-sizing: border-box` → set globally:
  `*, *::before, *::after { box-sizing: border-box; }`.
- `height: 100%` with no parent height → collapses; use `min-height` or a flex column.
- Horizontal overflow from fixed widths → `max-width: 100%` / `min-width: 0` on flex children.
- Over-specific selectors beating intended styles → keep specificity low, prefer classes.
- Magic numbers everywhere → use a spacing scale / CSS variables.

# CSS Recipes

## Center anything
```css
.center { display: flex; align-items: center; justify-content: center; }
.center-abs { position: absolute; inset: 0; margin: auto; /* needs size */ }
.center-grid { display: grid; place-items: center; }
```

## Card
```css
.card { background: var(--surface); border: 1px solid var(--border);
  border-radius: var(--radius); padding: 16px; box-shadow: 0 1px 3px rgba(0,0,0,.08); }
```

## Responsive grid (auto-fit)
```css
.grid { display: grid; gap: 16px;
  grid-template-columns: repeat(auto-fill, minmax(240px, 1fr)); }
```

## Sticky navbar
```css
.nav { position: sticky; top: 0; z-index: 10; display: flex;
  align-items: center; justify-content: space-between; padding: 12px 16px; }
```

## Responsive container
```css
.container { width: 100%; max-width: 1200px; margin-inline: auto; padding-inline: 16px; }
```

## Dark mode (class-based)
```css
:root { --bg: #fff; --fg: #111; }
.dark { --bg: #0f1115; --fg: #e6e6e6; }
body { background: var(--bg); color: var(--fg); }
```
Toggle by adding `.dark` to `<html>`.

## Spacing scale (use variables, not magic numbers)
```css
:root { --space-1: 4px; --space-2: 8px; --space-3: 12px; --space-4: 16px; --space-6: 24px; }
```

## Reset (top of stylesheet)
```css
*, *::before, *::after { box-sizing: border-box; }
body { margin: 0; }
```

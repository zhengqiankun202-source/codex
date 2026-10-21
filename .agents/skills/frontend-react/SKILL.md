---
name: frontend-react
description: Practical React assistant. Use when building or debugging React apps (React 18/19) — function components, hooks (useState/useEffect/useMemo/useCallback/useRef/useContext), data fetching, forms, routing (React Router), state management, and Vite setup. Covers common pitfalls like stale closures, effect-dependency loops, and key warnings.
metadata:
  short-description: React components, hooks & patterns
---

# React (function components + hooks)

Practical React for app work. A hook/pattern cheat sheet is in `references/react-hooks.md`.

## When to use

- Building components, hooks, or a React app from scratch (Vite).
- Debugging re-renders, effect loops, stale state, or "key" warnings.
- Data fetching, forms, routing, or lifting/shared state.

## Project setup (Vite)

```bash
npm create vite@latest my-app -- --template react-ts
cd my-app && npm install && npm run dev
```

## Components & JSX

- Prefer **function components** + hooks; no class components.
- One component per file, PascalCase, small and focused.
- Props: type them (TS) and destructure: `function Card({ title, onClose }: CardProps) {}`.
- List keys: use a **stable unique id**, never the array index.

## Core hooks

```jsx
const [count, setCount] = useState(0);
const total = useMemo(() => expensive(items), [items]);   // memoize compute
const handle = useCallback((x) => doThing(x), [dep]);      // memoize callback
const ref = useRef(null);                                  // DOM node or mutable value
```
- `useEffect(fn, [deps])` runs after render; `[]` = once; wrong deps → stale closures.
- Return a cleanup (timers, subscriptions, listeners) from `useEffect` to avoid leaks.
- Never call hooks conditionally or in loops — always top-level, same order each render.

## Data fetching

- Prefer **TanStack Query** (`useQuery`) for caching/retries, or `SWR`.
- Minimal: `useEffect` + `fetch` + `AbortController`, with loading & error states.
```jsx
const { data, isLoading, error } = useQuery({
  queryKey: ['user', id], queryFn: () => getUser(id),
});
```

## Forms

- Controlled inputs: `value` + `onChange`. Complex forms → **React Hook Form** + `zod` for validation.
- Validate on submit; surface field errors from the schema.

## Routing (React Router v6+)

```jsx
<Routes>
  <Route path="/" element={<Home />} />
  <Route path="/orders/:id" element={<Order />} />
</Routes>
// const { id } = useParams(); const nav = useNavigate();
```

## State management

- Local: `useState` / `useReducer`. Shared: lift to nearest common parent or `Context`.
- App-wide UI state: **Zustand**. Server data: TanStack Query (server state ≠ UI state — keep separate).

## Pitfalls

- **Stale closure**: effect captures old state → use correct deps or functional update
  `setCount(c => c + 1)`.
- **Infinite effect loop**: state set inside effect is also in its deps without stabilizing.
- **Missing keys** → reorder bugs / lost input focus.
- **Mutating state directly** → always return new objects/arrays (immutability).
- Derived data in `useEffect` → prefer `useMemo`.

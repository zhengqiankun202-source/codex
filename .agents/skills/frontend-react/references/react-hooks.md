# React Hooks Cheat Sheet

## Hook reference
| Hook | Use |
|---|---|
| `useState(init)` | local state; `const [v, setV] = useState(0)` |
| `useEffect(fn, deps)` | side effects after render; `[]` once, return cleanup |
| `useMemo(fn, deps)` | memoize expensive compute |
| `useCallback(fn, deps)` | memoize a callback (stable identity) |
| `useRef(init)` | mutable ref / DOM node (`.current`) |
| `useContext(Ctx)` | read context value |
| `useReducer(reducer, init)` | complex local state (like Redux lite) |
| `useId()` | stable unique id for a11y |

## Rules of hooks
- Only call at the top level of a component or another hook — never in loops/conditions.
- Order must be stable across renders.

## Effect cleanup (avoid leaks)
```jsx
useEffect(() => {
  const id = setInterval(tick, 1000);
  return () => clearInterval(id);   // cleanup
}, []);
```

## Data fetching with TanStack Query
```jsx
const { data, isLoading, error } = useQuery({
  queryKey: ['todos'],
  queryFn: () => fetch('/api/todos').then(r => r.json()),
});
```
- Mutations: `useMutation({ mutationFn, onSuccess })`.
- Invalidate to refetch: `queryClient.invalidateQueries({ queryKey: ['todos'] })`.

## Patterns
- Lift state up to nearest common parent; pass down via props or Context.
- Derived value → `useMemo`, not state + effect.
- Stable callbacks to children → `useCallback` (prevents needless re-renders).

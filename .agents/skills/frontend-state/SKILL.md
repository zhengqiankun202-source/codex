---
name: frontend-state
description: Advanced client-side state management specialist. Use when designing or refactoring app state in React (Redux Toolkit, Zustand, Jotai, Context) or Vue (Pinia advanced, composables). Covers server vs client state separation, store structure, selectors/derived state, normalization, actions/thunks, and avoiding re-render and stale-state pitfalls.
---

# Advanced State Management

The #1 mistake is putting **server data** in a global store. Read this first, then pick a tool.

## 1. Split server state from client state

- **Server state** (fetched from API, cached, invalidated): belongs in **TanStack Query / RTK Query / Vue Query**, NOT in Redux/Pinia. These handle caching, dedupe, refetch, pagination, optimistic updates for you.
- **Client state** (UI: modal open, theme, current tab, form draft, auth token): belongs in a store or context.
- Rule of thumb: if it comes from the server and multiple components read it, it's server state.

## 2. React: choose by scope

| Need | Tool | Why |
|---|---|---|
| Global app state (auth, settings, cart) | **Zustand** or **Redux Toolkit** | Simple API / devtools + structure |
| Atomic, fine-grained | **Jotai** | Bottom-up atoms, minimal re-renders |
| Ephemeral / local | `useState` + `Context` | Avoid global for things one subtree needs |
| Server data | **TanStack Query** | Don't hand-roll caching |

### Redux Toolkit (structured teams)
- Use `createSlice` + `createAsyncThunk`; never mutate by hand (Immer under the hood).
- **Selectors** with `createSelector` (reselect) for memoized derived data. Never compute inside `mapStateToProps` without memoization.
- Avoid putting the **entire** API response in Redux; store only what the UI needs, normalized by id.
- RTK Query replaces thunks + a separate cache for server state.

### Zustand (lightweight)
```ts
const useCart = create<CartState>((set) => ({
  items: [],
  add: (item) => set((s) => ({ items: [...s.items, item] })),
  total: 0,
}));
// Select narrowly to avoid re-renders:
const total = useCart((s) => s.items.reduce((a, i) => a + i.price, 0));
```
- Select with a **selector**, not the whole store, to prevent needless re-renders.
- For lists, keep normalized `{ byId, allIds }`; update by id.

## 3. Vue: Pinia advanced

```ts
// stores/cart.ts — setup store (preferred)
export const useCartStore = defineStore('cart', () => {
  const items = ref<Product[]>([]);
  const total = computed(() => items.value.reduce((a, i) => a + i.price, 0));
  function add(item: Product) { items.value.push(item); }
  return { items, total, add };
});
```
- **Setup stores** (ref/computed/function) are now preferred over options stores for most cases.
- Use `storeToRefs(store)` when destructuring to keep reactivity; direct destructure loses it.
- Derived data via `computed` (memoized). Cross-store reads: call another `useXStore()` inside a getter/action.
- **Persistence**: `pinia-plugin-persistedstate` for auth/theme; don't persist ephemeral UI state.
- **SSR/hydration**: use `pinia` on server with `nuxt`/`vite-ssr`; avoid module-level singletons across requests.

## 4. Normalization (lists of entities)

- Store `{ byId: Record<id, T>, allIds: id[] }` instead of `T[]` when items are updated/looked up by id.
- Selectors: `allIds.map(id => byId[id])` (memoize). Add/remove = O(1) on `byId`.
- Entity adapters: RTK `createEntityAdapter`, or a small helper in Zustand/Pinia.

## 5. Avoid re-render storms

- **React**: select primitives/factories, not new objects (`useStore(s => s.user.id)` not `useStore(s => ({...}))` which returns a new ref each render). Use `useShallow` when selecting multiple.
- **Vue**: keep reactive data shallow where possible (`shallowRef`/`shallowReactive`) for big lists you replace wholesale.
- Don't put rapidly-changing values (e.g. mouse position, scroll) in a global store — keep them local or throttle.

## 6. Stale-state & async pitfalls

- **Don't store derived server data** — refetch/invalidate instead. TanStack Query `useQuery` + `queryClient.invalidateQueries`.
- Optimistic updates: apply, then rollback on error (RTK Query `onQueryStarted`/`patchQueryData`; TanStack `onMutate`/`onError`).
- Race conditions: cancel previous request / ignore stale responses (`isCancelled` flag or AbortController).
- Keep **auth token** in memory (+ httpOnly cookie), reflected in store; never persist JWT in localStorage (XSS risk — see `secure-coding`).

## 7. Forms & draft state

- Use **React Hook Form / VeeValidate** with local state; lift only the committed value to the store. Don't sync every keystroke to global state.
- Debounce persistence of drafts; restore on remount from a safe store (not URL).

# State Management Recipes

## Server vs client state — decision
- From API, cached, shared → **TanStack Query / RTK Query** (server state). Do NOT put in Redux/Pinia.
- UI only (modal, theme, tab, auth flag, form draft) → store / context.

## Zustand — narrow selector
```ts
const useBear = create((set) => ({ bears: 0, add: () => set((s) => ({ bears: s.bears + 1 })) }));
// good: selects primitive
const bears = useBear((s) => s.bears);
// multiple: use shallow to avoid new-object re-render
import { useShallow } from 'zustand/react/shallow';
const { bears, add } = useBear(useShallow((s) => ({ bears: s.bears, add: s.add })));
```

## Redux Toolkit — entity adapter + selector
```ts
const adapter = createEntityAdapter<User>();
const slice = createSlice({ name: 'users', initialState: adapter.getInitialState(), reducers: {
  add: adapter.addOne, upsert: adapter.upsertMany,
}});
export const { selectAll, selectById } = adapter.getSelectors((s: Root) => s.users);
export const selectActive = createSelector(selectAll, (users) => users.filter((u) => u.active));
```

## Pinia — setup store + storeToRefs
```ts
export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null);
  const isAdmin = computed(() => user.value?.role === 'admin');
  function login(u: User) { user.value = u; }
  return { user, isAdmin, login };
});
// in component:
const { user, isAdmin } = storeToRefs(useUserStore()); // keeps reactivity
const { login } = useUserStore();                      // actions called directly
```

## Normalized shape
```ts
type State = { byId: Record<string, T>; allIds: string[] };
// select
const list = useMemo(() => state.allIds.map((id) => state.byId[id]), [state.allIds, state.byId]);
```

## Optimistic update (TanStack Query)
```ts
useMutation({
  mutationFn: save,
  onMutate: async (next) => {
    await queryClient.cancelQueries({ queryKey: ['item', next.id] });
    const prev = queryClient.getQueryData(['item', next.id]);
    queryClient.setQueryData(['item', next.id], next);
    return { prev };
  },
  onError: (_e, _v, ctx) => queryClient.setQueryData(['item', id], ctx?.prev),
  onSettled: () => queryClient.invalidateQueries({ queryKey: ['item', id] }),
});
```

## Avoid stale responses (race)
```ts
let active = true;
fetch('/api/x').then((r) => r.json()).then((d) => { if (active) setData(d); });
return () => { active = false; }; // or AbortController
```

## Auth token (secure)
- Keep JWT in memory + httpOnly cookie; reflect in store. Never `localStorage` (XSS). See `secure-coding`.

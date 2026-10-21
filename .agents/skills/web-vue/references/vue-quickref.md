# Vue 3 Quick Reference

## Reactivity APIs
| API | Use |
|---|---|
| `ref(x)` | primitive/object; read/write `.value` in script |
| `reactive(obj)` | object; mutate directly, no `.value` |
| `computed(fn)` | derived, cached value |
| `watch(src, cb)` | react to changes; `watch(() => s.x, ...)` |
| `watchEffect(fn)` | re-run when any tracked dep changes |
| `toRefs(obj)` | keep reactivity when destructuring |
| `shallowRef` / `shallowReactive` | opt out of deep reactivity |

## Lifecycle (in `<script setup>`)
`onMounted`, `onUpdated`, `onUnmounted`, `onBeforeUnmount` — import from `vue`.

## Props / emits
```ts
const props = defineProps<{ id: number; title?: string }>()
const emit  = defineEmits<{ (e: 'save', v: Form): void }>()
```

## Composable example
```ts
export function useCounter() {
  const n = ref(0)
  const inc = () => n.value++
  return { n, inc }
}
```

## Pinia store
```ts
export const useUser = defineStore('user', () => {
  const name = ref('')
  const set = (v: string) => (name.value = v)
  return { name, set }
})
// in component: const user = useUser(); user.set('Ada')
```

## Template tips
- `v-model` for two-way binding; `v-if`/`v-else`; `v-for` with `:key`.
- Event: `@click`; bind: `:prop` or `v-bind`; shorthand `:`.
- Template auto-unwraps `ref` — no `.value` needed there.

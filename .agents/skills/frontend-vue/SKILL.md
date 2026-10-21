---
name: frontend-vue
description: Practical Vue 3 assistant. Use when building or debugging Vue 3 apps — <script setup>, Composition API, reactivity (ref/reactive/computed/watch), components, props/emits, Pinia store, Vue Router, and Vite. Covers reactivity pitfalls and SFC structure.
metadata:
  short-description: Vue 3 Composition API & Pinia
---

# Vue 3 (Composition API + `<script setup>`)

Practical Vue 3 for app work. A quick reference is in `references/vue-quickref.md`.

## When to use

- Building Vue 3 SFCs, composables, or an app via Vite.
- Debugging reactivity (not updating), `ref` vs `reactive`, watchers.
- State (Pinia), routing (Vue Router), or forms.

## Project setup (Vite)

```bash
npm create vite@latest my-app -- --template vue-ts
cd my-app && npm install && npm run dev
```

## SFC & `<script setup>`

```vue
<script setup lang="ts">
import { ref, computed } from 'vue'
const count = ref(0)
const double = computed(() => count.value * 2)
function inc() { count.value++ }
</script>

<template>
  <button @click="inc">{{ count }} / {{ double }}</button>
</template>
```
- `<script setup>` is the default style — top-level bindings auto-exposed to the template.
- `ref` for primitives/objects (access via `.value` in script); `reactive` for objects (no `.value`).
- Prefer `ref`; `reactive` loses reactivity when reassigned or destructured.

## Reactivity

- `computed` for derived values; `watch` / `watchEffect` for side effects.
- Nested objects are reactive automatically; large readonly data → `shallowRef`.
- Mutate `reactive` objects directly; for a `ref` to an object, mutate `.value.x`.

## Props & emits

```vue
<script setup lang="ts">
const props = defineProps<{ title: string }>()
const emit = defineEmits<{ (e: 'close'): void }>()
</script>
```
- Props are readonly; never mutate them — `emit` an event instead.

## Composables

- Extract reusable stateful logic into `useXxx()` composables returning refs/reactive — the Vue
  equivalent of custom hooks.

## State (Pinia)

```ts
export const useCart = defineStore('cart', () => {
  const items = ref<Product[]>([])
  function add(p: Product) { items.value.push(p) }
  return { items, add }
})
```
- Pinia for shared/app state; call `useCart()` inside `setup`. Keep server data out of Pinia
  (use TanStack Query / `swrv` for caching).

## Routing (Vue Router 4)

```ts
const routes = [{ path: '/', component: Home }, { path: '/orders/:id', component: Order }]
// useRoute() / useRouter().push(...)
```

## Pitfalls

- Forgetting `.value` on a `ref` in script (template auto-unwraps, script does not).
- Destructuring `reactive` / `props` loses reactivity → use `toRefs`.
- Mutating a `props` value → emit instead.
- Watching a reactive property needs a getter: `watch(() => state.x, ...)`.

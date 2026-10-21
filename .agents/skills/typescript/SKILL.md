---
name: typescript
description: TypeScript assistant. Use when writing or refactoring TS — typing functions/components, interfaces vs type aliases, generics, utility types (Partial/Pick/Omit/Record), narrowing, discriminated unions, strict mode, and avoiding any. Complements frontend-react and frontend-vue.
metadata:
  short-description: TypeScript types & patterns
---

# TypeScript

Practical TS for app and component code. A utility-type cheat sheet is in `references/ts-utilities.md`.

## When to use

- Typing props, API responses, function signatures, or config.
- Modeling data with unions/interfaces; reducing `any`.
- Generics, narrowing, or strict-mode errors.

## Basics

- `interface` for object shapes (extendable); `type` for unions, primitives, mapped/utility types.
- Explicit types at **boundaries** (function params, API DTOs); let inference work inside.
- No implicit `any`: set `"strict": true` in `tsconfig.json`.

## Common utilities

```ts
type Partial<T>  // all properties optional
type Pick<T, K>  // keep only K
type Omit<T, K>  // drop K
type Record<K, V>// map of K -> V
type Readonly<T>
```
- Derive DTOs from entities: `type OrderDto = Pick<Order, 'id' | 'code' | 'status'>`.

## Generics

```ts
function first<T>(arr: T[]): T | undefined { return arr[0] }
type ApiResp<T> = { data: T; error: string | null }
```

## Narrowing (avoid casts)

- Prefer `typeof`, `instanceof`, `in`, and **discriminated unions** over `as`:
```ts
type Resp = { ok: true; value: User } | { ok: false; error: string }
function handle(r: Resp) {
  if (r.ok) use(r.value); else show(r.error)   // r narrowed automatically
}
```
- `unknown` is safer than `any` for untrusted input — narrow before use.

## With frontend frameworks

- React: `type XProps = {...}`; event types like `React.ChangeEvent<HTMLInputElement>`.
- Vue: `defineProps<{...}>()` / `defineEmits<{ (e: 'x'): void }>()`; `ref<T>()`.

## Pitfalls

- `any` defeats the type system — use `unknown` + narrowing, or generics `T`.
- Non-null assertion `!` hides real null bugs; prefer explicit checks.
- Mutating a readonly interface without intent; model immutability where it matters.
- Indexing without `noUncheckedIndexedAccess` → value is `T | undefined`.

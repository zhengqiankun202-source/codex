# TypeScript Utility Types

## Built-in
| Type | Meaning |
|---|---|
| `Partial<T>` | all props optional |
| `Required<T>` | all props required |
| `Readonly<T>` | all props readonly |
| `Pick<T, K>` | keep only keys K |
| `Omit<T, K>` | drop keys K |
| `Record<K, V>` | object with keys K and values V |
| `Exclude<U, X>` | remove X from union U |
| `Extract<U, X>` | keep only X from union U |
| `NonNullable<T>` | drop `null`/`undefined` |
| `ReturnType<F>` | return type of function F |
| `Parameters<F>` | tuple of F's params |
| `Awaited<T>` | unwrap Promise<T> |

## Mapped / conditional
```ts
type Nullable<T> = { [K in keyof T]: T[K] | null }
type Keys<T> = keyof T
type ApiOk<T> = { ok: true; data: T }
type ApiErr = { ok: false; error: string }
type ApiResp<T> = ApiOk<T> | ApiErr     // discriminated union
```

## Narrowing patterns
```ts
function isUser(u: unknown): u is User { return !!u && typeof u === 'object' && 'id' in u }
// guards let you narrow `unknown` safely instead of `as User`
```

## Strict tsconfig (recommended)
```json
{ "compilerOptions": { "strict": true, "noUncheckedIndexedAccess": true,
  "noImplicitOverride": true, "exactOptionalPropertyTypes": true } }
```

# typescript — Type Constraint Skill

Governs all TypeScript decisions on the `dev` branch.
Read this skill whenever writing or reviewing types, schemas, or component props.

---

## Non-Negotiable Rules

Before writing any type, read this list. These are not suggestions.

1. **No `any`.** Use `unknown` and narrow it. If a third-party type forces `any`,
   wrap it at the boundary and do not let it propagate.

2. **No `as` type casts inside application logic.** `as` is only permitted inside
   branded type constructor functions, and only to perform the branding itself.
   Everywhere else, `as` means a type has not been modelled correctly — fix the type.

3. **No primitive types for domain concepts.** A user ID is not a `string`.
   A price is not a `number`. Model domain concepts explicitly. Work down the
   type hierarchy; stop at the first level that fits.

4. **Exhaustive union checks everywhere.** Every `switch` on a union must have
   a `default: return assertNever(x)` branch. New union members then cause a
   compile error before they cause a runtime bug.

5. **`readonly` by default.** Mutability must be justified and explicit.
   Immutable data is easier to reason about and prevents accidental mutation bugs.

6. **Derive types from Zod schemas.** Never declare a TypeScript type for
   external data separately from its validation schema. The schema is the
   single source of truth; the type is derived from it.

---

## Type Hierarchy

Work through this list top to bottom. Use the first level that accurately
models the domain. Only descend to the next level if the current one does not fit.

### Level 1 — Branded Types

For any value that has a domain identity and must not be interchangeable with
structurally identical values.

```typescript
// src/types/branded.ts
type Brand<T, B extends string> = T & { readonly __brand: B }

// Domain types — extend as the project grows
export type UserId     = Brand<string, 'UserId'>
export type SessionId  = Brand<string, 'SessionId'>
export type PostSlug   = Brand<string, 'PostSlug'>
export type Price      = Brand<number, 'Price'>      // always in minor units (cents)
export type Timestamp  = Brand<number, 'Timestamp'>  // always Unix milliseconds
export type Percentage = Brand<number, 'Percentage'> // 0–100, not 0–1
```

Constructor functions validate and brand at boundaries:

```typescript
export function toUserId(raw: string): UserId {
  if (!/^usr_[a-z0-9]{16}$/.test(raw)) {
    throw new Error(`Invalid UserId format: "${raw}"`)
  }
  return raw as UserId  // 'as' is permitted only here, inside the constructor
}

export function toPrice(cents: number): Price {
  if (!Number.isInteger(cents) || cents < 0) {
    throw new Error(`Price must be a non-negative integer (cents): ${cents}`)
  }
  return cents as Price
}
```

**When to use:** IDs, tokens, slugs, monetary values, timestamps, percentages,
unit-specific measurements (pixels, rem, ms), route paths.

**When not to use:** Generic intermediary computations, values that will be
immediately transformed and never passed across function boundaries.

### Level 2 — Literal Union Types

For values drawn from a fixed, known set.

```typescript
// Correct: names the set explicitly
type OrderStatus   = 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled'
type UserRole      = 'admin' | 'editor' | 'viewer'
type SortDirection = 'asc' | 'desc'
type Theme         = 'light' | 'dark' | 'system'

// Incorrect: boolean hides semantic meaning
type { isAdmin: boolean }  // What is a non-admin? What roles exist?
// Replace with:
type { role: UserRole }
```

**When to use:** Status fields, roles, categories, fixed option sets, anything
that would otherwise be documented by a comment explaining valid string values.

**Never use `boolean`** when the values have semantic names or when more than
two states are conceivable now or in the future.

### Level 3 — Discriminated Unions

For types with multiple shapes, async states, and result types.

```typescript
// Async state — replaces boolean flag pairs (isLoading, hasError)
type AsyncState<T> =
  | { readonly status: 'idle' }
  | { readonly status: 'loading' }
  | { readonly status: 'success'; readonly data: T }
  | { readonly status: 'error';   readonly error: Error }

// Result type — replaces throw/catch for expected failures
type Result<T, E = Error> =
  | { readonly ok: true;  readonly value: T }
  | { readonly ok: false; readonly error: E }

// Concrete example: form state machine
type FormState<T> =
  | { readonly phase: 'idle' }
  | { readonly phase: 'submitting' }
  | { readonly phase: 'success'; readonly result: T }
  | { readonly phase: 'error';   readonly message: string }
```

**Exhaustive check — required in every switch:**

```typescript
// src/types/utils.ts
export function assertNever(x: never, context?: string): never {
  throw new Error(
    `Unhandled discriminated union case${context ? ` in ${context}` : ''}: ${JSON.stringify(x)}`
  )
}

// Usage
function renderOrderStatus(status: OrderStatus): string {
  switch (status) {
    case 'pending':    return 'Awaiting payment'
    case 'processing': return 'Being prepared'
    case 'shipped':    return 'On the way'
    case 'delivered':  return 'Delivered'
    case 'cancelled':  return 'Cancelled'
    default:           return assertNever(status, 'renderOrderStatus')
  }
}
// Adding a new OrderStatus member without updating this switch is a compile error.
```

### Level 4 — Template Literal Types

For constrained string shapes where a branded type is too rigid and a bare
string is too loose.

```typescript
// Route paths — catches typos at compile time
type AppRoute = `/users/${string}` | `/posts/${PostSlug}` | '/' | '/login'

// CSS values where unit matters
type CSSPixels = `${number}px`
type CSSRem    = `${number}rem`
type CSSColor  = `#${string}` | `rgb(${string})` | `hsl(${string})`

// Environment-prefixed keys
type EnvKey = `NEXT_PUBLIC_${Uppercase<string>}` | `NEXT_${Uppercase<string>}`
```

**When to use:** Route definitions, CSS value types, key naming patterns,
API endpoint strings. Not for every string — only when the structure is fixed
and errors are likely.

### Level 5 — Generics with Constraints

For reusable utilities that must work with multiple types while preserving shape.

```typescript
// Constrain to only the keys that hold a specific value type
type KeysOfType<T, V> = {
  [K in keyof T]: T[K] extends V ? K : never
}[keyof T]

// Make specific keys required
type RequireFields<T, K extends keyof T> = T & Required<Pick<T, K>>

// Paginated response wrapper — works with any data type
type PaginatedResponse<T> = {
  readonly data: readonly T[]
  readonly total: number
  readonly page: number
  readonly pageSize: number
}

// Usage: the constraint catches misuse at the call site
function sortBy<T, K extends KeysOfType<T, string | number>>(
  items: readonly T[],
  key: K,
  direction: SortDirection = 'asc'
): readonly T[] { ... }
```

### Level 6 — Primitives (last resort)

`string`, `number`, `boolean` only when:
- The value truly has no domain meaning beyond its primitive shape
- No more specific type from levels 1–5 applies
- The value is purely computational and immediately consumed

In practice, primitives in domain code are a signal to reconsider levels 1–4.

---

## External Data: Zod at Every Boundary

The schema is the contract. The TypeScript type is derived from it.
Never invert this — do not write a type and then write a matching schema.

```typescript
// src/schemas/user.ts
import { z } from 'zod'
import { toUserId, toTimestamp } from '@/types/branded'

export const UserSchema = z.object({
  id:        z.string().transform(toUserId),       // validated + branded
  email:     z.string().email(),
  name:      z.string().min(1).max(100),
  role:      z.enum(['admin', 'editor', 'viewer']),
  createdAt: z.number().int().transform(n => n as Timestamp),
  status:    z.enum(['active', 'inactive', 'banned']),
})

// Type is derived — never declared separately
export type User = z.infer<typeof UserSchema>

// Partial schema for update payloads
export const UpdateUserSchema = UserSchema
  .pick({ name: true, role: true })
  .partial()

export type UpdateUserPayload = z.infer<typeof UpdateUserSchema>
```

At every entry point, use `safeParse` for recoverable errors or `parse` for
hard failures:

```typescript
// API route — recoverable, return 400 on failure
const parsed = UserSchema.safeParse(await request.json())
if (!parsed.success) {
  return Response.json(
    { error: parsed.error.flatten() },
    { status: 400 }
  )
}
const user = parsed.data  // User — fully typed and validated

// Internal utility — hard fail is appropriate
const user = UserSchema.parse(rawData)
```

---

## Compiler Options That Are Active

These go in `tsconfig.json`. Do not remove or weaken any of them.

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true,
    "noPropertyAccessFromIndexSignature": true,
    "noImplicitOverride": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

**What `noUncheckedIndexedAccess` means in practice:**
```typescript
const items: string[] = ['a', 'b', 'c']

// Without this option: TypeScript infers string (wrong — could be undefined)
const first = items[0]   // type: string | undefined (correct with option enabled)

// Always narrow before use:
const first = items[0]
if (first !== undefined) {
  console.log(first.toUpperCase())
}
// Or with nullish coalescing:
const label = items[index] ?? 'default'
```

**What `exactOptionalPropertyTypes` means in practice:**
```typescript
type Config = {
  timeout?: number  // means: timeout can be absent, but NOT present with undefined
}

// Correct
const c1: Config = {}                // timeout absent — OK
const c2: Config = { timeout: 5000 } // timeout present — OK

// Incorrect — caught by this option
const c3: Config = { timeout: undefined }  // type error
```

---

## React Component Props

```typescript
// Props are always a named interface, never inline type
interface UserCardProps {
  readonly user: User
  readonly onSelect: (userId: UserId) => void
  readonly variant?: 'compact' | 'full'  // literal union, not string
}

// Component function signature is explicit
export function UserCard({ user, onSelect, variant = 'full' }: UserCardProps) {
  ...
}

// Children: be explicit about what is accepted
interface LayoutProps {
  readonly children: React.ReactNode   // any renderable content
}
interface WrapperProps {
  readonly children: React.ReactElement // single React element only
}
```

---

## `readonly` Discipline

```typescript
// Object props: readonly by default
interface Config {
  readonly apiUrl: string
  readonly timeout: number
}

// Arrays: readonly by default
function processItems(items: readonly string[]): readonly string[] { ... }

// Utility type for deep immutability when needed
type DeepReadonly<T> = {
  readonly [K in keyof T]: T[K] extends object ? DeepReadonly<T[K]> : T[K]
}

// Exceptions — mutability must be documented
interface MutableBuffer {
  data: Uint8Array  // intentionally mutable: written to incrementally before sealing
}
```

---

## When You See These Patterns, Stop

| Pattern | Problem | Fix |
|---|---|---|
| `as SomeType` in app logic | Hiding a type mismatch | Model the type correctly or add Zod validation |
| `as any` anywhere | Abandoning the type system | Use `unknown` and narrow it |
| `{ isLoading: boolean, hasError: boolean }` | Impossible states representable | Use discriminated union with `status` |
| Function parameter typed as `string` for an ID | IDs are interchangeable | Use branded type |
| `// @ts-ignore` or `// @ts-expect-error` | Silencing a legitimate error | Fix the underlying type |
| `interface Foo { [key: string]: unknown }` | Any string accepted as key | Use specific literal union keys |

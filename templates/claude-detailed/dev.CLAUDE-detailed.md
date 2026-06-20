# {{PROJECT_NAME}} — Dev Branch: Detailed Reference

Framework: {{FRAMEWORK}} · Package manager: {{PKG_MANAGER}}

## Philosophy

Quality is not a phase at the end — it is the default state during development.
Sloppy types, missing tests, and undocumented decisions compound into debt that
costs more to fix later. The standard here is exactly what ships to users.

---

## TypeScript: Full Type Hierarchy

Work down this list when choosing any type. Stop at the first level that accurately
models the domain.

### Level 1 — Branded / Nominal Types (always consider first)

Use when the value has a domain identity that must not be interchangeable with
other values of the same underlying type.

```typescript
// types/branded.ts — define once, use everywhere
type Brand<T, B extends string> = T & { readonly __brand: B }

export type UserId     = Brand<string, 'UserId'>
export type SessionId  = Brand<string, 'SessionId'>
export type Price      = Brand<number, 'Price'>      // always in minor units (cents)
export type Timestamp  = Brand<number, 'Timestamp'>  // always Unix milliseconds
export type Slug       = Brand<string, 'Slug'>

// Constructor functions validate and brand at the boundary
export function toUserId(raw: string): UserId {
  if (!/^usr_[a-z0-9]{16}$/.test(raw)) throw new Error(`Invalid UserId: ${raw}`)
  return raw as UserId
}
```

A `UserId` cannot be accidentally passed where a `SessionId` is expected.
This eliminates an entire category of bugs at compile time, not runtime.

### Level 2 — Literal Union Types

Use when the value is one of a fixed, known set. Never use `boolean` for state
that has semantic names.

```typescript
type OrderStatus   = 'pending' | 'processing' | 'shipped' | 'delivered' | 'cancelled'
type SortDirection = 'asc' | 'desc'
type Theme         = 'light' | 'dark' | 'system'
```

### Level 3 — Discriminated Unions

Use for state machines, async states, and any type with branching shapes.

```typescript
type AsyncState<T> =
  | { readonly status: 'idle' }
  | { readonly status: 'loading' }
  | { readonly status: 'success'; readonly data: T }
  | { readonly status: 'error';   readonly error: Error }

type Result<T, E = Error> =
  | { readonly ok: true;  readonly value: T }
  | { readonly ok: false; readonly error: E }
```

**Exhaustive check — always required:**
```typescript
// In types/utils.ts
export function assertNever(x: never, context?: string): never {
  throw new Error(`Unhandled case${context ? ` in ${context}` : ''}: ${JSON.stringify(x)}`)
}

// Usage — compiler catches missing cases at build time
switch (state.status) {
  case 'idle':    return <Idle />
  case 'loading': return <Spinner />
  case 'success': return <DataView data={state.data} />
  case 'error':   return <ErrorView error={state.error} />
  default:        return assertNever(state, 'AsyncState render')
}
```

### Level 4 — Primitives (last resort)

`string`, `number`, `boolean` only when no more specific type applies.
This should be the exception in domain code, not the default.

---

## External Data: Validate at Every Boundary

API responses, URL params, form inputs, localStorage — none are trusted.
Derive TypeScript types from Zod schemas, not the other way around:

```typescript
// schema.ts — schema is the single source of truth
export const UserSchema = z.object({
  id:        z.string().transform(toUserId),
  email:     z.string().email(),
  name:      z.string().min(1),
  createdAt: z.number().transform(n => n as Timestamp),
  status:    z.enum(['active', 'inactive', 'banned']),
})

export type User = z.infer<typeof UserSchema>  // type derived from schema

// At the fetch boundary — parse throws on invalid data
const user = UserSchema.parse(await res.json())
```

Never use `as` casts to satisfy the compiler. If you feel tempted to cast,
that is a signal to model the type properly or add a Zod schema.

---

## Compiler Options Reference

These are active on this project. Understand what they enforce:

| Option | What It Catches |
|---|---|
| `strict` | Null checks, implicit any, strict function types |
| `noUncheckedIndexedAccess` | `arr[i]` returns `T \| undefined`, not `T` |
| `exactOptionalPropertyTypes` | `{ a?: string }` ≠ `{ a: string \| undefined }` |
| `noPropertyAccessFromIndexSignature` | Must use bracket notation for index types |

---

## Component Architecture

Components have one job. If a component fetches data AND renders it AND handles
errors AND manages a modal, it has too many jobs.

```
Page component     — routing, layout, passes data down
Container          — fetches/transforms data, owns async state
Presentational     — receives props, renders, no side effects
Hook (useXxx)      — encapsulates stateful logic, tested independently
```

---

## Commit Convention

Format: `type(scope): description` (lowercase, imperative, no trailing period)

```
feat(auth): add OAuth2 login with Google
fix(cart): prevent double-submit on slow connections
refactor(api): extract useQueryCache hook
test(checkout): cover failed payment path
docs(arch): document new services/ directory
chore(deps): update zod to 3.22
```

---

## Feature Workflow

```
1. Update SPEC.md if requirements need clarification
2. Update ARCHITECTURE.md if directory structure changes
3. Define types first — branded types, Zod schemas, discriminated unions
4. Implement against types (types are the contract)
5. Write unit tests for pure functions and business logic
6. Write component tests for all meaningful UI states
7. pnpm typecheck && pnpm lint — both must be clean
8. PR to main: describe what changed and why
```

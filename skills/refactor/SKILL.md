# refactor — Code Quality Skill

Use this skill on the `refactor` branch.
Read before making any structural change to existing code.

---

## The Contract

Every refactoring must satisfy:
1. Observable behavior is identical before and after
2. Every test that passed before still passes after
3. No new tests needed (behavior did not change)
4. TypeScript clean throughout

If any of these are violated, revert and try a smaller step.

---

## Before You Start: Verify Coverage

```bash
pnpm test --coverage -- --testPathPattern="src/path/to/module"
```

If coverage is thin, write characterization tests first and commit them
separately before starting the refactor.

---

## Patterns

### Extract Function
Signal: A block inside a function could be named and tested independently.
Commit: `refactor(scope): extract calculateTax from checkout`

### Extract Hook
Signal: A component manages logic that could stand alone and be reused.
Commit: `refactor(profile): extract useUser hook from ProfilePage`

### Collapse Boolean Flags to Discriminated Union
Signal: Multiple booleans create ambiguous or impossible state combinations.
```typescript
// Before: { isLoading: boolean; hasError: boolean; data: User | null }
// After:
type State =
  | { status: 'loading' }
  | { status: 'success'; data: User }
  | { status: 'error'; message: string }
```

### Early Return to Flatten Nesting
Signal: Happy path buried > 2 levels deep in conditionals.
```typescript
// Before: if (a) { if (b) { if (c) { ... } } }
// After: guard clauses at top, happy path last
if (!a) return
if (!b) return
if (!c) return
// happy path
```

### Rename for Clarity
Signal: Name does not match what the thing actually is or does.
`const d = ...` → `const activeUsers = ...`
`async function req(id)` → `async function fetchUserProfile(userId: UserId)`

### Introduce Parameter Object
Signal: Function has > 3 parameters or params that change together.
```typescript
// Before: createUser(name, email, role, orgId)
// After: createUser({ name, email, role, orgId }: CreateUserParams)
```

---

## Commit Discipline

One pattern per commit. Name the pattern:
```
refactor(cart): collapse isLoading/hasError flags to AsyncState union
refactor(checkout): early return to flatten payment validation
refactor(api): rename res/req variables throughout
```

---

## Code Smell → Pattern

| Smell | Pattern |
|---|---|
| Function > 30 lines | Extract Function |
| Component fetches + renders | Extract Hook |
| Boolean flag pairs | Discriminated Union |
| Same logic in 3+ places | Extract Function |
| Nesting > 2 levels | Early Return |
| > 3 function parameters | Parameter Object |
| Primitive for domain concept | Branded Type (see typescript skill) |

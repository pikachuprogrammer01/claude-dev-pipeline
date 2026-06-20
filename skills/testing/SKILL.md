# testing — Test Coverage Skill

Use this skill on the `test` branch when writing or improving tests.

---

## Test Pyramid

```
        ▲ few     E2E — critical user flows only
       /   \
      /─────\     Integration — module boundaries, hooks, API contracts
     /───────\
    /─────────\   Unit — pure functions, business logic, Zod schemas
```

Write most tests at the unit level. Integration tests for boundaries.
E2E only for flows where failure has the highest user impact.

---

## Unit Tests

Target: pure functions, Zod schemas, custom hooks in isolation.

```typescript
// Pure function — test all branches and edge cases
describe('applyDiscount', () => {
  it('reduces price by rate', () =>
    expect(applyDiscount(1000 as Price, 0.1)).toBe(900))
  it('returns full price when rate is 0', () =>
    expect(applyDiscount(1000 as Price, 0)).toBe(1000))
  it('clamps to 0 when rate exceeds 1', () =>
    expect(applyDiscount(1000 as Price, 1.5)).toBe(0))
})

// Zod schema — test valid AND intentionally invalid inputs
describe('UserSchema', () => {
  it('parses a valid user', () =>
    expect(() => UserSchema.parse(validUserFixture)).not.toThrow())
  it('rejects invalid email', () =>
    expect(() => UserSchema.parse({ ...validUserFixture, email: 'bad' })).toThrow())
  it('rejects unknown status', () =>
    expect(() => UserSchema.parse({ ...validUserFixture, status: 'deleted' })).toThrow())
})

// Branded type constructor
describe('toUserId', () => {
  it('accepts valid format', () =>
    expect(() => toUserId('usr_abc1234567890123')).not.toThrow())
  it('rejects invalid format', () =>
    expect(() => toUserId('not-a-user-id')).toThrow())
})
```

---

## Integration Tests

Target: hooks with real dependencies, API route handlers, module boundaries.

```typescript
// Hook integration — uses MSW to intercept network requests
describe('useUser', () => {
  it('returns success state after fetch resolves', async () => {
    server.use(
      http.get('/api/users/:id', () => HttpResponse.json(validUserFixture))
    )
    const { result } = renderHook(() => useUser('usr_abc123' as UserId))
    expect(result.current.status).toBe('loading')
    await waitFor(() => expect(result.current.status).toBe('success'))
    if (result.current.status === 'success') {
      expect(result.current.data.email).toBe(validUserFixture.email)
    }
  })

  it('returns error state on 500', async () => {
    server.use(
      http.get('/api/users/:id', () => new HttpResponse(null, { status: 500 }))
    )
    const { result } = renderHook(() => useUser('usr_abc123' as UserId))
    await waitFor(() => expect(result.current.status).toBe('error'))
  })
})
```

---

## Mock Strategy

Mock only at boundaries. Never mock your own implementations.

```
Boundary          | Tool
──────────────────|──────────────────────────────────
Network           | MSW (msw) — intercept at the HTTP level
Browser APIs      | vi.fn() / jsdom built-ins
Time (Date, timers)| vi.useFakeTimers()
External SDK      | vi.fn() wrapping the SDK call
```

Never mock:
- Your own pure functions (test them directly)
- Internal state management
- React hooks you own (test them with renderHook)

---

## Component Tests

Test meaningful states, not implementation details:

```typescript
describe('UserCard', () => {
  it('renders the user name', () => {
    render(<UserCard user={validUserFixture} onSelect={vi.fn()} />)
    expect(screen.getByText(validUserFixture.name)).toBeInTheDocument()
  })

  it('calls onSelect with the user id when clicked', async () => {
    const onSelect = vi.fn()
    render(<UserCard user={validUserFixture} onSelect={onSelect} />)
    await userEvent.click(screen.getByRole('button'))
    expect(onSelect).toHaveBeenCalledWith(validUserFixture.id)
  })
})
```

Test what a user would observe. Do not test internal state or which functions
were called internally.

---

## TypeScript in Tests

Same constraints as `dev` apply. No `any` in test files.

```typescript
// src/__tests__/fixtures/users.ts
export const validUserFixture: User = UserSchema.parse({
  id: 'usr_abc1234567890123',
  email: 'test@example.com',
  name: 'Test User',
  createdAt: Date.now(),
  status: 'active',
})

// Type-safe render helper
function renderWithProviders(
  ui: React.ReactElement,
  options?: RenderOptions
) {
  return render(<Providers>{ui}</Providers>, options)
}
```

---

## Coverage Analysis

```bash
pnpm test --coverage
open coverage/lcov-report/index.html
```

Focus on:
1. Functions at 0% — highest priority gaps
2. Uncovered branches in business logic
3. Zod schemas not tested with invalid inputs

Target: ≥ 80% overall, 100% for pure functions and schemas.
Chase meaningful coverage, not aggregate percentage.

---

## Test File Conventions

```
src/
  components/Cart/
    Cart.tsx
    Cart.test.tsx          ← co-located
  hooks/
    useUser.ts
    useUser.test.ts        ← co-located
  utils/
    pricing.ts
    pricing.test.ts        ← co-located
  __tests__/
    integration/           ← integration tests (not co-located)
    fixtures/              ← shared test data
```

---

## E2E Candidates

Reserve E2E for flows where failure has highest user impact:
- Authentication (login / logout / session expiry)
- Primary conversion flow (checkout, signup, core action)
- Critical mutations (delete account, irreversible actions)

E2E tests are slow and fragile. Every new E2E test is a maintenance commitment.
Be selective.

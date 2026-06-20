# {{PROJECT_NAME}} — Test Branch: Detailed Reference

## Philosophy

Tests are not proof that code works — they are proof that code works for the
cases you thought of. Their primary value is as a regression safety net and
as a forcing function for well-structured, modular code. Untestable code is
usually poorly designed code.

---

## Test Pyramid in Practice

### Unit Tests (widest base)

Target: pure functions, business logic, Zod schemas, custom hooks in isolation.

```typescript
// Good unit test — pure function, clear input/output, no mocks
describe('applyDiscount', () => {
  it('reduces price by the given rate', () => {
    expect(applyDiscount(1000 as Price, 0.1)).toBe(900)
  })
  it('returns full price when rate is 0', () => {
    expect(applyDiscount(1000 as Price, 0)).toBe(1000)
  })
  it('clamps to 0 when rate exceeds 1', () => {
    expect(applyDiscount(1000 as Price, 1.5)).toBe(0)
  })
})

// Good schema test — valid and intentionally invalid inputs
describe('UserSchema', () => {
  it('parses a valid user', () => {
    expect(() => UserSchema.parse(validUserFixture)).not.toThrow()
  })
  it('rejects a user with invalid email', () => {
    expect(() => UserSchema.parse({ ...validUserFixture, email: 'not-email' })).toThrow()
  })
  it('rejects a user with unknown status', () => {
    expect(() => UserSchema.parse({ ...validUserFixture, status: 'deleted' })).toThrow()
  })
})
```

### Integration Tests (middle layer)

Target: module boundaries, custom hooks with real dependencies, API route handlers.

```typescript
// Hook integration test — tests the hook in a realistic environment
describe('useUser', () => {
  it('returns success state after fetch resolves', async () => {
    server.use(http.get('/api/users/:id', () => HttpResponse.json(validUserFixture)))
    const { result } = renderHook(() => useUser('usr_abc123' as UserId))

    expect(result.current.status).toBe('loading')
    await waitFor(() => expect(result.current.status).toBe('success'))
    if (result.current.status === 'success') {
      expect(result.current.data.id).toBe('usr_abc123')
    }
  })

  it('returns error state when fetch fails', async () => {
    server.use(http.get('/api/users/:id', () => new HttpResponse(null, { status: 500 })))
    const { result } = renderHook(() => useUser('usr_abc123' as UserId))
    await waitFor(() => expect(result.current.status).toBe('error'))
  })
})
```

### E2E Tests (narrow top)

Target: critical user flows only. E2E tests are slow, flaky, and expensive to maintain.
Reserve them for flows where failure has the highest user impact.

Candidates for E2E:
- Authentication (login / logout / session expiry)
- Primary conversion flow (checkout, signup, core action)
- Critical data mutation (delete account, submit form)

---

## Mock Strategy

**Mock at boundaries only.** Mocking implementation details makes tests
brittle and provides false confidence.

```
Boundary         → Mock it           Example
─────────────────────────────────────────────────────
Network          → MSW (msw)        API requests
Browser APIs     → vi.fn() / jsdom  localStorage, clipboard
Time             → vi.useFakeTimers Date.now(), setTimeout
External service → vi.fn()          Analytics, payment SDK
```

Do not mock:
- Your own pure functions (test them directly)
- React state management internals
- Module implementations you own

---

## Test File Conventions

```
src/
  components/
    Cart/
      Cart.tsx
      Cart.test.tsx      ← co-located with the component
  hooks/
    useUser.ts
    useUser.test.ts
  utils/
    pricing.ts
    pricing.test.ts
  __tests__/
    integration/         ← integration tests here, not co-located
    e2e/                 ← E2E tests here
```

---

## Coverage Analysis

```bash
pnpm test --coverage

# View report
open coverage/lcov-report/index.html
```

Focus coverage analysis on:
1. Functions with 0% coverage — highest priority gaps
2. Branches (if/switch) with uncovered paths — edge cases
3. Lines in critical business logic paths

Avoid chasing aggregate % at the expense of meaningful test quality.
A 90% coverage suite with shallow tests is worse than 70% with deep ones.

---

## TypeScript in Tests

Same constraints as `dev` apply. No `any` in test files.
Type-safe test utilities:

```typescript
// fixtures/users.ts — typed fixtures, not raw objects
export const validUserFixture: User = UserSchema.parse({
  id: 'usr_abc1234567890123',
  email: 'test@example.com',
  name: 'Test User',
  createdAt: Date.now(),
  status: 'active',
})

// Type-safe render helper
function renderWithProviders(ui: React.ReactElement) {
  return render(<Providers>{ui}</Providers>)
}
```

---

## TEST-PLAN.md Maintenance

Update `TEST-PLAN.md` when:
- A new feature area requires a new testing strategy
- Coverage gaps are identified in a PR review
- A bug escapes to production (add to "known gaps" section)
- E2E test candidates are identified but not yet implemented

# {{PROJECT_NAME}} — Refactor Branch: Detailed Reference

## Philosophy

Refactoring is structural change without behavior change. The test suite is
the authority on whether behavior changed. If any test breaks after a refactor,
the refactor introduced a bug — revert immediately and try a smaller step.

The enemy of good refactoring is scope creep. The moment you start fixing bugs
or adding features "while you're in there," you lose the safety of the
structural-only constraint and make the change harder to review and revert.

---

## Safety Net: Tests Before Structure

Before touching any code, verify you have tests that exercise the behavior
you are about to restructure:

```bash
pnpm test --coverage -- --testPathPattern="src/path/to/module"
```

If coverage is thin, write characterization tests first — tests that describe
what the code currently does, even if you don't love how it does it:

```typescript
// Characterization test: captures current behavior before refactor
describe('Cart module (pre-refactor characterization)', () => {
  it('returns the correct total including tax', () => {
    const cart = new Cart()
    cart.add({ price: 1000 as Price, qty: 2 })
    expect(cart.getTotal()).toBe(2200)  // captured from current behavior
  })
})
```

Commit the characterization tests separately before the refactor begins.

---

## Patterns and When to Use Them

### Extract Function
**When:** A named block inside a function could stand alone and be tested.
```typescript
// Before
function processOrder(order: Order): ProcessedOrder {
  const discounted = order.total * (1 - order.discountRate)  // inline logic
  const tax = discounted * 0.08
  const final = discounted + tax
  return { ...order, finalPrice: final as Price }
}

// After
function applyDiscount(total: Price, rate: number): Price {
  return (total * (1 - rate)) as Price
}
function addTax(subtotal: Price, rate = 0.08): Price {
  return (subtotal * (1 + rate)) as Price
}
function processOrder(order: Order): ProcessedOrder {
  const finalPrice = addTax(applyDiscount(order.total, order.discountRate))
  return { ...order, finalPrice }
}
```

### Extract Hook
**When:** A component manages logic that could stand alone and be reused.
```typescript
// Before: logic and render mixed in one component
function ProfilePage({ userId }: { userId: UserId }) {
  const [user, setUser] = useState<User | null>(null)
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading')
  useEffect(() => { /* fetch logic */ }, [userId])
  // ...render
}

// After
function useUser(userId: UserId): AsyncState<User> {
  // encapsulated logic, independently testable
}
function ProfilePage({ userId }: { userId: UserId }) {
  const state = useUser(userId)
  // render only
}
```

### Collapse Boolean Flags to Discriminated Union
**When:** Multiple boolean flags create ambiguous or impossible state combinations.
```typescript
// Before — what does isLoading=false, hasError=false, data=null mean?
interface State {
  isLoading: boolean
  hasError: boolean
  data: User | null
}

// After — every state is complete and unambiguous
type ProfileState =
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: User }
  | { status: 'error'; message: string }
```

### Rename for Clarity
**When:** The name does not reflect what the thing actually is or does.
```typescript
// Before
const d = users.filter(u => u.a)   // what is 'a'?
const res = await req(id)           // what is being requested?

// After
const activeUsers = users.filter(user => user.isActive)
const profile = await fetchUserProfile(userId)
```

### Early Return to Reduce Nesting
**When:** Deep nesting makes the happy path hard to follow.
```typescript
// Before
function processPayment(order: Order) {
  if (order) {
    if (order.items.length > 0) {
      if (order.paymentMethod) {
        // happy path buried 3 levels deep
      }
    }
  }
}

// After
function processPayment(order: Order) {
  if (!order) return
  if (order.items.length === 0) return
  if (!order.paymentMethod) return
  // happy path at top level
}
```

---

## Commit Discipline

One refactoring pattern per commit. Name the pattern applied:
```
refactor(profile): extract useUser hook from ProfilePage
refactor(cart): collapse loading/error flags to AsyncState union
refactor(order): rename processPayment parameters for clarity
refactor(checkout): apply early return to reduce nesting
```

Atomic commits make the history readable and allow partial reverts without
losing all refactoring progress.

---

## Code Smell → Pattern Reference

| Smell | Pattern |
|---|---|
| Function > 30 lines | Extract Function |
| Component doing fetch + render + state | Extract Hook |
| Boolean flags creating ambiguity | Discriminated Union |
| Duplicated logic in 3+ places | Extract Function + shared module |
| Name doesn't match purpose | Rename |
| Deep nesting, hard to follow | Early Return |
| Long parameter list | Introduce Parameter Object |

# {{PROJECT_NAME}} — Perf Branch: Detailed Reference

## Philosophy

Premature optimization is the root of much unnecessary complexity. Optimization
on a measured hot path is engineering. Optimization based on intuition is guessing.

Every change on this branch must have a before/after measurement. If there is no
measurement, there is no optimization — there is only untested complexity.

---

## Profiling Workflow

### Step 1 — Identify the Real Bottleneck

Before profiling, form a hypothesis about where the problem is. Then verify it.

**For render performance:**
```bash
# In browser DevTools → Performance tab
# Record a slow interaction
# Look for: long tasks (>50ms), layout thrashing, repeated renders
```

**For bundle size:**
```bash
pnpm build
# Analyze the output
npx vite-bundle-visualizer   # for Vite projects
# or
npx @next/bundle-analyzer    # for Next.js
```

**For runtime operations:**
```typescript
// Instrument specific operations
performance.mark('operation-start')
await heavyOperation()
performance.mark('operation-end')
performance.measure('heavyOperation', 'operation-start', 'operation-end')

const [measure] = performance.getEntriesByName('heavyOperation')
console.log(`Duration: ${measure.duration.toFixed(2)}ms`)
```

### Step 2 — Record Baseline in BENCHMARK.md

Before touching any code:
```markdown
## YYYY-MM-DD — LCP on Dashboard page

**Condition:** Production build, throttled 4G, mid-range Android device
**Baseline:** 3.2s LCP (measured 5 times, median)
**Target:** < 2.5s LCP
```

### Step 3 — Implement One Change

One optimization per commit. If you implement multiple changes simultaneously,
you cannot attribute the improvement and cannot revert a regression cleanly.

### Step 4 — Measure Again

Measure under identical conditions. Document the result in `BENCHMARK.md`.

---

## Common React Performance Issues

### Unnecessary Re-renders

```typescript
// Symptom: component re-renders when its props haven't changed
// Fix: memoize with React.memo for components, useMemo/useCallback for values

// Before: UserList re-renders whenever parent re-renders
export function UserList({ users }: { users: User[] }) { ... }

// After: only re-renders when users array reference changes
export const UserList = React.memo(function UserList({ users }: { users: User[] }) {
  ...
})

// Before: callback recreated on every render, breaks memo downstream
<UserList onSelect={(user) => handleSelect(user)} />

// After: stable reference across renders
const handleSelectUser = useCallback((user: User) => {
  handleSelect(user)
}, [handleSelect])
<UserList onSelect={handleSelectUser} />
```

### Expensive Computations on Every Render

```typescript
// Before: filter + sort runs on every render
function ProductGrid({ products }: { products: Product[] }) {
  const sorted = products
    .filter(p => p.inStock)
    .sort((a, b) => a.price - b.price)
  return <Grid items={sorted} />
}

// After: recomputes only when products changes
function ProductGrid({ products }: { products: Product[] }) {
  const sorted = useMemo(
    () => products.filter(p => p.inStock).sort((a, b) => a.price - b.price),
    [products]
  )
  return <Grid items={sorted} />
}
```

### Bundle Size Anti-patterns

```typescript
// Bad: imports entire library
import _ from 'lodash'
const result = _.groupBy(items, 'category')

// Good: named import, tree-shakeable
import { groupBy } from 'lodash-es'
const result = groupBy(items, 'category')

// Bad: static import of a large library used only on one route
import { Chart } from 'chart.js'

// Good: dynamic import, loaded only when needed
const { Chart } = await import('chart.js')
```

---

## Core Web Vitals Reference

| Metric | Good | Needs Improvement | Poor |
|---|---|---|---|
| LCP (Largest Contentful Paint) | < 2.5s | 2.5–4s | > 4s |
| INP (Interaction to Next Paint) | < 200ms | 200–500ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | 0.1–0.25 | > 0.25 |

Measure in field conditions (real devices, real networks), not lab conditions only.
DevTools throttling is an approximation — real device testing is authoritative.

---

## BENCHMARK.md Maintenance

Every optimization attempt gets an entry — including failed ones. A failed
optimization that is documented saves the next person from trying the same thing.

```markdown
## YYYY-MM-DD — Attempt: [what was tried]

**Result:** No improvement / Regression / NN% improvement
**Reason:** Why it did or did not work
**Decision:** Reverted / Merged / Deferred
```

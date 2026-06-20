# performance — Performance Optimization Skill

Use this skill on the `perf` branch.
Never optimize without a measured baseline. Never merge without a measured result.

---

## Step 1 — Measure First

Form a hypothesis. Then prove it with measurement before touching code.

### Bundle Analysis

```bash
pnpm build

# Vite projects
npx vite-bundle-visualizer

# Next.js
ANALYZE=true pnpm build  # requires @next/bundle-analyzer in next.config
```

Look for: unexpectedly large chunks, duplicated libraries, synchronous imports
of heavy dependencies that are only used on some routes.

### Render Performance (React DevTools Profiler)

1. Open DevTools → Profiler tab
2. Start recording
3. Perform the slow interaction
4. Stop recording
5. Look for: components that render many times, long render durations,
   components rendering when their props did not change

### Runtime Measurement

```typescript
// Instrument specific operations before optimizing
performance.mark('op-start')
await heavyOperation()
performance.mark('op-end')
performance.measure('heavyOperation', 'op-start', 'op-end')

const [entry] = performance.getEntriesByName('heavyOperation')
console.log(`Duration: ${entry.duration.toFixed(2)}ms`)
```

---

## Step 2 — Record Baseline in BENCHMARK.md

Before touching any code, document the measurement:

```markdown
## YYYY-MM-DD — LCP on /dashboard

**Target:** Dashboard page initial load
**Condition:** Production build, Chrome DevTools throttled 4G, mid-range Android
**Baseline:** 3.2s LCP (5 measurements, median)
**Goal:** < 2.5s LCP
```

---

## Step 3 — One Change at a Time

One optimization per commit. If you implement multiple changes, you cannot
attribute the improvement and cannot cleanly revert a regression.

---

## Step 4 — Measure Again and Document

Under identical conditions. Document in BENCHMARK.md:

```markdown
**After:** 2.1s LCP (5 measurements, median)
**Delta:** −1.1s LCP (−34%)
**Method:** Deferred non-critical JS with dynamic import, moved hero image to priority fetch
**Decision:** Merged
```

---

## Common Fixes: Render Performance

### Unnecessary Re-renders

```typescript
// Symptom: component re-renders when props have not changed
// Fix: React.memo for stable prop references
export const UserList = React.memo(function UserList({ users }: { users: readonly User[] }) {
  return <>{users.map(u => <UserCard key={u.id} user={u} />)}</>
})

// Symptom: callback prop recreated on every render, breaks memo downstream
// Fix: stable reference with useCallback
const handleSelect = useCallback((userId: UserId) => {
  selectUser(userId)
}, [selectUser])
```

### Expensive Computation on Every Render

```typescript
// Symptom: filter + sort on every render regardless of inputs
// Fix: useMemo with correct dependencies
const sortedUsers = useMemo(
  () => users.filter(u => u.isActive).sort((a, b) => a.name.localeCompare(b.name)),
  [users]
)
```

### Context Causing Broad Re-renders

```typescript
// Symptom: entire tree re-renders on any context change
// Fix: split context — separate fast-changing state from slow-changing state
const UserContext  = createContext<User | null>(null)       // changes infrequently
const ThemeContext = createContext<Theme>('light')           // can change per interaction
```

---

## Common Fixes: Bundle Size

### Named Imports for Tree Shaking

```typescript
// Bad: pulls entire library
import _ from 'lodash'
const grouped = _.groupBy(items, 'category')

// Good: tree-shakeable named import
import { groupBy } from 'lodash-es'
const grouped = groupBy(items, 'category')
```

### Dynamic Import for Route-Specific Libraries

```typescript
// Bad: chart library loaded on every page
import { Chart } from 'chart.js'

// Good: loaded only when the component that needs it mounts
const ChartComponent = dynamic(() => import('@/components/Chart'), { ssr: false })
```

### Audit Import Cost

```bash
npx cost-of-modules  # shows size contribution of each dependency
```

---

## Core Web Vitals Reference

| Metric | Good | Poor |
|---|---|---|
| LCP (Largest Contentful Paint) | < 2.5s | > 4s |
| INP (Interaction to Next Paint) | < 200ms | > 500ms |
| CLS (Cumulative Layout Shift) | < 0.1 | > 0.25 |

Measure in real conditions (real device, real network) not only DevTools simulation.
DevTools throttling is an approximation.

---

## Failed Optimization Policy

Document failed attempts in BENCHMARK.md. A failed optimization documented
saves the next person from repeating the same experiment:

```markdown
## YYYY-MM-DD — Attempt: memoize UserList

**Result:** No improvement
**Reason:** Parent re-renders passed new array references on every render,
  defeating memo. Root cause is in the parent, not UserList.
**Decision:** Reverted. Will address in parent component separately.
```

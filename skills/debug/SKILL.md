# debug — Bug Investigation Skill

Use this skill on the `fix` branch when investigating any bug.
Read the full skill before starting investigation. Do not jump to solutions.

---

## Mindset

The first explanation that comes to mind is usually wrong, or at least incomplete.
Bugs that seem obvious often have non-obvious root causes. The process below is
designed to prevent fixing symptoms while the actual cause persists.

---

## Step 1 — Write a Failing Test Before Touching Code

Before examining source code, write a test that fails because of the bug:

```typescript
// The test should fail on the current code
it('does not allow negative price', () => {
  expect(() => toPrice(-1)).toThrow()   // currently does not throw
})
```

If the bug is in UI behavior that is hard to unit test, write a minimal
reproduction script or document the exact steps that trigger it.

A test you cannot write yet means you do not fully understand the bug yet.
Stay in Step 1 until you can write it.

---

## Step 2 — Categorize the Bug

| Category | Signature |
|---|---|
| **Race condition** | Bug appears intermittently, under load, or with fast interaction |
| **Stale closure** | React: callback uses an old value (common with useEffect deps) |
| **Missing type guard** | Value assumed to be one type, arrives as another at runtime |
| **Unvalidated boundary** | External data not parsed by Zod, shape assumed not checked |
| **Off-by-one** | Boundary conditions wrong (first/last item, empty state, 0 vs 1) |
| **Missing guard clause** | A case not anticipated in conditional logic |
| **Mutation of shared state** | Object modified in place where immutability was assumed |
| **Promise not awaited** | Async operation assumed synchronous |

---

## Step 3 — Form and Test Hypotheses

For each hypothesis: predict what you would observe if this were the cause.
Then look for that specific evidence. Do not fix based on an untested hypothesis.

**Git bisect for regressions:**
```bash
git bisect start
git bisect bad HEAD
git bisect good v1.2.3
# mark each tested commit: git bisect good / git bisect bad
git bisect reset
```

**Temporary diagnostic — remove before committing:**
```typescript
console.log('[debug] data at entry:', JSON.stringify(rawData, null, 2))
const parsed = Schema.safeParse(rawData)
if (!parsed.success) console.error('[debug] validation:', parsed.error.flatten())
```

---

## Step 4 — State the Root Cause Explicitly

Before writing the fix, write one sentence:

> "The cart allows duplicate items because addItem checks equality by object
> reference, not by item ID, so two objects with the same ID are considered distinct."

If you cannot state it this clearly, return to Step 3.

---

## Step 5 — Minimal Fix

Address the root cause with the smallest possible change.
- No cleanup of surrounding code
- No refactoring while fixing
- No "while I'm in here" improvements
- One commit, one reason

If you find other problems: log them in BUGLOG.md as deferred, do not fix now.

---

## Step 6 — Verify and Log

```bash
pnpm test -- --testPathPattern="your/test"  # failing test must now pass
pnpm test                                    # full suite must still pass
pnpm typecheck                               # must be clean
```

Add entry to BUGLOG.md:
```markdown
## YYYY-MM-DD — Short description

**Reported:** How discovered
**Root cause:** The actual underlying cause
**Fix:** What changed and why
**Regression test:** src/__tests__/file.test.ts → "test name"
```

---

## Common React Bugs

**Stale closure:**
```typescript
// Bug: missing dependency
useEffect(() => {
  const id = setInterval(() => console.log(count), 1000)
  return () => clearInterval(id)
}, [])  // count not in deps — stale

// Fix:
}, [count])
```

**Fetch on unmounted component:**
```typescript
useEffect(() => {
  const controller = new AbortController()
  fetch('/api/data', { signal: controller.signal })
    .then(r => r.json()).then(setData)
    .catch(e => { if (e.name !== 'AbortError') setError(e) })
  return () => controller.abort()
}, [])
```

**Index as React key:**
```typescript
// Bug:  items.map((item, i) => <Card key={i} />)
// Fix:  items.map(item => <Card key={item.id} />)
```

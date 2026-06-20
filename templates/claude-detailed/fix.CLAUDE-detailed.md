# {{PROJECT_NAME}} — Fix Branch: Detailed Reference

## Philosophy

A fix that does not understand the root cause will resurface. A fix without a
regression test will resurface silently. The discipline of this branch is to
slow down enough to fix things once, correctly.

---

## Investigation Process

### Step 1 — Reproduce Reliably

A bug you can reproduce consistently is a bug you can fix confidently.

Before touching production code, write a failing test that proves the bug exists:
```typescript
it('should not duplicate items when add is called rapidly', () => {
  const cart = createCart()
  cart.add(item)
  cart.add(item)  // simulates rapid double-click
  expect(cart.items).toHaveLength(1)  // fails on current code
})
```

If the bug is difficult to unit-test, create a minimal reproduction in isolation.
Do not investigate a bug you cannot reproduce.

### Step 2 — Root Cause Analysis

Ask "why" until you reach an underlying cause, not just the surface symptom.

**Common root cause categories:**

| Category | Signs |
|---|---|
| Race condition | Bug appears under load or with async timing |
| Missing guard | A case was not anticipated in conditional logic |
| Stale closure | Function captures a value that has since changed (React) |
| Type confusion | Value assumed to be one shape, arrives as another |
| Off-by-one | Boundary conditions incorrect |
| Missing validation | External data accepted without checking shape |

For each hypothesis: predict what you would observe if this were the cause,
then test the prediction. Do not fix based on a guess.

**Useful investigation commands:**
```bash
# Find when a bug was introduced
git bisect start
git bisect bad HEAD
git bisect good vX.Y.Z  # last known good version

# See all changes to a file over time
git log --follow -p src/path/to/file.ts

# Compare behavior between two versions
git diff vX.Y.Z..HEAD -- src/
```

### Step 3 — Minimal Fix

The fix must address the root cause with the smallest possible change.

Do not, while fixing:
- Clean up surrounding code
- Add features or improvements
- Fix other unrelated issues you notice

If you find other problems, log them in `BUGLOG.md` under separate headings.
Address them on the appropriate branch after this fix is complete.

### Step 4 — Regression Test

The failing test from Step 1 must now pass. If you skipped Step 1, write the
test now. A fix without a regression test is not finished.

The test should:
1. Demonstrate the original bug would have been caught
2. Be named to describe the behavior, not the bug number:
   - Good: `'does not duplicate items on rapid add'`
   - Avoid: `'bug fix for issue #42'`

### Step 5 — BUGLOG.md Entry

Add an entry before closing the branch:

```markdown
## YYYY-MM-DD — Brief description of the bug

**Reported:** User report / GitHub issue #N / CI failure / Manual testing
**Root cause:** The actual underlying cause (not the symptom)
**Fix:** What was changed and why this resolves the root cause
**Regression test:** `src/__tests__/file.test.ts` → test name
```

---

## Hotfix Process

For bugs that require immediate production fixes without waiting for `dev`:

```bash
# Branch from main, not dev
git checkout main
git checkout -b fix/critical-description

# Implement and test the fix
# PR directly to main

# After main merge, bring the fix to dev
git checkout dev
git cherry-pick <merge-commit-hash>
git push origin dev
```

This keeps `dev` current without requiring a full `dev → main` merge cycle.

---

## What Not to Do

- Do not refactor adjacent code while fixing. One change, one reason.
- Do not merge a fix without a regression test.
- Do not skip `BUGLOG.md`. The log builds a pattern history that prevents
  the same root causes from recurring across different symptoms.

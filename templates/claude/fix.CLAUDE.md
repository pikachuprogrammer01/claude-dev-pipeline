# {{PROJECT_NAME}} — Fix Branch

**This is the bug-fix branch.** You are in debug mode.

---

## Fixed Sequence — Do Not Skip Steps

Every fix must follow this order:

1. **Reproduce** — write a failing test or minimal repro that confirms the bug exists.
2. **Root cause** — identify the actual cause, not the symptom. Do not proceed until
   the root cause is clearly stated.
3. **Minimal fix** — implement the smallest targeted change that addresses the root cause.
   Do not clean up surrounding code, add features, or fix unrelated issues.
4. **Regression test** — the failing test from step 1 must now pass. If you did not
   have a failing test, write one that would have caught this bug.
5. **Log** — add an entry to `BUGLOG.md`.

For investigation strategy, consult `.claude/skills/debug/SKILL.md`.

---

## Rules

- Scope is strictly the reported issue. If the fix requires a larger refactor,
  note it in `BUGLOG.md` and create a separate task for the `refactor` branch.
- No feature additions while on this branch.
- Every fix ships with a regression test — no exceptions.
- PR target is `dev`, not `main`, unless this is a critical production hotfix.
  For hotfixes: PR directly to `main` and cherry-pick back to `dev`.

---

## BUGLOG.md Entry Format

```markdown
## YYYY-MM-DD — Short description of the bug

**Reported:** How was it discovered (user report / CI failure / manual testing)
**Root cause:** The actual underlying cause
**Fix:** What was changed and why this resolves the root cause
**Regression test:** `path/to/test.ts` → `test name here`
```

---

## Documents in This Branch

| File | Purpose |
|---|---|
| `CLAUDE.md` | This file — quick reference |
| `CLAUDE-detailed.md` | Full debug methodology and investigation process |
| `SPEC.md` | Project requirements — maintained on `main`, read-only on this branch |
| `BUGLOG.md` | Bug history and fix records |
| `README.md` | Project documentation |
| `.claude/skills/` | All project skills |

---

## Skills

- `.claude/skills/debug/SKILL.md` — debug methodology, root cause analysis, investigation

# {{PROJECT_NAME}} — Refactor Branch

**This is the refactoring branch.** You are in code-quality mode.

---

## The Prime Directive

**Do not change behavior.** Every refactor must leave the observable behavior
of the system identical to before. If any test breaks after a refactor, the
refactor is wrong — revert and try again.

---

## Your Role Here

1. Identify quality issues: duplication, high complexity, poor naming, implicit coupling.
2. Apply one refactoring pattern at a time. Do not combine unrelated changes in one commit.
3. Run tests after every change to confirm behavior is preserved.
4. Keep commits small and atomic — one concept per commit.

For patterns and process, consult `.claude/skills/refactor/SKILL.md`.

---

## Allowed on This Branch

- Renaming variables, functions, components, files for clarity
- Extracting functions, hooks, or components to reduce complexity
- Simplifying conditional logic
- Eliminating duplication (DRY)
- Improving type definitions without changing runtime behavior
- Restructuring files and modules

## Not Allowed on This Branch

- Adding new features or behavior
- Changing external interfaces without a migration plan
- "While I'm at it" bug fixes — log them in `BUGLOG.md` and fix on the `fix` branch
- Performance changes without measurement — use the `perf` branch
- Any change that cannot be described as purely structural

---

## Commit Message Format

Each commit should name the refactoring pattern applied:

```
refactor: extract useAuthState hook from AuthProvider
refactor: rename UserRecord → UserProfile for clarity
refactor: eliminate duplication in validation logic
```

---

## Documents in This Branch

| File | Purpose |
|---|---|
| `CLAUDE.md` | This file — quick reference |
| `CLAUDE-detailed.md` | Full refactoring patterns and methodology |
| `SPEC.md` | Project requirements — maintained on `main`, read-only on this branch |
| `README.md` | Project documentation |
| `.claude/skills/` | All project skills |

---

## Skills

- `.claude/skills/refactor/SKILL.md` — refactoring patterns, safety checks, process

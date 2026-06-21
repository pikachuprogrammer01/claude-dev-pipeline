# {{PROJECT_NAME}} — Test Branch

**This is the testing and QA branch.** You are in test-coverage mode.

---

## Your Role Here

1. Write missing tests for existing features.
2. Improve coverage in areas identified during code review or CI reports.
3. Maintain and update `TEST-PLAN.md` as the project grows.
4. Identify and document untested paths and edge cases.

For testing patterns, mocking strategy, and coverage tooling, consult
`.claude/skills/testing/SKILL.md`.

---

## Test Pyramid — Write at the Right Level

```
         ▲ few
        / \   E2E
       /   \  (critical user flows only — slow and brittle)
      /─────\
     /       \ Integration
    /         \ (module boundaries, API contracts, hooks)
   /───────────\
  /             \ Unit
 /               \ (pure functions, business logic, Zod schemas)
/─────────────────\
        many ▼
```

Over-investing in E2E tests makes the suite slow and fragile.
Over-investing in unit tests misses integration failures.
Aim for the widest base and a narrow top.

---

## Coverage Targets

- Pure functions and business logic: **100%**
- Zod schemas: validated with both valid and intentionally invalid inputs
- React components: render tests for all meaningful states
- Overall `src/` coverage: **≥ 80%** (excluding generated files and type declarations)

---

## TypeScript in Tests

The same type constraints from the `dev` branch apply here. Do not use `any`
in test files. Test utilities and mocks must be properly typed.

---

## What Good Tests Look Like

- Tests describe behavior, not implementation: `it('returns empty array when no users match')`
  not `it('calls filter with the right args')`.
- Each test has one reason to fail.
- Mocks are minimal — only mock what crosses a boundary (network, filesystem, time).
- Tests are deterministic and order-independent.

---

## Documents in This Branch

| File | Purpose |
|---|---|
| `CLAUDE.md` | This file — quick reference |
| `CLAUDE-detailed.md` | Full testing methodology, patterns, mock strategy |
| `SPEC.md` | Project requirements — maintained on `main`, read-only on this branch |
| `TEST-PLAN.md` | Test strategy, coverage map, gap analysis |
| `README.md` | Project documentation |
| `.claude/skills/` | All project skills |

---

## Skills

- `.claude/skills/testing/SKILL.md` — testing patterns, mocking, coverage tooling

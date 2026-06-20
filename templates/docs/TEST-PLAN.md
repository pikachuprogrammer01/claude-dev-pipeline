# {{PROJECT_NAME}} — Test Plan

> Documents the testing strategy, coverage targets, known gaps, and
> E2E candidates for this project. Update as the project grows.

---

## Strategy

Testing follows the pyramid model:

```
      ▲ few    E2E — critical user flows only
     / \
    /───\      Integration — module boundaries, hooks, API contracts
   /─────\
  /───────\    Unit — pure functions, business logic, Zod schemas
```

All tests use TypeScript with the same strict type constraints as `src/`.

---

## Coverage Targets

| Area | Target | Current |
|---|---|---|
| Pure functions and utilities | 100% | — |
| Zod schemas (valid + invalid inputs) | 100% | — |
| Business logic hooks | ≥ 90% | — |
| Overall `src/` coverage | ≥ 80% | — |

Run `pnpm test --coverage` to get the current report.

---

## Test Inventory

### Unit Tests
_[List key test files and what they cover as the project grows]_

### Integration Tests
_[List integration test files and the boundaries they cover]_

### E2E Tests
_[List E2E test files and the user flows they cover]_

---

## Known Gaps

<!-- Areas intentionally not covered, or known to have insufficient coverage.
     Add entries when gaps are discovered in PR review or post-bug analysis. -->

| Area | Gap | Priority | Notes |
|---|---|---|---|
| _[fill in]_ | _[describe gap]_ | High / Med / Low | |

---

## E2E Candidates

<!-- Flows that should eventually have E2E tests but don't yet. -->

- [ ] Authentication flow (login / logout / session expiry)
- [ ] _[Add project-specific critical flows]_

---

## Tools

| Tool | Purpose |
|---|---|
| _[fill in test runner]_ | Test runner |
| MSW (msw) | Network request mocking |
| `@testing-library/react` | Component and hook rendering |
| _[fill in]_ | E2E (if applicable) |

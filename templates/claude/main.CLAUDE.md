# {{PROJECT_NAME}} — Main Branch

**This is the production branch.** You are in deploy/review mode.

---

## Branch Rules

- No direct commits. All changes arrive via PR from `dev` or `fix`.
- Every merge to `main` must pass the full PR checklist below.
- Version tags follow semver: `v1.2.3`.
- SPEC.md must reflect the current deployed state at all times.

---

## Your Role Here

1. **Review incoming PRs** — correctness, type safety, test coverage, SPEC alignment.
2. **Run the deployment checklist** — see `DEPLOYMENT.md` before any push to production.
3. **Tag releases** — create git tags after merges from the `version` branch.
4. **Keep SPEC.md current** — update if architectural decisions changed in the release cycle.

---

## PR Merge Checklist

- [ ] All tests pass (`pnpm test`)
- [ ] TypeScript clean: `tsc --noEmit` reports zero errors
- [ ] ESLint clean: zero errors
- [ ] SPEC.md is up to date with what was shipped
- [ ] `DEPLOYMENT.md` checklist completed
- [ ] Version bumped appropriately in `package.json`
- [ ] `CHANGELOG.md` updated (via `version` branch)

---

## Documents in This Branch

| File | Purpose |
|---|---|
| `CLAUDE.md` | This file — quick reference |
| `CLAUDE-detailed.md` | Full deployment and review methodology |
| `SPEC.md` | Project requirements and architecture decisions |
| `README.md` | Project documentation |
| `DEPLOYMENT.md` | Pre-deploy checklist and environment config |
| `.claude/skills/` | All project skills |

---

## Skills

No branch-specific skill. For documentation updates use `.claude/skills/docs/SKILL.md`.

# {{PROJECT_NAME}} — Deployment Reference

> Complete this checklist before every production deployment.
> Do not skip items. If an item does not apply, mark it N/A with a reason.

---

## Pre-Deployment Checklist

### Code Quality
- [ ] `pnpm typecheck` — zero TypeScript errors
- [ ] `pnpm lint` — zero ESLint errors
- [ ] `pnpm test` — all tests passing
- [ ] `pnpm build` — build succeeds without warnings

### Review
- [ ] PR reviewed and approved
- [ ] SPEC.md reflects what is being deployed
- [ ] CHANGELOG.md updated for this release
- [ ] Version bumped in `package.json`

### Security
- [ ] `pnpm audit` — no critical or high severity vulnerabilities
- [ ] No hardcoded secrets, credentials, or API keys in the diff
- [ ] `.env.example` updated if new environment variables were added

---

## Environment Variables

<!-- List all required environment variables and where to find their values. -->
<!-- Never put actual values here — use a secret manager or .env.local locally. -->

| Variable | Required | Description | Where to get it |
|---|---|---|---|
| `NODE_ENV` | Yes | Runtime environment | Set by platform |
| _[add variables]_ | | | |

---

## Deployment Steps

<!-- Fill in the actual deployment steps for this project. -->

```bash
# Example — replace with actual commands
pnpm build
# deploy via CI/CD or manual push
```

---

## Post-Deployment Verification

- [ ] Application loads without errors
- [ ] Core user flow works end-to-end (manual smoke test)
- [ ] No error spikes in monitoring for 15 minutes post-deploy
- [ ] Performance metrics within acceptable range (check LCP, INP)

---

## Rollback Procedure

If the deployment causes issues:

```bash
git revert HEAD
git push origin main
# Trigger re-deploy
```

Rollback via `git revert`, never via `git reset --hard` on `main`.
Investigate root cause on the `fix` branch after production is stable.

---

## Infrastructure Notes

<!-- Document any infrastructure-specific details: CDN config, DB migrations needed,
     feature flags to toggle, cache invalidation steps, etc. -->

_[Fill in as infrastructure is established]_

---

_Last updated: by @git-init on project creation. Update whenever deployment process changes._

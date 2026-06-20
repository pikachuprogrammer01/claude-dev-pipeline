# {{PROJECT_NAME}} — Main Branch: Detailed Reference

## Philosophy

`main` is the source of truth for what is in production. It is not a staging area
and it is not a development sandbox. Every commit here is deployed or ready to deploy.

Work never happens directly on `main`. Every change has been built on `dev`,
reviewed, and verified against the deployment checklist.

---

## PR Review Process

**1. Read the description before the code.**
If the PR does not explain what changed and why, request that first.
Intent matters more than implementation — code shows what, descriptions show why.

**2. Verify types before verifying logic.**
Run `tsc --noEmit` if CI is insufficient. Confirm `strict` and all project compiler
flags are still set in `tsconfig.json`. A PR that weakens TypeScript config is a blocker.

**3. Check all data entry points.**
API responses, form inputs, URL parameters — every external value must enter through
a Zod schema. Unvalidated data crossing a boundary is a blocker.

**4. Confirm test coverage for changed paths.**
New logic requires new tests. Changed logic requires updated tests. A PR that adds
behavior without tests is incomplete, not just suboptimal.

**5. Verify SPEC.md alignment.**
Does the implementation match SPEC.md? If they diverge, one is wrong.
Either the PR went off-spec, or SPEC.md was not updated. Resolve before merging.

**6. Check DEPLOYMENT.md currency.**
If the PR adds environment variables, changes build steps, or modifies infrastructure,
`DEPLOYMENT.md` must be updated in the same PR. Do not accept deployment config changes
without documentation.

---

## Deployment Sequence

```
1. Merge approved PR: dev → main
2. Run through DEPLOYMENT.md checklist completely
3. Trigger deployment pipeline (CI/CD or manual push)
4. Monitor error rate and response time for 15 minutes post-deploy
5. If anomalies detected: rollback immediately, investigate on fix branch
```

---

## Rollback Procedure

When a deployment causes issues, revert immediately — do not try to fix forward
under pressure:

```bash
# Single bad commit
git revert HEAD

# Multiple consecutive bad commits
git revert HEAD~N..HEAD

git push origin main
# Trigger re-deploy with the revert commit
```

Never force-push `main`. Rollback via revert, not reset.
Investigate root cause on the `fix` branch after production is stable.

---

## Version Tagging

After every successful production release:
```bash
git tag -a vX.Y.Z -m "Release vX.Y.Z"
git push origin vX.Y.Z
```

Tags are permanent. Never delete or move a published tag.
If a release has a critical bug, the fix gets its own patch tag — do not
overwrite the original.

---

## SPEC.md Maintenance on Main

`SPEC.md` on `main` describes what is currently deployed. Update it:
- When a PR changes behavior relative to what SPEC.md describes
- When a decision made during development supersedes a documented requirement
- Never to describe aspirational or planned features — those live on `dev`

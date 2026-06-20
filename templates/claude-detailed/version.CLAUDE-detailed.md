# {{PROJECT_NAME}} — Version Branch: Detailed Reference

## Philosophy

A release is a promise to users about what they are getting. Semantic versioning
makes that promise explicit and machine-readable. A well-maintained CHANGELOG
makes it human-readable. Both matter.

---

## Semver Decision Tree

```
Were any public interfaces changed in a breaking way?
  Yes → MAJOR (X.0.0)
  No  →
    Were new features added?
      Yes → MINOR (x.Y.0)
      No  →
        Were bugs fixed or internals changed?
          Yes → PATCH (x.y.Z)
```

**Breaking change examples** (→ MAJOR):
- Removing or renaming a prop, API endpoint, or exported function
- Changing the shape of a response object
- Changing behavior that users depend on

**New feature examples** (→ MINOR):
- New optional prop on a component
- New API endpoint
- New exported utility
- New opt-in behavior

**Patch examples** (→ PATCH):
- Bug fix that doesn't change the interface
- Performance improvement
- Internal refactoring with no behavior change
- Dependency security update

When in doubt, choose the higher bump. It is safer to over-version than to
ship a breaking change as a patch.

---

## CHANGELOG.md Writing Guide

Every change gets one bullet under the correct heading. Bullets are written
for the user reading them, not the developer who made them.

```markdown
## [x.y.z] — YYYY-MM-DD

### Added
- New checkout flow with saved payment methods

### Changed
- Dashboard now shows last 90 days by default (was 30)

### Fixed
- Cart no longer duplicates items when add button clicked rapidly

### Breaking Changes
- `onSubmit` prop renamed to `onComplete` in CheckoutForm component
```

**Good bullet:** `Cart no longer duplicates items when add button clicked rapidly`
**Bad bullet:** `Fixed issue with Cart component state management in rapid click scenario`

Write what the user experiences, not what the code does.

---

## Full Release Sequence

```bash
# 1. Verify dev → main PR is merged and main is clean
git checkout main
git pull origin main
pnpm test && pnpm typecheck   # must pass

# 2. Determine version bump (see decision tree above)
# Reviewing commits since last tag:
git log $(git describe --tags --abbrev=0)..HEAD --oneline

# 3. Bump version
npm version patch   # or minor / major
# This updates package.json and creates a commit automatically

# 4. Update CHANGELOG.md
# Add section for new version above previous entries
# Commit: "docs: update CHANGELOG for vX.Y.Z"

# 5. Create annotated tag
git tag -a vX.Y.Z -m "Release vX.Y.Z"

# 6. Push everything
git push origin main --follow-tags

# 7. Verify DEPLOYMENT.md is current
# Review it — if anything changed since last release, update it now
```

---

## Pre-Release Checklist

- [ ] All PRs for this release are merged to `dev` and `dev → main` is merged
- [ ] `pnpm test` passes on `main`
- [ ] `pnpm typecheck` passes on `main`
- [ ] Version bumped correctly in `package.json`
- [ ] `CHANGELOG.md` has complete entry for this version
- [ ] Annotated git tag created
- [ ] `DEPLOYMENT.md` reviewed — current with any infrastructure changes

---

## Hotfix Release Process

When a critical bug in production requires an immediate patch release:

```bash
# 1. Fix is already on main via hotfix PR (see fix branch process)

# 2. Create patch version immediately
git checkout main
npm version patch

# 3. Minimal CHANGELOG entry
# ## [x.y.Z+1] — YYYY-MM-DD
# ### Fixed
# - Critical: [description of fix]

# 4. Tag and push
git tag -a vX.Y.Z+1 -m "Hotfix: brief description"
git push origin main --follow-tags
```

Hotfixes get their own patch release — never overwrite an existing tag.

---

## Version File Locations

Update all of these when bumping version:

- `package.json` → `"version"` field (primary, `npm version` handles this)

If the project has additional version references (e.g., in API headers,
build outputs, or documentation), list them here and update them together.

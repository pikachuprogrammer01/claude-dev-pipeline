# release — Release Management Skill

Use this skill on the `version` branch when preparing a release.

---

## Step 1 — Determine the Version Bump

Review all commits since the last tag:

```bash
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

Apply the decision tree:

```
Any breaking changes to public interfaces?
  Yes → MAJOR (X.0.0)
  No  → Any new features added?
          Yes → MINOR (x.Y.0)
          No  → Bug fixes or internal changes only?
                  Yes → PATCH (x.y.Z)
```

**Breaking change examples (→ MAJOR):**
- Removed or renamed a prop, export, or API endpoint
- Changed the shape of a response or callback signature
- Changed behavior that existing users depend on

**Feature examples (→ MINOR):**
- New component, hook, or utility
- New optional prop on an existing component
- New API endpoint

**Patch examples (→ PATCH):**
- Bug fix with no interface change
- Performance improvement
- Dependency security update
- Internal refactoring

When in doubt, choose the higher bump.

---

## Step 2 — Update CHANGELOG.md

Add a new section above the previous release. Write entries for users,
not developers:

```markdown
## [x.y.z] — YYYY-MM-DD

### Added
- New checkout flow with saved payment methods

### Changed
- Dashboard now shows last 90 days by default (was 30)

### Fixed
- Cart no longer duplicates items when add button clicked rapidly

### Breaking Changes
- `onSubmit` prop renamed to `onComplete` in CheckoutForm
```

Good entry: `Cart no longer duplicates items when add button clicked rapidly`
Bad entry: `Fixed state management issue in Cart component`

Write what the user experiences, not what the code does.

---

## Step 3 — Bump and Tag

```bash
# Verify main is clean
git checkout main && git pull origin main
pnpm test && pnpm typecheck

# Bump version (updates package.json and creates a commit)
npm version patch    # or minor / major

# Commit the CHANGELOG update
git add CHANGELOG.md
git commit -m "docs: update CHANGELOG for vX.Y.Z"

# Create annotated tag
git tag -a vX.Y.Z -m "Release vX.Y.Z"

# Push with tags
git push origin main --follow-tags
```

---

## Step 4 — Post-Release Checklist

- [ ] Tag visible on GitHub
- [ ] `package.json` version matches tag
- [ ] CHANGELOG.md has complete entry
- [ ] `DEPLOYMENT.md` reviewed and current
- [ ] Deployment triggered and verified

---

## Hotfix Release

For critical production bugs requiring immediate patch:

```bash
# Fix is already merged to main via hotfix PR from fix branch
git checkout main

# Create patch release immediately
npm version patch
git add CHANGELOG.md && git commit -m "docs: CHANGELOG for vX.Y.Z (hotfix)"
git tag -a vX.Y.Z -m "Hotfix: brief description"
git push origin main --follow-tags
```

Never overwrite an existing tag. Hotfixes always get a new patch version.

---

## Version File Locations

Primary: `package.json` → `"version"` field (managed by `npm version`)

If the project has additional version references (API response headers,
build output filenames, documentation), list them here and keep them
in sync with `package.json`.

# {{PROJECT_NAME}} — Version Branch

**This is the release management branch.** You are in release-prep mode.

---

## Your Role Here

1. Determine the correct version bump based on the changes since the last release.
2. Update `CHANGELOG.md` with all changes in the standard format.
3. Bump the version in `package.json` (and any other version files).
4. Create a signed git tag.
5. Verify `DEPLOYMENT.md` on `main` is current before signaling release readiness.

For the full release process, consult `.claude/skills/release/SKILL.md`.

---

## Versioning Rules (semver)

| Bump | When |
|---|---|
| `patch` x.x.**1** | Bug fixes only, no API or behavior changes |
| `minor` x.**1**.0 | New features, fully backward compatible |
| `major` **1**.0.0 | Breaking changes to external interfaces |

When in doubt, choose the higher bump. It is always safer to over-version than to
ship a breaking change as a patch.

---

## CHANGELOG.md Format

Each release gets a section:

```markdown
## [x.y.z] — YYYY-MM-DD

### Added
- New feature or capability

### Changed
- Modified existing behavior

### Fixed
- Bug corrections

### Breaking Changes
- Changes that require action from consumers of this project
```

Keep entries concise and written for the reader, not the developer.

---

## Release Checklist

- [ ] All PRs for this release are merged to `dev`
- [ ] `dev` → `main` PR reviewed and merged
- [ ] Version bumped in `package.json`
- [ ] `CHANGELOG.md` updated with all changes
- [ ] Git tag created: `git tag -a vX.Y.Z -m "Release vX.Y.Z"`
- [ ] `DEPLOYMENT.md` on `main` is reviewed and current

---

## Documents in This Branch

| File | Purpose |
|---|---|
| `CLAUDE.md` | This file — quick reference |
| `CLAUDE-detailed.md` | Full release methodology and versioning process |
| `SPEC.md` | Project requirements |
| `CHANGELOG.md` | Version history |
| `README.md` | Project documentation |
| `.claude/skills/` | All project skills |

---

## Skills

- `.claude/skills/release/SKILL.md` — release process, semver decisions, tagging

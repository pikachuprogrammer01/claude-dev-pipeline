# docs — Documentation Skill

Use this skill on the `docs` branch and whenever generating or updating
README files in any branch.

---

## README Generation Process

Before generating, scan the actual files in the directory being documented.
Generate from source — never write from scratch without reading the code.

### Root README — required sections

```markdown
# Project Name
One-paragraph description.

## Features
- Feature 1

## Tech Stack
| Layer | Technology |

## Getting Started
Prerequisites → Installation → Development commands

## Project Structure
Brief description of key directories

## Scripts
| Script | Purpose |

## Contributing
Branch strategy and PR process (brief)
```

### Subdirectory README — required sections

```markdown
# Directory Name
One sentence: what is in this directory and why.

## Contents
| File | Purpose |

## Conventions
Naming, export, or organizational rules specific to this directory.
```

Keep subdirectory READMEs to 20–40 lines.

---

## When to Regenerate

- New directory or significant file added
- Setup or usage instructions change
- Major feature added or removed
- Before a minor or major release

Do not regenerate after every small change.

---

## SPEC Sync to All Branches

SPEC.md has a single authoritative copy on `main`. Other branches treat it
as read-only. After any update to SPEC.md on `main`:

```bash
git add SPEC.md && git commit -m "docs: update SPEC"

for branch in dev fix refactor version test docs perf security; do
  git checkout "$branch"
  git checkout main -- SPEC.md
  git add SPEC.md && git commit -m "docs: sync SPEC from main"
done

git checkout main
```

When to sync:
- After adding or removing a requirement
- After an architectural decision changes the stack or structure
- After the Out of Scope section changes
- Before a minor or major release

## ADR Process

Write an ADR when a decision adds a major dependency, establishes a
convention, or would be hard to reverse.

File: `docs/decisions/ADR-NNNN-short-title.md`

```markdown
# ADR-NNNN: Short Title

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-XXXX

## Context
What situation prompted this decision?

## Decision
"We will use X for Y." Direct statement.

## Consequences
### Positive
- What becomes easier?
### Negative or Constrained
- What becomes harder?
```

Never delete ADRs. Mark superseded ones and link to the replacement.

---

## TSDoc Standards

Document all exported functions, hooks, and components:

```typescript
/**
 * Brief description.
 * @param userId - Branded user identifier.
 * @returns AsyncState containing the User or an Error.
 * @example
 * const state = useUser('usr_abc123' as UserId)
 */
export function useUser(userId: UserId): AsyncState<User> { ... }
```

Do not document what the code obviously does from reading it.

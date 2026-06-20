# {{PROJECT_NAME}} — Specification

> This document describes what the project is, what it must do, and the
> architectural decisions that govern how it is built.
> Keep it current with what is deployed on `main`. Aspirational features
> belong in issues or a roadmap, not here.

---

## Overview

<!-- One paragraph: what is this project and what problem does it solve? -->

**Project:** {{PROJECT_NAME}}
**Description:** _[fill in]_
**Primary users:** _[fill in]_
**Current status:** In development

---

## Architecture

**Framework:** {{FRAMEWORK}}
**Package manager:** {{PKG_MANAGER}}
**Language:** TypeScript (strict mode)
**Deployment target:** _[fill in from project.config.json]_

### Key Dependencies

| Package | Purpose |
|---|---|
| `zod` | Runtime validation and type derivation |
| _[add as needed]_ | |

### TypeScript Configuration

`strict: true` plus:
- `noUncheckedIndexedAccess`
- `exactOptionalPropertyTypes`
- `noPropertyAccessFromIndexSignature`

No `any`. No `as` casts. External data validated at boundaries via Zod.

---

## Functional Requirements

<!-- List what the system must do. Use "must" for required, "should" for preferred. -->

### Core Features

1. _[Fill in core feature 1]_
2. _[Fill in core feature 2]_

### Out of Scope

<!-- Explicitly state what this project does NOT do. Prevents scope creep. -->

- _[Fill in]_

---

## Non-Functional Requirements

| Requirement | Target |
|---|---|
| Accessibility | WCAG 2.1 AA |
| Browser support | Last 2 versions of major browsers |
| Performance | LCP < 2.5s (4G, mid-range device) |
| TypeScript coverage | 100% — no untyped files |
| Test coverage | ≥ 80% of `src/` |

---

## Decisions

<!-- Significant decisions made during development. For detailed reasoning, see docs/decisions/ ADRs. -->

| Date | Decision | Rationale |
|---|---|---|
| _[YYYY-MM-DD]_ | _[decision]_ | _[brief reason]_ |

---

## Open Questions

<!-- Unresolved questions that will affect implementation. Remove when resolved. -->

- _[Question — owner — target resolution date]_

---

_Last updated: by @git-init on project creation. Update when behavior or architecture changes._

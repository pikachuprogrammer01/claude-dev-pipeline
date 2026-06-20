# {{PROJECT_NAME}} — Docs Branch: Detailed Reference

## Philosophy

Documentation has a half-life. Code changes; docs that are not maintained
actively become misleading. The goal is not to have extensive documentation —
it is to have accurate documentation. Accurate and minimal beats comprehensive
and stale every time.

---

## README Generation Process

README files are generated via `.claude/skills/docs/SKILL.md`, not written
from scratch. This ensures consistent structure and reduces the effort of
keeping them current.

When to regenerate a README:
- After a significant feature is added or removed
- When the directory structure changes meaningfully
- When setup or usage instructions become outdated
- Before a minor or major release

The root `README.md` is the project's public face. It should answer:
1. What is this?
2. How do I set it up?
3. How do I use it?
4. How do I contribute?

Subdirectory READMEs answer: what is in this directory and why?

---

## TSDoc Standards

Comments in source code are the source of truth for API documentation.
Generate docs from them; do not maintain a separate copy.

```typescript
/**
 * Fetches a user by ID and returns their profile.
 *
 * @param userId - The unique identifier of the user to fetch.
 *   Must be a valid {@link UserId} branded type.
 * @returns An {@link AsyncState} containing the user profile on success,
 *   or an error state if the request fails.
 *
 * @example
 * ```tsx
 * const state = useUser('usr_abc123' as UserId)
 * if (state.status === 'success') {
 *   console.log(state.data.name)
 * }
 * ```
 */
export function useUser(userId: UserId): AsyncState<User> { ... }
```

Document:
- All exported functions, hooks, and components
- All non-obvious parameters
- Return types when not immediately clear from the signature
- Side effects when present

Do not document:
- What the code obviously does from reading it
- Internal implementation details
- Temporary or private utilities

---

## Architecture Decision Records (ADRs)

ADRs are lightweight records of significant architectural decisions.
They live in `docs/decisions/ADR-NNNN-title.md`.

### When to Write an ADR

Write one whenever a decision:
- Adds a major dependency or changes the tech stack
- Establishes a pattern that others must follow
- Changes the project architecture in a non-obvious way
- Would be difficult or expensive to reverse
- Was reached after meaningful deliberation

### ADR Lifecycle

```
Proposed → Accepted → [Deprecated | Superseded by ADR-XXXX]
```

Do not delete ADRs. Mark them as deprecated or superseded and link to
the replacement. History is valuable.

### ADR Template

```markdown
# ADR-NNNN: Short Title

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-XXXX

## Context

What situation, constraint, or problem prompted this decision?
What forces are at play?

## Decision

What was decided, stated directly. Not "we considered..." but "we will..."

## Consequences

### Positive
- What becomes easier or better?

### Negative or Constrained
- What becomes harder, more limited, or requires new discipline?

### Neutral
- What changes without clear positive or negative impact?
```

---

## Documentation Maintenance Triggers

The `post-commit` hook will remind you when documentation may need updating.
These are the mapping rules — consult this to understand why you received a prompt:

| Changed files | Documentation to check |
|---|---|
| `src/` structure changes | `ARCHITECTURE.md` directory map |
| New or changed exports | TSDoc on the export + root README if it's public API |
| `package.json` (deps) | `SPEC.md` dependencies section |
| API route changes | API documentation in `docs/` or TSDoc |
| `feat:` commit | `README.md` if feature is user-facing |
| Architectural decision made | New ADR in `docs/decisions/` |

---

## ARCHITECTURE.md Maintenance

`ARCHITECTURE.md` has two owners:
- The `dev` branch: updates it when structure changes during development
- The `docs` branch: audits it periodically to ensure accuracy

`ARCHITECTURE.md` must always accurately describe the actual project structure.
Running a diff between the doc and the real directory is a valid audit:

```bash
# Compare documented structure against actual
tree src/ --dirsfirst -I "node_modules|*.test.*|*.spec.*"
```

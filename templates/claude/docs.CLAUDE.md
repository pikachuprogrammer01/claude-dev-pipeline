# {{PROJECT_NAME}} — Docs Branch

**This is the documentation branch.** You are in documentation mode.

---

## Your Role Here

1. Keep README files accurate and synchronized with the current code.
2. Generate or update API documentation when interfaces change.
3. Write Architecture Decision Records (ADRs) for significant decisions.
4. Ensure every major source subdirectory has a README.

For all documentation generation, consult `.claude/skills/docs/SKILL.md`.

---

## Documentation Standards

- **README files** — generated via the docs skill, never written from scratch
  without it. Always reflect the current state of the code, not aspirational state.
- **Language** — clear, direct, present tense. No marketing language. Write for
  the next developer, not for a product page.
- **ADRs** — stored in `docs/decisions/ADR-NNNN-title.md`. Use the template below.
- **API docs** — TSDoc comments in source are the authoritative source. Generate
  from them; do not maintain a separate manual copy.

---

## When to Write an ADR

Write an ADR whenever a decision:
- Adds a major dependency or changes the tech stack
- Alters the project architecture in a non-obvious way
- Establishes a team convention that others must follow
- Would be difficult or expensive to reverse

---

## ADR Template

```markdown
# ADR-NNNN: Short Title

**Date:** YYYY-MM-DD
**Status:** Proposed | Accepted | Deprecated | Superseded by ADR-XXXX

## Context
What situation, constraint, or problem prompted this decision?

## Decision
What was decided, stated clearly and directly.

## Consequences
What becomes easier as a result?
What becomes harder or more constrained?
```

---

## Documents in This Branch

| File | Purpose |
|---|---|
| `CLAUDE.md` | This file — quick reference |
| `CLAUDE-detailed.md` | Full documentation methodology and standards |
| `SPEC.md` | Project requirements |
| `README.md` | Project documentation |
| `docs/decisions/` | Architecture Decision Records |
| `.claude/skills/` | All project skills |

---

## Skills

- `.claude/skills/docs/SKILL.md` — README generation, ADR process, API docs

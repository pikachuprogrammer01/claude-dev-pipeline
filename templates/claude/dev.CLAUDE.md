# {{PROJECT_NAME}} — Dev Branch

**This is the active development branch.** You are in feature-build mode.
Framework: {{FRAMEWORK}} · Package manager: {{PKG_MANAGER}}

---

## TypeScript — Non-Negotiable Rules

Apply these to every line of code on this branch. No exceptions.

1. **No primitive types when a domain type exists.**
   Use `Brand<string, 'UserId'>` not bare `string` for IDs, tokens, slugs, etc.
   Use `Brand<number, 'Price'>` not bare `number` for money, measurements, etc.
   When in doubt about whether to brand a type, brand it.

2. **No `any`.** Use `unknown` and narrow explicitly. If you feel tempted to
   write `any`, that is a signal to model the type properly instead.

3. **No `as` type casts.** Validate external data at the boundary using Zod.
   Derive TypeScript types from Zod schemas (`z.infer<typeof Schema>`).

4. **Exhaustive union checks.** Every `switch` on a union type must have a
   `default` branch that assigns to `never` to catch unhandled cases at
   compile time.

5. **`readonly` by default.** All object and array types are `Readonly<>` or
   `readonly[]` unless mutability is explicitly required and documented.

6. **Compiler options in effect:** `strict`, `noUncheckedIndexedAccess`,
   `exactOptionalPropertyTypes`, `noPropertyAccessFromIndexSignature`.

For all type decisions, consult `.claude/skills/typescript/SKILL.md`.

---

## Your Role Here

1. Build features against `SPEC.md` requirements and `ARCHITECTURE.md` patterns.
2. Write unit tests alongside code — not after.
3. Update `ARCHITECTURE.md` if the directory structure or data flow changes.
4. When a feature is complete: PR from `dev` → `main`.

---

## Workflow

```
Requirement in SPEC.md
  → update ARCHITECTURE.md if structure changes
  → define types first (branded where applicable)
  → implement against types
  → write unit tests
  → PR to main
```

---

## Documents in This Branch

| File | Purpose |
|---|---|
| `CLAUDE.md` | This file — quick reference |
| `CLAUDE-detailed.md` | Full dev workflow, coding standards, patterns |
| `SPEC.md` | Project requirements — maintained on `main`, read-only on this branch |
| `ARCHITECTURE.md` | Directory structure, data flow, conventions |
| `README.md` | Project documentation |
| `.claude/skills/` | All project skills |

---

## Skills

- `.claude/skills/typescript/SKILL.md` — type hierarchy, branded types, patterns
- `.claude/skills/docs/SKILL.md` — update README or ARCHITECTURE.md

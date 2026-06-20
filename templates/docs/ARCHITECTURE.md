# {{PROJECT_NAME}} — Architecture

> Describes the actual structure of the project as it exists today.
> Update this document whenever the directory structure, data flow, or
> conventions change. Stale architecture docs are actively harmful.
> Last verified against: _[fill in date when audited]_

---

## Tech Stack

| Layer | Technology | Version |
|---|---|---|
| Framework | {{FRAMEWORK}} | _[fill in]_ |
| Language | TypeScript | _[fill in]_ |
| Package manager | {{PKG_MANAGER}} | _[fill in]_ |
| Testing | _[fill in]_ | _[fill in]_ |
| Styling | _[fill in]_ | _[fill in]_ |
| Runtime validation | Zod | _[fill in]_ |

---

## Directory Structure

<!-- Keep this in sync with the actual project. Run `tree src/ --dirsfirst` to audit. -->

```
{{PROJECT_NAME}}/
├── src/
│   ├── app/              # [Next.js App Router / framework entry points]
│   ├── components/       # Reusable UI components
│   │   └── [Component]/
│   │       ├── index.tsx
│   │       └── [Component].test.tsx
│   ├── hooks/            # Custom React hooks
│   ├── lib/              # Utilities and helpers
│   ├── types/            # Shared TypeScript types
│   │   ├── branded.ts    # Brand<T, B> type + domain branded types
│   │   └── index.ts      # Re-exports
│   └── schemas/          # Zod schemas (source of truth for external data types)
├── public/               # Static assets
├── docs/
│   └── decisions/        # Architecture Decision Records (ADRs)
├── .claude/              # Claude Dev Pipeline files
│   └── skills/
└── [config files]
```

---

## Data Flow

<!-- Describe how data moves through the system. Update when fetch patterns change. -->

```
External API / Database
  └── API Route / Server Action
        └── Zod schema parse (boundary: external → internal)
              └── Typed domain objects (branded types)
                    └── Business logic / hooks
                          └── React components (render only)
```

All external data is validated via Zod at the boundary.
TypeScript types are derived from Zod schemas, not declared separately.

---

## Component Conventions

| Layer | Responsibility | Rule |
|---|---|---|
| Page / Route | Routing, layout, initial data fetch | No business logic |
| Container | Async state management, data transformation | Uses hooks, no direct fetch |
| Presentational | Render UI from props | No side effects, fully typed props |
| Hook (`useXxx`) | Stateful logic, API calls, derived state | Independently testable |

---

## Type Conventions

All types follow the hierarchy defined in `CLAUDE-detailed.md`:

1. Branded types for domain concepts (see `src/types/branded.ts`)
2. Literal unions for fixed option sets
3. Discriminated unions for state machines and result types
4. Primitives only when no more specific type applies

---

## Import Conventions

```typescript
// Order: external → internal absolute → relative
import { z } from 'zod'
import { useUser } from '@/hooks/useUser'
import { UserCard } from './UserCard'
```

Path alias `@/` maps to `src/`.

---

## Testing Conventions

- Unit tests co-located with source: `Component.test.tsx` next to `Component.tsx`
- Integration tests in `src/__tests__/integration/`
- Test utilities and fixtures in `src/__tests__/fixtures/`

---

## Key Decisions

| Decision | Rationale | ADR |
|---|---|---|
| Zod for all external data | Type-safe at runtime, types derived from schema | — |
| Branded types for domain concepts | Prevents accidental type confusion at compile time | — |
| _[add decisions as made]_ | | |

---

_Update this document when: adding directories, changing data flow, establishing new conventions._

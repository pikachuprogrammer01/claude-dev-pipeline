# {{PROJECT_NAME}} — Security Branch: Detailed Reference

## Philosophy

Security is not a phase at the end of development — vulnerabilities introduced
during development are harder to fix post-hoc and more likely to reach production.
This branch exists to audit proactively, before a vulnerability becomes an incident.

---

## Audit Process

### Step 1 — Dependency Scan

```bash
pnpm audit
# or
pnpm audit --audit-level=moderate

# For a detailed report
pnpm audit --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
for vuln in data.get('vulnerabilities', {}).values():
    print(f\"{vuln['severity'].upper()}: {vuln['name']} — {vuln['via'][0] if isinstance(vuln['via'][0], str) else vuln['via'][0]['title']}\")
"
```

Resolve critical and high severity findings before any release.
For medium and below: document in `SECURITY.md` and schedule.

### Step 2 — Secret Scan

```bash
# Check for accidentally committed secrets
git log --all --full-history -- "*.env"
git log --all --full-history -- "*.pem"
git log --all --full-history -- "*.key"

# Check current working tree
grep -r "sk_live_\|pk_live_\|AKIA\|ghp_\|xox[baprs]-" src/ --include="*.ts" --include="*.tsx"
```

If a secret is found in git history, it must be rotated immediately —
removing it from the current tree is insufficient; history is public.

### Step 3 — Input Validation Audit

Verify every external data entry point uses Zod validation:

```typescript
// Every API route handler should start with schema validation
export async function POST(request: Request) {
  const body = await request.json()
  
  // This line must exist. Raw body.anything is never safe.
  const parsed = CreateOrderSchema.safeParse(body)
  if (!parsed.success) {
    return Response.json({ error: parsed.error.flatten() }, { status: 400 })
  }
  
  // Only proceed with typed, validated data
  const order = parsed.data
  ...
}
```

Entry points to audit:
- All API route handlers
- All form `onSubmit` handlers
- URL parameter parsing
- `localStorage` / `sessionStorage` reads
- `postMessage` listeners

### Step 4 — Authentication and Authorization Check

For each protected resource, verify:
1. Authentication is checked (session is valid)
2. Authorization is checked (user has permission for this specific resource)
3. Neither check can be bypassed via URL manipulation

```typescript
// Pattern: auth check at the top of every protected handler
export async function GET(request: Request, { params }: { params: { id: string } }) {
  const session = await getSession(request)
  if (!session) return Response.json({ error: 'Unauthorized' }, { status: 401 })
  
  // Authorization: verify the user owns this resource
  const resource = await db.findById(params.id)
  if (resource.ownerId !== session.userId) {
    return Response.json({ error: 'Forbidden' }, { status: 403 })
  }
  ...
}
```

### Step 5 — Document All Findings

Every finding gets a `SECURITY.md` entry, regardless of severity:

```markdown
## YYYY-MM-DD — Finding Title

**Severity:** Critical | High | Medium | Low | Info
**Location:** src/app/api/orders/route.ts line 23
**Description:** POST handler accepts user input without Zod validation
**Impact:** Malformed input could cause unhandled exceptions or data corruption
**Remediation:** Add CreateOrderSchema.safeParse() at the start of the handler
**Status:** Open
```

---

## OWASP Top 10 Checklist (Web)

| Risk | Check |
|---|---|
| Broken Access Control | Every resource checks both auth + authz |
| Cryptographic Failures | Sensitive data encrypted at rest and in transit, no MD5/SHA1 |
| Injection | All external input through Zod; no string-constructed queries |
| Insecure Design | Threat modelling done for sensitive flows |
| Security Misconfiguration | Security headers set (CSP, HSTS, X-Frame-Options) |
| Vulnerable Components | `pnpm audit` clean for critical/high |
| Auth Failures | Sessions expire, tokens rotated, no credentials in code |
| Integrity Failures | Supply chain: lockfile committed, dependencies reviewed |
| Logging Failures | Auth events logged; no sensitive data in logs |
| SSRF | External URL inputs validated against allowlist |

---

## Security Headers (verify these are set)

```typescript
// next.config.ts or equivalent
const securityHeaders = [
  { key: 'X-DNS-Prefetch-Control',      value: 'on' },
  { key: 'Strict-Transport-Security',   value: 'max-age=63072000; includeSubDomains; preload' },
  { key: 'X-Frame-Options',             value: 'SAMEORIGIN' },
  { key: 'X-Content-Type-Options',      value: 'nosniff' },
  { key: 'Referrer-Policy',             value: 'origin-when-cross-origin' },
  { key: 'Permissions-Policy',          value: 'camera=(), microphone=(), geolocation=()' },
]
```

---

## Closing Findings

Update `SECURITY.md` entry status to `Resolved (YYYY-MM-DD)` when fixed.
Include a reference to the fix commit. Never delete finding entries.

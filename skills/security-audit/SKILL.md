# security-audit — Security Audit Skill

Use this skill on the `security` branch during audits.
Run a full audit before every minor and major release.

---

## Audit Sequence

Complete all steps. Document every finding in SECURITY.md regardless of severity.

---

## Step 1 — Dependency Vulnerability Scan

```bash
pnpm audit

# JSON output for scripting
pnpm audit --json | python3 -c "
import json, sys
data = json.load(sys.stdin)
vulns = data.get('vulnerabilities', {})
for name, v in vulns.items():
    via = v['via'][0]
    title = via if isinstance(via, str) else via.get('title', name)
    print(f\"{v['severity'].upper():10} {name}: {title}\")
" 2>/dev/null || pnpm audit
```

Resolution targets:
- **Critical / High:** block release, fix immediately
- **Medium:** fix before next scheduled release, document in SECURITY.md
- **Low / Info:** document in SECURITY.md, fix when convenient

---

## Step 2 — Secret and Credential Scan

```bash
# Secrets in git history (most dangerous — rotation required if found)
git log --all --oneline --diff-filter=A -- "*.env*" "*.pem" "*.key" "*.p12"

# Patterns in current working tree
grep -rn \
  -e "sk_live_" \
  -e "pk_live_" \
  -e "AKIA[0-9A-Z]{16}" \
  -e "ghp_[a-zA-Z0-9]{36}" \
  -e "xox[baprs]-" \
  -e "-----BEGIN RSA PRIVATE KEY-----" \
  src/ --include="*.ts" --include="*.tsx" --include="*.js"

# Verify .env files are gitignored
git check-ignore -v .env .env.local .env.production 2>/dev/null
```

If a secret is found in git history: rotate it immediately.
Removing it from the current tree is insufficient — history is public.

---

## Step 3 — Input Validation Audit

Every external data entry point must pass through a Zod schema.

Entry points to inspect:
- API route handlers (`app/api/**/route.ts`)
- Server Actions
- Form `onSubmit` handlers that call mutations
- URL search parameter parsing
- `localStorage` / `sessionStorage` reads
- `postMessage` event listeners

Pattern to verify is present at each entry point:

```typescript
// API route — required pattern
export async function POST(request: Request) {
  const body = await request.json()
  const parsed = CreateOrderSchema.safeParse(body)    // must be here
  if (!parsed.success) {
    return Response.json({ error: parsed.error.flatten() }, { status: 400 })
  }
  // Only parsed.data is used from this point — never body directly
  const order = parsed.data
}
```

Flag any handler that uses raw `body.field` or `params.value` without validation.

---

## Step 4 — Authentication and Authorization Audit

For each protected resource, verify both checks are present and in the right order:

```typescript
// Required pattern for every protected handler
export async function GET(request: Request, { params }: { params: { id: string } }) {
  // 1. Authentication: is there a valid session?
  const session = await getSession(request)
  if (!session) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 })
  }

  // 2. Authorization: does this user own this resource?
  const resource = await db.findById(params.id)
  if (!resource || resource.ownerId !== session.userId) {
    return Response.json({ error: 'Forbidden' }, { status: 403 })
  }

  // Only then: return the resource
  return Response.json(resource)
}
```

Common failures to look for:
- Auth check present but authorization skipped (user can read any resource by ID)
- Auth check in middleware but bypassed by direct route access
- Admin-only endpoints checking `user.role === 'admin'` with user-supplied role

---

## Step 5 — Security Headers Audit

Verify these headers are set in the framework config:

```typescript
// next.config.ts
const securityHeaders = [
  { key: 'X-DNS-Prefetch-Control',    value: 'on' },
  { key: 'Strict-Transport-Security', value: 'max-age=63072000; includeSubDomains; preload' },
  { key: 'X-Frame-Options',           value: 'SAMEORIGIN' },
  { key: 'X-Content-Type-Options',    value: 'nosniff' },
  { key: 'Referrer-Policy',           value: 'origin-when-cross-origin' },
  { key: 'Permissions-Policy',        value: 'camera=(), microphone=(), geolocation=()' },
]
```

Verify in browser: DevTools → Network → any request → Response Headers.

---

## Step 6 — Document All Findings

Every finding gets a SECURITY.md entry:

```markdown
## YYYY-MM-DD — Finding Title

**Severity:** Critical | High | Medium | Low | Info
**Location:** src/app/api/orders/route.ts line 23
**Description:** POST handler uses raw request body without Zod validation
**Impact:** Malformed input could cause unhandled exceptions or data corruption
**Remediation:** Add CreateOrderSchema.safeParse() at start of handler
**Status:** Open
```

When fixed, update status — never delete entries:
```
**Status:** Resolved (YYYY-MM-DD, commit: abc1234)
```

---

## OWASP Top 10 Checklist

| Risk | Check |
|---|---|
| Broken Access Control | Every resource checks auth AND authz |
| Cryptographic Failures | No MD5/SHA1, secrets not in env, HTTPS enforced |
| Injection | All external input through Zod, no string-built queries |
| Insecure Design | Auth flows, password reset, and payment flows reviewed |
| Security Misconfiguration | Security headers set, no debug mode in production |
| Vulnerable Components | `pnpm audit` clean at critical/high |
| Auth Failures | Sessions expire, no credentials in source, tokens rotated |
| Integrity Failures | Lockfile committed, no unreviewed scripts in package.json |
| Logging Failures | Auth events logged, no PII in logs |
| SSRF | External URLs validated against allowlist if accepted as input |

---

## Severity Definitions

| Level | Meaning | Release Impact |
|---|---|---|
| Critical | RCE, auth bypass, or data breach possible | Block all releases |
| High | Significant risk to user data or system | Fix before next release |
| Medium | Moderate risk, requires specific conditions | Fix in next release |
| Low | Minor risk, limited exploitability | Fix when convenient |
| Info | Observation, no direct risk | No action required |

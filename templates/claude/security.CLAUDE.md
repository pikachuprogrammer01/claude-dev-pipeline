# {{PROJECT_NAME}} — Security Branch

**This is the security audit branch.** You are in audit mode.

---

## Your Role Here

1. Audit the codebase for security vulnerabilities using the checklist below.
2. Review dependencies for known CVEs.
3. Document all findings in `SECURITY.md` with severity and remediation guidance.
4. Verify previously reported findings are resolved before closing them.

For the full audit methodology, consult `.claude/skills/security-audit/SKILL.md`.

---

## Severity Levels

| Level | Meaning | Action |
|---|---|---|
| **Critical** | Data breach or RCE possible | Block all releases immediately |
| **High** | Significant risk | Fix before next release |
| **Medium** | Moderate risk | Fix in next scheduled release |
| **Low** | Minor risk | Fix when convenient |
| **Info** | Observation only | No immediate action required |

---

## Audit Checklist

**Authentication & Authorization**
- [ ] No hardcoded credentials or API keys in source or git history
- [ ] Authentication tokens validated on every protected route
- [ ] Least-privilege access enforced

**Input Handling**
- [ ] All external data (API responses, form inputs, URL params) validated via Zod at entry points
- [ ] No user input used to construct queries, commands, or file paths without sanitization
- [ ] File upload types and sizes restricted

**Dependencies**
- [ ] `pnpm audit` reports no critical or high CVEs
- [ ] No abandoned or unmaintained packages in critical paths

**Secrets**
- [ ] `.env` and all secret files are gitignored
- [ ] No secrets in source code, comments, or commit history
- [ ] All environment variables documented in `.env.example` without actual values

---

## SECURITY.md Finding Format

```markdown
## YYYY-MM-DD — Finding Title

**Severity:** Critical | High | Medium | Low | Info
**Location:** path/to/file.ts (line N) or component/feature name
**Description:** What the vulnerability is and how it could be triggered
**Impact:** What an attacker could achieve by exploiting this
**Remediation:** Specific steps to fix or mitigate
**Status:** Open | In Progress | Resolved (YYYY-MM-DD)
```

---

## Documents in This Branch

| File | Purpose |
|---|---|
| `CLAUDE.md` | This file — quick reference |
| `CLAUDE-detailed.md` | Full security audit methodology |
| `SPEC.md` | Project requirements — maintained on `main`, read-only on this branch |
| `SECURITY.md` | Vulnerability findings and remediation status |
| `README.md` | Project documentation |
| `.claude/skills/` | All project skills |

---

## Skills

- `.claude/skills/security-audit/SKILL.md` — OWASP checklist, audit process, CVE scanning

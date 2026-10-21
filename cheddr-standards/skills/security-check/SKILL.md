---
name: security-check
description: Run a security audit on staged changes, a PR, or the full codebase. Wraps Cloudflare's security-audit skill with Cheddr-specific attack class routing.
disable-model-invocation: true
---

# Security Check

Targeted security audit. Wraps the security-audit skill and routes to relevant attack classes based on what changed.

## Usage

```
/security-check              # Audit staged/unstaged changes
/security-check --full        # Full codebase audit
/security-check --pr <number> # Audit a specific PR's diff
```

## How it works

1. Determine scope:
   - No args: `git diff` + `git diff --cached`
   - `--full`: entire codebase
   - `--pr N`: `gh pr diff N`

2. Route to relevant attack classes based on changed files:

| Files changed | Attack classes |
|---|---|
| routes/, middleware/, API handlers | web-protocol-and-auth |
| payment/, wallet/, ledger/, settlement/ | data-isolation-and-lifecycle, resource-exhaustion |
| auth/, session/, token/ | web-protocol-and-auth, client-side |
| package.json, package-lock.json, deps | supply-chain-and-release |
| lambda/, infra/, deploy/, Dockerfile | cloud-and-deployment |
| frontend components, DOM, templates | client-side |
| All other / unsure | core attack classes |

3. Run the security-audit skill with the scoped files and selected attack classes.

4. Output findings to `.claude/reviews/security-<date>.md` with verdicts:
   - **confirmed** — exploitable, with source trace and impact
   - **needs_validation** — plausible but has an unresolved fact
   - **rejected** — disproved, logged for record

## Rules

- The agent that checks a finding is never the agent that found it
- Severity requires impact, not just checklist deviation
- Defense-in-depth gaps are not vulnerabilities
- confirmed findings get CRITICAL. needs_validation gets WARNING.
- Save output locally. Never post to GitHub.

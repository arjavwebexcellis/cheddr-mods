---
name: pr-review
description: Convention-aware review of another developer's PR. Learns the codebase's patterns before judging, cites existing code for every finding, and rounds re-reviews. LOCAL ONLY — never posts to GitHub.
disable-model-invocation: true
---

**LOCAL ONLY. Never post comments, reviews, approvals. Never call `gh pr review`, `gh pr comment`, or any GitHub write. Output is a local file only. No emojis anywhere.**

# PR Review

Review a PR against how THIS codebase already works. The main job is convention conformance — every changed file measured against the patterns of the code around it. A finding without a citation of existing code is an opinion, not a finding.

## Usage

```
/pr-review <PR-number>              # new review (round 1, or next round if prior exists)
/pr-review <PR-number> --re-review  # force diff-only follow-up round
```

## Step 0 — Load context (every time)

Read `CLAUDE.md`, `AGENTS.md`, `MEMORY.md` in repo root and each touched subrepo — documented conventions override generic advice. Then check `.claude/reviews/pr-<number>/` for prior rounds. If any exist, this is a re-review (see bottom) unless the user says otherwise.

## Step 1 — Metadata + convention baseline

`gh pr view <number>` for title, body, author, changed files (read-only; no write subcommands). For each directory the PR touches, sample 1–2 existing unchanged files in that same directory and learn the local norms: response shape, error handling, model/data-access style, import style, naming. State the baseline in a few bullets before reviewing — it is what every finding is judged against.

## Step 2 — Review order

1. **Diff** — `gh pr diff <number>`. Read surrounding code around each hunk, not just the hunks.
2. **PR body match** — does the diff do what the body claims? Flag scope drift and undocumented changes.
3. **Convention check (main job)** — every changed file vs the surrounding-codebase patterns from Step 1. This is where most findings come from.
4. **Impact analysis** — what calls the changed code; what breaks downstream; API-contract changes across repos.
5. **Security (concrete only)** — trace an actual untrusted input path to the sink. No input path traced = no security finding. No hypotheticals.
6. **Size check** — is the PR too large to review safely / mixing unrelated changes? Say so.
7. **Test quality** — apply 2g below.
8. **Mechanical scan** — apply 2h below.
9. **Structural quality** — apply 2i below.
10. **Over-engineering** — apply 2j below.
11. **Security audit (prod PRs)** — apply 2k below.
12. **Analytics coverage** — apply 2l below.

### 2g. Test quality
If the PR adds tests, apply the authoring gate:
1. What behavior does this test protect?
2. What regression makes it fail?
3. Why doesn't existing coverage catch it?
4. Does it need a test-only production seam?

Flag: source re-assertions, over-permissive mocks, implementation-coupled tests, test-only exports. A test that breaks on behavior-preserving refactoring is asserting implementation — flag it.

If the PR changes behavior WITHOUT adding tests, flag that too.

### 2h. Mechanical scan
Per changed function:
- Null paths: new variables that could be null — handled?
- Async errors: every await/promise — has catch/try-catch?
- Dead branches: unreachable conditionals?
- Off-by-one: array/loop edge cases?
- Frontend only: useEffect/useCallback dependency arrays complete?

### 2i. Structural quality
- Did this PR push any file past 1000 lines? Flag as CRITICAL.
- New files over 300 lines? Suggest splitting.
- Are there ad-hoc conditionals bolted onto unrelated flows? (spaghetti growth)
- Is there a simpler framing that would delete whole branches/helpers/modes?
- Any thin wrappers or identity abstractions adding indirection without clarity?

Structural and size findings (file too big, simpler framing, spaghetti growth) don't require a cite — they're measured, not convention-compared.

### 2j. Over-engineering check
For each new addition in the diff, climb the Ponytail ladder:
- Does this need to exist? Could it be inline?
- Already in codebase? (grep first)
- Stdlib does it? Don't wrap it.
- Installed dep does it? Don't add another.
- One line? Then one line.

Flag new deps where existing ones work, wrapper functions around native APIs, multi-file additions for simple logic.

### 2k. Security audit (prod PRs only)

If the PR base branch is main, master, or production:

1. Identify which attack classes are relevant based on changed files:
   - Routes/API/middleware → run web-protocol-and-auth checks
   - Payment, wallet, ledger, settlement → run data-isolation-and-lifecycle checks
   - Auth, session, token → run web-protocol-and-auth + client-side checks
   - package.json, dependencies → run supply-chain-and-release checks
   - Lambda, infra, deploy configs → run cloud-and-deployment checks
   - If unsure → run core attack classes only

2. Scope to changed files only — don't audit the full codebase on a PR review.

3. For each finding from the security audit:
   - confirmed → CRITICAL in the review findings table
   - needs_validation → WARNING with the exact unresolved fact noted
   - rejected → drop silently

4. Append security findings to the main review output under a "Security Audit" section.

Security audit findings are exempt from the cite rule below — the audit's source trace is the evidence.

If the PR targets dev, staging, or feature branches → skip this step entirely.

### 2l. Analytics coverage

For each user-facing change in the PR:
- New screen/modal/flow? → check for Mixpanel screen_view event
- New CTA/action? → check for Mixpanel tap event
- New purchase/payment? → check for AppsFlyer revenue event
- New user state? → check for Braze attribute/trigger
- Removed flow? → check old events are deprecated

Cite the existing naming convention from analyticsEvents.ts. Flag gaps as WARNING.
AppsFlyer is revenue ONLY — never suggest engagement events for it.

**Finding rule:** every finding MUST cite existing code (`file:line`) that establishes the right pattern. **No cite → NOTE at most, never WARNING or CRITICAL.** Prefer a clarifying question over an assumption — when you don't know why the author did something, ask it in the report rather than asserting it's wrong.

Severity: CRITICAL (data/money loss, auth bypass, PII exposure, prod break) · WARNING (bug under plausible conditions, or convention violation with a cite) · NOTE (style, uncited observation, question). **APPROVE means merge as-is.**

## Step 3 — Output

Write the review as markdown first, then have the answer-me-with-html plugin convert it to a polished HTML page. Don't write HTML manually.

1. Save the markdown to `.claude/reviews/pr-<number>/round-<N>.md`.
2. Invoke the answer-me-with-html skill to render that file next to it: `am render .claude/reviews/pr-<number>/round-<N>.md -o .claude/reviews/pr-<number>/round-<N>.html --no-open --style off` (`--style off`: review wording is not rewritten for the STE check). If the plugin isn't installed, the markdown alone is the review.
3. Update `.claude/reviews/pr-<number>/meta.json` — round number, date, PR number, verdict, findings summary (for the next round to read).

N is the next integer after the highest existing round in that directory (round 1 if none).

Review markdown format:

````markdown
---
title: "PR #<number>: <title>"
---
Author: <name> | Stack: <stack> | Size: +<add>/-<del>
Verdict: APPROVE / REQUEST CHANGES / NEEDS DISCUSSION

## Convention Baseline
[bullets from Step 1]

## Findings
| # | File:Line | Issue | Convention (cite) | Impact | Severity | Priority | Fix |

## Impact Analysis
Callers affected, dependencies changed, breaking changes

## What's Good
[genuine positives]

## Questions for Author
[intent, trade-offs]
````

## Re-review mode

Read the prior round's `meta.json` and markdown. Fetch only the NEW diff since that round (`gh pr diff`, compared against what the prior round covered). For each prior finding, mark: **FIXED** / **NOT ADDRESSED** / **REGRESSED**. Add any findings newly introduced by the new commits. Write as the next `round-<N>.md` (rendered to `round-<N>.html` as in Step 3) + updated `meta.json`. Don't re-review unchanged code.

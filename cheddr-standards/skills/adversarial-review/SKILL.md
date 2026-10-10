---
name: adversarial-review
description: Convention-aware self-review of your own changes. Learns the codebase's patterns from real files first, then judges the diff against them. Every finding cites existing code. Use before committing your own work.
---

# Adversarial Review

Self-review. Judge the diff against how THIS codebase already does things — not against generic best practice. A finding is only real if you can point at existing code that does it the right way.

**Guiding rule:** No false positives over zero missed issues. A wrong "finding" costs the author trust and time; a missed nitpick costs little. When unsure, drop it.

## Step 0 — Load conventions (every time, no caching)

Read, in the repo root and in each touched subrepo: `CLAUDE.md`, `AGENTS.md`, `MEMORY.md`. Project conventions override generic advice — a finding that contradicts a documented convention is invalid. Re-read every run; they change.

## Step 1 — Establish the convention baseline

For each directory the diff touches, sample 2–3 existing, unchanged files in that same directory (siblings of the changed file, not the changed file). Read them to learn the local norms:

- **Response shape** — how handlers return success/error, status codes, envelope
- **Error handling** — try/catch vs middleware, throw vs return, logging pattern
- **Model / data access** — query style, atomic ops, soft-delete filter, session usage
- **Import style** — ESM vs CJS, ordering, alias vs relative
- **Naming** — casing, prefixes, how the domain names things

State the baseline in **3–5 bullets** before reviewing. This is what you judge against.

## Step 2 — Get the diff

`git diff HEAD` + `git diff --cached` + `git status --short`. Read the surrounding code around each hunk — most bugs live in the caller, not the diff.

## Step 3 — The finding gate

Every candidate finding MUST answer all three, or it is not a finding:

1. **Actually wrong, or just different?** Different-but-valid is not a finding.
2. **Does it violate an established convention?** Name the convention from Step 1's baseline or Step 0's docs.
3. **Can you cite existing code that does it right?** `file:line` of a sibling doing it correctly. **No cite → it's an opinion, not a finding. Drop it or demote to NOTE.**

Also:
- **Don't duplicate the linter.** Formatting, unused imports, quote style — the linter owns those. Skip them.
- **CLEAN is a valid verdict.** An empty findings list with a solid Verified OK list is a real, useful result. Never manufacture findings to look thorough.

Still hunt the substance — atomicity on money, unhandled rejections, missing auth/ownership, PII in logs, non-idempotent writes — but each must clear the gate above.

### Test quality gate
If the change adds or modifies tests, apply the authoring gate:
1. What observable behavior or invariant does this test protect?
2. What credible regression makes it fail?
3. Why doesn't existing coverage already catch that failure?
4. Does it need a production seam (export, flag, wrapper) that no production caller uses? If yes, move the test to the real boundary.

Flag tests that:
- Re-assert source text, export lists, or string literals from the implementation
- Pass because a mock/stub accepts any method (verify the mock constrains correctly)
- Break under behavior-preserving refactoring (testing implementation, not behavior)
- Exist only to exercise a test-only export or wrapper
- Are bug regression tests that never demonstrably failed on pre-fix code

### Mechanical scan (Copilot-gap coverage)
For each changed function/block:
- Null/undefined: can any new variable be null? Is it handled before use?
- Async errors: every new async call (await, .then, fetch, DB query) — has error handling?
- Dead branches: any conditional where one branch is unreachable?
- Off-by-one: array access, loop bounds, slice/substring — correct at edges?
- Assignment vs comparison: any `=` where `===` was intended?

### Structural simplification (code-judo check)
For the change as a whole, ask:
- Is there a restructuring that would delete a whole layer of complexity rather than rearrange it?
- Can conditionals, helpers, or modes disappear entirely with a different framing?
- Is any new abstraction actually earning its keep, or is it a thin wrapper adding indirection?
- Did the change push a file past 1000 lines? If so, flag as CRITICAL — decompose first.

Don't settle for "this could be cleaner." Look for the move that makes the code feel inevitable.

Structural and size findings (file too big, simpler framing, spaghetti growth) don't require a cite — they're measured, not convention-compared.

## Output

First line: `Verdict: <BLOCK|CONCERNS|CLEAN> — <single most important fix>`

Then:
- **Convention baseline** — the 3–5 bullets from Step 1
- **Findings**, each with: `file:line` · convention violated · cite of existing code doing it right (`file:line`) · severity (CRITICAL / WARNING / NOTE) · concrete fix
- **Verified OK** — what you checked and cleared (always present, especially on CLEAN)

Verdict rules: any CRITICAL → BLOCK · any WARNING → CONCERNS · only NOTEs or nothing → CLEAN.

Save to `.claude/reviews/self-YYYY-MM-DD-<slug>.md`. Never to `docs/`. Review only — do not fix.

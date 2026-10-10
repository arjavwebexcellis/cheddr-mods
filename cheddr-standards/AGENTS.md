# Cheddr Engineering Standards

Standards that apply regardless of which AI coding agent you use.

## Before starting work

Classify the request. Act accordingly.

- **Question?** Read the files, answer. No ceremony.
- **Planning/design?** Interview first — ask focused questions until requirements are tight.
- **Code review?** Convention baseline first. Sample existing files in the same directory. Every finding must cite existing code that does it right. No cite = opinion.
- **Self-review?** Same as above, but against your own changes.
- **Bug?** Reproduce → rank hypotheses → instrument → fix → regression test. Don't guess-and-check.
- **Code change?** Ask: does this need to exist? Can I reuse something? Stdlib? One line? Only then: the minimum that works. After the change: verify (tests, lint, type-check). Human commits.
- **Investigation?** Use a cheaper/faster model or sub-agent for scanning. Don't burn expensive context reading files.

## Code discipline

- Climb the laziness ladder before writing: does this need to exist → reuse → stdlib → native platform → installed dep → one line → minimum that works.
- Never cut validation, security, or accessibility to save lines.
- Verification loop: plan → change → verify → ready. Human decides when to commit.
- One logical change per loop. Don't batch features.

## Review standards

- Read CLAUDE.md, AGENTS.md, and MEMORY.md in the project before any review.
- Sample 2-3 existing files in the same directory to establish convention baseline.
- Every finding must cite existing code (file:line) that does it the right way. No cite = opinion, not a finding.
- Structural findings (file >1000 lines, spaghetti growth) don't need a cite — they're measured.
- Test quality gate: what behavior does this test protect? What regression makes it fail? Does it need a test-only production seam?
- Mechanical scan: null paths, async error handling, dead branches, off-by-one.
- Code-judo check: is there a restructuring that deletes complexity rather than rearranging it?

## Test authoring gate

Before adding any test, answer:
1. What observable behavior does it protect?
2. What credible regression makes it fail?
3. Why doesn't existing coverage already catch it?
4. Does it need a test-only production seam?

Flag tests that: re-assert source text, pass because mocks accept anything, break on behavior-preserving refactoring, exist only for test-only exports.

## PR review output

Every finding has: file:line | issue | convention violated (cite) | impact | severity | fix.
Severity: CRITICAL (blocks) | WARNING (should fix) | NOTE (author's call).
APPROVE means merge as-is. "Approve with changes" = REQUEST CHANGES.
Reviews are local only. Never post to GitHub automatically.

## Rules

- Lead with the answer. Context after.
- Match response length to the question.
- When in doubt, do it rather than ask.
- No "I hope this helps." No over-apologizing.
- Undercover: no AI attribution in commits unless asked.

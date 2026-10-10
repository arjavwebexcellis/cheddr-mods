# Stack Checklists

Read only the section matching the stack detected in Step 1.

## Backend

**Correctness:**
- Does the logic match the PR description's intent?
- Edge cases: null/undefined inputs, empty arrays, missing fields
- Error handling: are errors caught, logged, and returned with correct status codes?
- Database: are queries efficient? Missing indexes? N+1 patterns?

**Security:**
- Auth: does every new endpoint have proper auth middleware?
- Input validation: is user input validated before use?
- PII: any sensitive data in logs, error messages, or response bodies?
- SQL/NoSQL injection: parameterized queries?
- Rate limiting on sensitive endpoints?

**Concurrency & Data Integrity:**
- Race conditions on shared state?
- Transaction boundaries correct? (especially for money/balance operations)
- Idempotency on mutation endpoints?

**Performance:**
- Unnecessary database calls in loops?
- Missing pagination on list endpoints?
- Large payloads without streaming?

**Testing:**
- Are there tests for the new code? If not, flag it.
- Do existing tests still cover the changed behavior?

## Frontend

**Correctness:**
- Does the UI match the intended behavior from the PR description?
- State management: are updates handled correctly? Race conditions on async state?
- Edge cases: empty states, loading states, error states handled?

**UX:**
- Accessibility: proper aria labels, keyboard navigation, screen reader support?
- Responsive: does it work on mobile/tablet?
- Loading/error feedback: does the user know what's happening?

**Performance:**
- Unnecessary re-renders? (check useEffect deps, memo usage)
- Large bundle impact? New dependencies justified?
- Images/assets optimized?

**Security:**
- XSS: user input rendered without sanitization?
- Sensitive data in localStorage/sessionStorage?
- API keys or tokens exposed in client code?

**Testing:**
- Component tests for new UI?
- Integration tests for user flows?

## Infra/Config

- Breaking changes to env vars?
- CI pipeline changes tested?
- Docker changes: layer order optimized? Security scan?
- Dependency updates: changelog checked for breaking changes?

## All stacks (cross-cutting)

- **Breaking changes:** does this PR break any existing API contract, component interface, or database schema?
- **Naming:** are new functions/variables/files named consistently with the codebase?
- **Documentation:** if behavior changes, are docs/README/comments updated?
- **Revert safety:** can this be rolled back cleanly? Migrations one-way?

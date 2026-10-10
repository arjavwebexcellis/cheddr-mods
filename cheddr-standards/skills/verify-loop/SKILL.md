---
name: verify-loop
description: Verification loop for code changes. Write → test → lint → fix → repeat until clean. Use this for ANY code change, not just big ones.
---

# Verification Loop

## Step 0: Stack Detect (run once per session, not per loop)

Before the first loop iteration, answer these questions and cache the answers:

1. **Language:** JS or TS? → determines if 3a (type-check) applies
2. **Build step?** Does `npm run build` exist in package.json? → determines if 3d applies
3. **Test wiring:** What does the test runner cover? Check jest config (roots, testPathIgnorePatterns, modulePathIgnorePatterns). If services/ are excluded and only common/ is tested, know that before assuming `npm test` covers your change.
4. **DB reachable?** Can you connect to a local Mongo? If not, smoke tests are structural only (explain() on pipeline shape, not execution). State this explicitly — "structurally verified, not executed" is a valid outcome, not a skip.
5. **Long commands?** If the project uses tm-run or similar wrappers, use them instead of raw npm test/npm run build to avoid flooding context.

Mark inapplicable verification steps as **N/A — [reason]** rather than silently skipping them. A skipped step with no label reads as a pass. An explicit N/A reads as an acknowledged gap.

## The Loop

1. **PLAN** — state what you're changing and why (one line)
2. **CHANGE** — smallest possible change
3. **VERIFY** — run ALL verification steps below
4. **PASS?** — no → 5. FIX, then back to 3. yes → 6
5. **FIX**
6. **READY** — verified, ready for the human's commit

## Verification Steps (Step 3)

### 3a. Type check
- If TS project (from Step 0): `npx tsc --noEmit` (Flow: `npx flow`)
- N/A for plain JS.

### 3b. Lint
- Run the project's linter: `npm run lint` or `npx eslint <changed-files>`
- If no linter configured, skip but note it as a gap

### 3c. Tests
- Run tests related to the changed code: `npm test -- --grep <relevant-pattern>` or the project's test command
- If no tests exist for this code, write at least one test for the happy path before continuing

### 3d. Build
- If build step exists (from Step 0): `npm run build`
- N/A for backend-only with no build.

### 3e. Smoke test
- **API change + DB reachable:** curl/script the endpoint, verify response shape
- **API change + no DB:** structural verification only — assert pipeline shape in a unit test, run explain() on the query plan. State: "structurally verified, DB not reachable locally"
- **DB/query change:** verify with explain("executionStats") if DB is reachable; otherwise verify index usage from the query plan shape
- **UI change:** screenshot or browser verify
- **None applicable:** state "N/A — [reason]" explicitly

### 3f. Spot-check OR confirm prior review
- **If /adversarial-review already ran on this change:** don't re-review. Instead, confirm each prior finding was either addressed or deliberately accepted (with reason).
- **If no prior review:** pick the single most dangerous line. Ask: "What input breaks this? What if this runs twice? What if the dependency fails?" Fix anything found.

## Cheddr-Specific Notes

- **Services aren't jest targets.** Only `common/` is covered by the default test runner (jest roots exclude services/). If your change is in a service, test the underlying common/ logic it calls.
- **After common/ changes:** re-run `localSetupForMac.sh` to rebuild shared modules.
- **No live DB/AWS locally:** smoke tests are structural only. State this, don't pretend it's a full verify.
- **Full suite:** use `tm-run` instead of raw `npm test` to avoid context flooding.
- **Read MEMORY.md** for project-specific test patterns before writing new tests.

## Deliberate Non-Changes

After the loop, list any changes you considered but deliberately did NOT make, with reasoning. Example: "Did not add _id secondary sort — would defeat the compound index on {marketId, status, settledAt}."

## Rules

1. **One logical change per loop.** Don't batch 3 features into one loop. If you're changing auth AND adding a field AND fixing a bug, that's 3 loops.
2. **Never skip step 3.** Even for "obvious" changes. The obvious ones are where bugs hide.
3. **If step 3 fails twice on the same issue,** stop and rethink the approach. Don't keep patching — the design might be wrong.
4. **Report what was verified, what was N/A and why, and any deliberate non-changes.** The human decides when to commit.
5. **For security-sensitive changes** (auth, payments, PII) without a prior review, run /adversarial-review after the loop. If adversarial-review already ran, just confirm findings were addressed — don't re-run.

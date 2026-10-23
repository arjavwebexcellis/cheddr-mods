---
name: analytics-check
description: Audit a diff or feature branch for missing analytics instrumentation. Checks Mixpanel, AppsFlyer, and Braze coverage against Cheddr's tracking plan.
disable-model-invocation: true
---

# Analytics Check

Find missing analytics in a diff or feature branch. Checks Mixpanel (engagement), AppsFlyer (attribution/revenue), and Braze (messaging triggers).

## Usage

```
/analytics-check              # Check staged/unstaged changes
/analytics-check --pr <number> # Check a PR's diff
```

## Step 0: Learn the tracking plan

Before checking, read:
- Frontend: `lib/analyticsEvents.ts` or equivalent — event names, properties, naming convention
- Frontend: any `MIXPANEL_EVENTS_LIST.md` or analytics docs
- Backend: `common/services/mixpanelService.js`, `common/services/appsFlyerEventService.js`, `common/services/brazeService.js`
- MEMORY.md for analytics-related feedback

## Step 1: Identify user-facing changes

For each changed file, classify:
- New screen/modal/bottom sheet? → needs screen_view event
- New CTA/button/tap target? → needs tap/press event
- New purchase/deposit/payment flow? → needs revenue event
- New user state change (signup, KYC, level up)? → needs attribute update
- Renamed/removed flow? → old events need deprecation

Skip: refactors with no behavior change, backend-only logic, test files, config changes.

## Step 2: Check each provider

### Mixpanel (engagement tracking)
What MUST have events:
- Every new screen/modal → `screen_name_view` or equivalent
- Every new user action → `feature_action_press` or equivalent
- Every new flow completion → `flow_name_complete`
- Every new error state shown to user → `flow_name_error`

What must NOT:
- No event per keystroke or scroll
- No PII in properties (email, phone, name — use IDs only)
- Event name must follow existing convention in analyticsEvents.ts

### AppsFlyer (attribution — revenue only)
What MUST have events:
- New purchase/deposit → `af_purchase` with revenue and currency
- New subscription → `af_subscribe`
- That's it. AppsFlyer is NOT for engagement.

What must NOT:
- No screen views, no tap events, no engagement tracking
- No duplicate of Mixpanel events

### Braze (messaging triggers)
What MUST have events:
- New state that should trigger a push/email/in-app → custom event
- New user attribute for segmentation → custom attribute
- Events must match campaign trigger names

What must NOT:
- No engagement tracking (that's Mixpanel)
- No revenue tracking (that's AppsFlyer)

## Step 3: Output

```
## Analytics Check

| # | File:Line | What changed | Missing event | Provider | Event name (suggested) | Properties |
|---|-----------|-------------|---------------|----------|----------------------|------------|

Summary: N user-facing changes found, M missing instrumentation.
```

If everything is covered: "All user-facing changes have analytics. No gaps found."

## Rules

1. Only flag genuinely user-facing changes. Backend logic without UI impact doesn't need frontend analytics.
2. Check the existing event naming convention before suggesting names. Cite an existing event as the pattern.
3. One event per user action, not per code path. If three code paths lead to the same modal, one event covers it.
4. AppsFlyer is revenue ONLY. Never suggest engagement events for AppsFlyer.
5. If unsure whether something needs tracking, flag it as a question, not a finding.

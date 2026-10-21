---
name: lean-audit
description: Audit a diff or codebase for over-engineering. Finds unnecessary abstractions, stdlib wrappers, duplicate deps, and code that shouldn't exist. Returns a delete-list.
disable-model-invocation: true
---

# Lean Audit

Scan the diff (or full codebase with `--full`) for code that shouldn't exist. Returns a prioritized delete-list.

## Usage
```
/lean-audit              # Audit staged/unstaged changes
/lean-audit --full       # Audit entire codebase
/lean-audit --file path  # Audit specific file
```

## The Ladder

For every function, class, module, or dependency in scope, climb:

1. **Does this need to exist?** Could the caller do it inline? Is it a wrapper around a single call?
2. **Already in the codebase?** Grep before adding. Duplicate helpers are the #1 bloat source.
3. **Stdlib/runtime does it?** Buffer, URL, crypto, path, fs, util — don't wrap them.
4. **Native platform feature?** Don't install a dep for what the platform gives you.
5. **Installed dep already does it?** Don't add a second one for what an existing dep covers.
6. **Can it be one line?** Then it should be one line. Not a file.

## What to flag

- Wrapper functions around stdlib/native APIs (cite the stdlib method that replaces it)
- New dependencies where an installed dep or stdlib already covers it
- Multi-file additions (new module + index + types + tests) for what could be a 5-line helper
- Abstractions with one caller and one implementation (the abstraction is overhead)
- Files over 1000 lines (decompose first)
- Thin pass-through layers that add indirection without simplifying the API
- Generic "utility" modules that encode simple assumptions behind indirection
- Code that exists "for the future" but has no caller today (YAGNI)

## What NOT to flag

- Validation, error handling, security, accessibility — never on the chopping block
- Abstractions with multiple callers or multiple implementations — they earn their keep
- Test helpers that make tests readable — test clarity matters
- Configuration that changes per environment — that's not over-engineering

## Output

```
## Lean Audit — [scope]

Findings: N items, estimated deletable: ~X lines

| # | File:Line | What | Why it's unnecessary | Replace with | Lines saved |
|---|-----------|------|---------------------|-------------|-------------|

Total estimated savings: X lines, Y files removable
```

Keep it short. No prose. The table IS the deliverable.

## Rules

1. Every flag must say what replaces it. "Delete this" without "use X instead" is useless.
2. Don't flag style. This is about existence, not formatting.
3. Lazy, not negligent. Security and validation stay.
4. If unsure whether something earns its keep, leave it. False positives waste the author's time.

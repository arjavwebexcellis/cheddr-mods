# cheddr-standards

Engineering standards for Cheddr: convention-aware reviews, verification loops, model-routed agents.

## Install

```bash
claude plugin marketplace add arjavwebexcellis/cheddr-mods
claude plugin install cheddr-standards@cheddr-mods
```

Update later with `claude plugin marketplace update cheddr-mods`.

## What's included

### Skills

| Skill | Use |
|---|---|
| `/adversarial-review` | Self-review your own diff before committing. Learns the codebase's conventions first; every finding cites existing code. Saves to `.claude/reviews/`. |
| `/pr-review <number>` | Review someone else's PR. Convention baseline, cited findings, round-based re-reviews. Local only — never posts to GitHub. Output: `.claude/reviews/pr-<number>/round-<N>.html`. |
| `/verify-loop` | Plan → change → verify (type-check, lint, tests, build, smoke) → ready. Inapplicable steps are marked N/A, never silently skipped. |

### Agents

| Agent | Model | Use |
|---|---|---|
| `investigator` | Haiku | Cheap read-only scanning: "where is X", "which files use Y". |
| `reviewer` | Sonnet (high effort) | General correctness/security/design review. |
| `review-quick` | Haiku | Fast pass on small changes. Escalates financial, aggregation and auth code to `review-deep`. |
| `review-deep` | Sonnet | Complex, security-sensitive or financial changes. |

`investigator` and `reviewer` also list MCP tools from the `claude-mem` and `context-mode` plugins. Install those plugins for the full toolset.

## Setup

Copy the CLAUDE.md template into your project root and fill in the project name:

```bash
cp ~/.claude/plugins/marketplaces/cheddr-mods/cheddr-standards/CLAUDE.md.template ./CLAUDE.md
```

It routes each request type (question, design, review, bug, code change, investigation) to the right skill, agent and model.

# cheddr-standards

Engineering standards for Cheddr: convention-aware reviews, verification loops, model-routed agents.

## Agent Support

These standards work with any AI coding agent:

| Agent | How it loads |
|---|---|
| Claude Code | Plugin install + AGENTS.md |
| Codex | AGENTS.md auto-loaded |
| Cursor | `.cursor/rules/cheddr-standards.mdc` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Windsurf | `.windsurf/rules/` |
| Cline | `.clinerules/` |
| Kiro | `.kiro/steering/` |
| Amp (Sourcegraph) | AGENTS.md auto-loaded |
| Jules (Google) | AGENTS.md auto-loaded |
| CodeWhale | AGENTS.md auto-loaded |
| Swival | AGENTS.md auto-loaded |

**Minimal setup (any agent):** Copy `AGENTS.md` to your project root. Done.

For Cursor, Copilot, Windsurf, Cline or Kiro, also copy that agent's adapter folder (e.g. `.cursor/`) to your project root — each adapter points at the root `AGENTS.md`.

**Full setup (Claude Code):**
```bash
claude plugin marketplace add arjavwebexcellis/cheddr-mods
claude plugin install cheddr-standards@cheddr-mods
cp CLAUDE.md.template ./CLAUDE.md
```

## Quick setup (recommended)

Run the setup script to install all recommended plugins at once:

```bash
curl -sL https://raw.githubusercontent.com/arjavwebexcellis/cheddr-mods/main/cheddr-standards/setup.sh | bash
```

Or clone and run locally:
```bash
git clone git@github.com:arjavwebexcellis/cheddr-mods.git
cd cheddr-mods/cheddr-standards
bash setup.sh
```

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
| `/pr-review <number>` | Review someone else's PR. Convention baseline, cited findings, round-based re-reviews. Local only — never posts to GitHub. Output: `.claude/reviews/pr-<number>/round-<N>.md` (+ `.html` with answer-me-with-html). |
| `/verify-loop` | Plan → change → verify (type-check, lint, tests, build, smoke) → ready. Inapplicable steps are marked N/A, never silently skipped. |
| `/lean-audit` | Find code that shouldn't exist. Returns a delete-list. |

### Agents

| Agent | Model | Use |
|---|---|---|
| `investigator` | Haiku | Cheap read-only scanning: "where is X", "which files use Y". |
| `reviewer` | Sonnet (high effort) | General correctness/security/design review. |
| `review-quick` | Haiku | Fast pass on small changes. Escalates financial, aggregation and auth code to `review-deep`. |
| `review-deep` | Sonnet | Complex, security-sensitive or financial changes. |

`investigator` and `reviewer` also list MCP tools from the `claude-mem` and `context-mode` plugins. Install those plugins for the full toolset.

### Optional: HTML review output

The review skills write markdown. With [answer-me-with-html](https://github.com/QingYunA/answer-me-with-html) installed (needs Node.js 20+), they also render each review to an HTML page next to the markdown. Without it, you get markdown only.

```bash
claude plugin marketplace add QingYunA/answer-me-with-html
claude plugin install answer-me-with-html@answer-me-with-html
```

Note: answer-me-with-html also offers HTML pages for other answers (explanations, comparisons) on its own. Turn off auto-open with `/answer-me-with-html:config open off`.

## Setup

Copy the CLAUDE.md template into your project root and fill in the project name:

```bash
cp ~/.claude/plugins/marketplaces/cheddr-mods/cheddr-standards/CLAUDE.md.template ./CLAUDE.md
```

It routes each request type (question, design, review, bug, code change, investigation) to the right skill, agent and model.

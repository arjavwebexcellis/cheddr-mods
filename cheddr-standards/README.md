# Cheddr Engineering Standards

Skills, agents, and conventions for writing better code across the Cheddr platform. Works with Claude Code, Codex, Cursor, Copilot, and 10+ other AI coding agents.

## Quick setup

One command installs everything:

```bash
curl -sL https://raw.githubusercontent.com/arjavwebexcellis/cheddr-mods/main/cheddr-standards/setup.sh | bash
```

Or step by step:

```bash
claude plugin marketplace add arjavwebexcellis/cheddr-mods
claude plugin install cheddr-standards@cheddr-mods
```

Then copy the config template to your project:

```bash
cp ~/.claude/plugins/marketplaces/cheddr-mods/cheddr-standards/CLAUDE.md.template ./CLAUDE.md
```

## What you get

### Skills

| Skill | What it does |
|---|---|
| `/adversarial-review` | Convention-aware self-review. Samples sibling files, establishes baseline, cites existing code for every finding. Includes Ponytail over-engineering check and test quality gate. |
| `/pr-review <number>` | PR review for other devs' code. Auto-detects frontend/backend. Round-based with re-review mode. HTML output via answer-me-with-html. LOCAL ONLY — never posts to GitHub. |
| `/verify-loop` | Verification loop for code changes. Plan → change → verify (tests, lint, type-check) → ready. Stack-aware — detects JS/TS, build steps, test wiring, DB reachability. |
| `/lean-audit` | Find code that shouldn't exist. Climbs the laziness ladder: does it need to exist → reuse → stdlib → one line. Returns a prioritized delete-list. |
| `/security-check` | Security audit on changes or full codebase. Routes to relevant attack classes. Wraps Cloudflare's security-audit skill. Runs automatically on prod PR reviews. |
| `/analytics-check` | Audit changes for missing Mixpanel, AppsFlyer, and Braze instrumentation. Checks naming conventions against existing tracking plan. |

### Agents

| Agent | Model | Use for |
|---|---|---|
| `investigator` | Haiku | Cheap codebase scanning. Read-only. Use for "find X" and "how does Y work". |
| `reviewer` | Sonnet | Deep code review with judgment calls. |
| `review-quick` | Haiku | Fast PR triage. Cannot clear financial/auth code — escalates to review-deep. |
| `review-deep` | Sonnet | Full convention-aware review for complex/security-sensitive changes. |

### Recommended plugins (installed by setup.sh)

| Plugin | What it does |
|---|---|
| claude-mem | Session memory — remembers patterns, feedback, and project context across sessions |
| ponytail | Write less code. Laziness ladder on every code generation. |
| caveman | Terse output. Shrinks what the agent says. |
| mattpocock skills | `/diagnosing-bugs`, `/grill-me`, `/tdd`, and 35+ engineering skills |
| context7 | Live, version-specific library documentation |
| context-mode | Context management and optimization |
| answer-me-with-html | Rich HTML output for complex answers and reports |

## Agent support

These standards work with any AI coding agent. Copy `AGENTS.md` to your project root.

| Agent | How it loads |
|---|---|
| Claude Code | Plugin install (above) + AGENTS.md |
| Codex | AGENTS.md auto-loaded |
| Cursor | `.cursor/rules/cheddr-standards.mdc` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Windsurf | `.windsurf/rules/cheddr-standards.md` |
| Cline | `.clinerules/cheddr-standards.md` |
| Kiro | `.kiro/steering/cheddr-standards.md` |
| Amp, Jules, CodeWhale, Swival | AGENTS.md auto-loaded |

For non-Claude agents, copy the adapter file for your agent from this repo into your project.

## What the standards enforce

- **Convention-aware reviews** — every finding must cite existing code (file:line) that does it right. No cite = opinion, not a finding.
- **Laziness ladder** — does this need to exist? Already in codebase? Stdlib? Installed dep? One line? Only then: the minimum that works.
- **Verification loop** — plan → change → verify → ready. Human decides when to commit.
- **Test quality gate** — what behavior does this test protect? What regression makes it fail?
- **Over-engineering check** — don't add deps for what stdlib does, don't wrap native APIs, don't create abstractions with one caller.
- **Mechanical scan** — null paths, async error handling, dead branches, off-by-one.
- **Structural quality** — files over 1000 lines are flagged. Spaghetti growth blocked.
- **Model routing** — Opus/Fable for planning, Sonnet for implementation/review, Haiku for scanning.
- **No AI attribution** — no `Co-Authored-By: Claude` trailers or "Generated with Claude Code" lines in commits or PRs. Enforced below.

## No AI co-author trailers

Three layers, so one missed setup step doesn't leak a trailer:

1. **Claude Code hook (automatic).** Installing the plugin adds a `PreToolUse` hook (`hooks/block-ai-attribution.sh`) that blocks any `git commit` / `gh pr` command carrying a Claude/Anthropic trailer, in every repo.
2. **Claude Code settings.** `setup.sh` sets `"attribution": {"commit": "", "pr": ""}` in `~/.claude/settings.json` so Claude stops adding the trailer at all. Not using the script? Add that key yourself.
3. **Git hooks (catches Cursor, Copilot, manual commits).** `git-hooks/commit-msg` rejects the message; `git-hooks/pre-push` rejects any not-yet-pushed commit that has one (already-pushed history never blocks). The app repos use husky, which overrides a global `core.hooksPath`, so the hooks are committed per repo:

   ```bash
   cp ~/.claude/plugins/marketplaces/cheddr-mods/cheddr-standards/git-hooks/{commit-msg,pre-push} .husky/
   ```

   For a repo without husky: `git config core.hooksPath ~/.claude/plugins/marketplaces/cheddr-mods/cheddr-standards/git-hooks`.

Blocked commit? Reword it: `git commit --amend` for the last one, `git rebase -i <base>` for older ones.

## Optional: HTML review output

Install answer-me-with-html for polished HTML reports from PR reviews:

```bash
claude plugin marketplace add QingYunA/answer-me-with-html
claude plugin install answer-me-with-html@answer-me-with-html
```

Requires Node.js 20+.

## File structure

```
cheddr-standards/
├── AGENTS.md                           # Universal — works with 11+ agents
├── CLAUDE.md.template                  # Claude Code project template
├── setup.sh                            # One-command team setup
├── .cursor/rules/cheddr-standards.mdc  # Cursor adapter
├── .github/copilot-instructions.md     # GitHub Copilot adapter
├── .windsurf/rules/                    # Windsurf adapter
├── .clinerules/                        # Cline adapter
├── .kiro/steering/                     # Kiro adapter
├── skills/
│   ├── adversarial-review/SKILL.md
│   ├── pr-review/SKILL.md
│   ├── verify-loop/SKILL.md
│   ├── lean-audit/SKILL.md
│   ├── security-check/SKILL.md
│   └── analytics-check/SKILL.md
├── agents/
│   ├── investigator.md
│   ├── reviewer.md
│   ├── review-quick.md
│   └── review-deep.md
├── hooks/                              # Claude Code hook: blocks AI co-author trailers
├── git-hooks/                          # commit-msg + pre-push: same rule for any tool
└── .claude-plugin/plugin.json
```

## License

MIT

# Cheddr Mods

Plugins, skills, and engineering standards for the Cheddr platform. Built for AI-assisted development across Claude Code, Codex, Cursor, Copilot, and more.

## What's inside

### cheddr-standards

A complete engineering toolkit — convention-aware code reviews, verification loops, over-engineering audits, and model-routed agents. One install gives your team consistent code quality standards enforced by AI.

**Highlights:**
- `/adversarial-review` — self-review that learns your codebase patterns and cites existing code
- `/pr-review` — PR review with HTML reports, round-based re-review, and convention baseline
- `/verify-loop` — plan → change → verify → ready (human commits)
- `/lean-audit` — find and delete code that shouldn't exist
- 4 model-routed agents: investigator (Haiku), reviewer (Sonnet), review-quick, review-deep
- Setup script that installs 8 recommended plugins in one command

[Full documentation →](cheddr-standards/README.md)

## Quick start

### One-command setup (installs everything)

```bash
curl -sL https://raw.githubusercontent.com/arjavwebexcellis/cheddr-mods/main/cheddr-standards/setup.sh | bash
```

### Manual install

```bash
# Add the marketplace
claude plugin marketplace add arjavwebexcellis/cheddr-mods

# Install the standards plugin
claude plugin install cheddr-standards@cheddr-mods

# Copy config template to your project
cp ~/.claude/plugins/marketplaces/cheddr-mods/cheddr-standards/CLAUDE.md.template ./CLAUDE.md
```

### Any AI agent (no plugin needed)

Copy `AGENTS.md` from `cheddr-standards/` to your project root. Works with Claude Code, Codex, Cursor, Copilot, Amp, Jules, and 5+ more agents — they read it automatically.

## What the standards enforce

| Principle | What it means |
|---|---|
| Convention-aware reviews | Every finding cites existing code that does it right |
| Laziness ladder | Does this need to exist? Reuse? Stdlib? One line? |
| Verification loop | Plan → change → verify → ready. Human commits. |
| Test quality gate | What behavior does this test protect? |
| Over-engineering check | Don't add deps for what stdlib does |
| Mechanical scan | Null paths, async errors, dead branches |
| Model routing | Opus for design, Sonnet for implementation, Haiku for scanning |

## Agent compatibility

| Agent | Setup |
|---|---|
| Claude Code | `claude plugin install cheddr-standards@cheddr-mods` |
| Codex | Copy `AGENTS.md` to project root |
| Cursor | Copy `.cursor/rules/cheddr-standards.mdc` |
| GitHub Copilot | Copy `.github/copilot-instructions.md` |
| Windsurf | Copy `.windsurf/rules/cheddr-standards.md` |
| Cline | Copy `.clinerules/cheddr-standards.md` |
| Kiro | Copy `.kiro/steering/cheddr-standards.md` |
| Amp, Jules, CodeWhale, Swival | Copy `AGENTS.md` to project root |

## Recommended plugins

The setup script installs these alongside cheddr-standards:

| Plugin | Purpose |
|---|---|
| [claude-mem](https://github.com/thedotmack/claude-mem) | Session memory across conversations |
| [ponytail](https://github.com/DietrichGebert/ponytail) | Write less, smarter code |
| [caveman](https://github.com/JuliusBrussee/caveman) | Terse, focused output |
| [mattpocock skills](https://github.com/mattpocock/skills) | Debugging, grilling, TDD, and 35+ skills |
| [context7](https://github.com/upstash/context7) | Live library documentation |
| [context-mode](https://github.com/mksglu/context-mode) | Context management |
| [answer-me-with-html](https://github.com/QingYunA/answer-me-with-html) | Rich HTML output for reviews and explanations |

## Contributing

This repo powers the Cheddr engineering workflow. To add or update a skill:

1. Edit the skill in `cheddr-standards/skills/<skill-name>/SKILL.md`
2. Test it locally with `claude --plugin-dir cheddr-standards`
3. Push to `main`
4. Team members update with: `claude plugin marketplace update cheddr-mods`

## License

MIT

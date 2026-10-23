#!/bin/bash
set -euo pipefail

echo "=== Cheddr Engineering Standards — Setup ==="
echo ""

# Check claude is installed
if ! command -v claude &> /dev/null; then
  echo "Error: Claude Code not found. Install from https://claude.ai/download"
  exit 1
fi

echo "Installing recommended plugins..."
echo ""

# Core — memory and context
echo "[1/7] claude-mem (session memory)..."
claude plugin marketplace add thedotmack/claude-mem 2>/dev/null || true
claude plugin install claude-mem@thedotmack 2>/dev/null && echo "  ✓ installed" || echo "  ✓ already installed"

# Code discipline
echo "[2/7] ponytail (write less code)..."
claude plugin marketplace add DietrichGebert/ponytail 2>/dev/null || true
claude plugin install ponytail@ponytail 2>/dev/null && echo "  ✓ installed" || echo "  ✓ already installed"

echo "[3/7] caveman (terse output)..."
claude plugin marketplace add JuliusBrussee/caveman 2>/dev/null || true
claude plugin install caveman@caveman 2>/dev/null && echo "  ✓ installed" || echo "  ✓ already installed"

# Skills
echo "[4/7] mattpocock skills (debugging, grilling, TDD)..."
claude plugin marketplace add mattpocock/skills 2>/dev/null || true
claude plugin install mattpocock-skills@mattpocock 2>/dev/null && echo "  ✓ installed" || echo "  ✓ already installed"

# Context
echo "[5/7] context7 (live library docs)..."
claude plugin install context7@claude-plugins-official 2>/dev/null && echo "  ✓ installed" || echo "  ✓ already installed"

echo "[6/7] context-mode (context management)..."
claude plugin marketplace add mksglu/context-mode 2>/dev/null || true
claude plugin install context-mode@context-mode 2>/dev/null && echo "  ✓ installed" || echo "  ✓ already installed"

# HTML output
echo "[7/7] answer-me-with-html (rich HTML answers)..."
claude plugin marketplace add QingYunA/answer-me-with-html 2>/dev/null || true
claude plugin install answer-me-with-html@answer-me-with-html 2>/dev/null && echo "  ✓ installed" || echo "  ✓ already installed"

echo ""

# Cheddr standards
echo "Installing Cheddr engineering standards..."
claude plugin marketplace add arjavwebexcellis/cheddr-mods 2>/dev/null || true
claude plugin install cheddr-standards@cheddr-mods 2>/dev/null && echo "  ✓ installed" || echo "  ✓ already installed"

echo ""

# Environment
echo "Setting recommended defaults..."
# Set default model to Sonnet (cost-effective for most tasks)
claude config set model sonnet 2>/dev/null || sed -i '' 's/"model": "[^"]*"/"model": "sonnet"/' ~/.claude/settings.json 2>/dev/null || true

# Set claude-mem to share memory across worktrees
grep -q "CLAUDE_MEM_PROJECT_NAME_SOURCE" ~/.zshrc 2>/dev/null || {
  echo 'export CLAUDE_MEM_PROJECT_NAME_SOURCE=git-remote' >> ~/.zshrc
  echo "  ✓ Added git-remote memory sharing to .zshrc"
}

echo ""
echo "=== Setup complete ==="
echo ""
echo "What you now have:"
echo "  /adversarial-review  — convention-aware self-review"
echo "  /pr-review <number>  — PR review with HTML output"
echo "  /verify-loop         — plan → change → verify → ready"
echo "  /lean-audit          — find code that shouldn't exist"
# analytics-check ships with cheddr-standards — no separate install needed
echo "  /analytics-check     — find missing Mixpanel/AppsFlyer/Braze events"
echo "  /diagnosing-bugs     — structured debugging"
echo "  /grill-me            — interview before building"
echo ""
echo "Next: copy CLAUDE.md.template to your project root as CLAUDE.md"
echo "  cp ~/.claude/plugins/marketplaces/cheddr-mods/cheddr-standards/CLAUDE.md.template ./CLAUDE.md"
echo ""
echo "For Opus on design work: claude --model opus"
echo "Default model is Sonnet (best cost/quality for implementation)"

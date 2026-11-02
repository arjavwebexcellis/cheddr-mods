#!/usr/bin/env python3
# PreToolUse(Bash): block git commits / PRs that carry Claude/Anthropic attribution.
# Reads the tool call JSON on stdin; exit 2 blocks the call and shows stderr to the model.
import json
import re
import sys

# git [global opts, quoted -C paths included] commit|merge|tag, or gh pr create|edit|merge
MUTATING = re.compile(
    r"""\bgit\b(?:\s+(?:-C\s+(?:"[^"]*"|'[^']*'|\S+)|-c\s+\S+|--?[\w-]+(?:=\S+)?))*\s+(?:commit|merge|tag)\b"""
    r"""|\bgh\s+pr\s+(?:create|edit|merge)\b"""
)
ATTRIBUTION = re.compile(
    r"co-authored-by:[^\n]*(?:claude|anthropic)|noreply@anthropic\.com|generated with \[?claude code",
    re.IGNORECASE,
)

try:
    command = json.load(sys.stdin)["tool_input"]["command"]
except (ValueError, KeyError, TypeError):
    sys.exit(0)

if isinstance(command, str) and MUTATING.search(command) and ATTRIBUTION.search(command):
    print("Blocked by cheddr-standards: remove the Claude/Anthropic Co-Authored-By trailer and any "
          "'Generated with Claude Code' line, then retry.", file=sys.stderr)
    sys.exit(2)

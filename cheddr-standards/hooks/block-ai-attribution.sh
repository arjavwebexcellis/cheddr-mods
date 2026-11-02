#!/bin/sh
# PreToolUse(Bash): block git commits / PRs that carry Claude/Anthropic attribution.
# Input is the tool call as JSON on stdin; exit 2 blocks the call and shows stderr to the model.
input=$(cat)
printf '%s' "$input" | grep -Eq '(git|gh)[^|;&]*(commit|merge|tag|pr )' || exit 0
if printf '%s' "$input" | grep -Eiq 'co-authored-by:[^\\"]*(claude|anthropic)|noreply@anthropic\.com|generated with \[claude code\]'; then
  echo "Blocked by cheddr-standards: remove the Claude/Anthropic Co-Authored-By trailer and any 'Generated with Claude Code' line, then retry." >&2
  exit 2
fi
exit 0

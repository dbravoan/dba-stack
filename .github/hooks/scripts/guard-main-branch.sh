#!/bin/bash
# Warns if the agent attempts to interact with the main branch
# Receives JSON on stdin with tool call details

set -e

INPUT=$(cat)

# Check if the command contains references to main branch operations
COMMAND=$(echo "$INPUT" | grep -oP '"command"\s*:\s*"[^"]*"' | head -1 | sed 's/"command"\s*:\s*"//;s/"$//' 2>/dev/null || true)

if echo "$COMMAND" | grep -qiE '(checkout\s+main|push.*main|merge.*main|branch.*main)'; then
    cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "WARNING: This command targets the 'main' branch. Per project policy, only the Human Supervisor can merge to main. Feature branches should target 'dev'."
  }
}
EOF
    exit 0
fi

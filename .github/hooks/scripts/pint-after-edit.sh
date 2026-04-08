#!/bin/bash
# Runs Pint auto-fix on files that were just edited by the agent
# Receives JSON on stdin with tool call details

set -e

# Read stdin for PostToolUse context
INPUT=$(cat)

# Extract the file path from the tool call if available
FILE=$(echo "$INPUT" | grep -oP '"filePath"\s*:\s*"[^"]*"' | head -1 | sed 's/"filePath"\s*:\s*"//;s/"$//' 2>/dev/null || true)

# Only run pint on PHP files
if [[ "$FILE" == *.php ]] && [[ -f "vendor/bin/pint" ]]; then
    vendor/bin/pint "$FILE" --quiet 2>/dev/null || true
fi

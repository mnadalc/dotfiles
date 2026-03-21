#!/usr/bin/env bash
# Block git commits that contain Co-Authored-By trailers from AI tools.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if echo "$COMMAND" | grep -qi 'git commit'; then
  if echo "$COMMAND" | grep -qi 'Co-Authored-By'; then
    echo "Blocked: commit contains Co-Authored-By. Remove it and try again." >&2
    exit 2
  fi
fi

exit 0

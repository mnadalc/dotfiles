#\!/bin/bash
set +H
INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.content // empty')
if echo "$PROMPT" | grep -q 'ralph-loop'; then
  if echo "$PROMPT" | grep -qv '\-\-max-iterations'; then
    echo '{"systemMessage":"WARNING: Ralph loop started without --max-iterations. This will run forever. Add --max-iterations N to set a limit."}'
  fi
fi

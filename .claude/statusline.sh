#!/bin/bash

input=$(cat)
MODEL=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
ORANGE='\033[38;5;208m'
RESET='\033[0m'

# Check if in git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    # Not in a git repo - show red message
    echo -e "${RED}Not in git repository${RESET} | ${ORANGE}${MODEL}${RESET}"
else
    # In a git repo - show normal status
    REPO=$(basename "$CURRENT_DIR")
    BRANCH=$(git branch --show-current 2>/dev/null)
    STAGED=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    UNSTAGED=$(git diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    NEW=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')

    echo -e "${CYAN}${REPO}${RESET} | ${GREEN}${BRANCH}${RESET} | staged: ${YELLOW}${STAGED}${RESET} | unstaged: ${YELLOW}${UNSTAGED}${RESET} | new: ${YELLOW}${NEW}${RESET} | ${ORANGE}${MODEL}${RESET}"
fi

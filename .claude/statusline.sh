#!/bin/bash

input=$(cat)
MODEL=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
USED_PCT=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
ORANGE='\033[38;5;208m'
RESET='\033[0m'
# GitHub dark theme colors (true color)
GH_GREEN='\033[38;2;63;185;80m'
GH_RED='\033[38;2;248;81;73m'
CTX_GREEN='\033[0;32m'

# Build compact context progress bar (10 chars wide)
build_progress_bar() {
    local pct="${1:-0}"
    local width=10
    local filled=$(( pct * width / 100 ))

    # Pick color based on usage
    if [ "$pct" -ge 85 ]; then
        local bar_color="$RED"
    elif [ "$pct" -ge 60 ]; then
        local bar_color="$YELLOW"
    else
        local bar_color="$CTX_GREEN"
    fi

    local bar=""
    local i=0
    while [ $i -lt $filled ]; do
        bar="${bar}█"
        i=$(( i + 1 ))
    done
    while [ $i -lt $width ]; do
        bar="${bar}░"
        i=$(( i + 1 ))
    done

    printf "%b%s%b %s%%" "$bar_color" "$bar" "$RESET" "$pct"
}

# Gather git info
IN_GIT_REPO=0
BRANCH=""
STAGED=0
UNSTAGED=0
NEW=0
if git -C "$CURRENT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    IN_GIT_REPO=1
    BRANCH=$(git -C "$CURRENT_DIR" branch --show-current 2>/dev/null)
    STAGED=$(git -C "$CURRENT_DIR" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    UNSTAGED=$(git -C "$CURRENT_DIR" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
    NEW=$(git -C "$CURRENT_DIR" ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
fi

# Context bar
if [ -n "$USED_PCT" ]; then
    USED_INT=$(printf "%.0f" "$USED_PCT")
    BAR_OUTPUT=$(build_progress_bar "$USED_INT")
else
    BAR_OUTPUT=$(build_progress_bar 0)
fi

# Line 1: branch | +lines/-lines | context bar | model
LINE1=""
if [ "$IN_GIT_REPO" -eq 1 ] && [ -n "$BRANCH" ]; then
    LINE1=$(printf '\xee\xa0\xa2 %b%s%b' "$CTX_GREEN" "$BRANCH" "$RESET")
else
    LINE1=$(printf '⚠️  %bno repo%b' "$RED" "$RESET")
fi

LINE1="${LINE1} · "
LINE1="${LINE1}$(printf '%b+%s%b %b-%s%b' "$GH_GREEN" "$LINES_ADDED" "$RESET" "$GH_RED" "$LINES_REMOVED" "$RESET")"
LINE1="${LINE1} · 📊 ${BAR_OUTPUT}"
LINE1="${LINE1} · "
LINE1="${LINE1}$(printf '🤖 %b%s%b' "$ORANGE" "$MODEL" "$RESET")"

printf '%s\n' "$LINE1"

# Line 2: staged | unstaged | new
if [ "$IN_GIT_REPO" -eq 1 ]; then
    printf '✚ staged: %b%s%b | ~ unstaged: %b%s%b | ? new: %b%s%b\n' "$YELLOW" "$STAGED" "$RESET" "$YELLOW" "$UNSTAGED" "$RESET" "$YELLOW" "$NEW" "$RESET"
else
    printf '\n'
fi

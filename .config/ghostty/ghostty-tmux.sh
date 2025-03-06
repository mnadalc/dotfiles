#!/bin/bash

# Source shell profile and set PATH
source ~/.zshrc 2>/dev/null
export PATH="/opt/homebrew/bin:$PATH"

tmux new-session
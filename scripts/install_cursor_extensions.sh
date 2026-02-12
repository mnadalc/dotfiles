#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INPUT_FILE="${ROOT_DIR}/apps/cursor/extensions.txt"

if ! command -v cursor >/dev/null 2>&1; then
  echo "Error: cursor CLI is not installed or not in PATH."
  exit 1
fi

if [ ! -f "$INPUT_FILE" ]; then
  echo "Error: extension list not found at $INPUT_FILE"
  exit 1
fi

if [ ! -s "$INPUT_FILE" ]; then
  echo "Error: extension list is empty at $INPUT_FILE"
  exit 1
fi

installed=0
failed=0

while IFS= read -r extension; do
  # Skip empty lines and comments.
  [ -z "$extension" ] && continue
  [[ "$extension" =~ ^# ]] && continue

  if cursor --install-extension "$extension"; then
    installed=$((installed + 1))
  else
    failed=$((failed + 1))
    echo "Failed to install: $extension"
  fi
done <"$INPUT_FILE"

echo "Installed/updated extensions: $installed"
echo "Failed extensions: $failed"

if [ "$failed" -gt 0 ]; then
  exit 1
fi

#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_FILE="${ROOT_DIR}/apps/cursor/extensions.txt"

if ! command -v cursor >/dev/null 2>&1; then
  echo "Error: cursor CLI is not installed or not in PATH."
  exit 1
fi

mkdir -p "$(dirname "$OUTPUT_FILE")"
cursor --list-extensions --show-versions | sort >"$OUTPUT_FILE"

echo "Exported Cursor extensions to: $OUTPUT_FILE"
echo "Total extensions: $(wc -l <"$OUTPUT_FILE" | tr -d ' ')"

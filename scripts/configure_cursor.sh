#!/bin/bash

CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor/User"
DOTFILES_CURSOR_CONFIG="$HOME/.dotfiles/apps/cursor/settings.json"

cursor() {
  # Create Cursor config directory if it doesn't exist
  mkdir -p "$CURSOR_CONFIG_DIR"

  # Create symbolic link for settings.json
  echo "Creating symbolic link for Cursor settings..."
  ln -sf "$DOTFILES_CURSOR_CONFIG" "$CURSOR_CONFIG_DIR/settings.json"

  echo "✅ Cursor configuration completed" 
}

cursor
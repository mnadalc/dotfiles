#!/bin/bash

source './osx/utils.sh'

link_if_safe() {
  local source_path="$1"
  local target_path="$2"
  local label="$3"

  if [ -L "$target_path" ]; then
    rm "$target_path"
  elif [ -e "$target_path" ]; then
    print_error "$target_path already exists and is not a symlink. Skipping $label."
    return 1
  fi

  if execute "ln -s \"$source_path\" \"$target_path\""; then
    print_info "Symlinked $label to $target_path"
  fi
}

configure_claude_files() {
  local ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
  print_info "Configuring Claude Code files."

  if [ ! -d "$HOME/.claude" ]; then
    execute "mkdir -p \"$HOME/.claude\""
  fi

  for item in "$ROOT_DIR/.claude/"*; do
    [ ! -e "$item" ] && continue

    local item_name
    item_name=$(basename "$item")
    [ "$item_name" = "skills" ] && continue

    link_if_safe "$(realpath "$item")" "$HOME/.claude/$item_name" "$item_name"
  done
  unset item

  if [ -f "$HOME/.claude/statusline.sh" ]; then
    execute "chmod +x \"$HOME/.claude/statusline.sh\""
    print_info "Made statusline.sh executable"
  fi

  print_success "Configured Claude Code files."
}

install_claude_code() {
  if cmd_exists claude; then
    print_info "Claude Code CLI already installed ($(claude --version 2>/dev/null || echo 'unknown version'))"
    print_info "Native installer auto-updates in the background — skipping reinstall."
    return 0
  fi

  print_info "Installing Claude Code via native installer..."
  if curl -fsSL https://claude.ai/install.sh | bash; then
    # Ensure the binary is available in the current session
    export PATH="$HOME/.claude/bin:$PATH"
    print_success "Claude Code installed"
  else
    print_error "Claude Code native installer failed."
    return 1
  fi
}

install_claude_code
configure_claude_files

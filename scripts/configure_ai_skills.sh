#!/bin/bash

source './osx/utils.sh'

link_if_safe() {
  source_path="$1"
  target_path="$2"
  label="$3"

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

configure_ai_skills() {
  ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
  print_info "Configuring shared AI skills."

  if [ ! -d "$HOME/.claude" ]; then
    execute "mkdir -p \"$HOME/.claude\""
  fi

  if [ ! -d "$HOME/.agents" ]; then
    execute "mkdir -p \"$HOME/.agents\""
  fi

  link_if_safe "$(realpath "$ROOT_DIR/.ai/skills")" "$HOME/.claude/skills" ".claude/skills"
  link_if_safe "$(realpath "$ROOT_DIR/.ai/skills")" "$HOME/.agents/skills" ".agents/skills"

  print_success "Configured shared AI skills."
}

configure_ai_skills

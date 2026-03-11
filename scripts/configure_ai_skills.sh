#!/bin/bash

source './osx/utils.sh'

link_if_safe() {
  local source_path="$1"
  local target_path="$2"
  local label="$3"

  if [ -L "$target_path" ]; then
    rm "$target_path" || return 1
  elif [ -e "$target_path" ]; then
    print_error "$target_path already exists and is not a symlink. Skipping $label."
    return 1
  fi

  execute "ln -s \"$source_path\" \"$target_path\"" || return 1
  print_info "Symlinked $label to $target_path"
}

configure_ai_skills() {
  local ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
  local shared_skills_dir="$(realpath "$ROOT_DIR/.ai/skills")"
  print_info "Configuring shared AI skills."

  if [ ! -d "$HOME/.claude" ]; then
    execute "mkdir -p \"$HOME/.claude\"" || return 1
  fi

  if [ ! -d "$HOME/.agents" ]; then
    execute "mkdir -p \"$HOME/.agents\"" || return 1
  fi

  # Home-level skill links should point directly to the shared source of truth.
  link_if_safe "$shared_skills_dir" "$HOME/.claude/skills" "~/.claude/skills -> .ai/skills" || return 1
  link_if_safe "$shared_skills_dir" "$HOME/.agents/skills" "~/.agents/skills -> .ai/skills" || return 1

  print_success "Configured shared AI skills."
}

configure_ai_skills

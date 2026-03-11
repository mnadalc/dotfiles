#!/bin/bash

source './osx/utils.sh'

CONTEXT7_OAUTH_URL="https://mcp.context7.com/mcp/oauth"

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

context7_configured_for_oauth() {
  local config_path="$HOME/.claude.json"

  [ -f "$config_path" ] || return 1

  if cmd_exists jq; then
    jq -e --arg url "$CONTEXT7_OAUTH_URL" '.mcpServers.context7.type == "http" and .mcpServers.context7.url == $url' "$config_path" > /dev/null 2>&1
  else
    grep -q '"context7"' "$config_path" && grep -q "\"url\": \"$CONTEXT7_OAUTH_URL\"" "$config_path"
  fi
}

context7_config_exists() {
  local config_path="$HOME/.claude.json"

  [ -f "$config_path" ] || return 1

  if cmd_exists jq; then
    jq -e '.mcpServers.context7 != null' "$config_path" > /dev/null 2>&1
  else
    grep -q '"context7"' "$config_path"
  fi
}

configure_mcp() {
  local had_error=0
  print_info "Configuring MCP servers for Claude Code..."

  if ! cmd_exists claude; then
    print_info "Claude CLI not found. Skipping MCP configuration."
    return 0
  fi

  if context7_configured_for_oauth; then
    print_info "Context7 MCP server already configured for OAuth"
  elif context7_config_exists; then
    print_info "Replacing existing Context7 MCP server with OAuth configuration..."
    if ! execute "claude mcp remove context7"; then
      had_error=1
    elif ! execute "claude mcp add --scope user --transport http context7 $CONTEXT7_OAUTH_URL"; then
      had_error=1
    else
      print_info "Finish Context7 setup in Claude Code with /mcp -> context7 -> Authenticate"
    fi
  else
    print_info "Adding Context7 MCP server with OAuth..."
    if ! execute "claude mcp add --scope user --transport http context7 $CONTEXT7_OAUTH_URL"; then
      had_error=1
    else
      print_info "Finish Context7 setup in Claude Code with /mcp -> context7 -> Authenticate"
    fi
  fi

  if [ "$had_error" -eq 0 ]; then
    print_success "Claude MCP configuration checked."
  else
    print_error "Claude MCP configuration completed with errors."
    return 1
  fi
}

configure_claude_files
configure_mcp

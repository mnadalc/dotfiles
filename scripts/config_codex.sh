#!/bin/bash

source './osx/utils.sh'

CONTEXT7_OAUTH_URL="https://mcp.context7.com/mcp/oauth"
OPENAI_DEVELOPER_DOCS_URL="https://developers.openai.com/mcp"

codex_http_mcp_configured_with_url() {
  local server_name="$1"
  local expected_url="$2"
  local codex_mcp_json

  codex_mcp_json="$(codex mcp get "$server_name" --json 2>/dev/null)" || return 1

  if cmd_exists jq; then
    printf '%s\n' "$codex_mcp_json" | jq -e --arg url "$expected_url" '.transport.type == "streamable_http" and .transport.url == $url' > /dev/null 2>&1
  else
    printf '%s\n' "$codex_mcp_json" | grep -q '"type": "streamable_http"' && printf '%s\n' "$codex_mcp_json" | grep -q "\"url\": \"$expected_url\""
  fi
}

codex_mcp_config_exists() {
  local server_name="$1"

  codex mcp get "$server_name" --json > /dev/null 2>&1
}

ensure_codex_http_mcp() {
  local server_name="$1"
  local expected_url="$2"
  local add_message="$3"
  local replace_message="$4"
  local post_add_message="$5"

  if codex_http_mcp_configured_with_url "$server_name" "$expected_url"; then
    print_info "$server_name MCP server already configured"
  elif codex_mcp_config_exists "$server_name"; then
    print_info "$replace_message"
    if ! execute "codex mcp remove $server_name"; then
      return 1
    elif ! execute "codex mcp add $server_name --url $expected_url"; then
      return 1
    elif [ -n "$post_add_message" ]; then
      print_info "$post_add_message"
    fi
  else
    print_info "$add_message"
    if ! execute "codex mcp add $server_name --url $expected_url"; then
      return 1
    elif [ -n "$post_add_message" ]; then
      print_info "$post_add_message"
    fi
  fi
}

configure_codex_mcp() {
  local had_error=0
  print_info "Configuring Codex MCP servers..."

  if ! cmd_exists codex; then
    print_info "Codex CLI not found. Skipping Codex MCP configuration."
    return 0
  fi

  if ! ensure_codex_http_mcp \
    "context7" \
    "$CONTEXT7_OAUTH_URL" \
    "Adding Context7 MCP server to Codex with OAuth..." \
    "Replacing existing Codex Context7 MCP server with OAuth configuration..." \
    "Finish Codex Context7 setup with: codex mcp login context7"; then
    had_error=1
  fi

  if ! ensure_codex_http_mcp \
    "openaiDeveloperDocs" \
    "$OPENAI_DEVELOPER_DOCS_URL" \
    "Adding OpenAI developer docs MCP server to Codex..." \
    "Replacing existing OpenAI developer docs MCP server configuration..." \
    ""; then
    had_error=1
  fi

  if [ "$had_error" -eq 0 ]; then
    print_success "Codex MCP configuration checked."
  else
    print_error "Codex MCP configuration completed with errors."
    return 1
  fi
}

configure_codex_mcp

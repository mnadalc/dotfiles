source './osx/utils.sh'

claude_folder() {
  # Get the directory where the script is located
  ROOT_DIR="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
  print_info "Symlinking .claude folder to $HOME/.claude directory."

  # Create the .claude directory if it doesn't exist
  if [ ! -d "$HOME/.claude" ]; then
    execute "mkdir -p $HOME/.claude"
  fi
  
  # Symlink the entire .claude folder contents
  for item in "$ROOT_DIR/.claude/"*; do
    item_name=$(basename "$item")
    # Remove existing symlink if it exists
    [ -L "$HOME/.claude/$item_name" ] && rm "$HOME/.claude/$item_name"
    execute "ln -s $(realpath "$item") $HOME/.claude/$item_name"

    print_info "Symlinked $item_name to $HOME/.claude/$item_name"
  done
  unset item
  
  # Make statusline.sh executable
  if [ -f "$HOME/.claude/statusline.sh" ]; then
    execute "chmod +x $HOME/.claude/statusline.sh"
    print_info "Made statusline.sh executable"
  fi
  
  print_success "Symlinked .claude folder to $HOME/.claude directory."
}

configure_mcp() {
  print_info "Configuring MCP servers for Claude Code..."
  
  # Check if claude CLI is available
  if ! command -v claude &> /dev/null; then
    print_error "Claude CLI not found. Skipping MCP configuration."
    return 1
  fi
  
  # Add Playwright MCP server
  print_info "Adding Playwright MCP server..."
  execute "claude mcp add playwright npx @playwright/mcp@latest"

  print_info "Adding Context7 MCP server..."
  execute "claude mcp add context7 -- npx -y @upstash/context7-mcp@latest"
  
  print_success "MCP servers configured for Claude Code."
}

# configure_mcp
claude_folder
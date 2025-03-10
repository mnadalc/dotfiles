source './osx/utils.sh'

GHOSTTY_SCRIPT="$HOME/.config/ghostty/ghostty-tmux.sh"

ghostty() {
  # Check if file exists before trying to chmod
  if [ -f "$GHOSTTY_SCRIPT" ]; then
    if [ ! -x "$GHOSTTY_SCRIPT" ]; then
      print_info "Making ghostty-tmux.sh executable..."
      chmod +x "$GHOSTTY_SCRIPT"
      print_success "ghostty-tmux.sh is now executable"
    else
      print_info "ghostty-tmux.sh is already executable"
    fi
  else
    print_error "ghostty-tmux.sh not found at $GHOSTTY_SCRIPT"
  fi
}

ghostty
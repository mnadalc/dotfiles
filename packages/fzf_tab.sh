source './osx/utils.sh'

FZF_TAB_DIR="$HOME/.config/fzf-tab"

fzf_tab() {
  # Only clone if directory doesn't exist
  if [ ! -d "$FZF_TAB_DIR" ]; then
    print_info "Installing fzf-tab..."
    git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"
    print_success "fzf-tab installed"
  else
    print_info "fzf-tab is already installed"
    # Optionally update if already exists
    if [ -d "$FZF_TAB_DIR/.git" ]; then
      print_info "Updating fzf-tab..."
      cd "$FZF_TAB_DIR" && git pull
      print_success "fzf-tab updated"
    fi
  fi
}

fzf_tab
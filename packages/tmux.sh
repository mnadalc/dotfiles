source './osx/utils.sh'

install_packages() {
  print_info "Installing Tmux packages..."
  if [ ! -d "$HOME/.config/tmux/plugins/tpm/.git" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
    print_success "Tmux packages installed"
  else
    print_info "Tmux TPM already installed"
  fi

  print_info "Installing Tmux plugins..."
  if [ -f "$HOME/.config/tmux/plugins/tpm/scripts/install_plugins.sh" ]; then
    bash "$HOME/.config/tmux/plugins/tpm/scripts/install_plugins.sh"
    print_success "Tmux plugins installed"
  else
    print_error "Tmux TPM plugin installer not found"
  fi
}

install_packages

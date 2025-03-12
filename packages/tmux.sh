source './osx/utils.sh'

install_packages() {
  print_info "Installing Tmux packages..."
  git clone https://github.com/tmux-plugins/tpm $HOME/.config/tmux/plugins/tpm
  print_success "Tmux packages installed"

  print_info "Installing Tmux plugins..."
  bash $HOME/.config/tmux/plugins/tpm/scripts/install_plugins.sh
  print_success "Tmux plugins installed"
}

install_packages

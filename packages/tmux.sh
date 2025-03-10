source './osx/utils.sh'

install_packages() {
  print_info "Installing Tmux packages..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  print_success "Tmux packages installed"
}

install_packages

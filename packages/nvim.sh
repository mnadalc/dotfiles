source './osx/utils.sh'

install_kickstart() {
  print_info "Installing Neovim kickstart..."
  git clone https://github.com/nvim-lua/kickstart.nvim.git "${XDG_CONFIG_HOME:-$HOME/.dotfiles/.config}"/nvim
  print_success "Neovim kickstart installed"
}

install_kickstart

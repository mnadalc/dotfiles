source './osx/utils.sh'

MISE_CONFIG="$HOME/.dotfiles/.config/mise/config.toml"

install_mise () {
  print_info "Trusting and installing mise"
  mise trust $MISE_CONFIG
  cd $MISE_CONFIG
  mise install
  print_success "mise installed"
}

install_mise
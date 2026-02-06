source './osx/utils.sh'

MISE_DIR="$HOME/.dotfiles/.config/mise"
MISE_CONFIG="$MISE_DIR/config.toml"

install_mise () {
  print_info "Trusting and installing mise"
  mise trust "$MISE_CONFIG"
  cd "$MISE_DIR"
  mise install
  mise ls
  print_success "mise installed"
}

install_mise

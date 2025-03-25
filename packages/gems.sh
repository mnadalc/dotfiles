source './osx/utils.sh'

GEMRC="$HOME/.gemrc"

install_gems() {
  gem install rails
  gem install neovim
  print_success "Rails installed"
}

gems() {
  if [ ! -f "$GEMRC" ] || ! grep -q "gem: --no-document" "$GEMRC"; then
    print_info "Configuring gem to skip documentation..."
    echo "gem: --no-document" >> "$GEMRC"
    print_success "Gem configured to skip documentation"
    print_info "Installing gems..."
    install_gems

    # To ensure the gem bin directory is in $PATH.
    gem environment
    print_success "Gems installed"
  else
    print_info "Gem already configured to skip documentation"
  fi
}

gems
source './osx/utils.sh'

GEMRC="$HOME/.gemrc"

install_gems() {
  for gem_name in rails neovim bundler prettier_print syntax_tree syntax_tree-haml syntax_tree-rbs; do
    if ! gem list -i "$gem_name" > /dev/null 2>&1; then
      gem install "$gem_name"
    fi
  done
  print_success "Rails installed"
}

gems() {
  if [ ! -f "$GEMRC" ] || ! grep -q "gem: --no-document" "$GEMRC"; then
    print_info "Configuring gem to skip documentation..."
    echo "gem: --no-document" >> "$GEMRC"
    print_success "Gem configured to skip documentation"
  else
    print_info "Gem already configured to skip documentation"
  fi

  print_info "Installing gems..."
  install_gems

  # To ensure the gem bin directory is in $PATH.
  gem environment
  print_in_purple rails -v
  print_success "Gems installed"
}

gems

source './osx/utils.sh'

# Use Homebrew Ruby instead of macOS system Ruby (which is read-only)
if [ -d "$(brew --prefix)/opt/ruby/bin" ]; then
  export PATH="$(brew --prefix)/opt/ruby/bin:$PATH"
  export PATH="$(brew --prefix ruby)/lib/ruby/gems/$(ls $(brew --prefix ruby)/lib/ruby/gems/ | tail -1)/bin:$PATH"
fi

GEMRC="$HOME/.gemrc"

install_gems() {
  for gem_name in rails neovim bundler prettier_print syntax_tree syntax_tree-haml syntax_tree-rbs; do
    if ! gem list -i "$gem_name" > /dev/null 2>&1; then
      print_in_blue "Installing gem ${gem_name}..."
      gem install "$gem_name" --verbose
    else
      print_info "Already installed: ${gem_name}"
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

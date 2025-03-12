source './osx/utils.sh'

# Only change shell if it's not already zsh
ZShell() {
  if [[ "$SHELL" != "$(which zsh)" ]]; then
    print_info "Changing shell to zsh..."
    chsh -s "$(which zsh)"
    print_success "Shell changed to zsh"
  else
    print_info "Shell is already set to zsh"
  fi
}

ZShell
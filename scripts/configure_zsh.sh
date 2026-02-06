source './osx/utils.sh'
SH="${HOME}/.zshrc"

configure_zsh() {
  # Resolve repo root without requiring a .git directory (tarball installs)
  ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
  print_info "Configuring zsh"

  # Create the .zshrc file if it doesn't exist
  if [ ! -f "$SH" ]; then
    touch "$SH"
  else
    # If the .zshrc file already exists, make a backup and create a new one
    file_exists "$SH"
    touch "$SH"
  fi

  for file in "$ROOT_DIR/shell/"*; do
    filename=$(basename "$file")
    echo "source $(realpath "$file")" >> "$SH"
    print_info "Added source line for $filename"
  done
  unset file

  print_success "zsh configured"
  print_in_blue "\nTo apply changes:\n"
  print_in_blue "1. Start a new terminal session, or\n"
  print_in_blue "2. Run: source ~/.zshrc\n"
}

configure_zsh

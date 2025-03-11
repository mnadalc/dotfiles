source './osx/utils.sh'
SH="${HOME}/.zshrc"

configure_zsh() {
  # Get the directory where the script is located
  ROOT_DIR="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"
  print_info "Configuring zsh"

  # Create the .zshrc file if it doesn't exist
  if [ ! -f "$SH" ]; thens
    touch "$SH"
  fi

  for file in "$ROOT_DIR/shell/"*; do
    filename=$(basename "$file")
    echo "source $(realpath "$file")" >> "$SH"
    print_info "Sourced $filename"
  done
  unset file

  print_success "zsh configured"
}

configure_zsh
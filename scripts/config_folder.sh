source './osx/utils.sh'

config_folder() {
  # Resolve repo root without requiring a .git directory (tarball installs)
  ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
  print_info "Symlinking configuration files to $HOME/.config directory."

  # Create the .config directory if it doesn't exist
  if [ ! -d "$HOME/.config" ]; then
    execute "mkdir -p $HOME/.config"
  fi
  
  for folder in "$ROOT_DIR/.config/"*; do
    # Skip if glob didn't match anything
    [ ! -e "$folder" ] && continue
    
    folder_name=$(basename "$folder")
    # Get absolute path (macOS compatible)
    abs_folder_path="$(cd "$folder" && pwd)"
    
    # Remove existing symlink if it exists
    [ -L "$HOME/.config/$folder_name" ] && rm "$HOME/.config/$folder_name"
    execute "ln -s \"$abs_folder_path\" \"$HOME/.config/$folder_name\""

    print_info "Symlinked $folder_name to $HOME/.config/$folder_name"
  done
  unset folder
  
  print_success "Symlinked configuration files to $HOME/.config directory."
}

config_folder

source './osx/utils.sh'

root_dotfiles() {
  # Get the git root directory
  ROOT_DIR="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"

  # Symlink the dotfiles to the home folder
  # .gitconfig, .gitignore, .finicky.js -> $HOME
  ## TODO: When finicky is updated to v4, move it into .config
  ## https://github.com/johnste/finicky/issues/315
  print_info "Symlinking .editorconfig to $HOME directory."
  
  for file in "$ROOT_DIR"/.{editorconfig}; do
    # Skip if file doesn't exist (important for brace expansion)
    [ -e "$file" ] || continue
    
    file_name=$(basename "$file")

    # Create a backup of the file if it exists
    file_exists "$HOME/$file_name"
    # Remove existing symlink if it exists
    [ -L "$HOME/$file_name" ] && rm "$HOME/$file_name"
    
    execute "ln -s "$(realpath "$ ")" $HOME/.$folder_name"
  done
  unset file
  
  print_success "Symlinked dotfiles to $HOME directory."
}

root_dotfiles
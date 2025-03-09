source './osx/utils.sh'

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SH="${HOME}/.zshrc"

# Check if we want to create a new .zshrc if it doesn't exist
if [ ! -f "$SH" ]; then
    touch "$SH"
fi

print_in_purple '\n.dotfiles - Miguel Nadal\n\n'

chmod u+x ./osx/*.sh
chmod u+x ./packages/*.sh
chmod u+x ./shell/*.sh

./osx/xcode-install.sh
./osx/osx-preferences.sh

# Symlink the dotfiles to the home folder
# .gitconfig, .gitignore, .finicky.js -> $HOME
## TODO: When finicky is updated to v4, move it into .config
## https://github.com/johnste/finicky/issues/315
print_info "Symlinking .gitconfig, .gitignore, .finicky.js to $HOME directory."
for file in $SCRIPT_DIR/.{finicky.js,gitconfig,gitignore}; do
  file_name=$(basename "$file")
	execute "ln -s "$(realpath "$file")" $HOME/$file_name"
done;
unset file;
print_success "Symlinked .gitconfig, .gitignore to $HOME directory."

# Symlink the .config folder
print_info "Symlinking configuration files to $HOME/.config directory."
for folder in $SCRIPT_DIR/.config/*; do
	folder_name=$(basename "$folder")
	execute "ln -s "$(realpath "$folder")" $HOME/.config/$folder_name"
  print_info "Symlinked $folder_name to $HOME/.config/$folder_name"
done;
unset folder;
print_success "Symlinked configuration files to $HOME/.config directory."

# Configure zsh
print_info "Configuring zsh"
for file in $SCRIPT_DIR/shell/*.sh; do
  filename=$(basename "$file")
  echo "source $(realpath "$file")" >> "$SH"
  print_info "Sourced $filename"
done;
unset file;
print_success "zsh configured"

# echo "# -------------- mnadalc: Reload files ---------------"
# if [ -d "$HOME/.aerospace.toml" ]; then
#     echo "Removing ~/.aerospace.toml"
#     rm "$HOME/.aerospace.toml"
# fi
# if [ -d "$HOME/.config/aerospace" ]; then
#     echo "Reloading aerospace .config"
#     aerospace reload-config --no-gui
# fi

./packages/brew-install.sh
./packages/brew-packages.sh
./packages/zsh.sh
./packages/asdf.sh
./packages/fzf_tab.sh
./packages/gems.sh
./packages/ghostty.sh
./packages/aerospace.sh
restart

#!/bin/bash

source './osx/utils.sh'

print_in_purple '\n.dotfiles - Miguel Nadal\n\n'

chmod u+x ./osx/*.sh
chmod u+x ./packages/*.sh
chmod u+x ./shell/*.sh
chmod u+x ./scripts/*.sh

./osx/xcode-install.sh
# ./osx/root_dotfiles.sh # We don't have any root dotfiles to symlink (.editorconfig is not added by the script, check if we want to add it)
./osx/zsh.sh
./scripts/config_folder.sh

sudo softwareupdate --install-rosetta --agree-to-license

./packages/brew-install.sh || {
  print_error "Brew installation failed. Cannot proceed with system configuration."
  exit 1
}
./packages/brew-packages.sh || {
  print_error "Some Brew packages failed to install. Cannot proceed with system configuration."
  exit 1
}
./packages/mise.sh
./packages/gems.sh
./packages/tmux.sh
./packages/aerospace.sh
./packages/fzf_tab.sh
./packages/bat.sh

# ./packages/nvim.sh # Installs kickstart.nvim (not needed)
./osx/osx-preferences.sh

./scripts/configure_zsh.sh
./scripts/configure_ghostty.sh
./scripts/configure_cmux.sh
./scripts/configure_ai_skills.sh
./scripts/config_claude.sh
./scripts/config_codex.sh
./scripts/configure_cursor.sh
./scripts/install_cursor_extensions.sh
./scripts/setup-dockutil.sh

restart

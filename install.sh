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

./packages/brew-install.sh
./packages/brew-packages.sh
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
./scripts/config_claude.sh
./scripts/configure_cursor.sh

restart


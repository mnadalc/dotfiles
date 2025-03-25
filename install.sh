#!/bin/bash

source './osx/utils.sh'

print_in_purple '\n.dotfiles - Miguel Nadal\n\n'

chmod u+x ./osx/*.sh
chmod u+x ./packages/*.sh
chmod u+x ./shell/*.sh
chmod u+x ./scripts/*.sh

# ./osx/xcode-install.sh
# ./osx/osx-preferences.sh
# ./osx/root_dotfiles.sh
./osx/zsh.sh
./scripts/config_folder.sh

./packages/brew-install.sh
./packages/brew-packages.sh
./packages/asdf.sh
./packages/gems.sh
./packages/tmux.sh
./packages/aerospace.sh
./packages/fzf_tab.sh
./packages/bat.sh
# ./packages/nvim.sh # Installs kickstart.nvim (not needed)

zsh ./scripts/configure_zsh.sh
./scripts/configure_ghostty.sh

# restart

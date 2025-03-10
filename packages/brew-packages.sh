source './osx/utils.sh'

brew_packages() {
  if cmd_exists "brew"; then
		print_in_blue "Updating brew packages ..."
		brew update
		brew upgrade --all
		brew cleanup

    # Install packages
    brew bundle --file "${SCRIPT_DIR}/../Brewfile"
  else
    print_error 'brew not installed, the packages cannot be installed without brew.'
    ./packages/brew-install.sh
  fi
}

brew_packages
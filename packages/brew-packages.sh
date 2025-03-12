source './osx/utils.sh'

brew_packages() {
  # Get the directory where the script is located
  ROOT_DIR="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel)"

  if cmd_exists "brew"; then
		print_in_blue "Updating brew packages ..."
		brew update
		brew upgrade
		brew cleanup

    # Install packages
    brew bundle --file "${ROOT_DIR}/Brewfile"
  else
    print_error 'brew not installed, the packages cannot be installed without brew.'
    ./packages/brew-install.sh
  fi
}

brew_packages
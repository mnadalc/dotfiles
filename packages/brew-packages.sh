source './osx/utils.sh'

brew_packages() {
  # Resolve repo root without requiring a .git directory (tarball installs)
  ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

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

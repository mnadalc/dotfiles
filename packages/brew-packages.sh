source './osx/utils.sh'

brew_packages() {
  # Resolve repo root without requiring a .git directory (tarball installs)
  ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

  # Load Homebrew into the current shell if it was installed in a previous
  # subshell (e.g. right after brew-install.sh ran) but isn't in PATH yet.
  if ! cmd_exists "brew" && [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  if cmd_exists "brew"; then
		print_in_blue "Updating brew packages ..."
		brew update
		brew upgrade
		brew cleanup

    # Install packages
    brew bundle --file "${ROOT_DIR}/Brewfile" --verbose
  else
    print_error 'brew not installed, the packages cannot be installed without brew.'
    ./packages/brew-install.sh
  fi
}

brew_packages

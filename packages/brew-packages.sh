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

    # Install packages individually for per-package progress
    while IFS= read -r line; do
      [[ "$line" =~ ^[[:space:]]*# ]] && continue
      [[ -z "${line// }" ]] && continue

      if [[ "$line" =~ ^tap[[:space:]]\"([^\"]+)\" ]]; then
        brew tap "${BASH_REMATCH[1]}" 2>/dev/null || true
      elif [[ "$line" =~ ^brew[[:space:]]\"([^\"]+)\" ]]; then
        pkg="${BASH_REMATCH[1]}"
        print_in_blue "Installing ${pkg}..."
        brew install "${pkg}" || print_error "Failed to install ${pkg}"
      elif [[ "$line" =~ ^cask[[:space:]]\"([^\"]+)\" ]]; then
        cask="${BASH_REMATCH[1]}"
        print_in_blue "Installing cask ${cask}..."
        brew install --cask "${cask}" || print_error "Failed to install ${cask}"
      fi
    done < "${ROOT_DIR}/Brewfile"
  else
    print_error 'brew not installed, the packages cannot be installed without brew.'
    ./packages/brew-install.sh
  fi
}

brew_packages

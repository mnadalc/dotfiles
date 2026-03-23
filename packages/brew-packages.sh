source './osx/utils.sh'

brew_packages() {
  # Resolve repo root without requiring a .git directory (tarball installs)
  ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

  # Load Homebrew into the current shell if it was installed in a previous
  # subshell (e.g. right after brew-install.sh ran) but isn't in PATH yet.
  if ! cmd_exists "brew" && [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi

  if ! cmd_exists "brew"; then
    print_error 'Brew is not installed. Cannot install packages.'
    return 1
  fi

  print_in_blue "Updating brew packages ..."
  brew update
  brew upgrade
  brew cleanup

  local failed_packages=()

  # Install packages individually for per-package progress
  while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ -z "${line// }" ]] && continue

    if [[ "$line" =~ ^tap[[:space:]]\"([^\"]+)\" ]]; then
      brew tap "${BASH_REMATCH[1]}" 2>/dev/null || true
    elif [[ "$line" =~ ^brew[[:space:]]\"([^\"]+)\" ]]; then
      pkg="${BASH_REMATCH[1]}"
      print_in_blue "Installing ${pkg}..."
      brew install "${pkg}" || { print_error "Failed to install ${pkg}"; failed_packages+=("${pkg}"); }
    elif [[ "$line" =~ ^cask[[:space:]]\"([^\"]+)\" ]]; then
      cask="${BASH_REMATCH[1]}"
      print_in_blue "Installing cask ${cask}..."
      brew install --cask "${cask}" || { print_error "Failed to install cask ${cask}"; failed_packages+=("${cask}"); }
    fi
  done < "${ROOT_DIR}/Brewfile"

  if [ ${#failed_packages[@]} -gt 0 ]; then
    print_error "The following packages failed to install:"
    for pkg in "${failed_packages[@]}"; do
      print_error "  - ${pkg}"
    done
    return 1
  fi

  print_success "All Brew packages installed successfully."
}

brew_packages
exit $?

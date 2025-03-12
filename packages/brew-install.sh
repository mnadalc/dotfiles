source './osx/utils.sh'

brew_install() {
  print_info "Installing Homebrew"
  
  if command -v brew &> /dev/null; then
    print_success 'Brew already installed!'
  else
	  ask_for_confirmation "Would you like to install Homebrew (Brew) ?"
    if answer_is_yes; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      if cmd_exists "brew"; then
        print_success 'Brew has been succesfully installed!'

        # Configure shell for Homebrew if not already configured
        if ! grep -q "eval \"\$(\/opt\/homebrew\/bin\/brew shellenv)\"" ~/.zprofile; then
          print_info "Configuring shell for Homebrew"
          echo '# Configure shell for Homebrew' >> ~/.zprofile
          echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
          print_success 'Brew has been configured for your shell.'
        fi
      else
        print_error 'Something went wrong while installing brew.'
      fi
    else
      print_error 'Brew not installed.'
    fi
  fi
}

brew_install
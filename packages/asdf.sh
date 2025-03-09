source './osx/utils.sh'

# Function to install asdf plugin and latest version
install_asdf_plugin() {
  local plugin=$1
  if ! asdf plugin list | grep -q "^$plugin$"; then
    asdf plugin add "$plugin"
    asdf install "$plugin" latest
    asdf global "$plugin" latest
    print_success "Plugin $plugin installed"
  else
    print_info "Plugin $plugin is already installed"
  fi
}

install_asdf () {
  # Install plugins
  install_asdf_plugin nodejs # https://mac.install.guide/rubyonrails/6
  bash $HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring
  
  install_asdf_plugin yarn # https://mac.install.guide/rubyonrails/6
  install_asdf_plugin ruby # https://mac.install.guide/rubyonrails/7
}

install_asdf
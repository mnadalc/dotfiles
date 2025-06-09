source './osx/utils.sh'

# Function to install asdf plugin and latest version
install_asdf_plugin() {
  local plugin=$1
  if ! asdf plugin list | grep -q "^$plugin$"; then
    asdf plugin add "$plugin"
    asdf install "$plugin" latest
    print_success "Plugin $plugin installed"
  else
    print_info "Plugin $plugin is already installed"
  fi
}

install_asdf () {
  print_info "Installing asdf"

  # Install plugins
  install_asdf_plugin nodejs # https://mac.install.guide/rubyonrails/6
  bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
  
  install_asdf_plugin yarn # https://mac.install.guide/rubyonrails/6
  install_asdf_plugin ruby # https://mac.install.guide/rubyonrails/7

  # Add a .asdfrc configuration file to your user home directory to enable asdf to read .ruby-version files.
  touch $HOME/.asdfrc
  echo "# ASDF_CONFIG_FILE" >> $HOME/.asdfrc
  echo "legacy_version_file = yes" >> $HOME/.asdfrc

  touch $HOME/.tool-versions
  echo "# ASDF_DEFAULT_TOOL_VERSIONS_FILENAME " >> $HOME/.tool-versions
  echo "nodejs lts" >> $HOME/.tool-versions
  
  asdf set -u nodejs latest
  asdf set -u yarn latest
  asdf set -u ruby latest

  print_success "asdf installed and configured"
}

install_asdf
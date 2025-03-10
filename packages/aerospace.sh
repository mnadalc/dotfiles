source './osx/utils.sh'

config_aerospace() {
  if [ -d "$HOME/.aerospace.toml" ]; then
    rm "$HOME/.aerospace.toml"
  fi
  if [ -d "$HOME/.config/aerospace" ]; then
    aerospace reload-config --no-gui
  fi

  print_success "Aerospace configured"
}

config_aerospace
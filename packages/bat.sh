source './osx/utils.sh'

configure_bat() {
  print_info "Configuring bat"
  
  # Create the .config/bat directory if it doesn't exist
  if [ ! -d "$(bat --config-dir)" ]; then
    execute "mkdir -p $(bat --config-dir)/themes"
  fi
  
  if [ ! -f "$(bat --config-dir)/themes/Catppuccin Mocha.tmTheme" ]; then
    execute "wget -P $(bat --config-dir)/themes https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"
  fi
  execute "bat cache --build"

  print_success "bat configured"
}

configure_bat
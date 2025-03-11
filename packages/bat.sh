source './osx/utils.sh'

configure_bat() {
  print_info "Configuring bat"
  
  # Create the .config/bat directory if it doesn't exist
  if [ ! -d "$(bat --config-dir)" ]; then
    execute "mkdir -p $(bat --config-dir)/themes"
  fi
  
  execute "wget -P $(bat --config-dir)/themes https://github.com/catppuccin/bat/raw/main/themes/Catppuccin%20Mocha.tmTheme"
  execute "bat cache --build"

  print_success "bat configured"
}

configure_bat
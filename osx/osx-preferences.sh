source './osx/utils.sh'

# osxprefs : Setting up my OS X preferences

# We can check all the defaults with:
# defaults domains | tr ',' '\n' # To get all domains
# defaults domains | tr ',' '\n' | grep -i textedit # To get all domains that contain textedit
# defaults read com.apple.TextEdit # To read TextEdit defaults

# Webpage showing some defaults: https://macos-defaults.com/

osxprefs() {
	# Show the ~/Library folder
	chflags nohidden ~/Library
	print_success "Library shown."

  # Show hidden files in Finder
  defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder
  print_success "Show hidden files in Finder."

  # Set default view style to list
  defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" && killall Finder
  print_success "Set default view style to list."
  
	# Scroll direction natural : False
	# defaults write -g com.apple.swipescrolldirection -bool false
	# print_success "Scroll direction natural (Lion style) set to false."

	# Automatically hide and show the Dock
	defaults write com.apple.dock autohide -bool true
	print_success "Automatically hide and show the Dock."

	# Display full path in Finder title window
	defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
	print_success "Finder shows full path in title."

	# Save screenshots in ~/Pictures/Screenshots folder
	# mkdir $HOME/Pictures/Screenshots
	# defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
	# print_success "Screenshot now will appear @ $HOME/Pictures/Screenshots"

	# Check for software updates daily, not just once per week
	# defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1
	# print_success "Software updates checking daily"

	# Trackpad: enable tap to click for this user and for the login screen
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
	defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
	print_success "Tap to click enabled at the trackpad"

	# Trackpad: map bottom right corner to right-click
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
	defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
	defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
	defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
	print_success "Right click mapped to the bottom right corner at the trackpad."

	# Always show scrollbars
	# defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
	# print_success "Scroll bars showing"
	# Possible values: `WhenScrolling`, `Automatic` and `Always`

	# Finder: show all filename extensions
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
	print_success "Finder showing filename extensions"

	# Automatically quit printer app once the print jobs complete
	# defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true
	# print_success "Printer app quit once the prints complete."

	# Disable the “Are you sure you want to open this application?” dialog
	# defaults write com.apple.LaunchServices LSQuarantine -bool false
	# print_success "Are you sure you want to open this app dialog disabled."

	# Enable full keyboard access for all controls
	# (e.g. enable Tab in modal dialogs)
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
	print_success "Full keyboard acces for all controls enabled."

	# Set the timezone; see `sudo systemsetup -listtimezones` for other values
	sudo systemsetup -settimezone "Europe/Madrid" > /dev/null
	print_success "Time zone set to : Europe/Madrid"

	# Require password immediately after sleep or screen saver begins
	defaults write com.apple.screensaver askForPassword -int 1
	defaults write com.apple.screensaver askForPasswordDelay -int 0
	print_success "Password required immediately after sleep or screen saver begins."

	# Enable the Develop menu and the Web Inspector in Safari
	defaults write com.apple.Safari IncludeDevelopMenu -bool true
	defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
	defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
	print_success "Safari developer tools and web inspector enabled."
}

osxprefs
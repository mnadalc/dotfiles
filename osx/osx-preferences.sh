source './osx/utils.sh'

# osxprefs : Setting up my OS X preferences

# We can check all the defaults with:
# defaults domains | tr ',' '\n' # To get all domains
# defaults domains | tr ',' '\n' | grep -i textedit # To get all domains that contain textedit
# defaults read com.apple.TextEdit # To read TextEdit defaults

# Webpage showing some defaults: https://macos-defaults.com/

osxprefs() {
  ###############################################################################
  # General UI/UX                                                               #
  ###############################################################################

  # Set computer name (as done via System Preferences → Sharing)
  #sudo scutil --set ComputerName "0x6D746873"
  #sudo scutil --set HostName "0x6D746873"
  #sudo scutil --set LocalHostName "0x6D746873"
  #sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "0x6D746873"

  # Disable the sound effects on boot
  sudo nvram SystemAudioVolume=" "

  # Always show scrollbars
  defaults write NSGlobalDomain AppleShowScrollBars -string "Automatic"

  # Save to disk (not to iCloud) by default
  defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

  # Automatically quit printer app once the print jobs complete
  defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

  # Set dark mode
  defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
  print_success "Dark mode enabled."

  # Show battery percentage in the menu bar
  defaults write com.apple.controlcenter.plist BatteryShowPercentage -bool true
  print_success "Battery percentage in the menu bar enabled."

  ###############################################################################
  # Finder                                                                      #
  ###############################################################################

  # Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
  defaults write com.apple.finder QuitMenuItem -bool true
  print_success "Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons."
  
  # Finder: disable window animations and Get Info animations
  defaults write com.apple.finder DisableAllAnimations -bool true
  print_success "Finder: disable window animations and Get Info animations."

  # Show the ~/Library folder
  chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library
  print_success "Library shown."

  # Show hidden files in Finder
  defaults write com.apple.finder AppleShowAllFiles -bool true
  print_success "Show hidden files in Finder."

  # Show path in Finder
  defaults write com.apple.finder ShowPathbar -bool true
  defaults write com.apple.finder ShowStatusBar -bool true
  print_success "Finder status bar enabled."

  # Show the /Volumes folder
  chflags nohidden /Volumes
  print_success "Volumes shown."

  defaults write com.apple.finder FXArrangeGroupViewBy "Name"
  defaults write com.apple.finder FXPreferredGroupBy "Date Modified"
  defaults write com.apple.finder "FK_ArrangeBy" "Date Modified"
  print_success "Finder grouped by date modified."

  # Set default view style to list
  defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
  print_success "Set default view style to list."

  # Finder: show all filename extensions
	defaults write NSGlobalDomain AppleShowAllExtensions -bool true
	print_success "Finder showing filename extensions"

	# Display full path in Finder title window
	defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
	print_success "Finder shows full path in title."

  # Avoid creating .DS_Store files on network or USB volumes
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

  # Save screenshots in ~/Screenshots
  mkdir -p ~/Screenshots
  defaults write com.apple.screencapture location ~/Screenshots

  ###############################################################################
  # Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
  ###############################################################################

	# Trackpad: enable tap to click (one finger) for built-in and Bluetooth trackpads
	defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
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

  # Scroll direction natural : True
	defaults write -g com.apple.swipescrolldirection -bool true
	print_success "Scroll direction natural (Lion style) set to true."

	# Increase sound quality for Bluetooth headphones/headsets
	defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

	# Enable full keyboard access for all controls
	# (e.g. enable Tab in modal dialogs)
	defaults write NSGlobalDomain AppleKeyboardUIMode -int 2
	print_success "Full keyboard access for all controls enabled."

	# Keyboard
	# Enable key repeat globally
	defaults write -g ApplePressAndHoldEnabled -bool false 
	print_success "Key repeat enabled globally."

  # Use fn key as standard function key
  defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true
  print_success "Fn key as standard function key enabled."

	# Set a blazingly fast keyboard repeat rate
	defaults write NSGlobalDomain KeyRepeat -int 1
	defaults write NSGlobalDomain InitialKeyRepeat -int 10
	print_success "Blazing fast keyboard repeat rate enabled."

	# Set the timezone; see `sudo systemsetup -listtimezones` for other values
	sudo systemsetup -settimezone "Europe/Madrid" > /dev/null
	print_success "Time zone set to : Europe/Madrid"

	# Require password immediately after sleep or screen saver begins
	defaults write com.apple.screensaver askForPassword -int 1
	defaults write com.apple.screensaver askForPasswordDelay -int 0
	print_success "Password required immediately after sleep or screen saver begins."

	# Show language indicator while switching input sources
	defaults write kCFPreferencesAnyApplication TSMLanguageIndicatorEnabled -bool "true"

  # Enable Group windows by app in Mission Control. Needed for proper Aerospace behaviour
  defaults write com.apple.dock "expose-group-apps" -bool true
  print_success "Group windows by app in Mission Control enabled."

  # Set language and text formats
  # Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
  # `Inches`, `en_GB` with `en_US`, and `true` with `false`.
  defaults write NSGlobalDomain AppleLanguages -array "en-ES" "es-ES"
  defaults write NSGlobalDomain AppleLocale -string "en_ES"
  defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
  defaults write NSGlobalDomain AppleMetricUnits -bool true
  defaults write NSGlobalDomain AppleTemperatureUnit -string "Celsius"


  # Disable automatic capitalization as it’s annoying when typing code
  defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
  print_success "Automatic capitalization disabled."
  
  # Disable smart dashes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
  print_success "Smart dashes disabled."

  # Disable automatic period substitution as it’s annoying when typing code
  defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
  print_success "Automatic period substitution disabled."

  # Disable smart quotes as they’re annoying when typing code
  defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
  print_success "Smart quotes disabled."

  # Disable auto-correct
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  print_success "Auto-correct disabled."
  ###############################################################################
  # Dock, Dashboard, and hot corners                                            #
  ###############################################################################
  # Set the icon size of Dock items to 72 pixels
  defaults write com.apple.dock tilesize -int 72
  print_success "Dock icon size set to 72 pixels."

  # Don’t animate opening applications from the Dock
  defaults write com.apple.dock launchanim -bool false
  print_success "Dock animations disabled."

  # Automatically hide and show the Dock
  defaults write com.apple.dock autohide -bool true
  print_success "Dock automatically hides."

  # Don’t show suggested and recent apps in Dock
  defaults write com.apple.dock show-recents -bool false
  print_success "Dock recent apps disabled."

  # Don’t automatically rearrange Spaces based on recent use
  defaults write com.apple.dock mru-spaces -bool false
  print_success "Automatic Space rearrangement disabled."

  # Change animation while minimizing applications
  defaults write com.apple.dock "mineffect" -string "scale"
  print_success "Dock animation changed to scale."

  # Change date format in the menu bar
  defaults write com.apple.menuextra.clock "DateFormat" -string "\"EEE d MMM HH:mm:ss\""
  print_success "Date format in the menu bar changed to \"EEE d MMM HH:mm:ss\"."

  defaults write com.apple.dock loc -string "en_GB:ES"

  # Hot corners
  # Possible values:
  #  0: no-op
  #  2: Mission Control
  #  3: Show application windows
  #  4: Desktop
  #  5: Start screen saver
  #  6: Disable screen saver
  #  7: Dashboard
  # 10: Put display to sleep
  # 11: Launchpad
  # 12: Notification Center
  # 13: Lock Screen
  defaults write com.apple.dock wvous-tl-corner -int 0
  defaults write com.apple.dock wvous-tl-modifier -int 0
  defaults write com.apple.dock wvous-tr-corner -int 0
  defaults write com.apple.dock wvous-tr-modifier -int 0
  defaults write com.apple.dock wvous-bl-corner -int 0
  defaults write com.apple.dock wvous-bl-modifier -int 0
  defaults write com.apple.dock wvous-br-corner -int 0
  defaults write com.apple.dock wvous-br-modifier -int 0
  print_success "All hot corners disabled."

  ###############################################################################
  # Safari & WebKit                                                             #
  ###############################################################################

  # Privacy: don’t send search queries to Apple
  defaults write com.apple.Safari UniversalSearchEnabled -bool false
  defaults write com.apple.Safari SuppressSearchSuggestions -bool true
  print_success "Safari privacy settings configured."

  # Enable the Develop menu and the Web Inspector in Safari
	defaults write com.apple.Safari IncludeDevelopMenu -bool true
	defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
	defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
  defaults write com.apple.Safari "ShowFullURLInSmartSearchField" -bool true
	print_success "Safari developer tools and web inspector enabled."

  # Block pop-up windows
  defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false
  print_success "Block pop-up windows in Safari."

  # Enable “Do Not Track”
  defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

  # Update extensions automatically
  defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true
  print_success "Extensions updated automatically."

  # Remove useless icons from Safari’s bookmarks bar
  defaults write com.apple.Safari ProxiesInBookmarksBar "()"

  # Add a context menu item for showing the Web Inspector in web views
  defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

  # Enable Safari’s debug menu
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
  print_success "Safari debug menu enabled."

  # Hide Safari’s bookmarks bar by default
  defaults write com.apple.Safari ShowFavoritesBar -bool false

  # Hide Safari’s sidebar in Top Sites
  defaults write com.apple.Safari ShowSidebarInTopSites -bool false

  ###############################################################################
  # Activity Monitor                                                            #
  ###############################################################################

  # Show the main window when launching Activity Monitor
  defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

  # Visualize CPU usage in the Activity Monitor Dock icon
  defaults write com.apple.ActivityMonitor IconType -int 5

  # Show all processes in Activity Monitor
  defaults write com.apple.ActivityMonitor ShowCategory -int 0

  # Sort Activity Monitor results by CPU usage
  defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
  defaults write com.apple.ActivityMonitor SortDirection -int 0

  ###############################################################################
  # Photos                                                                      #
  ###############################################################################

  # Prevent Photos from opening automatically when devices are plugged in
  defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
  print_success "Photos will not open automatically when devices are plugged in."

  ###############################################################################
  # Time Machine                                                                #
  ###############################################################################

  # Prevent Time Machine from prompting to use new hard drives as backup volume
  defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
  print_success "Time Machine will not prompt to use new hard drives as backup volume."

  ###############################################################################
  # TextEdit                                                                    #
  ###############################################################################
  # When adding quotes will remain in the form they are typed
  defaults write com.apple.TextEdit "SmartQuotes" -bool "false" 
  print_success "Quotes will remain in the form they are typed."

  # Disable just smart dashes
  defaults write -g NSAutomaticDashSubstitutionEnabled 0
  print_success "Disable automatic smart dashes"

  # Disable just smart quotes
  defaults write -g NSAutomaticQuoteSubstitutionEnabled 0
  print_success "Disable automatic smart quotes"
}

osxprefs

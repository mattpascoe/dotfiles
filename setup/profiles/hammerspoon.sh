#!/bin/bash
# MacOS scripting for hotkeys etc

# I'm not even printing anything on other platforms just so I can
# have this in the desktop roles and not be noisy
PKG_NAME=hammerspoon
case "$ID" in
  macos*)
    # First time setup
    if ! command -v hs >/dev/null 2>&1; then
      "$BREWPATH"/brew install "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d'
      msg "${BLU}Starting Hammerspoon the first time."
      msg "${BLU}Launching Accessibility settings. Enable Hammerspoon there first."

      # Setup app settings
      defaults write org.hammerspoon.Hammerspoon HSUploadCrashData 0
      defaults write org.hammerspoon.Hammerspoon SUAutomaticallyUpdate 0
      defaults write org.hammerspoon.Hammerspoon SUEnableAutomaticChecks 0
      defaults write org.hammerspoon.Hammerspoon SUHasLaunchedBefore 1
      osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Hammerspoon.app", hidden:false}'

      # The intent is to have the user allow hammerspoon to access accessibility
      # before they click the ok on starting hammerspoon the first time
      open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
      open -a hammerspoon
    else
      # Normal updates and setup
      "$BREWPATH"/brew install "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d'
      link_file ".hammerspoon"
    fi
    ;;
  #*) # Dont print just to be more quiet on other platforms
    #echo "-!- Install not supported."
  #  ;;
esac

msg "${BLU}Install complete."

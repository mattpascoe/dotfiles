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
      msg "${BLU}Launching Accessibility settings. Enable Hammerspoon there."

      open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

      sleep 1
      defaults write org.hammerspoon.Hammerspoon HSUploadCrashData 0
      defaults write org.hammerspoon.Hammerspoon SUAutomaticallyUpdate 0
      defaults write org.hammerspoon.Hammerspoon SUEnableAutomaticChecks 0
      defaults write org.hammerspoon.Hammerspoon SUHasLaunchedBefore 1
      osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Hammerspoon.app", hidden:false}'

      killall Hammerspoon
      sleep 1
      open -a hammerspoon

    else
      # Normal updates and setup
      "$BREWPATH"/brew install "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d'

      FILE=.hammerspoon
      if [ ! -L "$HOME/$FILE" ]; then
        if [ -e "$HOME/$FILE" ]; then
          msg "${BLU}Backing up current file to ${FILE}.bak"
          mv "$HOME/$FILE" "$HOME/$FILE.bak"
        fi
        msg "${BLU}Linking file $HOME/$FILE -> $DOTREPO/$FILE"
        ln -s "$DOTREPO/$FILE" "$HOME/$FILE"
      else
        echo -n "Found link: "
        ls -o "$HOME/$FILE"
      fi
    fi
    ;;
  #*)
    #echo "-!- Install not supported."
  #  ;;
esac

msg "${BLU}Install complete."

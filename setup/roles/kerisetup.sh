#!/usr/bin/env zsh

# This script is for Keri and her settings. It will first run setup.sh then apply these changes
# Basically, on Keris system, just run this.

~/dotfiles/setup.sh

echo
echo "---- Applying Keri's settings -----"

echo "- Ensuring install of Keri's brew packages..."
brew install -q zoom spotify quicken google-chrome

# Enable DarkMode
osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to 0'

# Ask for the administrator password upfront
# Shouldnt need this as it was done in the other startup.sh
#sudo -v

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false

# Show item info to the right of the icons on the desktop
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom true" ~/Library/Preferences/com.apple.finder.plist

# Enable the dock from being hidden all the time
defaults write com.apple.dock autohide-delay -float 0
# allow pinning in dock
defaults write com.apple.dock static-only -bool false

killall Dock
killall Finder

# Notes on conversion process
# BRAVE BROWSER
# -- on new machine
# cd ~
# OR BETTER
# rsync -avhn "keri@10.1.1.240:Library/Application\ Support/BraveSoftware/" ~/Library/Application\ Support/BraveSoftware
# rsync -avhn "keri@10.1.1.240:Library/Application\ Support/Google/" ~/Library/Application\ Support/Google
# chown -R keripascoe:staff Library/Application\ Support/BraveSoftware
# chown -R keripascoe:staff Library/Application\ Support/Google
#
# Still need to install extensions,  manually just re-install those.
#  1password - password manager
#  Grammarly
#  Pintrest save button
#  Rakuten
#  RetailMeNot deal finder

# Other apps not in brew
#  setexifdata
#  silhouette


# Real sync of files before syncthing, the issue is not data but file times
# rsync -avhn keri@10.1.1.240:Data/ ~/Data
# after you have files.. set up syncthing by pausing the old server and adding the new one as a recieve just to make sure things are all in sync still.. then you can switch to send.

echo "---- DONE Applying Keri's settings -----"

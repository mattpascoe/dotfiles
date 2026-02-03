#!/usr/bin/env bash
# Keri's mac environment setup

PROFILES=(
  starship
  fzf
  tmux
  nerdfonts
  1password
  brave-browser
  ghostty
  neovim
  zoom
)

run_profiles "${PROFILES[@]}"

# Setup some common config symlinks
msg "Checking dotfile config symlinks"
link_file ".config/btop"
link_file ".config/git"
link_file ".profile"
link_file ".vimrc"
link_file ".zshrc"

# TODO: Turn these into profiles
brew install -q \
  spotify \
  quicken \
  google-chrome

# MAC OS settings that differ from the ones I set globally
# Disable DarkMode
#osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to 0'

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

msg "${BLU}
# Notes on conversion process
# BRAVE BROWSER
# -- on new machine
# cd ~
# OR BETTER
# rsync -avhn 'keri@10.1.1.240:Library/Application\ Support/BraveSoftware/' ~/Library/Application\ Support/BraveSoftware
# rsync -avhn 'keri@10.1.1.240:Library/Application\ Support/Google/' ~/Library/Application\ Support/Google
# chown -R keripascoe:staff Library/Application\ Support/BraveSoftware
# chown -R keripascoe:staff Library/Application\ Support/Google
#
# Still need to install extensions,  manually just re-install those.
#  1password - password manager
#  Pintrest save button
#  Rakuten
#  RetailMeNot deal finder

# Other apps not in brew
#  setexifdata
#  silhouette

# Real sync of files before syncthing, the issue is not data but file times
# rsync -avhn keri@10.1.1.240:Data/ ~/Data
# after you have files.. set up syncthing by pausing the old server and adding the new one as a recieve just to make sure things are all in sync still.. then you can switch to send.
"

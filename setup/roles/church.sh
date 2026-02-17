#!/usr/bin/env bash
# Linux laptop for presentation slides at church

PROFILES=(
  starship
  fzf
  tmux
  nerdfonts
  lazygit
  neovim
  desktop
  kanata
  brave-browser
  ghostty
)

# Only process if we are not checking status
if [[ -z "$ROLE_STATUS" ]]; then
  run_profiles "${PROFILES[@]}"

  # Setup some common config symlinks
  msg "Checking dotfile config symlinks"
  link_file ".config/btop"
  link_file ".config/git"
  link_file ".profile"
  link_file ".vimrc"
  link_file ".zshrc"

  # Define a few other specifics just for this setup this is all hard coded!

  # disable notifications, AKA do not disturb
  gsettings set org.gnome.desktop.notifications show-banners false
  # set screen sleeps and stuff
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 7200
  # Dont suspend when on AC power
  gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'

  # Disable screen blank
  gsettings set org.gnome.desktop.session idle-delay 0

  # Install some apps
  sudo apt install vlc libreoffice
fi

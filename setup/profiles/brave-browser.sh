#!/bin/bash
# The Brave web browser

PKG_NAME=brave-browser
case "$ID" in
  # arch*)
  #   sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  #   # Install using brave official repo script
  #   # This requires an AUR like yay
  #   #curl -fsS https://dl.brave.com/install.sh | sh
  debian*|ubuntu*)
    # Install using brave official repo script
    curl -fsS https://dl.brave.com/install.sh | sh >& /dev/null
    xdg-settings set default-web-browser brave-browser.desktop
    ;;
  macos*)
    brew install "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

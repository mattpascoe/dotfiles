#!/bin/bash
# The Brave web browser

source setup/setup_lib.sh

PKG_NAME=brave-browser
case "$ID" in
  # arch*)
  #   sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  #   # Install using brave official repo script
  #   # This requires an AUR like yay
  #   #curl -fsS https://dl.brave.com/install.sh | sh
  debian*|ubuntu*)
    # Install using brave official repo script
    curl -fsS https://dl.brave.com/install.sh | sh
    xdg-settings set default-web-browser brave-browser.desktop
    ;;
  macos*)
    if brew list "$PKG_NAME" >/dev/null 2>&1; then
      msg "${BLU}Already installed via brew on Mac."
    else
      msg "${GRN}Installing..."
      brew install "$PKG_NAME"
    fi
    ;;
  *)
    echo "-!- Install not supported."
    ;;
esac


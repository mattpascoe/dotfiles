#!/bin/bash
# Ghostty terminal emulator

PKG_NAME=ghostty
case "$ID" in
  # arch*)
  #   # Ghostty says they have a package in the extras repo of arch.. I dont get one
  #   sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  debian*|ubuntu*)
    # Install using the community managed ubuntu install script
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)" >& /dev/null
    ;;
  macos*)
    brew install "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

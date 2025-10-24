#!/bin/bash
# Ghostty terminal emulator

source setup/setup_lib.sh

PKG_NAME=ghostty
case "$ID" in
  # arch*)
  #   # Ghostty says they have a package in the extras repo of arch.. I dont get one
  #   sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  debian*|ubuntu*)
    # Install using the community managed ubuntu install script
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)" >& /dev/null
    msg "${BLU}Install complete."
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


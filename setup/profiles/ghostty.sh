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
    link_file ".config/$PKG_NAME"
    ;;
  macos*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d'
    link_file ".config/$PKG_NAME"
    ;;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

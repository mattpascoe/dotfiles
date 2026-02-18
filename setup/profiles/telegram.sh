#!/bin/bash
# Telegram messaging app

PKG_NAME=telegram
case "$ID" in
  #arch*)
  #  sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  #debian*|ubuntu*)
  #  sudo apt install "$PKG_NAME"
  #  ;;
  macos*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

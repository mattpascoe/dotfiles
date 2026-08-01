#!/bin/bash
# Proton Pass App

PKG_NAME=proton-pass
case "$ID" in
  # arch*)
  #   sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  #debian*|ubuntu*)
  #  ;;
  macos*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d'
    ;;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

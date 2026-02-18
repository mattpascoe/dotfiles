#!/bin/bash
# TUI AI coding assistant

PKG_NAME=opencode
case "$ID" in
  #arch*)
  #  sudo pacman --needed --noconfirm -S "$PKG_NAME" ;;
  debian*|ubuntu*)
    sudo curl -fsSL https://opencode.ai/install | bash ;;
  macos*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

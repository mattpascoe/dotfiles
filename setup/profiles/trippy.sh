#!/bin/bash
# TUI network testing tool

PKG_NAME=trippy
case "$ID" in
  arch*)
    sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  debian*|ubuntu*)
    sudo apt install -y "$PKG_NAME"
    ;;
  macos*)
    brew install "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

#!/bin/bash
# TUI for searching log files

PKG_NAME=lnav
case "$ID" in
  arch*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN $INSTALLER_OPTS "$PKG_NAME" ;;
  debian*|ubuntu*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" ;;
  macos*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

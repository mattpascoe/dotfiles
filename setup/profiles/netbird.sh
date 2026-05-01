#!/bin/bash
# Zero trust VPN system

PKG_NAME=netbird
case "$ID" in
  macos*)
    # Install and setup if we dont have it yet
    # This one uses a tap
    if ! command -v "$PKG_NAME" &> /dev/null; then
      # shellcheck disable=SC2086
      $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "netbirdio/tap/$PKG_NAME" 2>&1|sed '/^To reinstall/,$d'
      netbird service install
      netbird service start
    else
      # Otherwise "install/upgrade" it
      # shellcheck disable=SC2086
      $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "netbirdio/tap/$PKG_NAME" 2>&1|sed '/^To reinstall/,$d'
    fi
    ;;
  *)
    if ! command -v "$PKG_NAME" &> /dev/null; then
      prompt "Install netbird system wide using their installer script? (N/y) "
      read -r REPLY < /dev/tty
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        curl -fsSL https://pkgs.netbird.io/install.sh | sh
      fi
    else
      VERSION=$(netbird version)
      msg "${BLU}Netbird is already installed: v$VERSION"
    fi
    ;;
esac

msg "${BLU}Install complete."

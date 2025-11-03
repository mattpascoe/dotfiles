#!/bin/bash
# Zero trust VPN system

if ! command -v netbird &> /dev/null; then
  prompt "Install netbird system wide using their installer script? (N/y) "
  read -r REPLY < /dev/tty
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl -fsSL https://pkgs.netbird.io/install.sh | sh
  fi
else
  VERSION=$(netbird version)
  msg "${BLU}Netbird is already installed: v$VERSION"
fi

msg "${BLU}Install complete."

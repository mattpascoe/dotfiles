#!/bin/bash

# Funny enough Linux platforms dont really need much beyond the COMMON profile
# but we have this stubbed out just in case

# Ensure zsh is default if its available
if command -v "zsh" &> /dev/null; then
  if [ "$(grep "$USER" /etc/passwd|cut -d: -f7)" != "/bin/zsh" ]; then
    msg "${BLU}Switching default shell to ZSH"
    sudo usermod -s /bin/zsh "$USER"
  fi
fi

# OS specific settings and options
case "$ID" in
  debian*|ubuntu*)
    PLATFORM_INSTALLER_BIN="sudo apt"
    INSTALLER_OPTS="-y"
    PLATFORM_INSTALLER_DRYRUN_FLAG="--dry-run"
    ;;
  arch*)
    PLATFORM_INSTALLER_BIN="sudo pacman"
    INSTALLER_OPTS="--needed --noconfirm -Syu"
    PLATFORM_INSTALLER_DRYRUN_FLAG="--dry-run"

    # A special case on Arch, I'm going to enable the wheel group for sudo
    sed -i.bak '/^[[:space:]]*#\s*%wheel[[:space:]]\+ALL=(ALL)[[:space:]]\+ALL/s/^#\s*//' /etc/sudoers
    ;;
esac


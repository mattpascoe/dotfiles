#!/bin/bash
# Ghostty terminal emulator

# Get linux os type
[ -f /etc/os-release ] && . /etc/os-release
case "$ID" in
  debian*|ubuntu*)
    # Install using the community managed ubuntu install script
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    ;;
  arch*)
    sudo pacman --needed --noconfirm -Sy ghostty ;;
  *)
    echo "-!- Install not supported."
    ;;
esac


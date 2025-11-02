#!/bin/bash

# Funny enough Linux platforms dont really need much beyond the COMMON profile
# but we have this stubbed out just in case

# Update package system to make sure we have fresh context
# This runs before most other installs so it helps keep things up to date
case "$ID" in
  debian*|ubuntu*)
    sudo apt update -y
    ;;
  arch*)
    sudo pacman --needed --noconfirm -Syu
    # Also make sure yay is installed for AUR support
    if ! command -v "yay" &> /dev/null; then
      git clone https://aur.archlinux.org/yay.git
      cd yay || exit
      makepkg -si --noconfirm
      cd - > /dev/null || exit
    fi
    ;;
esac

# Ensure zsh is default if its available
if command -v "zsh" &> /dev/null; then
  if [ "$(grep "$USER" /etc/passwd|cut -d: -f7)" != "/bin/zsh" ]; then
    msg "${BLU}Switching default shell to ZSH"
    sudo usermod -s /bin/zsh "$USER"
  fi
fi

# Set the console log level to 6 on arch
# TODO: not useful here as it does not run at the very end of things
#[[ "$ID" == arch* ]] && sudo dmesg -n 6

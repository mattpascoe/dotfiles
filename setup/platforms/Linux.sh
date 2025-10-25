#!/bin/bash

msg "${BLU}Ensuring install of requested base packages..."
case "$ID" in
  debian*|ubuntu*)
    sudo apt install -y "${LINUX_PKGS[@]}"
    # Also set timezone
    sudo timedatectl set-timezone "$TIMEZONE"
    # Remove some useless crap
    sudo apt purge -y whoopsie
    ;;
  arch*)
    sudo dmesg -n 3 # Disable kernel messages since we are likely on a console
    sudo pacman --disable-sandbox --needed --noconfirm -Syu "${LINUX_PKGS[@]}"
    ;;
  *)
    msg "${RED}-!- This system is not a supported type, You should check that the following packages are installed:"
    echo "    ${LINUX_PKGS[*]}"
    ;;
esac

# Ensure zsh is default if its available
if command -v "zsh" &> /dev/null; then
  if [ "$(grep "$USER" /etc/passwd|cut -d: -f7)" != "/bin/zsh" ]; then
    msg "${BLU}Switching default shell to ZSH..."
    sudo usermod -s /bin/zsh "$USER"
  fi
fi

# Set the console log level to 6 on arch
[[ "$ID" == arch* ]] && sudo dmesg -n 6

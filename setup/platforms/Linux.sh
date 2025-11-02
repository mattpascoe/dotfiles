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

# Set the console log level to 6 on arch
[[ "$ID" == arch* ]] && sudo dmesg -n 6

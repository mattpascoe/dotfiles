#!/bin/bash
# tmux terminal multiplexer

# This profile will be installed by the COMMON profile so you
# dont need to add it to other roles
source setup/setup_lib.sh

PKG_NAME=tmux
case "$ID" in
  arch*)
    sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  debian*|ubuntu*)
    sudo apt install -y "$PKG_NAME"
    ;;
  macos*)
    if brew list "$PKG_NAME" >/dev/null 2>&1; then
      msg "${BLU}Already installed via brew on Mac."
    else
      brew install "$PKG_NAME"
    fi
    ;;
  *)
    echo "-!- Install not supported."
    ;;
esac

# Run <prefix> + I to install plugins the first time
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ];then
  msg "${UL}Installing TMUX plugin manager."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
  msg "${UL}Installing TMUX plugins. You may need to run <prefix> + I to install plugins if this doesn't work"
  eval "$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
fi

msg "${BLU}Install complete."

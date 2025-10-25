#!/bin/bash
# tmux terminal multiplexer

# This profile will be installed by the COMMON profile so you
# dont need to add it to other roles

PKG_NAME=tmux
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

# Run <prefix> + I to install plugins the first time
TMUXDIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TMUXDIR" ];then
  msg "${UL}Installing TMUX plugin manager."
  mkdir -p "$TMUXDIR"
  git clone https://github.com/tmux-plugins/tpm "$TMUXDIR"
  msg "${UL}Installing TMUX plugins. You may need to run <prefix> + I to install plugins if this doesn't work"
  eval "$TMUXDIR/bin/install_plugins"
fi

msg "${BLU}Install complete."

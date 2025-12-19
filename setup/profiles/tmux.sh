#!/bin/bash
# tmux terminal multiplexer

PKG_NAME=tmux
# On linux lets prompt to install since we may be running this on a shared server
# NOTE: This means in this case we will not upgrade the current package.
function linux_install_tmux() {
  local -a install_cmd=("${@}")
  if ! command -v "$PKG_NAME" &> /dev/null; then
    prompt "Install tmux system wide? (N/y) "
    read -r REPLY < /dev/tty
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      sudo "${install_cmd[@]}" "$PKG_NAME"
    fi
  else
    VERSION=$(tmux -V | cut -d ' ' -f 2)
    msg "${BLU}Tmux is already installed: $VERSION"
  fi
}

case "$ID" in
  arch*)
    linux_install_tmux pacman --needed --noconfirm -S
    ;;
  debian*|ubuntu*)
    linux_install_tmux apt install -y
    ;;
  macos*)
    "$BREWPATH"/brew install "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

# Link our config
link_file ".config/$PKG_NAME"

# Now install tmux plugin manager
# You may need to run <prefix> + I to install plugins the first time
TMUXDIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TMUXDIR" ];then
  msg "${UL}Installing TMUX plugin manager."
  mkdir -p "$TMUXDIR"
  git clone https://github.com/tmux-plugins/tpm "$TMUXDIR"
  msg "${UL}Installing TMUX plugins. You may need to run <prefix> + I to install plugins if this doesn't work"
  eval "$TMUXDIR/bin/install_plugins"
fi

msg "${BLU}Install complete."

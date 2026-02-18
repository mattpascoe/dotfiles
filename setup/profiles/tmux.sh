#!/bin/bash
# tmux terminal multiplexer

PKG_NAME=tmux
# On linux lets prompt to install since we may be running this on a shared server
# NOTE: This means in this case we will not upgrade the current package.
function linux_install_tmux() {
  local -a INSTALL_COMMAND=("${@}")
  if ! command -v "$PKG_NAME" &> /dev/null; then
    prompt "Install tmux system wide? (N/y) "
    read -r REPLY < /dev/tty
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      "${INSTALL_COMMAND[@]}" "$PKG_NAME"
    fi
  else
    VERSION=$(tmux -V | cut -d ' ' -f 2)
    msg "${BLU}Tmux is already installed: $VERSION"
  fi
}

case "$ID" in
  arch*)
    #shellcheck disable=SC2086
    linux_install_tmux "$PLATFORM_INSTALLER_BIN" $INSTALLER_OPTS "$PKG_NAME"
    ;;
  debian*|ubuntu*)
    #shellcheck disable=SC2086
    linux_install_tmux "$PLATFORM_INSTALLER_BIN" install $INSTALLER_OPTS "$PKG_NAME"
    ;;
  macos*)
    #shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
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

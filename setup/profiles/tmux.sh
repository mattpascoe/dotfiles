#!/bin/bash
# tmux terminal multiplexer

PKG_NAME=tmux
# On linux lets prompt to install since we may be running this on a shared server
# NOTE: This means in this case we will not upgrade the current package.
# Extra args (e.g. "install" for apt) are passed through; PLATFORM_INSTALLER_BIN
# is expanded unquoted so "sudo apt" splits into separate words like other profiles.
function linux_install_tmux() {
  local -a EXTRA_ARGS=("${@}")
  if ! command -v "$PKG_NAME" &> /dev/null; then
    prompt "Install tmux system wide? (N/y) "
    read -r REPLY < /dev/tty
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      # shellcheck disable=SC2086
      $PLATFORM_INSTALLER_BIN "${EXTRA_ARGS[@]}" $INSTALLER_OPTS "$PKG_NAME"
    else
      msg "${BLU}Skipping system-wide tmux install."
    fi
  else
    VERSION=$(tmux -V | cut -d ' ' -f 2)
    msg "${BLU}Tmux is already installed: $VERSION"
  fi
}

case "$ID" in
  arch*)
    linux_install_tmux
    ;;
  debian*|ubuntu*)
    linux_install_tmux install
    ;;
  macos*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

# Config + plugins only make sense when tmux is actually available
# (e.g. user declined system-wide install on a shared host with no tmux).
if ! command -v "$PKG_NAME" &> /dev/null; then
  msg "${YEL}tmux not found on PATH; skipping config link and plugins."
  return 0 2>/dev/null || exit 0
fi

# Link our config
link_file ".config/$PKG_NAME"

# Now install tmux plugin manager
# You may need to run <prefix> + I to install plugins the first time
TMUXDIR="$HOME/.config/tmux/plugins/tpm"
if [ ! -d "$TMUXDIR" ]; then
  msg "${UL}Installing TMUX plugin manager."
  mkdir -p "$TMUXDIR"
  git clone https://github.com/tmux-plugins/tpm "$TMUXDIR"
  msg "${UL}Installing TMUX plugins. You may need to run <prefix> + I to install plugins if this doesn't work"
  eval "$TMUXDIR/bin/install_plugins"
fi

msg "${BLU}Install complete."

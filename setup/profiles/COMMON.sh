#!/bin/bash
# The COMMON profile will always be run first, by the setup script

# TODO: look into using stow or chezmoi.io for dotfile management? For now I'm keeping it simple

# This is the common setup for ALL platform types.
# It will run BEFORE any other packages are installed so it should not have any dependancies on them.
# Anything done here should operate of its own accord.
# A goal on this common setup is to only install as the local user. No sudo and all in $HOME.

# Ensure $HOME/data exists. Also used in _macos.sh script
if [ ! -d "$HOME"/data ]; then
  msg "${BLU}Creating $HOME/data directory. PUT YOUR DATA HERE!"
  mkdir -p "$HOME"/data
fi

# Ensure $HOME/.config exists
if [ ! -d "$HOME/.config" ]; then
  mkdir -p "$HOME/.config"
fi

# Add $HOME/bin to PATH so we can install and use binaries during this install
mkdir -p "$HOME/bin"
export PATH="$HOME/bin:$PATH"

msg "\n${UL}Ensuring install of requested base packages"
case "$ID" in
  debian*|ubuntu*)
    $PLATFORM_INSTALLER_BIN update -y
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "${LINUX_PKGS[@]}"
    # Remove some useless crap
    $PLATFORM_INSTALLER_BIN purge -y whoopsie
    ;;
  arch*)
    sudo dmesg -n 3 # Disable kernel messages since we are likely on a console
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN --disable-sandbox $INSTALLER_OPTS "${LINUX_PKGS[@]}"
    # Also make sure yay is installed for AUR support
    if ! command -v "yay" &> /dev/null; then
      tmpdir=$(mktemp -d)
      git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
      cd "$tmpdir/yay" || exit
      makepkg -si --noconfirm
      cd - > /dev/null || exit
    fi
    ;;
  macos*)
    #shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS -q "${BREW_PKGS[@]}"
    ;;
  *)
    msg "${RED}-!- This system is not a supported type, You should check that the following packages are installed:"
    echo "    ${LINUX_PKGS[*]}"
    ;;
esac
msg "${BLU}Base packages installed."

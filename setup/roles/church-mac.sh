#!/usr/bin/env bash
# This role is a minimal desktop setup with my must haves only

PROFILES=(
  starship
  fzf
  tmux
  nerdfonts
  brave-browser
  ghostty
  neovim
  proton-pass
)

# Only process if we are not checking status
if [[ -z "$ROLE_STATUS" ]]; then
  run_profiles "${PROFILES[@]}"

  # Setup some common config symlinks
  msg "Checking dotfile config symlinks"
  link_file ".config/btop"
  link_file ".profile"
  link_file ".vimrc"
  link_file ".zshrc"

  # Install some apps directly with no profile layer
  # shellcheck disable=SC2086
  $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS vlc libreoffice

  # Set up SSH service, Does require terminal app to have full disk privs
  sudo systemsetup -setremotelogin on
fi

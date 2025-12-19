#!/bin/bash
# This role is for Matts standard Mac desktop setup

PROFILES=(
  desktop
  tmux
  nerdfonts
  1password
  aichat
  brave-browser
  ghostty
  kanata
  hammerspoon
  lazygit
  lnav
  neovim
  slack
  spotify
  trippy
  zoom
  zk
)

PROFILE_DIR="$DOTREPO"/setup/profiles
for PROFILE in "${PROFILES[@]}"; do
  # Check that it actually exists
  if [ ! -f "$PROFILE_DIR/$PROFILE.sh" ]; then
    msg "${RED}-!- Profile $PROFILE does not exist. Skipping."
    continue
  fi
  # Get the second line for a description to the user
  DESC=$(sed -n '2p' "$PROFILE_DIR/$PROFILE.sh")
  msg "Installing ${PROFILE} -- ${DESC}"
  source "$PROFILE_DIR/$PROFILE.sh"
done

# Setup some common config symlinks
link_file ".config/btop"
link_file ".config/git"
link_file ".profile"
link_file ".vimrc"
link_file ".zshrc"

#!/bin/bash
# This role is for Matts standard Mac desktop setup

source "$DOTREPO/setup/setup_lib.sh"

PROFILES=(
  desktop
  1password
  aichat
  brave-browser
  ghostty
  kanata
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

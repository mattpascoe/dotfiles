#!/bin/bash
# A basic install with no desktop settings

PROFILES=(
  lazygit
  neovim
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

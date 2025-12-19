#!/bin/bash
# A basic install with no desktop settings for work purposes

PROFILES=(
  tmux
  nerdfonts
  # This installs to ~/bin not system wide
  lazygit
  # neovim is managed separately and will conflict
  #neovim
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

# Link in our nvim config. We will expect neovim to be installed already outside of our profile
link_file ".config/nvim"

# Setup some common config symlinks
link_file ".config/btop"
#link_file ".config/git"
#link_file ".profile"
#link_file ".vimrc"
#link_file ".zshrc"

#!/usr/bin/env bash
# This role is a minimal desktop setup with my must haves only

PROFILES=(
  starship
  fzf
  tmux
  nerdfonts
  batcat
  brave-browser
  ghostty
  hammerspoon
  lazygit
  neovim
  netbird
  1password
)

# other things to install or setup profiles for
# microsoft office
# quicken
#
#
# Only process if we are not checking status
if [[ -z "$ROLE_STATUS" ]]; then
  run_profiles "${PROFILES[@]}"

  # Setup some common config symlinks
  msg "Checking dotfile config symlinks"
  link_file ".config/btop"
  link_file ".config/git"
  link_file ".profile"
  link_file ".vimrc"
  link_file ".zshrc"
fi

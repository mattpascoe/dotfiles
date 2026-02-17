#!/usr/bin/env bash
# A basic install with no desktop settings for work purposes

PROFILES=(
  starship
  fzf
  tmux
  nerdfonts
  # This installs to ~/bin not system wide
  lazygit
  # This installs to ~/bin not system wide
  neovim
)

# Only process if we are not checking status
if [[ -z "$ROLE_STATUS" ]]; then
  run_profiles "${PROFILES[@]}"

  # Setup some common config symlinks
  msg "Checking dotfile config symlinks"
  link_file ".config/btop"
  #link_file ".config/git"
  link_file ".profile"
  link_file ".vimrc"
  link_file ".zshrc"
fi

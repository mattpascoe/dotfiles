#!/bin/bash
# A basic install with no desktop settings

PROFILES=(
  starship
  fzf
  tmux
  nerdfonts
  lazygit
  neovim
)

run_profiles "${PROFILES[@]}"

# Setup some common config symlinks
msg "Checking dotfile config symlinks"
link_file ".config/btop"
link_file ".config/git"
link_file ".profile"
link_file ".vimrc"
link_file ".zshrc"

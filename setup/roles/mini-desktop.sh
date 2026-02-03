#!/usr/bin/env bash
# This role is a minimal desktop setup with my must haves only

PROFILES=(
  starship
  fzf
  desktop
  tmux
  nerdfonts
  aichat
  brave-browser
  ghostty
  kanata
  hammerspoon
  lazygit
  lnav
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

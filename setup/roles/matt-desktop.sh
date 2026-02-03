#!/usr/bin/env bash
# This role is for Matts standard Mac desktop setup

PROFILES=(
  starship
  fzf
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

run_profiles "${PROFILES[@]}"

# Setup some common config symlinks
msg "Checking dotfile config symlinks"
link_file ".config/btop"
link_file ".config/git"
link_file ".profile"
link_file ".vimrc"
link_file ".zshrc"

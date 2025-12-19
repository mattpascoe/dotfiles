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

run_profiles "$PROFILES"

msg "Checking dotfile config symlinks"
# Link in our nvim config. We will expect neovim to be installed already outside of our profile
link_file ".config/nvim"

# Setup some common config symlinks
link_file ".config/btop"
#link_file ".config/git"
#link_file ".profile"
#link_file ".vimrc"
#link_file ".zshrc"

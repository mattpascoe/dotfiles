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

  # Homebrew cask names. macOS only.
  case "$ID" in
    macos*) install_pkgs microsoft-office quicken ;;
    *) msg "${BLU}Skipping Office and Quicken. Package names are macOS only." ;;
  esac
fi

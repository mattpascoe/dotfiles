# This file contains configuration for the setup scripts to use.
# It can be sourced in as needed

# Set the location of our dotfiles git repo
# Other scripts may be relative to this
DOTREPO=~/dotfiles

# Set the URL of the dotfiles repo
DOTREPO_URL=https://github.com/mattpascoe/dotfiles

# Set the default timezone (mac)
TIMEZONE=America/Boise

# Some common packages for all platforms
COMMON_PKGS+=(
  "bat"
  "eza"
  "highlight"
  "jq"
  "tree"
)

# These are base packages I hope to use on all systems
# This will use the native package manager to install
LINUX_PKGS+=(
  "${COMMON_PKGS[@]}"
  "curl"
  "btop"
  "ripgrep"
  "shellcheck"
  "zsh"
)

# Homebrew packages
BREW_PKGS+=(
  "${COMMON_PKGS[@]}"
  "bash"
  "ykman"
  "shellcheck"
  "maccy"
  "homebrew/cask/syncthing"
  #"michaelroosz/ssh/libsk-libfido2"
)

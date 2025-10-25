# This file contains configuration for the setup scripts to use.
# It can be sourced in as needed

# Set the location of our dotfiles git repo
# Other scripts may be relative to this
DOTREPO=~/dotfiles

# Set the URL of the dotfiles repo
DOTREPO_URL=https://github.com/mattpascoe/dotfiles

# Set the default timezone (linux)
TIMEZONE=America/Boise

# These are base packages I hope to use on all systems
# This will use the native package manager to install
LINUX_PKGS+=(
  "bat"
  "btop"
  "curl"
  "eza"
  "git"
  "highlight"
  "jq"
  "tmux"
  "tree"
  "ripgrep"
  "shellcheck"
#  "yazi" # not on ubuntu but is on arch so far I dont use it much anyway. TBD
  "zsh"
)

# Homebrew packages
BREW_PKGS+=(
  # Some common packages
  "bat"
  "eza"
  "highlight"
  "jq"
  "tree"
  "tmux"
  # Below are more Mac specific, and dont require a full profile
  "bash"
  "ykman"
  "shellcheck"
  "maccy"
  "homebrew/cask/syncthing"
  #"michaelroosz/ssh/libsk-libfido2"
)

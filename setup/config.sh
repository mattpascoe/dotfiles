# This file contains configuration for the setup scripts to use.
# It can be sourced in as needed

# Set the location of our dotfiles git repo
# Other scripts may be relative to this
DOTREPO=~/dotfiles

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
  # Below are more Mac specific
  "maccy"
  "1password"
  "brave-browser"
  "ghostty"
  "bash"
  "nvim"
  "ykman"
  "jesseduffield/lazygit/lazygit"
  "shellcheck"
  "font-meslo-lg-nerd-font"
  "font-monaspace-nerd-font"
  "homebrew/cask/syncthing"
  #"michaelroosz/ssh/libsk-libfido2"
)

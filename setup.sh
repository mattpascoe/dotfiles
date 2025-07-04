#!/bin/bash

# This does not need to run as root, it will sudo when needed
# lots of install stuff.. you should be able to run this over and over without issue
# TODO: refactor and have more "configuration" instead of hardcoded things like package installs
# TODO: look into using stow for dotfile management

set -eou pipefail

# Colors/formatting
UL="\033[4m" # underline
NC="\033[0m" # no color/format
YEL="\033[33m"
BLU="\033[34m"
RED="\033[31m"
GRN="\033[32m"
BOLD="\033[1m"

function msg() {
  command echo -e "${BOLD}${YEL}---> $*${NC}"
}

# Check if USER is set and try a fallback
USER="${USER:-$(whoami)}"

# Determine what type of machine we are on
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac

if [ -f /etc/os-release ]; then
  . /etc/os-release
fi

SCRIPT=$(readlink -f "$0")
DIR=$(dirname "$SCRIPT")
declare -a LINKFILES

echo -e "${BOLD}${BLU}Looks like we are a $MACHINE system.${NC}"

###### Unraid specific stuff, barebones zsh setup
if [ -f /etc/unraid-version ]; then
  msg "Setting up as an Unraid system."

  # Combine the zshrc and shell-common files into /boot/config
  cat .zshrc .shell-common > /boot/config/myzshrc
  # Copy the vimrc file to /boot/config
  cp .vimrc /boot/config/myvimrc
  # Replace the default go file with our own
  cp .unraid-go /boot/config/go
  # Set up a link for vim wiki to point at my sync copy
  if [ ! -L ~/data/SYNC/wiki ]; then
    ln -s /mnt/user/data-syncthing/matt-personal/wiki ~/data/SYNC/wiki
  fi

  msg "Updates to /boot/config have been made."
  # Stop here since unraid is its own beast
  exit
fi

###### Ensure ~/data exists. Also used in .macos script
if [ ! -d ~/data ]
then
  msg "Creating ~/data directory. PUT YOUR DATA HERE!"
  mkdir ~/data
fi

###### Linux specific stuff
if [ "$MACHINE" == "Linux" ]; then
  echo -e "${BOLD}${BLU}Looks like the OS is ${PRETTY_NAME}.${NC}"

  # These are base packages I hope to use on all systems
  PKGS+=(
    "bat"
    "btop"
    "eza"
    "fzf"
    "git"
    "highlight"
    "jq"
  #  "lazygit" # not on ubuntu but is on arch
    "neovim"
    "tmux"
    "tree"
  #  "yazi" # not on ubuntu but is on arch
    "zsh"
  )

  msg "Ensuring install of requested base packages..."
  case "$ID" in
    debian*)    sudo apt install -y "${PKGS[@]}";;
    ubuntu*)    sudo apt install -y "${PKGS[@]}";;
    arch*)      sudo pacman --needed --noconfirm -Sy "${PKGS[@]}";;
    *)  echo -e "${BOLD}${RED}-!- This system is not a supported type, You should check that the following packages are installed:${NC}"
        echo "    ${PKGS[*]}";;
  esac

  # Ensure zsh is default if its available
  if command -v "zsh" &> /dev/null; then
    if [ "$(grep "$USER" /etc/passwd|cut -d: -f7)" != "/bin/zsh" ]; then
      msg "Switching default shell to ZSH, provide your password if prompted..."
      chsh -s /bin/zsh
    fi
  fi

  # Ensure Nerd Fonts are installed
  if [ ! -f /usr/local/share/fonts/MesloLGMNerdFontMono-Regular.ttf ]; then
    msg "Installing Nerd Fonts..."
    sudo mkdir -p /usr/local/share/fonts
    sudo curl -s -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontMono-Regular.ttf --output-dir /usr/local/share/fonts
    fc-cache -fv /usr/local/share/fonts
  fi
fi


###### Mac specific stuff
if [ "$MACHINE" == "Mac" ]; then
  # Install Git if it does not exist
  if ! command -v "git" &> /dev/null; then
    # run git command, it may ask to install developer tools, go ahead and do that to get the git command
    msg "Checking git version. If missing it will prompt to install developer tools..."
    git --version
  fi

  # Run NIX if we want
  echo -en "${BOLD}${GRN}Install NIX based packages... Continue (N/y) ${NC}"
  read -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if ! command -v "nix" &> /dev/null; then
      msg "Installing NIX tools..."
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    fi

    if command -v "nix" &> /dev/null; then
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
      nix flake update --flake .config/home-manager
      nix run home-manager -- switch --flake .config/home-manager
      # INFO: ok I'm leaving this impure info here for reference. https://nixos.wiki/wiki/1Password
      # I stopped using it since 1password does not integrate properly with the browser plugins
      # Running impure to install 1password gui that is flagged broken due to
      # /Applications requirement. I am ok because I copy all apps to
      # /Applications to fix the stupid spotlight problem
      # NIXPKGS_ALLOW_BROKEN=1 nix run home-manager -- switch --impure --flake .config/home-manager
      # #NIXPKGS_ALLOW_BROKEN=1 home-manager --impure switch (this is how you can run it manually)
    else
      echo -e "${BOLD}${RED}-!- ERROR: Unable to find NIX command. Please install NIX and try again.${NC}"
    fi
  else
    msg ".. Skipping NIX based config changes."
  fi

  # Run brew if we want
  #echo -en "${BOLD}${GRN}Install Homebrew based packages... Continue (N/y) ${NC}"
  #read -r
  #if [ "$REPLY" == "yDISABLED" ]; then
  #  if ! command -v "brew" &> /dev/null; then
  #    msg "Installing Brew tools..."
  #    #/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  #  fi

  #  # Load up brew environment, should work on ARM intel systems.
  #  if command -v "brew" &> /dev/null; then
  #    eval "$(brew shellenv)"

  #    msg "Ensuring install of requested brew packages..."
  #    brew install -q iterm2 maccy 1password brave-browser homebrew/cask-fonts/font-meslo-lg-nerd-font homebrew/cask-fonts/font-monaspace-nerd-font jq fzf highlight tree homebrew/cask/syncthing michaelroosz/ssh/libsk-libfido2 ykman tmux bash jesseduffield/lazygit/lazygit shellcheck eza

  #  else
  #    echo -e "${BOLD}${RED}-!- ERROR: Unable to find Brew command. Please install Brew and try again.${NC}"
  #  fi

  #else
  #  echo ".. [DISABLED] Skipping Brew based config changes."
  #fi

  # Setup lots of system settings using the "defaults" method
  echo -en "${BOLD}${GRN}Execute 'defaults' commands to set specific Mac settings... Continue (N/y) ${NC}"
  read -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo ~/dotfiles/.macos
  else
    msg ".. Skipping defaults based config changes."
  fi

  # For some reason /usr/local/bin is not on mac by default. Lets make it for starship
  if [ ! -d /usr/local/bin ]; then
    sudo mkdir -p /usr/local/bin
    sudo chown $(whoami):admin /usr/local/bin
  fi
fi

# Everyone gets starship!
if ! command -v "starship" &> /dev/null; then
  echo -en "${BOLD}${GRN}Do you want to install Starship.rs prompt? [y/N] ${NC}"
  read -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo sh -c "curl -fsSL https://starship.rs/install.sh | sh"
  fi
else
  msg "Starship is alredy installed."
fi

###### Link dotfile configs, could I use stow or chezmoi.io? sure, but less dependancies here
LINKFILES+=(
  ".config/btop"
  ".config/ghostty"
  ".config/git"
  ".config/home-manager"
  #".config/kitty"
  ".config/lazygit"
  ".config/nvim"
  ".config/rofi"
  ".config/starship.toml"
  ".config/tmux"
  ".config/zk"
  ".profile"
  ".vimrc"
  ".zshrc"
)
msg "Checking dotfile config symlinks..."
for FILE in "${LINKFILES[@]}"
do
  if [ ! -L "$HOME/$FILE" ]; then
    if [ -e "$HOME/$FILE" ]; then
      msg "Backing up current file to ${FILE}.bak"
      mv "$HOME/$FILE" "$HOME/$FILE.bak"
    fi
    msg "Linking file $HOME/$FILE -> $DIR/$FILE"
    ln -s "$DIR/$FILE" "$HOME/$FILE"
  else
    echo -n "Found link: "
    ls -o "$HOME/$FILE"
  fi
done

# Run <prefix> + I to install plugins the first time
if [ ! -d ~/.config/tmux/plugins/tpm ];then
  msg "Installing TMUX plugin manager."
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
  msg "Installing TMUX plugins. You may need to run <prefix> + I to install plugins if this doesn't work"
  ~/.config/tmux/plugins/tpm/bin/install_plugins
fi

echo
msg "Setup complete."

echo -en "${BOLD}${GRN}Do you want to source the .shell-common file? [y/N] ${NC}"
read -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  source "$DIR/.shell-common"
fi


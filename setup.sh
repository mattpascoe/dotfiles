#!/bin/bash

# This does not need to run as root, it will sudo when needed
# lots of install stuff.. you should be able to run this over and over without issue
# TODO: refactor and have more "configuration" instead of hardcoded things like package installs
# TODO: look into using stow for dotfile management

set -eou pipefail

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

echo
echo "Looks like we are a $MACHINE system."

###### Unraid specific stuff, barebones zsh setup
if [ -f /etc/unraid-version ]; then
  echo "- Setting up as an Unraid system."

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

  echo "- Updates to /boot/config have been made."
  # Stop here since unraid is its own beast
  exit
fi

###### Ensure ~/data exists. Also used in .macos script
if [ ! -d ~/data ]
then
  echo "- Creating ~/data directory. PUT YOUR DATA HERE!"
  mkdir ~/data
fi

###### Linux specific stuff
if [ "$MACHINE" == "Linux" ]; then
  echo "Looks like the OS is $PRETTY_NAME"
#  read -p "Do you want i3 configuration links? [y/N] " -r I3
#  echo    # (optional) move to a new line
#  if [[ $I3 =~ ^[Yy]$ ]]
#  then
#    LINKFILES+=(".config/i3")
#  fi

  PKGS+=("git"
    "bat"
    "btop"
    "eza"
    "fzf"
    "highlight"
    "jq"
    "neovim"
    "tmux"
    "tree"
    "zsh"
  )

  echo "- Ensuring install of requested packages..."
  case "$ID" in
    debian*)    sudo apt install "${PKGS[@]}";;
    ubuntu*)    sudo apt install "${PKGS[@]}";;
    *)  echo "-!- This system is not a supported type, You should check that the following packages are installed:"
        echo "    ${PKGS[*]}";;
  esac

  # Ensure zsh is default
  if [ "$(grep $USER /etc/passwd|cut -d: -f7)" != "/bin/zsh" ]; then
    echo "- Switching default shell to ZSH, provide your password if prompted..."
    chsh -s /bin/zsh
  fi

  # Ensure Nerd Fonts are installed
  if [ ! -f /usr/local/share/fonts/MesloLGMNerdFontMono-Regular.ttf ]; then
    echo "- Installing Nerd Fonts..."
    sudo curl -s -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontMono-Regular.ttf --output-dir /usr/local/share/fonts
    fc-cache -fv /usr/local/share/fonts
  fi

  echo "-!- Consider installing the following"
  echo "lazygit yazi"
fi


###### Mac specific stuff
if [ "$MACHINE" == "Mac" ]; then
  # Install Git if it does not exist
  if ! type "git" > /dev/null; then
    # run git command, it may ask to install developer tools, go ahead and do that to get the git command
    echo "- Checking git version. If missing it will prompt to install developer tools..."
    git --version
  fi

  # Run NIX if we want ( should probably move to all systems level)
  read -r -p "- Install NIX based packages... Continue (N/y) "
  if [ "$REPLY" == "y" ]; then
    if ! type "nix" > /dev/null; then
      echo "- Installing NIX tools..."
      curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    fi

    if type "nix" > /dev/null; then
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
      echo "ERROR: Unable to find NIX command"
    fi
  else
    echo ".. Skipping NIX based config changes."
  fi

  # Run brew if we want
  read -r -p "- Install Homebrew based packages... Continue (N/y) "
  if [ "$REPLY" == "yDISABLED" ]; then
    if ! type "brew" > /dev/null; then
      echo "- Installing Brew tools..."
      #/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Load up brew environment, should work on ARM intel systems.
    if type "brew" > /dev/null; then
      eval "$(brew shellenv)"

      # Disabling yabai for now as well
#      read -p "Do you want yabai/skhd configuration? [y/N] " -r YAB
#      echo    # (optional) move to a new line
#      if [[ $YAB =~ ^[Yy]$ ]]
#      then
#        # Tiling window manager and shortcuts
#        brew install koekeishiya/formulae/yabai koekeishiya/formulae/skhd
#
#        LINKFILES+=(".config/yabai" ".config/skhd")
#      fi

      echo "- Ensuring install of requested brew packages..."
      brew install -q iterm2 maccy 1password brave-browser homebrew/cask-fonts/font-meslo-lg-nerd-font homebrew/cask-fonts/font-monaspace-nerd-font jq fzf highlight tree homebrew/cask/syncthing michaelroosz/ssh/libsk-libfido2 ykman tmux bash jesseduffield/lazygit/lazygit shellcheck eza

    else
      echo "ERROR: Unable to find Brew command"
    fi

  else
    echo ".. [DISABLED] Skipping Brew based config changes."
  fi

  # Setup lots of system settings using the "defaults" method
  read -r -p "- Execute 'defaults' commands to set specific Mac settings... Continue (N/y) "
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo ~/dotfiles/.macos
  else
    echo ".. Skipping defaults based config changes."
  fi

  # For some reason /usr/local/bin is not on mac by default. Lets make it for starship
  if [ ! -d /usr/local/bin ]; then
    sudo mkdir -p /usr/local/bin
    sudo chown $(whoami):admin /usr/local/bin
  fi
fi

# Everyone gets starship!
if ! type "starship" &> /dev/null; then
  read -p "Do you want to install Starship.rs prompt? [y/N] " -r STAR
  echo    # (optional) move to a new line
  if [[ $STAR =~ ^[Yy]$ ]]; then
    sudo sh -c "curl -fsSL https://starship.rs/install.sh | sh"
  fi
else
  echo "- Starship is alredy installed."
fi

###### Link dotfile configs, could I use stow or chezmoi.io? sure, but less dependancies here
LINKFILES+=(
  ".config/btop"
  ".config/git"
  ".config/ghostty"
  ".config/home-manager"
  ".config/lazygit"
  ".config/kitty"
  ".config/nvim"
  ".config/starship.toml"
  ".config/tmux"
  ".profile"
  ".vimrc"
  ".zshrc"
)
echo "- Checking dotfile config symlinks..."
for FILE in "${LINKFILES[@]}"
do
  if [ ! -L "$HOME/$FILE" ]; then
    if [ -e "$HOME/$FILE" ]; then
      echo "Backing up current file to ${FILE}.bak"
      mv "$HOME/$FILE" "$HOME/$FILE.bak"
    fi
    echo "Linking file $HOME/$FILE -> $DIR/$FILE"
    ln -s "$DIR/$FILE" "$HOME/$FILE"
  else
    echo -n "Found link: "
    ls -o "$HOME/$FILE"
  fi
done

# Run <prefix> + I to install plugins the first time
if [ ! -d ~/.config/tmux/plugins/tpm ];then
  echo "Installing TMUX plugin manager."
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
  echo "Installing TMUX plugins. You may need to run <prefix> + I to install plugins if this doesn't work"
  ~/.config/tmux/plugins/tpm/bin/install_plugins
fi

echo
echo "Setup complete."

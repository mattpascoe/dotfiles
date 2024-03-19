#!/bin/bash

# lots of install stuff.. you should be able to run this over and over without issue
# TODO: refactor and have more "configuration" instead of hardcoded things like package installs
# TODO: look into using stow for dotfile management

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
  if ! type "starship" &> /dev/null; then
    read -p "Do you want to install Starship.rs prompt? [y/N] " -r STAR
    echo    # (optional) move to a new line
    if [[ $STAR =~ ^[Yy]$ ]]
    then
      sudo sh -c "curl -fsSL https://starship.rs/install.sh | sh"
    fi
  else
    echo "- Starship is alredy installed."
  fi

  read -p "Do you want i3 configuration links? [y/N] " -r I3
  echo    # (optional) move to a new line
  if [[ $I3 =~ ^[Yy]$ ]]
  then
    LINKFILES+=(".config/i3")
  fi

  PKGS+=("git" "jq" "fzf" "tree" "zsh" "highlight" "tmux")
  echo "- Ensuring install of requested packages..."
  case "$ID" in
    debian*)    sudo apt install "${PKGS[@]}";;
    ubuntu*)    sudo apt install "${PKGS[@]}";;
    *)  echo "-!- This system is not a supported type, You should check that the following packages are installed:"
        echo "    ${PKGS[@]}";;
  esac

  if [ ! -f /bin/zsh ]; then
    echo "- Switching default shell to ZSH, provide your password if prompted..."
    chsh -s /bin/zsh
  fi

  echo "-!- Consider installing the following"
  echo "lazygit"
fi


###### Mac specific stuff
if [ "$MACHINE" == "Mac" ]; then
  # Install Git if it does not exist
  if ! type "git" > /dev/null; then
    # run git command, it may ask to install developer tools, go ahead and do that to get the git command
    echo "- Checking git version. If missing it will prompt to install developer tools..."
    git --version
  fi

  if ! type "brew" > /dev/null; then
    echo "- Installing Brew tools..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Load up brew environment, should work on ARM intel systems.
  if type "brew" > /dev/null; then
    eval "$(brew shellenv)"

    read -p "Do you want yabai/skhd configuration? [y/N] " -r YAB
    echo    # (optional) move to a new line
    if [[ $YAB =~ ^[Yy]$ ]]
    then
      # Tiling window manager and shortcuts
      brew install koekeishiya/formulae/yabai koekeishiya/formulae/skhd

      LINKFILES+=(".config/yabai" ".config/skhd")
    fi

    echo "- Ensuring install of requested brew packages..."
    brew install -q iterm2 maccy 1password brave-browser homebrew/cask-fonts/font-meslo-lg-nerd-font homebrew/cask-fonts/font-monaspace-nerd-font jq fzf highlight tree homebrew/cask/syncthing michaelroosz/ssh/libsk-libfido2 ykman tmux bash jesseduffield/lazygit/lazygit shellcheck

    echo "-!- Consider installing the following"
    echo "brew install zoom homebrew/cask-fonts/font-jetbrains-mono-nerd-font"
    echo
  else
    echo "ERROR: Unable to find Brew command"
  fi

#needs rosetta on m1
# brew install -q homebrew/cask-drivers/yubico-authenticator

  read -r -p "- Execute 'defaults' commands to set specific Mac settings... Continue (N/y) "
  if [ "$REPLY" == "y" ]; then
    ~/dotfiles/.macos
  else
    echo ".. Skipping defaults based config changes."
  fi
fi

###### Link dotfile configs
LINKFILES+=(".profile" ".vimrc" ".config/nvim" ".zshrc" ".config/tmux" ".config/git" ".config/btop" ".config/lazygit" ".config/starship.toml")
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

if [ ! -d ~/.tmux/plugins/tpm ];then
  echo "Installing TMUX plugin manager."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

echo
echo "Setup complete."

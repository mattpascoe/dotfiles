#!/bin/bash

set -e

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

echo "Updating system packages..."
case "$ID" in
debian*|ubuntu*)
  sudo apt update -y
  sudo apt install -y git
  ;;
arch*)
  # Disable kernel messages since we are likely on a console
  # We'll turn it back on in setup.sh
  sudo dmesg -n 3
  # Update the system and ensure git is installed
  sudo pacman --disable-sandbox --needed --noconfirm -Syu git curl wget sudo fontconfig
  ;;
*)
  if [ "$MACHINE" == "Mac" ]; then
    # Install Git if it does not exist
    if ! command -v "git" &> /dev/null; then
      # run git command, it may ask to install developer tools, go ahead and do that to get the git command
      msg "Checking git version. If missing it will prompt to install developer tools..."
      git --version
    fi
  else
    echo -e "-!- This system is not a supported type"
  fi
  ;;
esac

# set the location of our dotfiles install
DOTDIR=~/dotfiles

# Test if the dotfiles dir already exists.
if [ ! -d "$DOTDIR" ]; then
  echo "  Cloning dotfiles to $DOTDIR..."
  git clone https://github.com/mattpascoe/dotfiles "$DOTDIR"
else
  echo "  Git repo already exists."
#  echo "Updating dotfiles..."
#  cd "$DOTDIR" || exit
#  git pull >/dev/null
#  cd - > /dev/null || exit
fi

# Ask if you want to run installer or not
echo -en "Run setup scripts? Continue [Y/n] "
read -r REPLY < /dev/tty
REPLY=${REPLY:-Y} # Default to yes
if [[ $REPLY =~ ^[Yy]$ ]]; then
  source "$DOTDIR/setup.sh"
fi

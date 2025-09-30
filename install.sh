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
debian*)    sudo apt update -y ;
	    sudo apt install -y git ;;
ubuntu*)    sudo apt update -y ;
	    sudo apt install -y git ;;
arch*)      sudo pacman --needed --noconfirm -Sy ;
            sudo pacman --needed --noconfirm -Sy git ;;
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


# test if the dotfiles dir already exists.  if not clone it, if it does git pull
if [ ! -d ~/dotfiles ]; then
  echo "  Cloning dotfiles..."
  echo git clone https://github.com/mattpascoe/dotfiles ~/dotfiles >/dev/null
else
  echo "  Git repo already exists."
#  echo "Updating dotfiles..."
#  cd '~/dotfiles' || exit
#  git pull >/dev/null
#  cd - > /dev/null || exit
fi

# ask if you want to run installer or not
echo -en "Run setup scripts? Continue (N/y) "
read -r
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "  Running setup scripts..."
  echo source ~/dotfiles/setup.sh
fi

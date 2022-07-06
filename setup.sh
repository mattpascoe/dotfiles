#!/bin/bash

# lots of install stuff.. you should be able to run this over and over without issue
# TODO: refactor and have more "configuration" instead of hardcoded things like package installs

# Determine what type of machine we are on
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac

SCRIPT=$(readlink -f $0)
DIR="$(dirname $SCRIPT)"


echo
echo "Looks like we are a $MACHINE system."

###### Ensure ~/data exists. Also used in .macos script
if [ ! -d ~/data ]
then
  echo "- Creating ~/data directory. PUT YOUR DATA HERE!"
  mkdir ~/data
fi

###### Install Git if it does not exist
if ! type "git" > /dev/null; then
  if [ "$MACHINE" == "Mac" ]; then
    # run git command, it may ask to install developer tools, go ahead and do that to get the git command
    echo "- Checking git version. If missing it will prompt to install developer tools..."
    git --version
  fi
  if [ "$MACHINE" == "Linux" ]; then
    # For now, its debian based.. cuz.. RPM??
    apt-get install git
  fi
fi

###### Link dotfile configs
declare -a LINKFILES=(".profile" ".screenrc" ".vimrc" ".zshrc")
echo "- Checking dotfile config symlinks..."
for FILE in "${LINKFILES[@]}"
do
  if [ ! -L $HOME/$FILE ]; then
    if [ -e $HOME/$FILE ]; then
      echo "Backing up current file to ${FILE}.bak"
      mv $HOME/$FILE $HOME/$FILE.bak
    fi
    echo "Linking file $HOME/$FILE -> $DIR/$FILE"
    ln -s $DIR/$FILE $HOME/$FILE
  else
    echo -n "Found link: "
    ls -o $HOME/$FILE
  fi
done


###### Mac specific stuff
if [ "$MACHINE" == "Mac" ]; then
  if ! type "brew" > /dev/null; then
    echo "- Installing Brew tools..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  echo "- Ensuring install of requested brew packages..."
  brew install -q iterm2 maccy 1password brave-browser homebrew/cask-fonts/font-meslo-lg-nerd-font jq

  echo "-!- Consider installing the following"
  echo "brew install zoom"
  echo

#needs rosetta on m1
# brew install -q homebrew/cask-drivers/yubico-authenticator

  read -p "- Execute 'defaults' commands to set specific Mac settings... Continue (N/y) "
  if [ "$REPLY" == "y" ]; then
    ~/dotfiles/.macos
  else
    echo ".. Skipping defaults based config changes."
  fi
fi







## TODO: look more into neo-vim
## download the vim plug module
#if [ ! -f ~/.vim/autoload/plug.vim ]
#then
#  echo "Downloading vim-plug module..."
#  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
#fi

#echo
#echo "Once .vimrc is linked in you should run the following command to initialize vim plugins:"
#echo "       vim +PlugInstall +qall"

echo
echo "Setup complete."

#!/bin/bash

# Using the list of files in this directory
# make symlinks for the same files in the current
# users home directory..


# Determin what type of machine we are on
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac


# TODO: maybe add a backup copy operation
# TODO: needs to check for existing files
read -p "Linking all dotfiles in $PWD to files in $HOME. Continue? (y/N): "
echo

if [ "$REPLY" == "y" ]
then
  for FILE in $(find `pwd` -name "\.*")
  do
    # Ignore a few files
    if [ $(echo $FILE | egrep "(\.git$|\.svn$|\.macos)") ]
    then
      continue
    else
      echo ln -s $FILE $HOME/$(basename $FILE)
    fi
  done


fi

###### Install Git if it does not exist
if ! type "git" > /dev/null; then
  if [ "$MACHINE" == "Mac" ]; then
    # run git command, it may ask to install developer tools, go ahead and do that to get the git command
    echo "Running git command, this should prompt to install developer tools.... "
    git --help
  fi
  if [ "$MACHINE" == "Linux" ]; then
    # For now, its debian based.. cuz.. RPM??
    apt-get install git
  fi

fi

###### Mac specific stuff
if [ "$MACHINE" == "Mac" ]; then
  echo "installing Brew tools...."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "brew install iterm2 clipy 1password brave-browser"
  echo "~/dotfiles/.macos"
fi

echo
echo "Commands above not executed, cut/paste as desired"







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

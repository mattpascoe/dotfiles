#!/bin/bash

# Using the list of files in this directory
# make symlinks for the same files in the current
# users home directory..

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

  echo
  echo "Commands above not executed, cut/paste as desired"

fi

# download the vim plug module
if [ ! -f ~/.vim/autoload/plug.vim ]
then
  echo "Downloading vim-plug module..."
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

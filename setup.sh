#!/bin/bash

# Using the list of files in this directory
# make symlinks for the same files in the current
# users home directory..

# TODO: maybe add a backup copy operation
# TODO: needs to check for existing files
read -p "Linking all dotfiles in $PWD to files in $HOME. Continue? (y/N): "

if [ "$REPLY" == "y" ]
then
  for FILE in $(find `pwd` -name "\.*")
  do
    # Ignore a few files
    if [ $(echo $FILE | egrep "(\.git$|\.svn$)") ]
    then
      continue
    else
      echo ln -s $FILE $HOME/$(basename $FILE)
    fi
  done
fi


#!/bin/bash
#
###### Unraid specific stuff, barebones zsh setup

msg "${UL}Setting up as an Unraid system."

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

msg "${UL}Updates to /boot/config have been made."
# Stop here since unraid is its own beast
exit



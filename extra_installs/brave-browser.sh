#!/bin/bash

# Get linux os type
[ -f /etc/os-release ] && . /etc/os-release
case "$ID" in
  debian*|ubuntu*)
    # Install using
    curl -fsS https://dl.brave.com/install.sh | sh
    xdg-settings set default-web-browser brave-browser.desktop
    ;;
  arch*)
    sudo pacman --needed --noconfirm -Sy brave-browser ;;
  *)
    echo "-!- Install not supported."
    ;;
esac


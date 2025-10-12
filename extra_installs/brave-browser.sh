#!/bin/bash
# The Brave web browser

# Get linux os type
[ -f /etc/os-release ] && . /etc/os-release
case "$ID" in
  debian*|ubuntu*)
    # Install using brave official repo script
    curl -fsS https://dl.brave.com/install.sh | sh
    xdg-settings set default-web-browser brave-browser.desktop
    ;;
#  arch*)
#    sudo pacman --needed --noconfirm -Sy brave-browser ;;
    # Install using brave official repo script
    # This requires an AUR like yay
    #curl -fsS https://dl.brave.com/install.sh | sh
  *)
    echo "-!- Install not supported."
    ;;
esac


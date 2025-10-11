#!/bin/bash
# Slack messaging app

# Get linux os type
[ -f /etc/os-release ] && . /etc/os-release
case "$ID" in
  debian*|ubuntu*)
    curl 'https://slack.com/downloads/instructions/linux?ddl=1&build=deb' -o /tmp/slack.deb
    sudo dpkg -i /tmp/slack.deb
    sudo rm /tmp/slack.deb
    ;;
  #arch*)
  #  sudo pacman --needed --noconfirm -Sy slack ;;
  *)
    echo "-!- Install not supported."
    ;;
esac


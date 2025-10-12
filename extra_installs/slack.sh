#!/bin/bash
# Slack messaging app

# Get linux os type
[ -f /etc/os-release ] && . /etc/os-release
case "$ID" in
  debian*|ubuntu*)
    # Lame extract of latest version of the deb file. Probably will break in the future
    curl -s "https://slack.com/downloads/instructions/linux?ddl=1&build=deb" \
    | tr "\t\r\n'" '   "' \
    | grep -ioE 'href\s*=\s*"?https://[^" >]+' \
    | sed -E 's/^href\s*=\s*"?(https:[^" >]+).*/\1/' \
    | grep 'slack-desktop' \
    | head -n 1 \
    | xargs -r curl -L -o /tmp/slack.deb

    sudo dpkg -i /tmp/slack.deb
    sudo rm /tmp/slack.deb
    ;;
  #arch*)
  #  sudo pacman --needed --noconfirm -Sy slack ;;
  *)
    echo "-!- Install not supported."
    ;;
esac


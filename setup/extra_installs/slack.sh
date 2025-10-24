#!/bin/bash
# Slack messaging app

source setup/setup_lib.sh

PKG_NAME=slack
case "$ID" in
  #arch*)
  #  sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  debian*|ubuntu*)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    if [[ $ARCH == "arm64" ]]; then
      echo "-!- Slack debian not supported on arm64."
    else
      # Ensure dependencies are installed
      sudo apt install libxss1
      # Lame extract of latest version of the deb file. Probably will break in the future
      # The .deb file looks to be amd64 type only.
      curl -s "https://slack.com/downloads/instructions/linux?ddl=1&build=deb" \
      | tr "\t\r\n'" '   "' \
      | grep -ioE 'href\s*=\s*"?https://[^" >]+' \
      | sed -E 's/^href\s*=\s*"?(https:[^" >]+).*/\1/' \
      | grep 'slack-desktop' \
      | head -n 1 \
      | xargs -r curl -L -o /tmp/slack.deb

      sudo dpkg -i /tmp/slack.deb
      sudo rm /tmp/slack.deb
    fi
    ;;
  macos*)
    if brew list "$PKG_NAME" >/dev/null 2>&1; then
      msg "${BLU}Already installed via brew on Mac."
    else
      msg "${GRN}Installing..."
      brew install "$PKG_NAME"
    fi
    ;;
  *)
    echo "-!- Install not supported."
    ;;
esac


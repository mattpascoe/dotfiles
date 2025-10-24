#!/bin/bash
# Zoom meeting app

source setup/setup_lib.sh

PKG_NAME=zoom
case "$ID" in
  #arch*)
  #  sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  debian*|ubuntu*)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    if [[ $ARCH == "arm64" ]]; then
      echo "-!- Slack debian not supported on arm64."
    else
      curl -L -o /tmp/zoom.deb "https://zoom.us/client/latest/zoom_${ARCH}.deb"
      sudo apt install /tmp/zoom.deb -y
      sudo rm /tmp/zoom.deb
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


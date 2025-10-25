#!/bin/bash
# Zoom meeting app

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
    brew install "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

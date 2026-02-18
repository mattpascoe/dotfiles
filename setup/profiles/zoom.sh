#!/bin/bash
# Zoom meeting app

PKG_NAME=zoom
case "$ID" in
  #arch*)
  #  sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  debian*|ubuntu*)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    if [[ $ARCH == "arm64" ]]; then
      echo "-!- Not supported on arm64."
    else
      curl -L -o /tmp/zoom.deb "https://zoom.us/client/latest/zoom_${ARCH}.deb"
      # shellcheck disable=SC2086
      $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS /tmp/zoom.deb
      sudo rm /tmp/zoom.deb
    fi
    ;;
  macos*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

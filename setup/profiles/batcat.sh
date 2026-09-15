#!/bin/bash
# Cat clone with syntax highlighting

PKG_NAME=bat
case "$ID" in
  arch*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN $INSTALLER_OPTS "$PKG_NAME" ;;
  debian*|ubuntu*)
    tmpdir=$(mktemp -d)
    ARCH=${ARCH:-$(uname -m)}
    case "$ARCH" in
      x86_64) TARGET=x86_64-unknown-linux-musl ;;
      aarch64) TARGET=aarch64-unknown-linux-musl ;;
      armv7l|armv6l|arm) TARGET=arm-unknown-linux-musleabihf ;;
      i686|i386) TARGET=i686-unknown-linux-musl ;;
      *)
        echo "-!- Unsupported architecture: $ARCH"
        rm -rf "$tmpdir"
        TARGET=""
        ;;
    esac
    if [[ -n "$TARGET" ]]; then
      VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')
      wget -q -P "$tmpdir" https://github.com/sharkdp/bat/releases/latest/download/bat-v"${VERSION}"-"${TARGET}".tar.gz
      tar xf "$tmpdir/bat"*.tar.gz -C "$tmpdir"
      install "$tmpdir"/bat-*/"${PKG_NAME}" "$BIN_DIR"
    fi
    rm -rf "$tmpdir"
    ;;
  macos*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d'
    ;;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

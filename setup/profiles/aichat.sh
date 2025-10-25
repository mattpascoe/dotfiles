#!/bin/bash
# AI chat cli for local LLMs

PKG_NAME=aichat
case "$ID" in
  #arch*)
  #  sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  debian*|ubuntu*)
    tmpdir=$(mktemp -d)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    VERSION=$(curl -s https://api.github.com/repos/sigoden/aichat/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')
    # Download and extract
    #wget https://github.com/sigoden/aichat/releases/latest/download/aichat-v${AICHAT_VERSION}-$(dpkg --print-architecture)-unknown-linux-musl.tar.gz
    wget -q -P "$tmpdir" https://github.com/sigoden/aichat/releases/latest/download/aichat-v"${VERSION}"-arm-unknown-linux-musleabihf.tar.gz
    tar xf "$tmpdir/aichat"*.tar.gz -C "$tmpdir" ${PKG_NAME}
    install -b "$tmpdir/${PKG_NAME}" "$HOME/bin"
    rm -rf "$tmpdir"
    ;;
  macos*)
    brew install "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

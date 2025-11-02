#!/bin/bash
# Zettelkasten note taking cli tool

PKG_NAME=zk
case "$ID" in
  arch*)
    sudo pacman --needed --noconfirm -S "$PKG_NAME" ;;
  debian*|ubuntu*)
    tmpdir=$(mktemp -d)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    VERSION=$(curl -s https://api.github.com/repos/zk-org/zk/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')
    # Download and extract
    wget -q -P "$tmpdir" https://github.com/zk-org/zk/releases/latest/download/zk-v"${VERSION}"-linux-"${ARCH}".tar.gz
    tar xf "$tmpdir/zk"*.tar.gz -C "$tmpdir" ${PKG_NAME}
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

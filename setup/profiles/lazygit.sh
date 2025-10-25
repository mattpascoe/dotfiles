#!/bin/bash
# Git TUI interface

PKG_NAME=lazygit
case "$ID" in
  arch*)
    sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  debian*|ubuntu*)
    tmpdir=$(mktemp -d)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    # Get the latest version of lazygit
    VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')
    wget -q -P "$tmpdir" https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_"${VERSION}"_linux_"${ARCH}".tar.gz
    tar xf "$tmpdir/lazygit"*.tar.gz -C "$tmpdir" lazygit
    # Move to a system-wide location
    sudo install -b "$tmpdir"/lazygit /usr/local/bin
    rm -rf "$tmpdir"
    ;;
  macos*)
    brew install "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

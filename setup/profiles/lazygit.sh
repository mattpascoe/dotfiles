#!/bin/bash
# Git TUI interface

PKG_NAME=lazygit
case "$ID" in
  arch*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN $INSTALLER_OPTS "$PKG_NAME"
    ;;
  debian*|ubuntu*)
    tmpdir=$(mktemp -d)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    # Get the latest version of lazygit
    VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')
    wget -q -P "$tmpdir" https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_"${VERSION}"_linux_"${ARCH}".tar.gz
    tar xf "$tmpdir/lazygit"*.tar.gz -C "$tmpdir" lazygit
    install -b "$tmpdir/${PKG_NAME}" "$HOME/bin"
    link_file ".config/$PKG_NAME"
    rm -rf "$tmpdir"
    ;;
  macos*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d'
    link_file ".config/$PKG_NAME"
    ;;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

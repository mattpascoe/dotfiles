#!/bin/bash
# Nvim editor

source setup/setup_lib.sh

PKG_NAME=neovim
case "$ID" in
  arch*)
    sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  debian*|ubuntu*)
    tmpdir=$(mktemp -d)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    # Install gcc so it can compile extensions etc. If you are using an IDE I bet you might want a compiler too
    sudo apt install -y gcc
    # Remove neovim if it is already installed via package manager
    sudo apt remove -y "$PKG_NAME"
    msg "${GRN}Installing ${PKG_NAME}..."
    wget -q -P "$tmpdir" https://github.com/neovim/neovim/releases/download/stable/nvim-linux-"${ARCH}".tar.gz
    tar xf "$tmpdir/nvim"*.tar.gz -C "$tmpdir"
    sudo install -b "$tmpdir"/nvim-linux*/bin/nvim /usr/local/bin/nvim
    sudo cp -R "$tmpdir"/nvim-linux*/lib /usr/local/
    sudo cp -R "$tmpdir"/nvim-linux*/share /usr/local/
    # Install luarocks and tree-sitter-cli to resolve lazyvim :checkhealth warnings
    # TODO: this is a lot of crap it installs.. do I really need it?
    #sudo apt install -y luarocks tree-sitter-cli
    rm -rf "$tmpdir"
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

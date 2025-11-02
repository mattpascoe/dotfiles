#!/bin/bash
# Nvim editor

PKG_NAME=neovim
case "$ID" in
  arch*)
    sudo pacman --needed --noconfirm -S "$PKG_NAME" ;;
  debian*|ubuntu*)
    tmpdir=$(mktemp -d)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    # Install gcc so it can compile extensions etc. If you are using an IDE I bet you might want a compiler too
    sudo apt install -y gcc >& /dev/null
    # Remove neovim if it is already installed via package manager
    sudo apt remove -y "$PKG_NAME" >& /dev/null
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
    brew install "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

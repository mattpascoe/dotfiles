#!/bin/bash
# Nvim editor

source setup/setup_lib.sh

# Mac platform
if [ "$PLATFORM" == "Mac" ]; then
  PKG_NAME=nvim
  if brew info "$PKG_NAME" >/dev/null 2>&1; then
    msg "${BLU}Already installed via brew on Mac."
  else
    msg "${GRN}Installing..."
    brew install "$PKG_NAME"
fi

# Posix platforms
# Get linux os type
[ -f /etc/os-release ] && . /etc/os-release
case "$ID" in
  debian*|ubuntu*)
    tmpdir=$(mktemp -d)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    # Install gcc so it can compile extensions etc. If you are using an IDE I bet you might want a compiler too
    sudo apt install -y gcc
    # Remove neovim if it is already installed via package manager
    sudo apt remove -y neovim
    echo "Installing neovim..."
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
  arch*)
    sudo pacman --needed --noconfirm -Sy neovim ;;
  *)
    echo "-!- Install not supported."
    ;;
esac

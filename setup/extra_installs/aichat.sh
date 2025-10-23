#!/bin/bash
# AI chat cli for local LLMs

# Get linux os type
[ -f /etc/os-release ] && . /etc/os-release
case "$ID" in
  debian*|ubuntu*)
    tmpdir=$(mktemp -d)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    VERSION=$(curl -s https://api.github.com/repos/sigoden/aichat/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')
    # Download and extract
    #wget https://github.com/sigoden/aichat/releases/latest/download/aichat-v${AICHAT_VERSION}-$(dpkg --print-architecture)-unknown-linux-musl.tar.gz
    wget -P "$tmpdir" https://github.com/sigoden/aichat/releases/latest/download/aichat-v"${VERSION}"-arm-unknown-linux-musleabihf.tar.gz
    tar xf "$tmpdir/aichat"*.tar.gz -C "$tmpdir" aichat
    sudo install -b "$tmpdir"/aichat /usr/local/bin
    rm -rf "$tmpdir"
    ;;
  #arch*)
  #  sudo pacman --needed --noconfirm -Sy aichat ;;
  *)
    echo "-!- Install not supported."
    ;;
esac


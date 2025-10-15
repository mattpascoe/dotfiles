#!/bin/bash
# Kanata keyboard mapper and layers

# This does not install the cmd_allowed version of kanata
#
# Get linux os type
[ -f /etc/os-release ] && . /etc/os-release
case "$ID" in
  #debian*|ubuntu*)
  # Should work on anyone as long as it is x86 based
  *)
    tmpdir=$(mktemp -d)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    if [ "$ARCH" != "arm64" ]; then
      VERSION=$(curl -s https://api.github.com/repos/jtroo/kanata/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')
      wget -P "$tmpdir" https://github.com/jtroo/kanata/releases/download/v"${VERSION}"/kanata
      sudo install -b "$tmpdir"/kanata /usr/local/bin/kanata
      rm -rf "$tmpdir"
    else
      echo "-!- Install not supported on ARM."
    fi
    ;;
  #*)
  #  echo "-!- Install not supported."
  #  ;;
esac


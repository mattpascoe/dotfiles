#!/bin/bash
# Nvim editor

PKG_NAME=neovim
case "$ID" in
  arch*)
    # Since its arch we'll expect the version to be pretty close to the latest
    sudo pacman --needed --noconfirm -S "$PKG_NAME"
    link_file ".config/nvim"
    ;;
  debian*|ubuntu*)
    # This variation will install latest version into a local dir since we find yourselves on older systems
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    LATEST_VERSION=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')

    INSTALL_DIR="$HOME/.local/nvim"
    PREVIOUS_DIR="$HOME/.local/nvim-previous"

    CURRENT_VERSION=""
    [[ -x "$INSTALL_DIR/bin/nvim" ]] && \
      CURRENT_VERSION=$("$INSTALL_DIR/bin/nvim" --version | head -1 | grep -Po 'v\K[0-9.]+')

    if [[ -z "$LATEST_VERSION" ]]; then
      msg "Failed to determine latest github Neovim version; skipping"
    elif [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
      msg "${BLU}Latest Neovim v$LATEST_VERSION already installed. Nothing to do."
    else
      msg "${BLU}Installing Neovim v$LATEST_VERSION"
      tmpdir=$(mktemp -d)
      trap 'rm -rf "$tmpdir"' EXIT
      # Download nvim tarball
      wget -q -P "$tmpdir" "https://github.com/neovim/neovim/releases/download/v${LATEST_VERSION}/nvim-linux-${ARCH}.tar.gz"
      tar xf "$tmpdir/nvim-linux-$ARCH.tar.gz" -C "$tmpdir"
      # Shuffle previous with latest
      rm -rf "$PREVIOUS_DIR"
      [[ -d "$INSTALL_DIR" ]] && mv "$INSTALL_DIR" "$PREVIOUS_DIR"
      mv "$tmpdir/nvim-linux-$ARCH" "$INSTALL_DIR"
      # Link to personal bin
      ln -sfn "$INSTALL_DIR/bin/nvim" "$HOME/bin/nvim"
      hash -r
      # Cleanup
      rm -rf "$tmpdir"
      link_file ".config/nvim"
    fi
    ;;
  macos*)
    # Should track pretty close to latest
    brew install "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d'
    link_file ".config/nvim"
    ;;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

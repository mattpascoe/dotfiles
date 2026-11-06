#!/bin/bash
# Kanata keyboard mapper and layers

# This does not install the cmd_allowed version of kanata

PKG_NAME=kanata
case "$ID" in
  macos*)
    # This may still need some karabiner-hiddriver stuff and whatever comes with that
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d'
    link_file ".config/$PKG_NAME"
    # Launcher lives with config; only expose via BIN_DIR (~/.local/bin), not ~/bin.
    # Use `start-kanata.sh restart` after plugging in a USB keyboard (lrld does not re-scan devices).
    mkdir -p "${BIN_DIR}"
    ln -sfn "${DOTREPO}/.config/${PKG_NAME}/start-kanata.sh" "${BIN_DIR}/start-kanata.sh"
    chmod +x "${DOTREPO}/.config/${PKG_NAME}/start-kanata.sh"
    ;;
  # Should work on any linux system as long as it is x86 based
  *)
    tmpdir=$(mktemp -d)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    if [ "$ARCH" != "arm64" ]; then
      VERSION=$(curl -s https://api.github.com/repos/jtroo/kanata/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')
      wget -q -P "$tmpdir" https://github.com/jtroo/kanata/releases/download/v"${VERSION}"/linux-binaries-x64.zip
      # Unzip in-place; do not cd into tmpdir (profiles are sourced, so that would break setup cwd)
      unzip -q -d "$tmpdir" "$tmpdir/linux-binaries-x64.zip"
      sudo install "$tmpdir"/kanata_linux_x64 /usr/local/bin/kanata
      rm -rf "$tmpdir"

      sudo rm -f /etc/kanata.cfg
      sudo ln -s ~/.config/kanata/kanata.kbd /etc/kanata.cfg
      sudo tee /etc/systemd/system/kanata.service > /dev/null <<'EOF'
[Unit]
Description=Kanata keyboard remapping daemon
After=graphical.target

[Service]
ExecStart=/usr/local/bin/kanata --cfg /etc/kanata.cfg --quiet
Restart=on-failure

[Install]
WantedBy=default.target
EOF

      link_file ".config/$PKG_NAME"
      sudo systemctl enable kanata.service
      sudo systemctl start kanata.service
    else
      echo "-!- Not supported on arm64."
    fi
    ;;
esac

msg "${BLU}Install complete."

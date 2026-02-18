#!/bin/bash
# 1password password manager and tools


PKG_NAME=1password
case "$ID" in
  #arch*)
  #  sudo pacman --needed --noconfirm -Sy "$PKG_NAME" ;;
  debian*|ubuntu*)
    tmpdir=$(mktemp -d)
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    # NOTE: didnt always work I think due to architecture issues.. yea does not support arm64. use uname -m instead to get aarch64
    # works on x86_64
    # Need to test if running multiple times will do proper upgrades
    wget -q -P "$tmpdir" https://downloads.1password.com/linux/tar/stable/$(uname -m)/1password-latest.tar.gz && \
    tar xf "$tmpdir"/1password-latest.tar.gz -C "$tmpdir" && \
    sudo mkdir -p /opt/1Password && \
    sudo cp -a "$tmpdir"/1password-*/* /opt/1Password && \
    sudo /opt/1Password/after-install.sh
    sudo chown root:root /opt/1Password/1password
    # I saw somewhere they wanted 4755 permissions but I saw issues with that.
    sudo chmod 0755 /opt/1Password/1password

    # ----- Install 1password cli, find a way to get latest instead of a specific version
    # This can be run over and over to update the version.
    [[ $ARCH == "x86_64" ]] && ARCH="amd64"
    OP_VERSION=$(curl -fsS https://app-updates.agilebits.com/ | awk '/<section id="onepassword-cli2"/,/<\/section>/' | egrep -o 'Latest release: [0-9]+\.[0-9]+\.[0-9]+' | egrep -o '[0-9]+\.[0-9]+\.[0-9]+')
    wget -q -O "$tmpdir/op.zip" "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VERSION}/op_linux_${ARCH}_v${OP_VERSION}.zip" && \
    unzip -d "$tmpdir/op" "$tmpdir/op.zip" > /dev/null && \
    sudo groupadd -f onepassword-cli && \
    sudo install -m 2755 -o root -g onepassword-cli -b "$tmpdir/op/op" /usr/local/bin
    # reset ARCH
    ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
    rm -rf "$tmpdir"
    ;;
  macos*)
    # shellcheck disable=SC2086
    $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS "$PKG_NAME" 2>&1|sed '/^To reinstall/,$d';;
  *)
    echo "-!- Install not supported."
    ;;
esac

msg "${BLU}Install complete."

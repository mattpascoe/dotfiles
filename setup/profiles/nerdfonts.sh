#!/bin/bash
# Fancy icons for your terminal (installed in home dir)

if [[ "$ID" == "macos" ]]; then
  # shellcheck disable=SC2086
  $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS font-monaspace-nerd-font 2>&1|sed '/^To reinstall/,$d'
  # shellcheck disable=SC2086
  $PLATFORM_INSTALLER_BIN install $INSTALLER_OPTS font-meslo-lg-nerd-font 2>&1|sed '/^To reinstall/,$d'
else
  FONTDIR=$HOME/.local/share/fonts
  mkdir -p "$FONTDIR"

  # Ensure Nerd Fonts are installed in ~/.local
  # Prefer the release zip: individual raw paths under patched-fonts/ change and 404 often
  if [[ ! -s $FONTDIR/MesloLGMNerdFontMono-Regular.ttf || ! -s $FONTDIR/MesloLGMNerdFontPropo-Regular.ttf ]]; then
    msg "${BLU}Installing Nerd Fonts..."
    tmpdir=$(mktemp -d)
    if curl -fsSL "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip" -o "$tmpdir/Meslo.zip"; then
      if command -v unzip &> /dev/null; then
        unzip -qo "$tmpdir/Meslo.zip" -d "$FONTDIR"
      else
        python3 -c "import zipfile; zipfile.ZipFile('${tmpdir}/Meslo.zip').extractall('${FONTDIR}')"
      fi
      # Drop license/readme clutter from the zip
      find "$FONTDIR" -maxdepth 1 -type f \( -iname 'readme*' -o -iname 'license*' -o -name '*.txt' -o -name '*.md' \) -delete 2>/dev/null || true
    else
      msg "${RED}-!- Failed to download Meslo Nerd Font"
    fi
    rm -rf "$tmpdir"
    if command -v fc-cache &> /dev/null; then
      fc-cache -f "$FONTDIR"
    fi
  fi
fi

msg "${BLU}Install complete."

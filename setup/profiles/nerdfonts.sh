#!/bin/bash
# Fancy icons for your terminal (installed in home dir)

if [[ "$ID" == "macos" ]]; then
  "$BREWPATH"/brew install font-monaspace-nerd-font 2>&1|sed '/^To reinstall/,$d'
  "$BREWPATH"/brew install font-meslo-lg-nerd-font 2>&1|sed '/^To reinstall/,$d'
else
  FONTDIR=$HOME/.local/share/fonts
  mkdir -p "$FONTDIR"

  # Ensure Nerd Fonts are installed in ~/.local
  if [[ ! -f $FONTDIR/MesloLGMNerdFontMono-Regular.ttf || ! -f $FONTDIR/MesloLGMNerdFontPropo-Regular.ttf ]]; then
    msg "${BLU}Installing Nerd Fonts..."
    curl -s -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontMono-Regular.ttf --output-dir "$FONTDIR"
    curl -s -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontPropo-Regular.ttf --output-dir "$FONTDIR"
    fc-cache -fv "$FONTDIR"
  fi
fi

msg "${BLU}Install complete."

#!/bin/bash
# Fancy icons for your terminal

if [[ "$ID" == "macos" ]]; then
    if brew list "font-monaspace-nerd-font" >/dev/null 2>&1; then
      msg "${BLU}font-monaspace-nerd-font Already installed via brew on Mac."
    else
      "$BREWPATH"/brew install -q font-monaspace-nerd-font
    fi

    if brew list "font-meslo-lg-nerd-font" >/dev/null 2>&1; then
      msg "${BLU}font-meslo-lg-nerd-font Already installed via brew on Mac."
    else
      "$BREWPATH"/brew install -q font-meslo-lg-nerd-font
    fi
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

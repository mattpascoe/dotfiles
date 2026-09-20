#!/usr/bin/env bash
# Fuzzy search cli tool

# Everyone should get FZF! Add it to all the roles! (unless ya dont)
# This will be installed in $BIN_DIR

# Use the upstream installer to get the latest version.
# It resolves its base directory from BASH_SOURCE[0], so it must be run as a
# real file (not piped via curl|bash). Placing it under $HOME/.local makes
# the installer write the binary to $HOME/.local/bin/fzf ($BIN_DIR).
mkdir -p "$HOME/.local"
pushd "$HOME/.local" >/dev/null || exit

if ! command -v "fzf" &> /dev/null; then
  msg "Installing FZF tools"
else
  msg "FZF is already installed. Running installer again to get updates"
fi

FZF_INSTALL_SCRIPT="$HOME/.local/fzf-install.tmp"
FZF_INST_URL="https://raw.githubusercontent.com/junegunn/fzf/master/install"

if [[ "$DRY_RUN" == true ]]; then
  msg "${GRN}[DRY_RUN: command]${NC} curl -fsSL $FZF_INST_URL -o $FZF_INSTALL_SCRIPT && bash $FZF_INSTALL_SCRIPT --bin && rm -f $FZF_INSTALL_SCRIPT"
else
  curl -fsSL "$FZF_INST_URL" -o "$FZF_INSTALL_SCRIPT"
  bash "$FZF_INSTALL_SCRIPT" --bin
  rm -f "$FZF_INSTALL_SCRIPT"
fi

popd >/dev/null || exit

msg "${BLU}Install complete."

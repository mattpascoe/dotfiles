#!/bin/bash
# Fuzzy search cli tool

# Everyone should get FZF! Add it to all the roles! (unless ya dont)
# This will be installed in $HOME/bin

# We will use the fzf curl installer to ensure we get the latest version.

# NOTE: Their installer will throw an error about the BASH_SOURCE variable.
pushd "$HOME" >/dev/null || exit
if ! command -v "fzf" &> /dev/null; then
  msg "Installing FZF tools"
else
  msg "FZF is already installed. Running installer again to get updates"
fi
FZF_INST="curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/master/install | bash -s -- --bin --xdg --no-update-rc --no-completion --no-key-bindings"
if [[ "$DRY_RUN" == true ]]; then
  msg "${GRN}[DRY_RUN: command]${NC} $FZF_INST"
else
  eval "$FZF_INST"
fi
popd >/dev/null || exit

msg "${BLU}Install complete."

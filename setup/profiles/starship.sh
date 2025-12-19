#!/bin/bash
# Starship fancy prompts

# Everyone should get Starship! Add it to all the roles! (unless ya dont)
# This will be installed in $HOME/bin

# We will use the starship curl installer to ensure we get the latest version.
if ! command -v "starship" &> /dev/null; then
  msg "Installing Starship prompt"
else
  msg "Starship is already installed. Running installer again to get updates"
fi
SHIP_INST="curl -fsSL https://starship.rs/install.sh | sh -s -- --force --bin-dir $HOME/bin | sed '/Please follow the steps/,\$d'"
eval "$SHIP_INST"
link_file ".config/starship.toml"
# Starship installer leaves a bunch of mktemp dirs all over. This will clean them up even ones that are not ours!
find /tmp/ -name "tmp.*.tar.gz" -print0 2>/dev/null | while IFS= read -r -d '' file; do
  prefix="${file%.tar.gz}"
  rm "${prefix}"* 2>/dev/null
done

msg "${BLU}Install complete."

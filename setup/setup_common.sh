#!/bin/bash
# TODO: look into using stow or chezmoi.io for dotfile management? For now I'm keeping it simple

# This is the common setup for all platform types.
# It will run BEFORE any other packages are installed so it should not have any dependancies on them.
# Anything done here should operate of its own accord.

# Ensure ~/data exists. Also used in .macos script
if [ ! -d ~/data ]
then
  msg "${UL}Creating ~/data directory. PUT YOUR DATA HERE!"
  mkdir ~/data
fi

# Everyone gets starship!
if ! command -v "starship" &> /dev/null; then
  msg "${GRN}Do you want to install Starship.rs prompt? (N/y) \c"
  read -r REPLY < /dev/tty
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl -fsSL https://starship.rs/install.sh | sudo sh -s -- --force | sed '/Please follow the steps/,$d'
  fi
else
  msg "${UL}Starship is alredy installed. Running installer again to get updates..."
  curl -fsSL https://starship.rs/install.sh | sudo sh -s -- --force | sed '/Please follow the steps/,$d'
fi
# Starship installer leaves a bunch of mktemp dirs all over. This will clean them up even ones that are not ours!
sudo find /tmp/ -name "tmp.*.tar.gz" -print0 | while IFS= read -r -d '' file; do
  prefix="${file%.tar.gz}"
  sudo rm "${prefix}"*
done


###### Link dotfile configs, could I use stow or chezmoi.io? sure, but less dependancies here
declare -a LINKFILES
LINKFILES+=(
  ".config/btop"
  ".config/ghostty"
  ".config/git"
  ".config/home-manager"
  ".config/kanata"
  #".config/kitty"
  ".config/lazygit"
  ".config/nvim"
  ".config/rofi"
  ".config/starship.toml"
  ".config/tmux"
  ".config/zk"
  ".profile"
  ".vimrc"
  ".zshrc"
)
msg "${UL}Checking dotfile config symlinks..."
if [ ! -d "$HOME/.config" ]; then
  mkdir -p "$HOME/.config"
fi
for FILE in "${LINKFILES[@]}"
do
  if [ ! -L "$HOME/$FILE" ]; then
    if [ -e "$HOME/$FILE" ]; then
      msg "${UL}Backing up current file to ${FILE}.bak"
      mv "$HOME/$FILE" "$HOME/$FILE.bak"
    fi
    msg "${UL}Linking file $HOME/$FILE -> $DIR/$FILE"
    ln -s "$DIR/$FILE" "$HOME/$FILE"
  else
    echo -n "Found link: "
    ls -o "$HOME/$FILE"
  fi
done

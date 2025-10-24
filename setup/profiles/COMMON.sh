#!/bin/bash
# TODO: look into using stow or chezmoi.io for dotfile management? For now I'm keeping it simple

# This is the common setup for ALL platform types.
# It will run BEFORE any other packages are installed so it should not have any dependancies on them.
# Anything done here should operate of its own accord.
# A goal on this common setup is to only install as the local user. No sudo and all in $HOME.

# Ensure $HOME/data exists. Also used in _macos.sh script
if [ ! -d "$HOME"/data ]
then
  msg "${UL}Creating $HOME/data directory. PUT YOUR DATA HERE!"
  mkdir -p "$HOME"/data
fi

# Add $HOME/bin to PATH so we can install and use binaries during this install
mkdir -p "$HOME/bin"
export PATH="$HOME/bin:$PATH"
# Everyone gets starship!
# This installs in $HOME/bin
SHIP_INST="curl -fsSL https://starship.rs/install.sh | sh -s -- --force --bin-dir $HOME/bin | sed '/Please follow the steps/,\$d'"
if ! command -v "starship" &> /dev/null; then
  prompt "Do you want to install Starship.rs prompt? (N/y) "
  read -r REPLY < /dev/tty
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    eval "$SHIP_INST"
  fi
else
  msg "${UL}Starship is already installed. Running installer again to get updates..."
  eval "$SHIP_INST"
fi
# Starship installer leaves a bunch of mktemp dirs all over. This will clean them up even ones that are not ours!
find /tmp/ -name "tmp.*.tar.gz" -print0 | while IFS= read -r -d '' file; do
  prefix="${file%.tar.gz}"
  rm "${prefix}"*
done

# Everyone gets FZF!
# NOTE: Their installer will throw an error about the BASH_SOURCE variable.
# This installs in $HOME/bin
FZF_INST="curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/master/install | bash -s -- --bin --xdg --no-update-rc --no-completion --no-key-bindings
"
pushd "$HOME" >/dev/null || exit
if ! command -v "fzf" &> /dev/null; then
  eval "$FZF_INST"
else
  msg "${UL}FZF is already installed. Running installer again to get updates..."
  eval "$FZF_INST"
fi
popd >/dev/null || exit

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
  #".config/rofi"
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
    msg "${UL}Linking file $HOME/$FILE -> $DOTREPO/$FILE"
    ln -s "$DOTREPO/$FILE" "$HOME/$FILE"
  else
    echo -n "Found link: "
    ls -o "$HOME/$FILE"
  fi
done

# Run <prefix> + I to install plugins the first time
if [ ! -d "$HOME/.config/tmux/plugins/tpm" ];then
  msg "${UL}Installing TMUX plugin manager."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.config/tmux/plugins/tpm"
  msg "${UL}Installing TMUX plugins. You may need to run <prefix> + I to install plugins if this doesn't work"
  eval "$HOME/.config/tmux/plugins/tpm/bin/install_plugins"
fi

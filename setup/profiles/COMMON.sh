#!/bin/bash
# The COMMON profile will always be run first, by the setup script

# TODO: look into using stow or chezmoi.io for dotfile management? For now I'm keeping it simple

# This is the common setup for ALL platform types.
# It will run BEFORE any other packages are installed so it should not have any dependancies on them.
# Anything done here should operate of its own accord.
# A goal on this common setup is to only install as the local user. No sudo and all in $HOME.

# Ensure $HOME/data exists. Also used in _macos.sh script
if [ ! -d "$HOME"/data ]
then
  msg "${BLU}Creating $HOME/data directory. PUT YOUR DATA HERE!"
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
    msg "Installing Starship prompt"
    eval "$SHIP_INST"
  fi
else
  msg "Starship is already installed. Running installer again to get updates"
  eval "$SHIP_INST"
fi
# Starship installer leaves a bunch of mktemp dirs all over. This will clean them up even ones that are not ours!
find /tmp/ -name "tmp.*.tar.gz" -print0 2>/dev/null | while IFS= read -r -d '' file; do
  prefix="${file%.tar.gz}"
  rm "${prefix}"* 2>/dev/null
done

# Everyone gets FZF!
# NOTE: Their installer will throw an error about the BASH_SOURCE variable.
# This installs in $HOME/bin
FZF_INST="curl -fsSL https://raw.githubusercontent.com/junegunn/fzf/master/install | bash -s -- --bin --xdg --no-update-rc --no-completion --no-key-bindings
"
pushd "$HOME" >/dev/null || exit
if ! command -v "fzf" &> /dev/null; then
  msg "Installing FZF tools"
  eval "$FZF_INST"
else
  msg "FZF is already installed. Running installer again to get updates"
  eval "$FZF_INST"
fi
popd >/dev/null || exit

msg "\n${UL}Ensuring install of requested base packages"
case "$ID" in
  debian*|ubuntu*)
    sudo apt update -y
    sudo apt install -y "${LINUX_PKGS[@]}"
    # Remove some useless crap
    sudo apt purge -y whoopsie
    ;;
  arch*)
    sudo dmesg -n 3 # Disable kernel messages since we are likely on a console
    sudo pacman --disable-sandbox --needed --noconfirm -Syu "${LINUX_PKGS[@]}"
    # Also make sure yay is installed for AUR support
    if ! command -v "yay" &> /dev/null; then
      tmpdir=$(mktemp -d)
      git clone https://aur.archlinux.org/yay.git "$tmpdir/yay"
      cd "$tmpdir/yay" || exit
      makepkg -si --noconfirm
      cd - > /dev/null || exit
    fi
    ;;
  macos*)
    "$BREWPATH/brew" install -q "${BREW_PKGS[@]}"
    ;;
  *)
    msg "${RED}-!- This system is not a supported type, You should check that the following packages are installed:"
    echo "    ${LINUX_PKGS[*]}"
    ;;
esac
msg "${BLU}Base packages installed."

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
  ".config/starship.toml"
  ".config/tmux"
  ".config/zk"
  ".profile"
  ".vimrc"
  ".zshrc"
)
msg "\n${UL}Checking dotfile config symlinks"
if [ ! -d "$HOME/.config" ]; then
  mkdir -p "$HOME/.config"
fi
for FILE in "${LINKFILES[@]}"
do
  link_file "$FILE"
done

# These are best run after .config is setup
# Ensure Tmux is installed
echo
msg "Installing tmux -- # TMUX terminal multiplexer"
source "$DOTREPO/setup/profiles/tmux.sh"

# Everyone should have a good nerdfont
msg "Installing nerdfonts -- # Fancy icons for your terminal"
source "$DOTREPO/setup/profiles/nerdfonts.sh"

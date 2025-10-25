#!/bin/bash
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

# Ensure zsh is default if its available
if command -v "zsh" &> /dev/null; then
  if [ "$(grep "$USER" /etc/passwd|cut -d: -f7)" != "/bin/zsh" ]; then
    msg "${BLU}Switching default shell to ZSH"
    sudo usermod -s /bin/zsh "$USER"
  fi
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
    msg "\n${UL}Installing Starship prompt"
    eval "$SHIP_INST"
  fi
else
  msg "\n${UL}Starship is already installed. Running installer again to get updates"
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
  msg "\n${UL}Installing FZF tools"
  eval "$FZF_INST"
else
  msg "\n${UL}FZF is already installed. Running installer again to get updates"
  eval "$FZF_INST"
fi
popd >/dev/null || exit

msg "\n${UL}Ensuring install of requested base packages"
case "$ID" in
  debian*|ubuntu*)
    sudo apt update -y
    sudo apt install -y "${LINUX_PKGS[@]}"
    # Also set timezone
    sudo timedatectl set-timezone "$TIMEZONE"
    # Remove some useless crap
    sudo apt purge -y whoopsie
    ;;
  arch*)
    sudo dmesg -n 3 # Disable kernel messages since we are likely on a console
    sudo pacman --disable-sandbox --needed --noconfirm -Syu "${LINUX_PKGS[@]}"
    ;;
  macos*)
    "$BREWPATH"/brew install -q "${BREW_PKGS[@]}"
    ;;
  *)
    msg "${RED}-!- This system is not a supported type, You should check that the following packages are installed:"
    echo "    ${LINUX_PKGS[*]}"
    ;;
esac

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
msg "\n${UL}Checking dotfile config symlinks"
if [ ! -d "$HOME/.config" ]; then
  mkdir -p "$HOME/.config"
fi
for FILE in "${LINKFILES[@]}"
do
  if [ ! -L "$HOME/$FILE" ]; then
    if [ -e "$HOME/$FILE" ]; then
      msg "${BLU}Backing up current file to ${FILE}.bak"
      mv "$HOME/$FILE" "$HOME/$FILE.bak"
    fi
    msg "${BLU}Linking file $HOME/$FILE -> $DOTREPO/$FILE"
    ln -s "$DOTREPO/$FILE" "$HOME/$FILE"
  else
    echo -n "Found link: "
    ls -o "$HOME/$FILE"
  fi
done

# Ensure Tmux is installed
msg "Installing tmux -- tmux terminal multiplexer"
source "$DOTREPO/setup/profiles/tmux.sh"

# Everyone should have a good nerdfont
msg "Installing nerdfots -- fancy icons for your terminal"
source "$DOTREPO/setup/profiles/nerdfonts.sh"

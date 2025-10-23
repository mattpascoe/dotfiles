#!/bin/bash

# This does not need to run as root, it will sudo when needed
# lots of install stuff.. you should be able to run this over and over without issue
# TODO: refactor and have more "configuration" instead of hardcoded things like package installs
# TODO: look into using stow for dotfile management
# TODO: setup a 'bash_lib.sh' that contains this top seciton so that individual scripts can use it
# TODO: restructure things for the installer.  MACHINE/OS/PROFILE will gather individual setup parts. likely an install and configuation separation too.

#set -eou pipefail

# Colors/formatting
UL="\033[4m" # underline
NC="\033[0m" # no color/format
YEL="\033[33m"
BLU="\033[34m"
RED="\033[31m"
GRN="\033[32m"
BOLD="\033[1m"

function msg() {
  command echo -e "${BOLD}${YEL}$*${NC}"
}

# Check if USER is set and try a fallback
USER="${USER:-$(whoami)}"

# Determine what type of machine we are on
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    CYGWIN*)    MACHINE=Cygwin;;
    MINGW*)     MACHINE=MinGw;;
    *)          MACHINE="UNKNOWN:${unameOut}"
esac

if [ -f /etc/os-release ]; then
  . /etc/os-release
fi

# If DOTDIR variable is set, use it (usually from install.sh)
if [ -n "${DOTDIR:-}" ]; then
  DIR=$DOTDIR
else
  SCRIPT=$(readlink -f "$0")
  DIR=$(dirname "$SCRIPT")
fi
msg "${BLU}Running from $DIR."

declare -a LINKFILES

msg "${BLU}Looks like we are a $MACHINE system."

###### Unraid specific stuff, barebones zsh setup
if [ -f /etc/unraid-version ]; then
  msg "${UL}Setting up as an Unraid system."

  # Combine the zshrc and shell-common files into /boot/config
  cat .zshrc .shell-common > /boot/config/myzshrc
  # Copy the vimrc file to /boot/config
  cp .vimrc /boot/config/myvimrc
  # Replace the default go file with our own
  cp .unraid-go /boot/config/go
  # Set up a link for vim wiki to point at my sync copy
  if [ ! -L ~/data/SYNC/wiki ]; then
    ln -s /mnt/user/data-syncthing/matt-personal/wiki ~/data/SYNC/wiki
  fi

  msg "${UL}Updates to /boot/config have been made."
  # Stop here since unraid is its own beast
  exit
fi

###### Ensure ~/data exists. Also used in .macos script
if [ ! -d ~/data ]
then
  msg "${UL}Creating ~/data directory. PUT YOUR DATA HERE!"
  mkdir ~/data
fi

###### Linux specific stuff
if [ "$MACHINE" == "Linux" ]; then
  msg "${BLU}Looks like the OS is ${PRETTY_NAME}."

  # These are base packages I hope to use on all systems
  PKGS+=(
    "bat"
    "btop"
    "curl"
    "eza"
    #"fzf"
    "git"
    "highlight"
    "jq"
  #  "neovim" # old version, installing via direct download instead
    "tmux"
    "tree"
  #  "yazi" # not on ubuntu but is on arch, installing via direct download
    "zsh"
  )

  # Packages that Arch has
  ARCH_PKGS+=(
    "lazygit"
    "neovim"
    "yazi"
  )

  msg "${UL}Ensuring install of requested base packages..."
  case "$ID" in
    debian*|ubuntu*)
      sudo apt install -y "${PKGS[@]}"
      # Also set timezone
      sudo timedatectl set-timezone "America/Boise"
      # Remove some useless crap
      sudo apt purge -y whoopsie
      ;;
    arch*)
      sudo dmesg -n 3 # Disable kernel messages since we are likely on a console
      PKGS+=("${ARCH_PKGS[@]}")
      sudo pacman --disable-sandbox --needed --noconfirm -Syu "${PKGS[@]}"
      ;;
    *)
      msg "${RED}-!- This system is not a supported type, You should check that the following packages are installed:"
      echo "    ${PKGS[*]}"
      ;;
  esac

  # Ensure zsh is default if its available
  if command -v "zsh" &> /dev/null; then
    if [ "$(grep "$USER" /etc/passwd|cut -d: -f7)" != "/bin/zsh" ]; then
      msg "${UL}Switching default shell to ZSH..."
      sudo usermod -s /bin/zsh "$USER"
    fi
  fi

  # Install FZF directly
  # This installs in ~/bin
  pushd "$HOME" || exit
  if ! command -v "fzf" &> /dev/null; then
    wget -qO- https://raw.githubusercontent.com/junegunn/fzf/master/install | bash -s -- --bin --xdg --no-update-rc --no-completion --no-key-bindings
  fi
  popd || exit

  # Get the desktop environment
  DESK=$(echo "${XDG_CURRENT_DESKTOP:-UNKNOWN}")
  case "${DESK}" in
    *GNOME) source "$DIR/.gnome.sh";;
    UNKNOWN)
      # We'll assume one is not installed.
      msg "${GRN}Do you want to install Gnome desktop? (N/y) \c"
      read -r REPLY < /dev/tty
      case "$ID" in
        ubuntu*)
          if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo apt install -y ubuntu-desktop-minimal rsyslog rofi
            sudo systemctl set-default graphical.target
            export DESK="GNOME"
            source "$DIR/.gnome.sh"
          fi
          ;;
        arch*)
          if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo pacman --disable-sandbox --needed --noconfirm -Sy gnome
            sudo systemctl enable --now gdm
            export DESK="GNOME"
            source "$DIR/.gnome.sh"
          fi
          ;;
        *)
          ;;
      esac
      ;;
    *) msg "${RED}-!- ${DESK} is not a managed desktop environment.";;
  esac

  # Ensure Nerd Fonts are installed
  if [[ ! -f /usr/local/share/fonts/MesloLGMNerdFontMono-Regular.ttf || ! -f /usr/local/share/fonts/MesloLGMNerdFontPropo-Regular.ttf ]]; then
    msg "${UL}Installing Nerd Fonts..."
    sudo mkdir -p /usr/local/share/fonts
    sudo curl -s -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontMono-Regular.ttf --output-dir /usr/local/share/fonts
    sudo curl -s -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontPropo-Regular.ttf --output-dir /usr/local/share/fonts
    fc-cache -fv /usr/local/share/fonts
  fi

  # Install extra tools. These should have a prompt for each one.
  # TODO: IDEA: I chould also have a profiles dir.  it would just list the extras we want to install without prompting for each
  #       Then if we dont select a profile, we can do this loop of all them individually?
  echo "--------------------------------------------"
  msg "${GRN}Do you want to install extra tools? You will be prompted for each one. (N/y) \c"
  read -r REPLY < /dev/tty
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for FILE in $(find "$DIR/extra_installs" -type f -name "*.sh"); do
      EXTRA=$(basename "$FILE"|cut -d. -f1)
      DESC=$(sed -n '2p' "$FILE")
      msg "${GRN}Install ${EXTRA} -- ${DESC} (N/y) \c"
      read -r REPLY < /dev/tty
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        source "$FILE"
      fi
    done
  fi

fi
# End linux section


###### Mac specific stuff
if [ "$MACHINE" == "Mac" ]; then
  # Install Git if it does not exist
  if ! command -v "git" &> /dev/null; then
    # run git command, it may ask to install developer tools, go ahead and do that to get the git command
    msg "${UL}Checking git version. If missing it will prompt to install developer tools..."
    git --version
  fi

  # Run NIX if we want
#  msg "${GRN}Install NIX based packages... Continue (N/y) \c"
#  read -r REPLY < /dev/tty
#  # Think long and hard if you want another box using NIX
#  if [[ $REPLY =~ ^[Yy]DISABLED$ ]]; then
#    if ! command -v "nix" &> /dev/null; then
#      msg "${UL}Installing NIX tools..."
#      msg "${UL}Disabled for now"
#      #curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
#    fi
#
#    if command -v "nix" &> /dev/null; then
#      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
#      nix flake update --flake .config/home-manager
#      nix run home-manager -- switch --flake .config/home-manager
#      # INFO: ok I'm leaving this impure info here for reference. https://nixos.wiki/wiki/1Password
#      # I stopped using it since 1password does not integrate properly with the browser plugins
#      # Running impure to install 1password gui that is flagged broken due to
#      # /Applications requirement. I am ok because I copy all apps to
#      # /Applications to fix the stupid spotlight problem
#      # NIXPKGS_ALLOW_BROKEN=1 nix run home-manager -- switch --impure --flake .config/home-manager
#      # #NIXPKGS_ALLOW_BROKEN=1 home-manager --impure switch (this is how you can run it manually)
#    else
#      msg "${RED}-!- ERROR: Unable to find NIX command. Please install NIX and try again."
#    fi
#  else
#    msg "${UL}.. Skipping NIX based config changes."
#  fi

  # Run brew if we want
  msg "${GRN}Install Homebrew based packages... Continue (N/y) \c"
  read -r REPLY < /dev/tty
  if [ "$REPLY" == "y" ]; then
    if ! command -v "brew" &> /dev/null; then
      msg "${UL}Installing Brew tools..."
      NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    BREWPATH=/opt/homebrew/bin

    # Load up brew environment, should work on ARM intel systems.
    if [ -f $BREWPATH/brew ] &> /dev/null; then
      eval "$($BREWPATH/brew shellenv)"

      msg "${UL}Ensuring install of requested brew packages..."
      $BREWPATH/brew install -q \
        maccy \
        1password \
        brave-browser \
        ghostty \
        jq \
        fzf \
        highlight \
        tree \
        ykman \
        tmux \
        bash \
        nvim \
        jesseduffield/lazygit/lazygit \
        shellcheck \
        eza \
        font-meslo-lg-nerd-font \
        font-monaspace-nerd-font \
        homebrew/cask/syncthing \

        #michaelroosz/ssh/libsk-libfido2 \
    else
      msg "${RED}-!- ERROR: Unable to find Brew command. Please install Brew and try again."
    fi

  else
    msg ".. Skipping Brew based config changes."
  fi

  # Setup lots of system settings using the "defaults" method
  msg "${GRN}Execute 'defaults' commands to set specific Mac settings... Continue (N/y) \c"
  read -r REPLY < /dev/tty
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Running with and without sudo as I seem to get different behaviors?
    "$DIR/.macos"
    sudo "$DIR/.macos"
  else
    msg "${UL}.. Skipping defaults based config changes."
  fi

  # For some reason /usr/local/bin is not on mac by default. Lets make it for starship
  if [ ! -d /usr/local/bin ]; then
    sudo mkdir -p /usr/local/bin
    sudo chown $(whoami):admin /usr/local/bin
  fi

  msg "${BOLD}${BLU}
The following items are not currently controllable and will need to be done manually:
  - Reduce Motion: System Preferences -> Accessibility -> Display -> Reduce Motion
  - Install Raycast, then setup app keybinds for MEH+b, MEH+g, MEH+m etc.
  "
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

# Run <prefix> + I to install plugins the first time
if [ ! -d ~/.config/tmux/plugins/tpm ];then
  msg "${UL}Installing TMUX plugin manager."
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
  msg "${UL}Installing TMUX plugins. You may need to run <prefix> + I to install plugins if this doesn't work"
  export PATH=/opt/homebrew/bin:$PATH
  ~/.config/tmux/plugins/tpm/bin/install_plugins
fi

echo
msg "${UL}Setup complete."
msg "You should probably reboot if this is your first run"
msg "OR at least log out or start a 'tmux' session to utilize new shell changes."

# Set the console log level to 6 on arch
[[ "$ID" == arch* ]] && sudo dmesg -n 6

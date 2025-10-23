#!/bin/bash

# This does not need to run as root, it will sudo when needed
# lots of install stuff.. you should be able to run this over and over without issue
# TODO: refactor and have more "configuration" instead of hardcoded things like package installs
# TODO: look into using stow for dotfile management
# TODO: setup a 'bash_lib.sh' that contains this top seciton so that individual scripts can use it
# TODO: restructure things for the installer.  MACHINE/OS/PROFILE will gather individual setup parts. likely an install and configuation separation too.

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

fi

# Set the console log level to 6 on arch
[[ "$ID" == arch* ]] && sudo dmesg -n 6

#!/bin/bash

msg "${BLU}Ensuring install of requested base packages..."
case "$ID" in
  debian*|ubuntu*)
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
  *)
    msg "${RED}-!- This system is not a supported type, You should check that the following packages are installed:"
    echo "    ${LINUX_PKGS[*]}"
    ;;
esac

# Ensure zsh is default if its available
if command -v "zsh" &> /dev/null; then
  if [ "$(grep "$USER" /etc/passwd|cut -d: -f7)" != "/bin/zsh" ]; then
    msg "${BLU}Switching default shell to ZSH..."
    sudo usermod -s /bin/zsh "$USER"
  fi
fi

# Get the desktop environment
DESK=${XDG_CURRENT_DESKTOP:-UNKNOWN}
case "${DESK}" in
  *GNOME) source "$DOTREPO/setup/profiles/_gnome.sh";;
  UNKNOWN)
    # We'll assume one is not installed.
    prompt "Do you want to install Gnome desktop? (N/y) "
    read -r REPLY < /dev/tty
    case "$ID" in
      ubuntu*)
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          sudo apt install -y ubuntu-desktop-minimal rsyslog
          sudo systemctl set-default graphical.target
          export DESK="GNOME"
          source "$DOTREPO/setup/profiles/_gnome.sh"
        fi
        ;;
      arch*)
        if [[ $REPLY =~ ^[Yy]$ ]]; then
          sudo pacman --disable-sandbox --needed --noconfirm -Sy gnome
          sudo systemctl enable --now gdm
          export DESK="GNOME"
          source "$DOTREPO/setup/profiles/_gnome.sh"
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
  # TODO: is it better to have fonts in ~/.local?
  msg "${BLU}Installing Nerd Fonts..."
  sudo mkdir -p /usr/local/share/fonts
  sudo curl -s -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontMono-Regular.ttf --output-dir /usr/local/share/fonts
  sudo curl -s -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular/MesloLGMNerdFontPropo-Regular.ttf --output-dir /usr/local/share/fonts
  fc-cache -fv /usr/local/share/fonts
fi

# Set the console log level to 6 on arch
[[ "$ID" == arch* ]] && sudo dmesg -n 6

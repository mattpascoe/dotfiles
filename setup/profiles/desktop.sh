#!/bin/bash
# Desktop install and setup (Gnome)

# The goal here is to install if needed and then setup the desktop environment
case "$ID" in
  macos*)
    # Setup lots of system settings using the "defaults" method
    prompt "Execute 'defaults' commands to set specific Mac settings... Continue (N/y) "
    read -r REPLY < /dev/tty
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      # Running with and without sudo as I seem to get different behaviors?
    #  msg "${BLU}Running as normal user."
      "$DOTREPO/setup/profiles/_macos.sh"
    #  msg "${BLU}Running again with sudo."
    #  sudo "$DOTREPO/setup/profiles/_macos.sh"
    else
      msg "${BLU}Skipping defaults based config changes."
    fi
    ;;
  *)
    # NOTE: When installing the first time, some of the settings and gnome extensions wont work until you reboot.
    #       You will just have to re-run setup.sh one more time to make it complete. The complexity is not worth the effort.
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
              msg "${BLU}You will need to reboot and run setup.sh again to complete the install."
            fi
            ;;
          arch*)
            if [[ $REPLY =~ ^[Yy]$ ]]; then
              sudo pacman --disable-sandbox --needed --noconfirm -Sy gnome
              sudo systemctl set-default graphical.target
              #sudo systemctl enable --now gdm
              export DESK="GNOME"
              source "$DOTREPO/setup/profiles/_gnome.sh"
              msg "${BLU}You will need to reboot and run setup.sh again to complete the install."
            fi
            ;;
          *)
            ;;
        esac
        ;;
      *) msg "${RED}-!- ${DESK} is not a managed desktop environment.";;
    esac
    ;;
esac

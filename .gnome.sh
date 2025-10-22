#!/bin/bash
# Setup lots of system settings using the "defaults" method
echo -en "${BOLD}${GRN}Execute Gnome installation and setup commands... Continue (N/y) ${NC}"
read -r REPLY < /dev/tty
if [[ $REPLY =~ ^[Yy]$ ]]; then

# Install some basic desktop packages
[[ -f /etc/os-release && -z "$ID" ]] && . /etc/os-release
case "$ID" in
  debian*|ubuntu*)
    # placeholder for now
    ;;
esac

# Set some gnome settings if we have gsettings
if command -v "gsettings" &> /dev/null; then
  # Meh.. I hear about it but not yet using
  # TODO: this should check the OS type to install packages right
  #sudo apt install gnome-tweaks

  # These are the old way I installed extensions using direct github links. Keeping for a ref just in case
  #INSTALL_VER=$(curl -s https://api.github.com/repos/corecoding/Vitals/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')
  #wget -P "$tmpdir" https://github.com/corecoding/Vitals/releases/download/v"${INSTALL_VER}"/vitals.zip
  #gnome-extensions install --force "${tmpdir}/vitals.zip"
  # Install some extensions
  tmpdir=$(mktemp -d)
  # List the UUIDs of the extensions you want to install
  EXTENSIONS=( application-hotkeys@aaimio.github.com Vitals@CoreCoding.com )
  for i in "${EXTENSIONS[@]}"
  do
      echo "Installing Gnome extension: $i"
      VERSION_TAG=$(curl -Lfs "https://extensions.gnome.org/extension-query/?search=${i}" | jq '.extensions[0] | .shell_version_map | map(.pk) | max')
      wget -q -O "${tmpdir}/${i}.zip" "https://extensions.gnome.org/download-extension/${i}.shell-extension.zip?version_tag=$VERSION_TAG"
      gnome-extensions install --force "${tmpdir}/${i}.zip"
      if ! gnome-extensions list | grep --quiet "${i}"; then
          echo "Failed direct install, trying remote install"
          busctl --user call org.gnome.Shell.Extensions /org/gnome/Shell/Extensions org.gnome.Shell.Extensions InstallRemoteExtension s "${i}"
      fi
      gnome-extensions enable "${i}"
  done
  rm -rf "$tmpdir"

  # Set caps escape key
  gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
  # Close apps like a Mac.
  gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"

  # Experiment with some remapping of default keys to my own taste.  Makes it more Mac like?? is that a bad idea?
  gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "[]" # remove default binding
  gsettings set org.gnome.shell.keybindings focus-active-notification "[]" # remove default binding
  gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>n']" # change to n for notifications
  gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>k']"
  gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>j']"
  gsettings set org.gnome.shell.extensions.tiling-assistant tile-left-half "['<Super>Left', '<Super>KP_4', '<Super>h']"
  gsettings set org.gnome.shell.extensions.tiling-assistant tile-right-half "['<Super>Right', '<Super>KP_6', '<Super>l']"



  # Careful here.. need to test this more
  # There is other info about adjusting all GTK apps using this
  # https://unix.stackexchange.com/questions/342628/gnome-3-keybindings-in-source-where-are-ctrl-c-cut-copy-and-paste-defin/399632
  #gsettings set org.gnome.Ptyxis.Shortcuts paste-clipboard '<Super>v'
  #gsettings set org.gnome.Terminal.Legacy.Keybindings paste '<Super>v'
  #gsettings set org.gnome.Ptyxis.Shortcuts copy-clipboard '<Super>c'
  #gsettings set org.gnome.Terminal.Legacy.Keybindings copy '<Super>c'
  # This seems to work well for terminal.
  dconf write /org/gnome/terminal/legacy/keybindings/copy  \'"<Super>c"\'
  dconf write /org/gnome/terminal/legacy/keybindings/paste \'"<Super>v"\'
  #default values
  #org.gnome.Ptyxis.Shortcuts paste-clipboard '<ctrl><shift>v'
  #org.gnome.Terminal.Legacy.Keybindings paste '<Control><Shift>v'



  # Dock settings
  if gnome-extensions list --enabled | grep -q "ubuntu-dock@ubuntu.com"; then
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false # panel mode
  fi

  gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
  gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

  # Center new windows in the middle of the screen
  gsettings set org.gnome.mutter center-new-windows true
  # Set Cascadia Mono as the default monospace font
  #gsettings set org.gnome.desktop.interface monospace-font-name 'MesloLGM Nerd Font 10'
  # Reveal week numbers in the Gnome calendar
  gsettings set org.gnome.desktop.calendar show-weekdate true
  # Turn off ambient sensors for setting screen brightness (they rarely work well!)
  gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false

  # Adjust switching of windows in an app group to MEH-Tab
  gsettings set org.gnome.desktop.wm.keybindings switch-panels-backward "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>Above_Tab', '<Alt>Above_Tab', '<Shift><Control><Alt>Tab']"

  # Reserve slots for custom keybindings
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"

  # Set ROFI custom keybind
  # First remove existing keybind
  gsettings set org.gnome.desktop.wm.keybindings switch-input-source "@as []"
  # Set our new keybind
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "App Launcher"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "rofi -show drun -normal-window"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Super>space"
  #dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Rofi Launcher'"
  #dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'rofi -show drun'"
  #dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Super>space'"

  # AM/PM clock
  gsettings set org.gnome.desktop.interface clock-format '12h'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

  # set default terminal?
  # Having issues and having to start it with LIBGL_ALLOW_SOFTWARE=1 ghostty
  #gsettings set org.gnome.desktop.default-applications.terminal exec "ghostty"

  # set background
  gsettings set org.gnome.desktop.background picture-uri "file://${HOME}/.wallpaper.png"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://${HOME}/.wallpaper.png"
  gsettings set org.gnome.desktop.background primary-color "#000000" # black

  # Turn off animations so things are snappy
  gsettings set org.gnome.desktop.interface enable-animations false

  # Setup hotkeys for applications. Requires application-hotkeys extension to be installed
  dconf write /org/gnome/shell/extensions/application-hotkeys/configs "@as [
    '[\"org.gnome.Terminal.desktop\",    \"<Shift><Control><Alt>t\"]',
    '[\"brave-browser.desktop\",         \"<Shift><Control><Alt>b\"]',
    '[\"com.mitchellh.ghostty.desktop\", \"<Shift><Control><Alt>g\"]',
    '[\"1password.desktop\",             \"<Shift><Control><Alt>p\"]'
  ]"
fi
else
  msg ".. Skipping Gnome installation and setup changes."
fi

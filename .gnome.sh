#!/bin/bash
# Setup lots of system settings using the "defaults" method
echo -en "${BOLD}${GRN}Execute Gnome installation and setup commands... Continue (N/y) ${NC}"
read -r REPLY < /dev/tty
if [[ $REPLY =~ ^[Yy]$ ]]; then

# Set some gnome settings if we have gsettings
if command -v "gsettings" &> /dev/null; then
  # Meh.. I hear about it but not yet using
  # TODO: this should check the OS type to install packages right
  #sudo apt install gnome-tweaks

  # Install some extensions
  tmpdir=$(mktemp -d)
  ARCH=${ARCH:-$(uname -m)}; ARCH=${ARCH/aarch64/arm64}
  # ----- Install latest application hotkeys gnome extension
  INSTALL_VER=$(curl -s https://api.github.com/repos/aaimio/application-hotkeys/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')
  wget -P "$tmpdir" https://github.com/aaimio/application-hotkeys/releases/download/v"${INSTALL_VER}"/application-hotkeys@aaimio.github.com.shell-extension.zip
  sudo gnome-extensions install --force "${tmpdir}/application-hotkeys@aaimio.github.com.shell-extension.zip"
  # I think there might be a command to reload gnome extensions?

  # VITALS extension seems nice: https://extensions.gnome.org/away/https%253A%252F%252Fgithub.com%252Fcorecoding%252FVitals
  INSTALL_VER=$(curl -s https://api.github.com/repos/corecoding/Vitals/releases/latest | grep -Po '"tag_name": "v\K[0-9.]+')
  wget -P "$tmpdir" https://github.com/corecoding/Vitals/releases/download/v"${INSTALL_VER}"/vitals.zip
  sudo gnome-extensions install --force "${tmpdir}/vitals.zip"

  rm -rf "$tmpdir"

  # Set caps escape key
  gsettings set org.gnome.desktop.input-sources xkb-options "['caps:escape']"
  # Close apps like a Mac.
  gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"
  # Make it easy to maximize like you can fill left/right
  # TODO: I want super hjkl to do window sizing.  test the rest of these something seems to be doing alt-super-hl but I'm not sure what
  gsettings set org.gnome.desktop.wm.keybindings maximize "['<Super>k']"

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

  # Set ROFI custom keybind
  # First remove existing keybind
  gsettings set org.gnome.desktop.wm.keybindings switch-input-source "@as []"
  # Set our new keybind
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Rofi Launcher"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "rofi -show drun"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Super>space"

  # AM/PM clock
  gsettings set org.gnome.desktop.interface clock-format '12h'
  gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

  # set default terminal?
  #gsettings set org.gnome.desktop.default-applications.terminal exec "ghostty"

  # set background
  gsettings set org.gnome.desktop.background picture-uri "file://${HOME}/.wallpaper.png"
  gsettings set org.gnome.desktop.background picture-uri-dark "file://${HOME}/.wallpaper.png"
  gsettings set org.gnome.desktop.background primary-color "#ffffff"

  # Turn off animations so things are snappy
  gsettings set org.gnome.desktop.interface enable-animations false

  # Setup hotkeys for applications. Requires application-hotkeys extension to be installed
  dconf write /org/gnome/shell/extensions/application-hotkeys/configs "@as [
    '[\"brave-browser.desktop\",         \"<Shift><Control><Alt>b\"]',
    '[\"com.mitchellh.ghostty.desktop\", \"<Shift><Control><Alt>g\"]',
    '[\"1password.desktop\",             \"<Shift><Control><Alt>p\"]'
  ]"
fi
else
  msg ".. Skipping Gnome installation and setup changes."
fi

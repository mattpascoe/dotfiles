#!/bin/bash
# Setup lots of system settings using the "defaults" method
msg "${GRN}Execute Gnome installation and setup commands... Continue (N/y) \c"
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
  EXTENSIONS=( application-hotkeys@aaimio.github.com Vitals@CoreCoding.com clipboard-indicator@tudmotu.com)
  for i in "${EXTENSIONS[@]}"
  do
      msg "${BLU}Installing Gnome extension: $i"
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
  gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "[]" # remove default binding to free for other things
  gsettings set org.gnome.shell.keybindings focus-active-notification "[]" # remove default binding to free for other things
  gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super>n']" # change to n for notifications
  gsettings set org.gnome.desktop.wm.keybindings toggle-maximized "['<Super>k']"
  gsettings set org.gnome.desktop.wm.keybindings minimize "['<Super>j']"
  gsettings set org.gnome.shell.extensions.tiling-assistant tile-left-half-ignore-ta "['<Super>h']"
  gsettings set org.gnome.shell.extensions.tiling-assistant tile-right-half-ignore-ta "['<Super>l']"

  # Careful here.. need to test this more
  # There is other info about adjusting all GTK apps using this
  # https://unix.stackexchange.com/questions/342628/gnome-3-keybindings-in-source-where-are-ctrl-c-cut-copy-and-paste-defin/399632
  if gsettings list-recursively | grep -q "org.gnome.Ptyxis"; then
    gsettings set org.gnome.Ptyxis.Shortcuts paste-clipboard '<Super>v'
    gsettings set org.gnome.Ptyxis.Shortcuts copy-clipboard '<Super>c'
  fi
  #gsettings set org.gnome.Terminal.Legacy.Keybindings paste '<Super>v'
  #gsettings set org.gnome.Terminal.Legacy.Keybindings copy '<Super>c'
  # This seems to work well for terminal.
  dconf write /org/gnome/terminal/legacy/keybindings/copy  \'"<Super>c"\'
  dconf write /org/gnome/terminal/legacy/keybindings/paste \'"<Super>v"\'

  # Dock settings
  if gnome-extensions list --enabled | grep -q "ubuntu-dock@ubuntu.com"; then
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position BOTTOM
    gsettings set org.gnome.shell.extensions.dash-to-dock autohide true
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
    gsettings set org.gnome.shell.extensions.dash-to-dock show-trash false
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false # panel mode
  fi

  # Make sure scrolling is natural
  gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true
  gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

  # Center new windows in the middle of the screen
  gsettings set org.gnome.mutter center-new-windows true
  # Reveal week numbers in the Gnome calendar
  gsettings set org.gnome.desktop.calendar show-weekdate true
  # Turn off ambient sensors for setting screen brightness (they rarely work well!)
  gsettings set org.gnome.settings-daemon.plugins.power ambient-enabled false

  # Disable bell
  gsettings set org.gnome.desktop.wm.preferences audible-bell false

  # Adjust switching of windows in an app group to MEH-Tab
  gsettings set org.gnome.desktop.wm.keybindings switch-panels-backward "[]"
  gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Super>Above_Tab', '<Alt>Above_Tab', '<Shift><Control><Alt>Tab']"


  # Reserve slots for custom keybindings
  gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"

  # Instead of ROFI lets just keep it simple and use the built in app search mess.  Its harsh but much simpler to deal with for as much as I actually use it.
  gsettings set org.gnome.shell.keybindings toggle-overview "['<Super>space']"
  # Set ROFI custom keybind
  # First remove existing keybind
  #gsettings set org.gnome.desktop.wm.keybindings switch-input-source "@as []"
  ## Set our new keybind
  #gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "App Launcher"
  #gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "rofi -show drun -normal-window"
  #gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Super>space"
  ##dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'Rofi Launcher'"
  ##dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/command "'rofi -show drun'"
  ##dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Super>space'"

  # Keybind for ghostty that for now will set LIBGL_ALWAYS_SOFTWARE=1 because of horrible rendering issues on all my boxes. This is NON OPTIMAL
  # This keybind is a lame way to just get ghostty started since it adds Super to the list.  Then once open use regular keybinds in app-hotkeys definition.
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "Ghostty terminal"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "bash -c 'LIBGL_ALWAYS_SOFTWARE=1 ghostty'"
  gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "<Super><Shift><Control><Alt>g"

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

  # Disable home icon on desktop
  if gsettings list-recursively | grep -q "org.gnome.shell.extensions.ding"; then
    gsettings set org.gnome.shell.extensions.ding show-home false
  fi

  # Setup hotkeys for applications. Requires application-hotkeys extension to be installed
  # I'm using this instead of custom-keybinds because it knows to open vs focus.
  # TODO: could these all just be custom-keybindings instaead?
  dconf write /org/gnome/shell/extensions/application-hotkeys/configs "@as [
    '[\"org.gnome.Terminal.desktop\",    \"<Shift><Control><Alt>t\"]',
    '[\"brave-browser.desktop\",         \"<Shift><Control><Alt>b\"]',
    '[\"com.mitchellh.ghostty.desktop\", \"<Shift><Control><Alt>g\"]',
    '[\"1password.desktop\",             \"<Shift><Control><Alt>p\"]'
  ]"
  dconf write /org/gnome/shell/extensions/clipboard-indicator/toggle-menu "@as ['<Shift><Super>v']"
fi
else
  msg "${BLU}Skipping Gnome installation and setup changes."
fi

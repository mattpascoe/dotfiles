#!/bin/bash

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
prompt "Install Homebrew based packages... Continue (N/y) "
read -r REPLY < /dev/tty
if [ "$REPLY" == "y" ]; then
  if ! command -v "brew" &> /dev/null; then
    msg "${BLU}Installing Brew tools..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  BREWPATH=/opt/homebrew/bin

  # Load up brew environment, should work on ARM intel systems.
  if [ -f $BREWPATH/brew ] &> /dev/null; then
    eval "$($BREWPATH/brew shellenv)"

    msg "${BLU}Ensuring install of requested brew packages..."
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
  msg "${BLU}Skipping Brew based config changes."
fi

# Setup lots of system settings using the "defaults" method
prompt "Execute 'defaults' commands to set specific Mac settings... Continue (N/y) "
read -r REPLY < /dev/tty
if [[ $REPLY =~ ^[Yy]$ ]]; then
  # Running with and without sudo as I seem to get different behaviors?
  msg "${BLU}Running as normal user."
  "$DOTREPO/setup/profiles/_macos.sh"
  msg "${BLU}Running again with sudo."
  sudo "$DOTREPO/setup/profiles/_macos.sh"
else
  msg "${BLU}Skipping defaults based config changes."
fi

# For some reason /usr/local/bin is not on mac by default. Lets make it for starship
if [ ! -d /usr/local/bin ]; then
  sudo mkdir -p /usr/local/bin
  sudo chown $(whoami):admin /usr/local/bin
fi

msg "${BLU}
The following items are not currently controllable and will need to be done manually:
  - Reduce Motion: System Preferences -> Accessibility -> Display -> Reduce Motion
  - Install Raycast, then setup app keybinds for MEH+b, MEH+g, MEH+m etc.
"

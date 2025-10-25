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

# Install and setup Brew for package management
BREWPATH=/opt/homebrew/bin
if [ ! -f "$BREWPATH"/brew ] &> /dev/null; then
  msg "${BLU}Installing Brew tools..."
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Load up brew environment, so we can actually install things
if [ -f "$BREWPATH"/brew ] &> /dev/null; then
  eval "$("$BREWPATH"/brew shellenv)"
else
  msg "${RED}-!- ERROR: Unable to find Brew command. Please install Brew and try again."
fi

msg "${BLU}
The following items are not currently controllable and will need to be done manually:
  - Reduce Motion: System Preferences -> Accessibility -> Display -> Reduce Motion
  - Install Raycast, then setup app keybinds for MEH+b, MEH+g, MEH+m etc.
"

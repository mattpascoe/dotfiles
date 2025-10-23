#!/bin/bash

# It is intended that this script can and should be run at any time
# It will install a fresh system or will update an existing system with the latest packages and configurations
#
# flow to work toward:
# entrypoint in setup.sh that determines PLATFORM. It calls into setup/PLATFORM.sh
# each platform.sh script will then determin a release type and call setup/PLATFORM/RELEASE-ID.sh

set -e

# STEP 1: initial setup, turn this into a library
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
    Linux*)     PLATFORM=Linux;;
    Darwin*)    PLATFORM=Mac;;
    CYGWIN*)    PLATFORM=Cygwin;;
    MINGW*)     PLATFORM=MinGw;;
    *)          PLATFORM="UNKNOWN:${unameOut}"
esac

if [ -f /etc/os-release ]; then
  . /etc/os-release
fi

# If DOTDIR variable is set, use it
# TODO" this needs reworked.. may not need DOTDIR
if [ -n "${DOTDIR:-}" ]; then
  DIR=$DOTDIR
else
  SCRIPT=$(readlink -f "$0")
  DIR=$(dirname "$SCRIPT")
fi
msg "${BLU}Running from $DIR."
msg "${BLU}Looks like we are a $PLATFORM system."
msg "${BLU}Looks like the OS is ${PRETTY_NAME}."

# STEP 2: Check and install git if needed
msg "${UL}Checking for Git"
if ! command -v "git" &> /dev/null; then
  case "$ID" in
  debian*|ubuntu*)
#??    sudo apt update -y
    sudo apt install -y git
    ;;
  arch*)
    # Disable kernel messages since we are likely on a console
    # We'll turn it back on later, this just gets rid of some noise in output
    # TODO; move this dmesg to the arch install script too
    sudo dmesg -n 3
    # Update the system and ensure git is installed, grab some others just for good measure
    sudo pacman --disable-sandbox --needed --noconfirm -Syu git curl wget sudo fontconfig
    ;;
  *)
    if [ "$PLATFORM" == "Mac" ]; then
      # run git command, it may ask to install developer tools, go ahead and do that to get the git command
      msg "Checking git version. If missing it will prompt to install developer tools..."
      git --version
    else
      msg "${RED}-!- This system is not a supported type. Aborting."
      exit 1
    fi
    ;;
  esac
fi
msg "${GRN}Git is installed."

# STEP 3: Clone dotfiles repo
# set the location of our dotfiles install
DOTREPO=~/dotfiles

# Test if the dotfiles dir already exists.
if [ ! -d "$DOTREPO" ]; then
  msg "${GRN}Cloning dotfiles to $DOTREPO..."
  git clone https://github.com/mattpascoe/dotfiles "$DOTREPO"
else
  msg "${BLU}Clone of git repo already exists in $DOTREPO."
#  echo "Updating dotfiles..."
#  cd "$DOTDIR" || exit
#  git pull >/dev/null
#  cd - > /dev/null || exit
fi

# STEP 4: Run the setup_common.sh script that EVERYONE should run
echo
source "${DOTREPO}/setup/setup_common.sh"
echo

# STEP 5: Call the PLATFORM specific setup scripts
# Unraid is special so just call it here
if [ -f /etc/unraid-version ]; then
  source "${DOTREPO}/setup/unraid.sh"
else
  source "${DOTREPO}/setup/${PLATFORM}.sh"
fi


# Install extra tools. These should have a prompt for each one.
# THOUGHT; does this invert the structure such that each one of these sourced files has a section per platform?
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

# TODO: This needs to go somewhere better
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

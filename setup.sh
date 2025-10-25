#!/bin/bash

# It is intended that this script can and should be run at any time
# It will install a fresh system or will update an existing system with the latest packages and configurations
# Some manual desktop configuration aspects may be changed to something defined here so try and do it here where possible
#
# flow to work toward:
# entrypoint in setup.sh that determines PLATFORM. It calls into setup/PLATFORM.sh
# each platform.sh script will then determin a release type and call setup/PLATFORM/RELEASE-ID.sh

# ---- Set some defaults for initial direct curl/wget based installs
# I dont like that I have to set all the same library stuff here but its required
# to not have to have a separate install script. Maybe I dont actually need a
# separate library anyway??
# Some of these things are also in config
DOTREPO="$HOME/dotfiles"
DOTREPO_URL=https://github.com/mattpascoe/dotfiles

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
function prompt() {
  command echo -e "${BOLD}${GRN}$*${NC}\c"
}

# Check if USER is set and try a fallback
USER="${USER:-$(whoami)}"

# Determine what type of machine we are on
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     PLATFORM=Linux;;
    Darwin*)    PLATFORM=Mac
                # In leu of /etc/os-release we will provide our own
                PRETTY_NAME=$(system_profiler SPSoftwareDataType | grep "System Version" | cut -d : -f 2 | xargs)
                ID=macos
                ;;
    CYGWIN*)    PLATFORM=Cygwin;;
    MINGW*)     PLATFORM=MinGw;;
    *)          PLATFORM="UNKNOWN:${unameOut}"
esac

[[ -f /etc/os-release ]] && source /etc/os-release
# END inital library setup

msg "${BLU}Dotfile repo location: $DOTREPO."
msg "${BLU}Looks like we are a $PLATFORM system."
msg "${BLU}Looks like the OS is ${PRETTY_NAME}."

# Check for and install git if needed
if ! command -v "git" &> /dev/null; then
  msg "\n${UL}Installing Git"
  case "$ID" in
  debian*|ubuntu*)
    sudo apt install -y git
    ;;
  arch*)
    # Disable kernel messages since we are likely on a console
    # We'll turn it back on later, this just gets rid of some noise in output
    # TODO: move this dmesg to the arch install script too
    sudo dmesg -n 3
    # Update the system and ensure git is installed, grab some others just for good measure
    sudo pacman --disable-sandbox --needed --noconfirm -Syu git curl wget sudo fontconfig
    ;;
  macos*)
    # Run git command, it may ask to install developer tools, go ahead and do that to get the git command
    msg "Checking git version. If missing it will prompt to install developer tools..."
    git --version
    ;;
  *)
    msg "${RED}-!- This system is not a supported type. Aborting."
    exit 1
    ;;
  esac
  msg "${BLU}Git is installed."
fi

# Ensure we have a clone of dotfiles repo
# Test if the dotfiles dir already exists.
if [ ! -d "$DOTREPO" ]; then
  msg "${GRN}Cloning dotfiles to $DOTREPO..."
  git clone "$DOTREPO_URL" "$DOTREPO"
else
  pushd "$DOTREPO" >/dev/null || exit
  git fetch --all --tags
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  BEHIND_COUNT=$(git rev-list --count HEAD..origin/"$CURRENT_BRANCH" || echo "unknown")
  if [ "$BEHIND_COUNT" -gt 0 ]; then
    msg "!! Dotfile repo is NOT up to date on branch $CURRENT_BRANCH."
  else
    msg "${BLU}Dotfile repo is up to date on branch $CURRENT_BRANCH."
  fi
  popd >/dev/null || exit
fi
# ---- This ends the section for first time curl/wget based installs. The rest runs from the repo.

# Lets pull in our local repo based config and library to possibly
# override and add to defaults above
# Initialize some variables
[[ -f "$DOTREPO/setup/setup_lib.sh" ]] && source "$DOTREPO/setup/setup_lib.sh"
# Gather configuration for this process to use
[[ -f "$DOTREPO/setup/config.sh" ]] && source "$DOTREPO/setup/config.sh"

# Prompt user for a Role
# I'm going with a similar Role/Profile setup to Puppet.
# Profiles are just a targeted script that performs a block of actions.
# Roles are a collection of profiles that are related and are executed together.

# You can define a ROLE in the Environment. If we dont have an ENV
# Look for a file called .dotfile_role in your home directory
FILE_ROLE=""
DOTFILE_ROLE_PATH="$HOME/.dotfile_role"
# Get the current role from the file if it exists
[[ -f "$DOTFILE_ROLE_PATH" ]] && FILE_ROLE=$(cat "$DOTFILE_ROLE_PATH")
# If we have no role in the ENV but we do have a file, use the file
[[ $ROLE == "" ]] && [[ -f "$DOTFILE_ROLE_PATH" ]] && ROLE=$(cat "$DOTFILE_ROLE_PATH")
# If we dont find a role then prompt the user if they want to pick one.
if [[ $ROLE == "" ]]; then
  msg "\n${UL}No Role defined, please select one."
  msg "${GRN}Available roles:${NC}"
  # List the available roles and description
  for FILE in $(find "$DOTREPO/setup/roles" -type f -name "[0-9a-zA-Z]*.sh"); do
    # Get the name of the file as the extra item we are installing
    ROLE=$(basename "$FILE"|cut -d. -f1)
    # Get the second line for a description to the user
    DESC=$(sed -n '2p' "$FILE")
    echo "$ROLE -- $DESC"
  done
  prompt "Enter role name (enter for DEFAULT): "
  read -r ROLE < /dev/tty
fi
[[ $ROLE != "" ]] && msg "${BLU}The Role for this system is: $ROLE"
# If our role does not match what is in the local file, update it
[[ $ROLE != "" ]] && [[ $ROLE != $FILE_ROLE ]] && echo "$ROLE" > "$DOTFILE_ROLE_PATH"

# Run the COMMON.sh script that EVERYONE should run
source "${DOTREPO}/setup/profiles/COMMON.sh"

# Call the PLATFORM specific setup scripts
# Unraid is special so just call it here
if [ -f /etc/unraid-version ]; then
  source "${DOTREPO}/setup/platforms/unraid.sh"
else
  msg "\n${UL}Running the ${PLATFORM} platform setup script"
  source "${DOTREPO}/setup/platforms/${PLATFORM}.sh"
fi

# Actually process the role or prompt for individual profiles
if [[ $ROLE == "" ]]; then
  source "${DOTREPO}/setup/roles/DEFAULT.sh"
else
  msg "\n${UL}Running the ${ROLE} role setup script"
  if [ ! -f "$DOTREPO/setup/roles/$ROLE.sh" ]; then
    msg "${RED}-!- Role $ROLE does not exist."
  else
    source "$DOTREPO/setup/roles/$ROLE.sh"
  fi
fi

msg "\n${UL}Setup complete."
msg "You should probably reboot if this is your first run"
msg "OR at least log out or start a 'tmux' session to utilize new shell changes."

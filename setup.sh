#!/bin/bash

# It is intended that this script can and should be run at any time
# It will install a fresh system or will update an existing system with the latest packages and configurations
# Some manual desktop configuration aspects may be changed to something defined here so try and do it here where possible
#
# flow to work toward:
# entrypoint in setup.sh that determines PLATFORM. It calls into setup/PLATFORM.sh
# each platform.sh script will then determin a release type and call setup/PLATFORM/RELEASE-ID.sh

# STEP 1: Initialize some variables
source setup/setup_lib.sh

# Gather configuration for this process to use
source setup/config.sh

msg "${BLU}Dotfile repo location: $DOTREPO."
msg "${BLU}Looks like we are a $PLATFORM system."
msg "${BLU}Looks like the OS is ${PRETTY_NAME}."

# STEP 2: Check for and install git if needed
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
fi
msg "${GRN}Git is installed."

# STEP 3: Clone dotfiles repo
# Test if the dotfiles dir already exists.
if [ ! -d "$DOTREPO" ]; then
  msg "${GRN}Cloning dotfiles to $DOTREPO..."
  git clone "$DOTREPO_URL" "$DOTREPO"
else
  msg "${BLU}A clone of dotfiles git repo already exists in $DOTREPO."
#  echo "Updating dotfiles..."
#  cd "$DOTREPO" || exit
#  git pull >/dev/null
#  cd - > /dev/null || exit
fi

# STEP 4: Prompt user for Role
# I'm going with a similar Role/Profile setup to Puppet.
# Profiles are just a targeted script that performs a block of actions.
# Roles are a collection of profiles that are related and are executed together.
# THOUGHT; does this invert the structure such that each one of these sourced files has a section per platform?

# You can define a ROLE in the Environment. If we dont have an ENV
# Look for a file called .dotfile_role in your home directory
DOTFILE_ROLE_PATH="$HOME/.dotfile_role"
[[ -f "$DOTFILE_ROLE_PATH" ]] && FILE_ROLE=$(cat "$DOTFILE_ROLE_PATH")
[[ $ROLE == "" ]] && [[ -f "$DOTFILE_ROLE_PATH" ]] && ROLE=$(cat "$DOTFILE_ROLE_PATH")
# If we dont have a .dotfile_role in your home directory lets create one
[[ $ROLE != $FILE_ROLE ]] && echo "$ROLE" > "$DOTFILE_ROLE_PATH"
# If we dont find a role then prompt the user for ALL of them.
if [[ $ROLE == "" ]]; then
  AVAILABLE_ROLES=$(ls -1 "$DOTREPO/setup/roles/"|cut -d. -f1)
  msg "${UL}No Role defined."
  prompt "Y = Select a role. N = Choose profiles to run. (Y/n) "
  read -r REPLY < /dev/tty
  if [[ $REPLY =~ ^[Nn]$ ]]; then
    ROLE=""
  else
    msg "${UL}${BOLD}${GRN}Available roles:
    $AVAILABLE_ROLES"
    prompt "Enter role name:"
    read -r ROLE < /dev/tty
  fi
fi
[[ $ROLE != "" ]] && msg "${UL}The Role for this system is: $ROLE"

# STEP 5: Run the common.sh script that EVERYONE should run
echo
source "${DOTREPO}/setup/profiles/COMMON.sh"
echo

# STEP 5: Call the PLATFORM specific setup scripts
# Unraid is special so just call it here
if [ -f /etc/unraid-version ]; then
  source "${DOTREPO}/setup/platforms/unraid.sh"
else
  msg "${UL}Running the ${PLATFORM} platform setup script..."
  source "${DOTREPO}/setup/platforms/${PLATFORM}.sh"
fi

# Actually process the role or prompt for individual profiles
if [[ $ROLE == "" ]]; then
  prompt "Do you want to install extra tools? You will be prompted for each one. (N/y) "
  read -r REPLY < /dev/tty
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    for FILE in $(find "$DOTREPO/setup/profiles" -type f -name "*.sh"); do
      # Get the name of the file as the extra item we are installing
      PROFILE=$(basename "$FILE"|cut -d. -f1)
      # Skip the common profile since we already included it
      [[ $PROFILE == "COMMON" ]] && continue
      # Get the second line for a description to the user
      DESC=$(sed -n '2p' "$FILE")
      prompt "Install ${PROFILE} -- ${DESC} (N/y) "
      read -r REPLY < /dev/tty
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        source "$FILE"
      fi
    done
  fi
else
  source "$DOTREPO/setup/roles/$ROLE.sh"
fi

echo
msg "${UL}Setup complete."
msg "You should probably reboot if this is your first run"
msg "OR at least log out or start a 'tmux' session to utilize new shell changes."

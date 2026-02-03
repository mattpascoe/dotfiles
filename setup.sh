#!/usr/bin/env bash

# shellcheck disable=SC1090,SC1091


# It is intended that this script can and should be run at any time
# It will install a fresh system or will update an existing system with the latest packages and configurations
# Some manual desktop configuration aspects may be changed to something defined here so try and do it here where possible
#
# I'm going with a similar Role/Profile setup to Puppet.
# Profiles are just a targeted script that performs a block of actions.
# Roles are a collection of profiles that are related and are executed together.



# ---- Set some defaults for initial direct curl/wget based installs
# I dont like that I have to set all the same library stuff here but its required
# to not have to have a separate install script. Maybe I dont actually need a
# separate library anyway??
# Some of these things are also in config
DOTREPO="$HOME/dotfiles"
DOTREPO_URL=https://github.com/mattpascoe/dotfiles
DOTFILE_ROLE_PATH="$HOME/.dotfile_role"
PROFILE_DIR="$DOTREPO/setup/profiles"

# Get the current role from the cache file if it exists and we didnt set one in the ENV
[[ -f "$DOTFILE_ROLE_PATH" ]] && [[ $ROLE == "" ]] && ROLE=$(cat "$DOTFILE_ROLE_PATH" 2>/dev/null)

# Colors/formatting
UL="\033[4m" # underline
NC="\033[0m" # no color/format
YEL="\033[33m"
BLU="\033[34m"
RED="\033[31m"
GRN="\033[32m"
BOLD="\033[1m"

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

# --------- Define standard functions --------
function msg() {
  command echo -e "${BOLD}${YEL}$*${NC}"
}
function prompt() {
  command echo -e "${BOLD}${GRN}$*${NC}\c"
}

# Links the file in Home to dotfile repo
function link_file() {
  FILE=$1
  if [ ! -L "$HOME/$FILE" ]; then
    if [ -e "$HOME/$FILE" ]; then
      msg "${BLU}Backing up current config file to ${FILE}.bak"
      mv "$HOME/$FILE" "$HOME/$FILE.bak"
    fi
    msg "${BLU}Linking config file $HOME/$FILE -> $DOTREPO/$FILE"
    ln -s "$DOTREPO/$FILE" "$HOME/$FILE"
  else
    LINK_LIST=$(ls -o "$HOME/$FILE")
    msg "${BLU}Config link exists: $LINK_LIST"
  fi
}

# Execute the script for each profile passed in as an array
function run_profiles() {
  PROFILES=("${@}")
  for PROFILE in "${PROFILES[@]}"; do
    # Check that it actually exists
    if [ ! -f "$PROFILE_DIR/$PROFILE.sh" ]; then
      msg "${RED}-!- Profile $PROFILE does not exist. Skipping."
      continue
    fi
    # Get the second line for a description to the user
    DESC=$(sed -n '2p' "$PROFILE_DIR/$PROFILE.sh")
    msg "Installing ${PROFILE} -- ${DESC}"
    source "$PROFILE_DIR/$PROFILE.sh"
  done
}

# Check for and install git if needed
# This is a base requirement to establish the dotfiles repo
function check_git() {
  if ! command -v "git" &> /dev/null; then
    msg "\n${UL}Installing Git"
    case "$ID" in
    debian*|ubuntu*)
      sudo apt install -y git
      ;;
    arch*)
      # Disable kernel messages since we are likely on a console
      # We'll turn it back on later, this just gets rid of some noise in output
      # This assumes you are performing the initial install as root
      # TODO: dmesg here does not seem to be best and I dont ahve a good way of turning it off currently. tbd
      #dmesg -n 3
      # Update the system and ensure git is installed, grab some others just for good measure
      pacman --needed --noconfirm -Syu git curl wget sudo fontconfig jq zsh base-devel
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
}


# Ensure we have a clone of dotfiles repo
# Test if the dotfiles dir already exists.
function check_dotrepo() {
  if [ ! -d "$DOTREPO" ]; then
    msg "${GRN}Cloning dotfiles to $DOTREPO..."
    git clone "$DOTREPO_URL" "$DOTREPO"
  else
    pushd "$DOTREPO" >/dev/null || exit
    git fetch --all --tags > /dev/null
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    BEHIND_COUNT=$(git rev-list --count HEAD..origin/"$CURRENT_BRANCH" || echo "unknown")
    if [ "$BEHIND_COUNT" -gt 0 ]; then
      msg "!! Dotfile repo is NOT up to date on branch $CURRENT_BRANCH."
    else
      msg "${BLU}Dotfile branch: ${UL}$CURRENT_BRANCH${NC} ${BLU}(Up to date)"
    fi
    popd >/dev/null || exit
  fi
}

# List the available profiles
function list_profiles() {
  msg "${GRN}Available profiles:${NC}"
  # List the available profiles and description
  local LIST DESC PROFILE
  for FILE in $(find "$DOTREPO/setup/profiles" -type f -name "[0-9a-zA-Z]*.sh"|LC_ALL=C sort -h); do
    PROFILE=$(basename "$FILE" | cut -d. -f1)
    DESC=$(sed -n '2p' "$FILE")
    LIST="$LIST\n$PROFILE:$DESC"
  done
  echo -e "$LIST"|column -t -s ':'
}

# List the available roles
function list_roles() {
  msg "${GRN}Available roles:${NC}"
  # List the available roles and description
  local LIST DESC ROLE
  for FILE in $(find "$DOTREPO/setup/roles" -type f -name "[0-9a-zA-Z]*.sh"|LC_ALL=C sort -h); do
    ROLE=$(basename "$FILE" | cut -d. -f1)
    DESC=$(sed -n '2p' "$FILE")
    LIST="$LIST\n$ROLE:$DESC"
  done
  echo -e "$LIST"|column -t -s ':'
}

# This will prompt the user for a role
function prompt_for_role() {
  msg "\n${UL}Please select a role."
  list_roles

  while true; do
    prompt "Enter role name (enter for DEFAULT): "
    read -r ROLE < /dev/tty
    ROLE="${ROLE:-DEFAULT}"
    if [ -f "$DOTREPO/setup/roles/$ROLE.sh" ]; then
      break
    else
      msg "${RED}-!- Role '$ROLE' does not exist. Please try again."
    fi
  done
}


# Call the PLATFORM specific setup scripts
function setup_platform() {
  msg "\n${UL}Running platform setup script"
  source "${DOTREPO}/setup/platforms/${PLATFORM}.sh"
}


# Display some info about the system
function system_info() {
  msg "${BLU}Dotfile repo:   ${UL}$DOTREPO"
  msg "${BLU}Platform type:  ${UL}$PLATFORM"
  msg "${BLU}OS type:        ${UL}$PRETTY_NAME"
}


# Display help
function help() {
  cat <<EOF
Usage: $0 [options]

Options:
  -l, --list-profiles    List available profiles
  -p, --profile          Directly execute a specific profile.
  -g, --gitpull          Perform a git pull on the dotfiles repo
  -L, --list-roles       List available roles
  -r, --role             Role to setup. Overrides cache and ENV.
  -n, --no-save-role     Do not save role to local file cache
  -h, --help             Show this help message
EOF
}
# ---------- END standard functions

# Gather configuration for this process to use
[[ -f "$DOTREPO/setup/config.sh" ]] && source "$DOTREPO/setup/config.sh"

# Unraid OS installs are special so just call it here, this will exit in that script
[[ -f /etc/unraid-version ]] && source "${DOTREPO}/setup/platforms/unraid.sh"

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --list-roles|-L)
            list_roles
            exit 0
            ;;
        --list-profiles|-l)
            list_profiles
            exit 0
            ;;
        --role|-r)
            if [[ -z "$2" || "$2" == -* ]]; then
              echo "Error: role requires an argument" >&2
              exit 1
            fi
            ROLE="$2"
            shift 2
            ;;
        --gitpull|-g)
            msg "${UL}Performing git pull on dotfiles repo:${NC} ${BLU}$DOTREPO"
            cd "$DOTREPO" || exit
            git pull
            exit 0
            ;;
        --profile|-p)
            if [[ -z "$2" || "$2" == -* ]]; then
              echo "Error: profile requires an argument" >&2
              exit 1
            fi
            PROFILE="$2"
            shift 2
            system_info
            setup_platform
            msg "${UL}Directly running profile setup script:${NC} ${BLU}$PROFILE"
            source "$DOTREPO/setup/profiles/$PROFILE.sh"
            exit 0
            ;;
        --no-save-role|-n)
            NO_SAVE_ROLE=true
            shift
            ;;
        --help|-h)
            help
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1"
            echo "Run with -h flag for help."
            exit 1
            ;;
    esac
done

system_info
check_git
check_dotrepo
# ---- This ends the section for first time curl/wget based installs. The rest should run from the local repo.



# If we dont find a role then prompt the user if they want to pick one.
[[ $ROLE == "" ]] && prompt_for_role
# If we made it this far but the role doesnt actually exist, prompt the user again
[[ ! -f "$DOTREPO/setup/roles/$ROLE.sh" ]] && msg "${RED}-!- Role '$ROLE' does not exist. Please select a valid one." && prompt_for_role

msg "${BLU}Selected role:  ${UL}$ROLE"

setup_platform

# Run the COMMON.sh script that EVERYONE should run
source "${DOTREPO}/setup/profiles/COMMON.sh"

# Actually process the selected role
prompt "\nRun ${UL}${ROLE}${NC}${GRN} role setup script? (N/y) "
read -r REPLY < /dev/tty
if [[ $REPLY =~ ^[Yy]$ ]]; then
  source "$DOTREPO/setup/roles/$ROLE.sh"
fi

# Save the role to the local cache file
if [[ $NO_SAVE_ROLE == true ]]; then
  msg "\n${UL}Requested to skip role cache update."
else
  if [[ $ROLE != $(cat "$DOTFILE_ROLE_PATH" 2>/dev/null) ]]; then
    msg "\n${UL}Saving role to cache:${NC} ${BLU}$ROLE"
    echo "$ROLE" > "$DOTFILE_ROLE_PATH"
  fi
fi

# Finalize
msg "\n${UL}Setup complete"
msg "You should probably reboot if this is your first run"
msg "OR at least log out or start a 'tmux' session to utilize new shell changes."

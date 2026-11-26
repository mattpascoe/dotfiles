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
DOTFILE_MASTERLIST="$HOME/.dotfile_masterlist"
PROFILE_DIR="$DOTREPO/setup/profiles"

# Get the current role from the cache file if it exists and we didnt set one in the ENV
[[ -f "$DOTFILE_ROLE_PATH" ]] && [[ $ROLE == "" ]] && ROLE=$(cat "$DOTFILE_ROLE_PATH" 2>/dev/null)

# Colors/formatting
UL="\033[4m" # underline
UL_OFF="\033[24m" # no underline
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
                ID=macos
                ;;
    CYGWIN*)    PLATFORM=Cygwin;;
    MINGW*)     PLATFORM=MinGw;;
    *)          PLATFORM="UNKNOWN:${unameOut}"
esac

PLATFORM_INSTALLER_BIN=""
INSTALLER_OPTS=""
PLATFORM_INSTALLER_DRYRUN_FLAG=""
DRY_RUN=""

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
  if [[ "$DRY_RUN" == true ]]; then
    if [ ! -L "$HOME/$FILE" ]; then
      if [ -e "$HOME/$FILE" ]; then
        msg "${BLU}[DRY-RUN] Would backup current config file to ${FILE}.bak"
      else
        msg "${BLU}[DRY-RUN] Would link config file $HOME/$FILE -> $DOTREPO/$FILE"
      fi
    else
      LINK_LIST=$(ls -o "$HOME/$FILE")
      msg "${BLU}Config link exists: $LINK_LIST"
    fi
  else
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
    # Profiles are sourced; capture cwd so a profile cannot leave us in a deleted dir
    local PROFILE_PWD="$PWD"
    source "$PROFILE_DIR/$PROFILE.sh"
    # Restore cwd if it changed or was removed (avoids: getcwd() failed: No such file or directory)
    if ! cd . 2>/dev/null; then
      cd "$PROFILE_PWD" 2>/dev/null || cd "$HOME" 2>/dev/null || true
    elif [[ "$PWD" != "$PROFILE_PWD" ]]; then
      cd "$PROFILE_PWD" 2>/dev/null || true
    fi
  done
}

# Check for and install git if needed
# This is a base requirement to establish the dotfiles repo
function check_git() {
  if ! command -v "git" &> /dev/null; then
    msg "\n${UL}Git not found, Installing"
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
      # A special case on Arch, I'm going to enable the wheel group for sudo
      # This is here and assumes that if git is not installed, then we have not set up sudo. Probably better ways to do this.
      sed -i.bak '/^[[:space:]]*#\s*%wheel[[:space:]]\+ALL=(ALL)[[:space:]]\+ALL/s/^#\s*//' /etc/sudoers
      # Also a stupid thing to ensure I have a user setup, maybe prompt for this at some point
      msg "Adding mdp user, please provide a password when prompted"
      if ! id -u mdp &> /dev/null; then
        useradd -m -G wheel -s /bin/zsh mdp && passwd mdp < /dev/tty
      fi
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
      msg "!! Dotfile repo is NOT up to date on branch $CURRENT_BRANCH. Use ${UL}${BLU}pull${UL_OFF}${YEL} command to update."
    else
      msg "${BLU}Dotfile branch: ${UL}$CURRENT_BRANCH${NC} ${BLU}(Up to date)"
    fi
    popd >/dev/null || exit
  fi
}

# Check for package updates using the package manager
function check_package_updates() {
  echo
  msg "${GRN}Checking for package updates using package manager..."

  case "$ID" in
    macos*)
      UPGRADEABLE_PARAMS="outdated --greedy --verbose"
      UPGRADE_SYNTAX="brew upgrade -g"
      ;;
    debian*|ubuntu*)
      UPGRADEABLE_PARAMS="list --upgradable"
      UPGRADE_SYNTAX="apt upgrade"
      ;;
    arch*)
      UPGRADEABLE_PARAMS="-Qu"
      UPGRADE_SYNTAX="pacman -Su ??"
      ;;
  esac

  # shellcheck disable=SC2086
  UPGRADABLE=$($PLATFORM_INSTALLER_BIN $UPGRADEABLE_PARAMS 2>/dev/null|grep -v "Listing...")
  if [[ -n "$UPGRADABLE" ]]; then
    msg "${YEL}Upgradeable packages:${NC}"
    echo "$UPGRADABLE"
    msg "\n${YEL}Use ${UL}${BLU}${UPGRADE_SYNTAX}${UL_OFF}${YEL} command to update."
  else
    msg "${BLU}All packages are up to date"
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
    LIST+=("$PROFILE:$DESC\n")
  done
  echo -e " ${LIST[*]}"|column -t -s ':'|sed 's/^ //g'
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

# If we are doing a dry run, set the flag for the installer
function set_dry_run() {
  if [[ "$DRY_RUN" == true ]]; then
    msg "${YEL}Processing as a DRY RUN"
    INSTALLER_OPTS="$INSTALLER_OPTS $PLATFORM_INSTALLER_DRYRUN_FLAG"
  fi
}

# Display some info about the system
function system_info() {
  if [[ -n "$PRETTY_NAME" || "$PLATFORM" == "Mac" ]]; then
    # Mac has no /etc/os-release; only call system_profiler when a caller needs the pretty name.
    PRETTY_NAME=$(system_profiler SPSoftwareDataType 2>/dev/null | grep "System Version" | cut -d : -f 2 | xargs)
  fi
  msg "${BLU}Dotfile repo:   ${UL}$DOTREPO"
  msg "${BLU}Platform type:  ${UL}$PLATFORM"
  msg "${BLU}OS type:        ${UL}$PRETTY_NAME"
}

# Count upgradeable packages from the local package db. No index refresh and no sudo prompt.
function upgradeable_count() {
  local OUT
  case "$ID" in
    macos*)
      # Same location as BREWPATH in setup/platforms/Mac.sh. This path does not source that file.
      if ! OUT=$(HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_ENV_HINTS=1 /opt/homebrew/bin/brew outdated --greedy 2>/dev/null); then
        echo "?"
        return
      fi
      ;;
    debian*|ubuntu*)
      if ! command -v apt &> /dev/null; then
        echo "?"
        return
      fi
      if ! OUT=$(apt list --upgradable 2>/dev/null); then
        echo "?"
        return
      fi
      OUT=$(printf '%s\n' "$OUT" | grep 'upgradable' || true)
      ;;
    arch*)
      if ! command -v pacman &> /dev/null; then
        echo "?"
        return
      fi
      # Exit 1 means nothing is outdated, not a failure.
      OUT=$(pacman -Qu 2>/dev/null) || true
      ;;
    *)
      echo "?"
      return
      ;;
  esac

  if [[ -z "$OUT" ]]; then
    echo 0
  else
    printf '%s\n' "$OUT" | grep -c .
  fi
}

# Days from `uptime`. Less than a day is 0. Missing command is -.
function uptime_days() {
  local RAW
  RAW=$(uptime 2>/dev/null) || {
    echo "-"
    return
  }
  if [[ "$RAW" =~ ([0-9]+)[[:space:]]+day ]]; then
    printf '%s\n' "${BASH_REMATCH[1]}"
    return
  fi
  printf '0\n'
}

function uptime_label() {
  local DAYS="$1"
  if [[ -z "$DAYS" || "$DAYS" == "-" ]]; then
    printf '%s\n' '-'
  elif [[ "$DAYS" == 1 ]]; then
    printf '1 day\n'
  else
    printf '%s days\n' "$DAYS"
  fi
}

# One line: hostname= platform= role= branch= commit= upgradeable= uptime=
# Local git only. No fetch, no platform-script side effects.
function status_short() {
  local HOST ROLE_NAME GIT_OUT BRANCH COMMIT UPGRADEABLE UPTIME
  HOST=$(hostname -f 2>/dev/null || hostname 2>/dev/null || echo "-")
  ROLE_NAME="${ROLE:-"-"}"
  BRANCH="-"
  COMMIT="-"
  if [[ -d "$DOTREPO/.git" ]] && command -v git &> /dev/null; then
    # Two rev-parse modes cannot be combined; --abbrev-ref would rewrite the hash too.
    if GIT_OUT=$( { git -C "$DOTREPO" rev-parse --abbrev-ref HEAD && git -C "$DOTREPO" rev-parse --short HEAD; } 2>/dev/null ); then
      BRANCH="${GIT_OUT%%$'\n'*}"
      COMMIT="${GIT_OUT##*$'\n'}"
    fi
  fi
  UPGRADEABLE=$(upgradeable_count)
  UPTIME=$(uptime_days)
  printf 'hostname=%s platform=%s role=%s branch=%s commit=%s upgradeable=%s uptime=%s\n' \
    "$HOST" "${PLATFORM:-"-"}" "$ROLE_NAME" "$BRANCH" "$COMMIT" "$UPGRADEABLE" "$UPTIME"
}

# The main function to process the selected role
function process_role() {
  # If we dont find a role then prompt the user if they want to pick one.
  [[ $ROLE == "" ]] && prompt_for_role
  # If we made it this far but the role doesnt actually exist, prompt the user again
  [[ ! -f "$DOTREPO/setup/roles/$ROLE.sh" ]] && msg "${RED}-!- Role '$ROLE' does not exist. Please select a valid one." && prompt_for_role

  msg "${BLU}Selected role:  ${UL}$ROLE"

  # Run the COMMON.sh script that EVERYONE should run
  source "${DOTREPO}/setup/profiles/COMMON.sh"

  # Actually process the selected role
  source "$DOTREPO/setup/roles/$ROLE.sh"

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
}

# List the profiles used in the selected role
function profiles_in_role() {
  local ROLE="$1"
  LIST=()
  # Gather the list of profiles defined in role
  if [[ -f "$DOTREPO/setup/roles/$ROLE.sh" ]]; then
    ROLE_STATUS=1 source "$DOTREPO/setup/roles/$ROLE.sh"
    msg "${GRN}Profile count:  ${UL}${#PROFILES[@]}"

    for PROFILE in "${PROFILES[@]}"; do
        DESC=$(sed -n '2p' "$DOTREPO/setup/profiles/$PROFILE.sh")
        LIST+=("$PROFILE:$DESC\n")
    done

    echo -e " ${LIST[*]}"|column -t -s ':'|sort
    echo
  fi
}

# Display a full status including profile details for role
function full_status() {
  system_info
  check_package_updates
  # If we dont find a role then prompt the user to select one
  [[ $ROLE == "" ]] && process_role
  [[ ! -f "$DOTREPO/setup/roles/$ROLE.sh" ]] && ROLE="Unknown"

  local DESC; DESC=$(sed -n '2p' "$DOTREPO/setup/roles/$ROLE.sh")
  echo
  msg "${GRN}Selected role:  ${UL}$ROLE${NC} ${DESC}"

  profiles_in_role "$ROLE"

  msg "Use ${UL}${BLU}run${UL_OFF}${YEL} command to process profiles in the selected role."
}

# Display help
function help() {
  cat <<EOF
Usage: $0 [command] [options]

Commands:
  status             Show status (default if no command given)
  status-short       One-line status: hostname platform role branch commit upgradeable uptime
  report             SSH status-short for ~/.dotfile_masterlist and compare commits
  run                Run the setup process
  profile [name]     Directly execute a specific Profile or list all if no name given
  role [name]        Select a Role or list all if no name given. Overrides cache and ENV
  pull               Perform a git pull on the dotfiles repo
  help               Show help

Option flags:
  -s                 Show status
  -l                 List available profiles
  -L                 List available roles
  -g                 Perform a git pull on the dotfiles repo
  -n                 Do not save role to local file cache
  -d, --dry-run      Enable dry-run mode for package installs
  -p, --profile      Directly execute a specific profile
  -r, --role         Select a Role. Overrides cache and ENV
  -h, --help         Show this help message
EOF
}
# ---------- END standard functions

# Fast path: stay ahead of git fetch, platform setup, and system_profiler.
if [[ "$1" == "status-short" || "$1" == "--status-short" ]]; then
  status_short
  exit 0
fi
if [[ "$1" == "report" || "$1" == "--report" ]]; then
  # shellcheck disable=SC1091
  source "${DOTREPO}/setup/dot-report.sh"
  dot_report
fi

check_git
check_dotrepo

# Gather configuration for this process to use
[[ -f "$DOTREPO/setup/config.sh" ]] && source "$DOTREPO/setup/config.sh"

# Unraid OS installs are special so just call it here, this will exit in that script
[[ -f /etc/unraid-version ]] && source "${DOTREPO}/setup/platforms/unraid.sh"

# We will always setup based on the platform to establish the package manager etc
source "${DOTREPO}/setup/platforms/${PLATFORM}.sh"

# Make the default behavior a status call if no options are given
if [[ "$#" -eq 0 ]]; then
    full_status
    exit 0
fi

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --no-save-role|-n)
            NO_SAVE_ROLE=true
            shift
            ;;
        --dry-run|-d)
            DRY_RUN=true
            shift
            set_dry_run
            ;;
        --role|-r|role)
            if [[ -z "$2" || "$2" == -* ]]; then
              list_roles
              exit 0
            fi
            ROLE="$2"
            shift 2
            ;;
        --run|up|run)
            RUN_FLAG=true
            shift
            ;;
        -L)
            list_roles
            exit 0
            ;;
        -s|--status|status)
            full_status
            exit 0
            ;;
        status-short|--status-short)
            status_short
            exit 0
            ;;
        report|--report)
            # shellcheck disable=SC1091
            source "${DOTREPO}/setup/dot-report.sh"
            dot_report
            ;;
        -l)
            list_profiles
            exit 0
            ;;
        -g|pull)
            msg "${UL}Performing git pull on dotfiles repo:${NC} ${BLU}$DOTREPO"
            cd "$DOTREPO" || exit
            git pull
            exit 0
            ;;
        --profile|-p|profile|pro)
            if [[ -z "$2" || "$2" == -* ]]; then
              list_profiles
              exit 0
            fi
            PROFILE_FLAG=true
            PROFILE="$2"
            shift 2
            ;;
        --help|-h|help)
            help
            exit 0
            ;;
        *)
            echo "Error: Unknown option: $1"
            echo "Run with -h flag or help command."
            exit 1
            ;;
    esac
done

# Start main processing based on flag status

# If we are actually applying a role
if [[ "$RUN_FLAG" == true ]]; then
  system_info
  process_role
  exit 0
fi

# If we are applying a specific profile
if [[ "$PROFILE_FLAG" == true && "$PROFILE" != "" ]]; then
  system_info
  msg "${UL}Directly running profile setup script:${NC} ${BLU}$PROFILE"
  source "$DOTREPO/setup/profiles/$PROFILE.sh"
  exit 0
fi

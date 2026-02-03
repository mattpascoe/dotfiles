#!/usr/bin/env bash
# Prompt for each profile you want to install

# This does not use run_profiles since we want to prompt the user for each
msg "\n${UL}You will now be prompted for each available profile individually."
for FILE in $(find "$DOTREPO/setup/profiles" -type f -name "[0-9a-zA-Z]*.sh"); do
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

# Setup some common config symlinks
msg "Checking dotfile config symlinks"
link_file ".config/btop"
link_file ".config/git"
link_file ".profile"
link_file ".vimrc"
link_file ".zshrc"

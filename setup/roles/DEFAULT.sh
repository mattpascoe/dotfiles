#!/bin/bash
# DEFAULT will prompt you for each profile you want to install

msg "Using Default role. You will be prompted for each profile individually."
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

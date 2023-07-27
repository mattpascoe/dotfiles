# Settings for login shells
# Set up a prompt with spaces around the path so you can easily double click to select it
PS1='[\u@\h \w]\$ '

# If this is an xterm set the title to user@hostname
case $TERM in
    xterm*|rxvt*)
        TITLEBAR="\[\033]0;${USER}@${HOSTNAME}\007\]"
        ;;
    screen*)
        TITLEBAR="\[\033]0;${USER}@${HOSTNAME}\007\]"
        # Set the screen tab title to hostname when sshing
        # TODO: how does this work in a ssh -> ssh -> ssh scenario?
        function ssh () {
          args=$@
          printf %bk%s%b%b \\033 "${args##* }" \\033 \\0134
          command ssh $@;
          printf %bk%s%b%b \\033 "${HOSTNAME}" \\033 \\0134
        }
        # Set screen tab title initially for new windows:
        printf %bk%s%b%b \\033 "${HOSTNAME}" \\033 \\0134
        ;;
    *)
        TITLEBAR=""
        ;;
esac

# Update the prompt with the titlebar
PS1="$TITLEBAR$PS1"

# Show timestamps in history
HISTTIMEFORMAT="%Y-%m-%d %T "
HISTCONTROL=ignoreboth

shopt -s histappend # Append history, don't overwrite
shopt -s autocd # use autocd so you dont need to use cd command, just path

# include .bashrc if it exists
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

## Pull in common shell configuration
SCRIPT=$(readlink "$BASH_SOURCE")
SP=$(dirname "$SCRIPT")
source $SP/.shell-common

# Debian fzf completions
[[ -f /usr/share/bash-completion/completions/fzf ]] && source /usr/share/bash-completion/completions/fzf

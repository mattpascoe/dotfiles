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

# Set up some command aliases
alias ls='ls -F -G'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'
alias lt='ls -lt'

# Turn on vi mode
set -o vi

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi


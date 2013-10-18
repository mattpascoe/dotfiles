# Set up a prompt with spaces around the path so you can easily double click to select it
PS1='\u@\h: \w \$ '

# If this is an xterm set the title to user@hostname
case $TERM in
    xterm*|rxvt*)
        TITLEBAR="\[\033]0;${USER}@${HOSTNAME}\007\]"
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

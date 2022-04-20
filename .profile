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
# color for linux
##alias ls='ls -F --color=auto'
# color for mac
alias ls='ls -F -G'
alias la='ls -a'
alias ll='ls -l'
alias lla='ls -la'
alias lt='ls -lt'
alias cdd='cd $HOME/data'
# let diff know the width of my screen
alias diff='diff -W $(( $(tput cols) - 2 ))'

# Turn on vi mode
set -o vi

# Create ssh-reagent command to attached to existing agent sockets
ssh-reagent () {
  for agent in /tmp/ssh-*/agent.*; do
      export SSH_AUTH_SOCK=$agent
      if ssh-add -l 2>&1 > /dev/null; then
         echo Found working SSH Agent:
         ssh-add -l
         return
      fi
  done
  echo Cannot find ssh agent - maybe you should reconnect and forward it?
}

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


test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# https://starship.rs - a shell augmentation that seems simple
# get dejavumono nerdfont for iterm.
if command -v starship &> /dev/null; then
  echo "Enabling starship.."
  eval "$(starship init bash)"
fi

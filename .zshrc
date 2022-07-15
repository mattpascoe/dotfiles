# Settings for login shells
# Set up a prompt with spaces around the path so you can easily double click to select it
PS1='[%n@%m %~]$ '

# If this is an xterm set the title to user@hostname
case $TERM in
    xterm*|rxvt*)
        precmd () {print -Pn "\e]0;${USER}@${HOST}\a"}
        ;;
    *)
        ;;
esac


#HISTFILE=~/.zsh_history     #Where to save history to disk
HISTSIZE=50000               #How many lines of history to keep in memory
SAVEHIST=$HISTSIZE           #Number of history entries to save to disk
#HISTDUP=erase               #Erase duplicates in the history file
setopt    APPEND_HISTORY     #Append history to the history file (no overwriting)
setopt    INC_APPEND_HISTORY #Immediately append to the history file, not just when a term is killed
# Show timestamps in history using history -f
setopt    HIST_IGNORE_SPACE  #commands with space in front dont get stored
setopt    HIST_NO_FUNCTIONS  # dont store functions in history

# vi bind and reverse search
bindkey -v
bindkey '^R' history-incremental-search-backward

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
# git aliases
alias gs='git status'
alias gr='git remote'
alias gp='git pull'

# Turn on vi mode
set -o vi

# Create ssh_reagent command to attached to existing agent sockets
ssh_reagent () {
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

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -f /opt/homebrew/bin/brew ] &> /dev/null; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

# https://starship.rs - a shell augmentation that seems simple
# get dejavumono nerdfont for iterm.
if command -v starship &> /dev/null; then
  echo "Enabling starship.."
  eval "$(starship init zsh)"
fi

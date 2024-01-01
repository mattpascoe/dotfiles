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
setopt APPEND_HISTORY     #Append history to the history file (no overwriting)
setopt INC_APPEND_HISTORY #Immediately append to the history file, not just when a term is killed
# Show timestamps in history using history -f
setopt HIST_IGNORE_SPACE  #commands with space in front dont get stored
setopt HIST_NO_FUNCTIONS  # dont store functions in history
setopt AUTO_CD # automatically CD to directories without providing cd command
setopt CORRECT # suggest edits to commands. TBD if I like it

# vi bind and reverse search
bindkey -v
bindkey '^R' history-incremental-search-backward

# Enable completion system
autoload -Uz compinit && compinit

# Pull in common shell configuration
SCRIPT=$(readlink "${(%):-%x}")
SP=$(dirname "$SCRIPT")
[ -f $SP/.shell-common ] && source $SP/.shell-common

# Debian fzf completions
# if only the package was consistent in where it put its completions
[[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh

# Settings for login shells

# Define the XDG configuration directory
export XDG_CONFIG_HOME="$HOME/.config"

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
setopt INTERACTIVE_COMMENTS # allow comments in interactive shell

# vi bind and reverse search
bindkey -v
bindkey '^R' history-incremental-search-backward
#export KEYTIMEOUT=1 # some folks say this timeout is too short and it should
#be like 20. I have not ever used it so I dont know if I even need it. look into it more.


# Change cursor shape for different vi modes.
# more info https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes#For_Terminal_on_macOS
# Be aware that the cursor in vi also picks up on these settings.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[2 q';;      # block
        viins|main) echo -ne '\e[6 q';; # beam
    esac
}

zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[6 q"
}

zle -N zle-line-init
echo -ne '\e[6 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[6 q' ;} # Use beam shape cursor for each new prompt.
# End cursor shape change

# Enable completion system
autoload -Uz compinit && compinit

# Pull in common shell configuration
SCRIPT=$(readlink "${(%):-%x}")
SP=$(dirname "$SCRIPT")
[ -f $SP/.shell-common ] && source $SP/.shell-common

# Debian fzf completions
# if only the package was consistent in where it put its completions
[[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh

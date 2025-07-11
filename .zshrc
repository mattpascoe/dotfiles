# Settings for login shells

# Define the XDG configuration directory
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export HISTFILE="$XDG_STATE_HOME/zsh/history"

# Create $XDG_STATE_HOME/zsh if it doesn't exist
[ -d "$XDG_STATE_HOME/zsh" ] || mkdir -p "$XDG_STATE_HOME/zsh"

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

HISTFILE="$XDG_STATE_HOME/zsh/history" #Where to save history to disk
HISTSIZE=50000               #How many lines of history to keep in memory
SAVEHIST=$HISTSIZE           #Number of history entries to save to disk
#HISTDUP=erase               #Erase duplicates in the history file
setopt APPEND_HISTORY     #Append history to the history file (no overwriting)
setopt SHARE_HISTORY      #Share history between all sessions
setopt INC_APPEND_HISTORY #Immediately append to the history file, not just when a term is killed
# Show timestamps in history using history -f
setopt HIST_IGNORE_SPACE  #commands with space in front dont get stored
setopt HIST_NO_FUNCTIONS  # dont store functions in history
setopt AUTO_CD # automatically CD to directories without providing cd command
setopt CORRECT # suggest edits to commands. TBD if I like it
setopt INTERACTIVE_COMMENTS # allow comments in interactive shell
setopt NOAUTOMENU # dont select first match on tab completion

# vi bind and reverse search
bindkey -v
bindkey '^R' history-incremental-search-backward
bindkey '^n' history-search-forward
bindkey '^p' history-search-backward

# tab completion match case insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# tab completion list colors based on LS_COLORS. Color issues https://github.com/ohmyzsh/ohmyzsh/issues/6060
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

#export KEYTIMEOUT=1 # some folks say this timeout is too short and it should
#be like 20. I have not ever used it so I dont know if I even need it. look into it more.

# Change cursor shape for different vi modes.
# more info https://vim.fandom.com/wiki/Change_cursor_shape_in_different_modes#For_Terminal_on_macOS
# Be aware that the cursor in vi also picks up on these settings.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[3 q';;
        viins|main) echo -ne '\e[2 q';;
    esac
}

zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[2 q"
}

zle -N zle-line-init
echo -ne '\e[2 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[2 q' ;} # Use beam shape cursor for each new prompt.
# End cursor shape change

# Enable completion system
autoload -Uz compinit && compinit

# Set window/tab title specifically for lnav if using remote sessions
function lnav_preexec() {
  # Full command
  local cmd="$1"
  local shortcmd="${cmd%% *}"
  local context=""

  # Check for lnav with host:path pattern
  if [[ "$cmd" =~ ^(lnav)[[:space:]]+([^[:space:]]+): ]]; then
    shortcmd="${match[1]}"
    context="${match[2]}"

    # Set terminal title to "command context"
    echo -ne "\033k${shortcmd} ${context}\033\\"
  else
    print -Pn "\e]0;${USER}@${HOST}\a"
  fi
}

# Add lnav_preexec to preexec_functions, this is what will call extra functions
# before commands are executed
#preexec_functions+=("lnav_preexec")


# Pull in common shell configuration
SCRIPT=$(readlink "${(%):-%x}")
SP=$(dirname "$SCRIPT")
[ -f $SP/.shell-common ] && source $SP/.shell-common

# TODO: look at zinit for plugin management. Compare it to this manual method
#
# Load or install the zsh-autosuggestions plugin
if [ -f $XDG_CONFIG_HOME/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source $XDG_CONFIG_HOME/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
  # configure the autosuggestions
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#303030,underline'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  bindkey '^[[Z' autosuggest-accept # SHIFT-TAB to accept autosuggestion
else
  echo "Installing zsh-autosuggestions plugin."
  git clone https://github.com/zsh-users/zsh-autosuggestions $XDG_CONFIG_HOME/zsh/zsh-autosuggestions
fi

if [ -f $XDG_CONFIG_HOME/zsh/zsh-vi-mode/zsh-vi-mode.zsh ]; then
  source $XDG_CONFIG_HOME/zsh/zsh-vi-mode/zsh-vi-mode.zsh
else
  echo "Installing zsh-vi-mode plugin."
  git clone https://github.com/jeffreytse/zsh-vi-mode.git $XDG_CONFIG_HOME/zsh/zsh-vi-mode
fi
# Tell zsh-vi-mode to use insert mode by default
export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT


# Debian fzf completions
# if only the package was consistent in where it put its completions
# TODO shouldnt need this since its in shell-common, test it on linux
#[[ -f /usr/share/doc/fzf/examples/completion.zsh ]] && source /usr/share/doc/fzf/examples/completion.zsh

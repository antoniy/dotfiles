ZSH_CONFIG="$ZDOTDIR/.zshrc"

if [ -e $ZDOTDIR/.zshrc_local ]; then
    source $ZDOTDIR/.zshrc_local
fi

# Use neovim for vim if present.
command -v nvim >/dev/null && alias vim="nvim" vimdiff="nvim -d"

export EDITOR='nvim'

###############
### Aliases ###
###############

alias reload!="source $ZSH_CONFIG"

# Custom git alias which configures git to use specific git data directory
# and working directory set to $HOME.
# The purpose for this alias is to be used when dealing with dotfiles.
alias config="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"

# Verbosity and settings that you pretty much just always are going to want.
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -v"
alias mkd="mkdir -pv"
alias yt="youtube-dl --add-metadata -i"
alias yta="yt -x -f bestaudio/best"
alias ffmpeg="ffmpeg -hide_banner"

# Colorize commands when possible.
alias grep="grep --color=auto"
alias diff="diff --color=auto"
alias ccat="highlight --out-format=ansi"

# These common commands are just too long! Abbreviate them.
alias ka="killall"
alias ytv="youtube-viewer"
alias sdn="sudo shutdown -h now"
alias f="$FILE"
alias e="$EDITOR"
alias v="$EDITOR"

# Filesystem aliases
alias ..='cd ..'
alias ...='cd ../..'
alias ....="cd ../../.."
alias .....="cd ../../../.."

# Changing "ls" to "exa"
alias ls='exa --color=always --group-directories-first' # my preferred listing
alias la='exa -a --color=always --group-directories-first'  # all files and dirs
alias ll='exa -la --color=always --group-directories-first'  # long format
alias l='exa -l --color=always --group-directories-first'  # long format
alias lt='exa -aT --color=always --group-directories-first' # tree listing

#alias l="ls -lah ${colorflag}"
#alias la="ls -AF ${colorflag}"
#alias ll="ls -lFh ${colorflag}"
#alias rmf="rm -rf"

# Git aliases
alias g="git"
alias gst='git status'
alias gl='git ln'
alias gr='git remotes'
alias gf='git fetch'

# Config aliases
alias cfi='vim ~/.config/i3/config'
alias cft='vim ~/.tmux.conf'
alias cfv='vim ~/.config/nvim/init.vim'
alias cfg='vim ~/.gitconfig'
alias cfz="vim $ZSH_CONFIG"

# Helpers
alias grep='grep --color=auto'
alias df='df -h' # disk free, in Gigabytes, not bytes
alias du='du -h -c' # calculate disk usage for a folder

###################
### END Aliases ###
###################

#################
### Functions ###
#################

opendir() {
  tempfile="$(mktemp)"
  lf -last-dir-path "$tempfile"
  test -f "$tempfile" &&
      if [ "$(cat -- "$tempfile")" != "$(echo -n `pwd`)" ]; then
          cd -- "$(cat "$tempfile")"
      fi
  rm -f -- "$tempfile"
}
bindkey -s '^O' 'opendir\n'

# Create a new directory and enter it
function md() {
    mkdir -p "$@" && cd "$@"
}

# Extract archives - use: extract <file>
# Credits to http://dotfiles.org/~pseup/.bashrc
function extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2) tar xjf $1 ;;
            *.tar.gz) tar xzf $1 ;;
            *.bz2) bunzip2 $1 ;;
            *.rar) rar x $1 ;;
            *.gz) gunzip $1 ;;
            *.tar) tar xf $1 ;;
            *.tbz2) tar xjf $1 ;;
            *.tgz) tar xzf $1 ;;
            *.zip) unzip $1 ;;
            *.Z) uncompress $1 ;;
            *.7z) 7z x $1 ;;
            *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

#####################
### END Functions ###
#####################


################
### Vim mode ###
################

# Updates editor information when the keymap changes.
function zle-keymap-select() {
  zle reset-prompt
  zle -R
}

# Ensure that the prompt is redrawn when the terminal size changes.
TRAPWINCH() {
  zle &&  zle -R
}

zle -N zle-keymap-select
zle -N edit-command-line


bindkey -v

# By default, there is a 0.4 second delay after you hit the <ESC> key and when
# the mode change is registered. This results in a very jarring and frustrating
# transition between modes. Let's reduce this delay to 0.1 seconds.
export KEYTIMEOUT=1

# allow v to edit the command line (standard behaviour)
#autoload -Uz edit-command-line
#bindkey -M vicmd 'v' edit-command-line

# allow ctrl-p, ctrl-n for navigate history (standard behaviour)
bindkey '^P' up-history
bindkey '^N' down-history

# allow ctrl-h, ctrl-w, ctrl-? for char and word deletion (standard behaviour)
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# allow ctrl-r to perform backward search in history
bindkey '^r' history-incremental-search-backward

# allow ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[2 q'

  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[6 q'
  fi
}
zle -N zle-keymap-select

zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[6 q"
}
zle -N zle-line-init

# Use beam shape cursor on startup.
echo -ne '\e[6 q'
# Use beam shape cursor for each new prompt.
preexec() { echo -ne '\e[6 q' ;}

####################
### END Vim mode ###
####################

##############
### Prompt ###
##############

# Reference for colors: http://stackoverflow.com/questions/689765/how-can-i-change-the-color-of-my-prompt-in-zsh-different-from-normal-text

autoload -U colors && colors

setopt PROMPT_SUBST

set_prompt() {

    # [
    PS1="%{$fg[white]%}[%{$reset_color%}"

    # Path: http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
    PS1+="%{$fg_bold[cyan]%}${PWD/#$HOME/~}%{$reset_color%}"


    # Git
    if git rev-parse --is-inside-work-tree 2> /dev/null | grep -q 'true' ; then
        PS1+=', '
        PS1+="%{$fg[green]%}$(git rev-parse --abbrev-ref HEAD 2> /dev/null)%{$reset_color%}"
    fi


    # Timer: http://stackoverflow.com/questions/2704635/is-there-a-way-to-find-the-running-time-of-the-last-executed-command-in-the-shel
    if [[ $_elapsed[-10] -ne 0 ]]; then
        PS1+=', '
        PS1+="%{$fg[magenta]%}$_elapsed[-1]s%{$reset_color%}"
    fi

    # PID
#    if [[ $! -ne 0 ]]; then
#        PS1+=', '
#        PS1+="%{$fg[yellow]%}PID:$!%{$reset_color%}"
#    fi

    # Sudo: https://superuser.com/questions/195781/sudo-is-there-a-command-to-check-if-i-have-sudo-and-or-how-much-time-is-left
#    CAN_I_RUN_SUDO=$(sudo -n uptime 2>&1|grep "load"|wc -l)
#    if [ ${CAN_I_RUN_SUDO} -gt 0 ]
#    then
#        PS1+=', '
#        PS1+="%{$fg_bold[red]%}SUDO%{$reset_color%}"
#    fi

    PS1+="%{$fg[white]%}]: %{$reset_color%}% "
}

set_prompt # Initially execute the prompt command
precmd_functions+=( set_prompt ) # automatically execute prompt command

preexec () {
   (( ${#_elapsed[@]} > 1000 )) && _elapsed=(${_elapsed[@]: -1000})
   _start=$SECONDS
}

precmd () {
   (( _start >= 0 )) && _elapsed+=($(( SECONDS-_start )))
   _start=-1
}

###################
### END Prompt ###
###################


##################
### ZSH Config ###
##################

setopt NO_BG_NICE
setopt NO_HUP
setopt NO_LIST_BEEP
setopt LOCAL_OPTIONS
setopt LOCAL_TRAPS
setopt PROMPT_SUBST

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# history
setopt HIST_VERIFY
setopt EXTENDED_HISTORY
setopt HIST_REDUCE_BLANKS
unsetopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS

setopt COMPLETE_ALIASES

# display how long all tasks over 10 seconds take
export REPORTTIME=10

#######################
### END ZSH Config  ###
#######################

########################
### Fzf Key Bindings ###
########################

fzf_killps() {
  zle -I
  ps -ef | sed 1d | fzf -m | awk '{print $2}' | xargs kill -${1:-9}
}
zle -N fzf_killps
bindkey '^Q' fzf_killps

# fshow - git commit browser
fzf_git_log() {
  zle -I
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}
zle -N fzf_git_log
bindkey '^[gl' fzf_git_log

fzf_git_add() {
  zle -I
  GIT_ROOT=$(git rev-parse --show-toplevel)
  FILES_TO_ADD=$(git status --porcelain | grep -v '^[AMD]' | sed s/^...// | fzf -m)

  if [[ ! -z $FILES_TO_ADD ]]; then
    for FILE in $FILES_TO_ADD; do
      git add $@ "$GIT_ROOT/$FILE"
      done
  else
    echo "Nothing to add"
  fi
}
zle -N fzf_git_add
bindkey '^[ga' fzf_git_add

# CTRL-T - Paste the selected file path(s) into the command line
__fsel() {
  local cmd="${FZF_CTRL_T_COMMAND:-"command find -L . \\( -path '*/\\.*' -o -fstype 'dev' -o -fstype 'proc' \\) -prune \
    -o -type f -print \
    -o -type d -print \
    -o -type l -print 2> /dev/null | sed 1d | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  eval "$cmd | $(__fzfcmd) -m $FZF_CTRL_T_OPTS" | while read item; do
    echo -n "${(q)item} "
  done
  local ret=$?
  echo
  return $ret
}

__fzfcmd() {
  [ ${FZF_TMUX:-1} -eq 1 ] && echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

fzf-file-widget() {
  LBUFFER="${LBUFFER}$(__fsel)"
  local ret=$?
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N   fzf-file-widget
bindkey '^T' fzf-file-widget

# ALT-C - cd into the selected directory
fzf-cd-widget() {
  local cmd="${FZF_ALT_C_COMMAND:-"command find -L . \\( -path '*/\\.*' -o -fstype 'dev' -o -fstype 'proc' \\) -prune \
    -o -type d -print 2> /dev/null | sed 1d | cut -b3-"}"
  setopt localoptions pipefail 2> /dev/null
  cd "${$(eval "$cmd | $(__fzfcmd) +m $FZF_ALT_C_OPTS"):-.}"
  local ret=$?
  zle reset-prompt
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N    fzf-cd-widget
bindkey '\ec' fzf-cd-widget

# CTRL-R - Paste the selected command from history into the command line
fzf-history-widget() {
  local selected num
  setopt localoptions noglobsubst pipefail 2> /dev/null
  selected=( $(fc -l 1 | eval "$(__fzfcmd) +s --tac +m -n2..,.. --tiebreak=index --toggle-sort=ctrl-r $FZF_CTRL_R_OPTS -q ${(q)LBUFFER}") )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
  return $ret
}
zle     -N   fzf-history-widget
bindkey '^R' fzf-history-widget

############################
### END Fzf Key Bindings ###
############################


bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

bindkey "^[b" backward-word
bindkey "^[f" forward-word

if [[ -a ~/.localrc ]]; then
    source ~/.localrc
fi

autoload -U zmv

# initialize autocomplete
autoload -U compinit
compinit

[ -z "$TMUX" ] && export TERM=xterm-256color

[[ -e ~/.terminfo ]] && export TERMINFO_DIRS=~/.terminfo:/usr/share/terminfo

# ZSH syntax highlighting
# Source: https://github.com/zsh-users/zsh-syntax-highlighting
if [ -e /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then # test for linux standard location
    source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -e /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then # test for mac osx standard location
    source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

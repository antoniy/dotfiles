# -------- General {{{
# --------------------

ZSH_CONFIG="$ZDOTDIR/.zshrc"

if [ -e $ZDOTDIR/.zshrc_local ]; then
    source $ZDOTDIR/.zshrc_local
fi

# Use neovim for vim if present.
[[ $commands[nvim] ]] && alias vim="nvim" vimdiff="nvim -d"

export EDITOR='nvim'

[ -z "$TMUX" ] && export TERM=xterm-256color

[[ -e ~/.terminfo ]] && export TERMINFO_DIRS=~/.terminfo:/usr/share/terminfo

# }}}
# -------- Aliases {{{
# --------------------

alias reload!="source $ZSH_CONFIG"

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

# Changing "ls" to "exa" if "exa" is installed
if [[ $commands[exa] ]]; then
  alias ls='exa --color=always --group-directories-first' # my preferred listing
  alias la='exa -a --color=always --group-directories-first'  # all files and dirs
  alias ll='exa -la --color=always --group-directories-first'  # long format
  alias l='exa -l --color=always --group-directories-first'  # long format
  alias lt='exa -aT --color=always --group-directories-first' # tree listing
else
  alias ls="ls --color=always --group-directories-first"
  alias la="ls -A --color=always --group-directories-first"
  alias ll="ls -lAFh --color=always --group-directories-first"
  alias l="ls -lFh --color=always --group-directories-first"
  alias lt="tree -aC --dirsfirst"
fi

alias rmf="rm -rf"

# Git aliases
alias g="git"
alias gst='git status'
alias gl='git ln'
alias gr='git remotes'
alias gf='git fetch'

# Helpers
alias grep='grep --color=auto'
alias df='df -h' # disk free, in Gigabytes, not bytes
alias du='du -h -c' # calculate disk usage for a folder

# }}}
# -------- Functions {{{
# ----------------------

# Ensure precmds are run after cd
redraw-prompt() {
  local precmd
  for precmd in $precmd_functions; do
    $precmd
  done
  zle reset-prompt
}
zle -N redraw-prompt

opendir() {
  tempfile=`mktemp`
  lf -last-dir-path $tempfile
  if [[ -f $tempfile && $(cat -- "$tempfile") != "$(echo -n `pwd`)" ]]; then
    cd -- "$(cat "$tempfile")"
  fi
  rm -f -- "$tempfile" > /dev/null
  zle redraw-prompt
}
zle -N opendir
bindkey '^O' opendir

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

# }}}
# -------- Vim Mode {{{
# ---------------------

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

# alt+{a,e} - go to beginnig/end of the line
bindkey "^[a" beginning-of-line
bindkey "^[e" end-of-line

# alt+{b,f} - go to prev/next word
bindkey "^[b" backward-word
bindkey "^[f" forward-word

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

# }}}
# -------- Prompt {{{
# -------------------

# Reference for colors: http://stackoverflow.com/questions/689765/how-can-i-change-the-color-of-my-prompt-in-zsh-different-from-normal-text

autoload -U colors && colors

setopt PROMPT_SUBST

set_prompt() {

    # [
    PS1="%{$fg[white]%}[%{$reset_color%}"

    # Path: http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
    PS1+="%{$fg_bold[cyan]%}${PWD/#$HOME/~}%{$reset_color%}"

    # Git
    # Note: don't show git info when we're are in $HOME. 
    # The git repo there is our dotfiles so let's not make a prompt mess in our $HOME.
    if [[ "$HOME/.git" != `git rev-parse --absolute-git-dir 2> /dev/null` ]]; then
        PS1+=', '
        PS1+="%{$fg[green]%} $(git rev-parse --abbrev-ref HEAD 2> /dev/null)%{$reset_color%}"
    fi

    # ]:
    PS1+="%{$fg[white]%}]: %{$reset_color%}% "
}

# add prompt generator function to precmd hooks
autoload -Uz add-zsh-hook
add-zsh-hook precmd set_prompt

# }}}
# -------- ZSH Config {{{
# -----------------------

setopt no_bg_nice
setopt no_hup
setopt no_list_beep
setopt local_options
setopt local_traps
setopt prompt_subst

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

# history
setopt hist_verify
setopt extended_history
setopt hist_reduce_blanks
unsetopt share_history
setopt hist_ignore_all_dups

setopt complete_aliases

# Changing directories
setopt auto_cd
setopt auto_pushd
unsetopt pushd_ignore_dups
setopt pushdminus

# display how long all tasks over 10 seconds take
export REPORTTIME=10

# }}}
# -------- Fzf Key Bindings {{{
# -----------------------------

[ -e /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh

# }}}
# -------- ZSH Modules {{{
# ------------------------

autoload -U zmv

# initialize autocomplete with menu selection
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit

# Include hidden files in autocomplete:
_comp_options+=(globdots)

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
# bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
# bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# Include hidden files in autocomplete:
_comp_options+=(globdots)

# }}}
# -------- Plugins: zplug {{{
# -----------------------------

[ -f ~/.zplug/init.zsh ] && source ~/.zplug/init.zsh

zplug 'zsh-users/zsh-autosuggestions'
zplug 'zsh-users/zsh-completions'
zplug 'zsh-users/zsh-history-substring-search'
zplug 'zdharma/fast-syntax-highlighting'
zplug 'wfxr/forgit'
# zplug "rupa/z", use:z.sh
# zplug "changyuheng/fz", defer:1
# zplug 'andrewferrier/fzf-z'
# zplug 'leophys/zsh-plugin-fzf-finder'
# zplug 'b4b4r07/enhancd', use:init.sh

zplug load

bindkey '^K' history-substring-search-up
bindkey '^J' history-substring-search-down
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# }}}

# initialize fasd
eval "$(fasd --init auto)"


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

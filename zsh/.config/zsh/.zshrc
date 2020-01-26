# -------- General {{{
# --------------------

ZSH_CONFIG="$ZDOTDIR/.zshrc"

if [[ -e $ZDOTDIR/.zshrc_local ]]; then
    source $ZDOTDIR/.zshrc_local
fi

# Use neovim for vim if present.
(( $+commands[nvim] )) && alias vim="nvim" vimdiff="nvim -d"

export EDITOR='nvim'

[ -z "$TMUX" ] && export TERM=xterm-256color

[[ -e ~/.terminfo ]] && export TERMINFO_DIRS=~/.terminfo:/usr/share/terminfo

export GPG_TTY=$(tty)

# }}}
# -------- ZSH Config {{{
# -----------------------

setopt no_bg_nice
setopt no_hup
unsetopt list_beep
setopt local_options
setopt local_traps
setopt prompt_subst

HISTFILE="${HISTFILE:-${ZDOTDIR:-$HOME}/.zhistory}"  # The path to the history file.
HISTSIZE=50000
SAVEHIST=$HISTSIZE

# history
setopt hist_verify          # Don't exec command expanded from hist - just place it in the buff
setopt extended_history     # Use extended hist format with timestamps
setopt hist_reduce_blanks   # Remove useless blanks from each cmd before write it to hist
unsetopt share_history      # Don't share history between shells
setopt hist_ignore_all_dups # If new command is added to hist, remove any older command that's
                            # a duplicate (even if it's not the last one)

setopt complete_aliases     # Make aliases compleatable

# Changing directories
setopt auto_cd              # If a command cannot be executed as normal cmd - try to cd into
                            # directory instead
setopt auto_pushd           # Make cd push old directory onto the directory stach
unsetopt pushd_ignore_dups  # Don't push the same directory onto the stack
setopt pushd_minus          # The meaning of + and - is swapped in the dir stack context


# Completion
setopt auto_menu            # Automatically use menu completion after second tab
setopt always_to_end        # Move the cursor to end of the completed word
setopt complete_in_word     # Completion is done from both ends of the word the cursor's in
unsetopt flow_control       # Disable flow control (assigned to ^S/^Q) in the shell
unsetopt menu_complete      # On multiple matches, insert the first one immediately then when
                            # the completion is requested again, remove the first match at put
                            # the second match, etc. - iterate on matches

# Display how long all tasks over 10 seconds take.
# Negative value - stops that feature
export REPORTTIME=-1

# Load zmv program module
autoload -U zmv

# load colors function - used for prompt coloring
autoload -U colors && colors

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
autoload -Uz edit-command-line
bindkey -M vicmd 'v' edit-command-line

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

_is_ssh() {
    [[ -n "${SSH_CONNECTION-}${SSH_CLIENT-}${SSH_TTY-}" ]]
}

set_prompt() {

    # [
    # PS1="%{$fg[white]%}%{$reset_color%}"

    local host=''
    _is_ssh && host=" at %F{yellow}%m%{$reset_color%}"

    # Path: http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
    PS1="%{$fg_bold[cyan]%}${PWD/#$HOME/~}%{$reset_color%}"

    # Git
    # Note: don't show git prompt when we're are in $HOME dotfiles repo. 
    # The git repo there is our dotfiles so let's not make a prompt mess in our $HOME.
    if [[ $(git rev-parse --absolute-git-dir 2> /dev/null) ]]; then
        PS1+=" %{$fg[green]%} $(git rev-parse --abbrev-ref HEAD 2> /dev/null)%{$reset_color%}"
    fi

    # ]:
    PS1+="$host%{$fg[magenta]%} ❯ %{$reset_color%}% "
}

# add prompt generator function to precmd hooks
autoload -Uz add-zsh-hook
add-zsh-hook precmd set_prompt

# }}}
# -------- Plugins {{{
# --------------------

# Load fzf
if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all --no-update-rc --no-bash --no-fish
fi

if [ -f ~/.fzf.zsh ]; then
  source ~/.fzf.zsh
else
  echo "File ~/.fzf.zsh is missing. Please reinstall fzf: ~/.fzf/install --all"
fi

# Initialize zinit plugin manager
if [[ ! -f $ZDOTDIR/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p $ZDOTDIR/.zinit
    command git clone https://github.com/zdharma/zinit $ZDOTDIR/.zinit/bin && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%F" || \
        print -P "%F{160}▓▒░ The clone has failed.%F"
fi
source "$HOME/.config/zsh/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
# end initialization

export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions
bindkey '^ ' autosuggest-accept # accept auto suggestion with Ctrl-Space

zinit ice wait lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

# Substring search
# enable fuzzy search: ab c will match *ab*c*
HISTORY_SUBSTRING_SEARCH_FUZZY='true'
zinit ice wait lucid
zinit light zsh-users/zsh-history-substring-search

zinit ice wait'2' lucid
zinit light wfxr/forgit

zinit ice wait lucid atinit"zpcompinit; zpcdreplay"
zinit light zdharma/fast-syntax-highlighting

zinit ice wait"2" lucid as"program" pick"bin/git-dsf"
zinit load zdharma/zsh-diff-so-fancy

FZF_MARKS_COMMAND="fzf --height 40% --reverse --preview-window right:50%:hidden"
FZF_MARKS_JUMP='^O'
zinit ice wait lucid
zinit load urbainvaes/fzf-marks

zinit ice wait'1' lucid trackbinds bindmap'\e\e -> ^F'
zinit light laggardkernel/zsh-thefuck

# Up/Down - trigger substring search in insert/command mode
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M vicmd '^[[A' history-substring-search-up
bindkey -M vicmd '^[[B' history-substring-search-down

# Alt+j/k - trigger substring search in insert/command mode
bindkey '^[k' history-substring-search-up
bindkey '^[j' history-substring-search-down
bindkey -M vicmd '^[k' history-substring-search-up
bindkey -M vicmd '^[j' history-substring-search-down

# }}}
# -------- Completions {{{
# ------------------------

# If there are no completions, try to correct minor typos in the input.
zstyle ':completion:*' completer _complete _correct

# Load the nice LS_COLORS into the completion menu too. Pretty!
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# initialize autocomplete with menu selection
zstyle ':completion:*' menu select
zstyle ':completion:*' list-prompt ' '
zstyle ':completion:*' select-prompt ' %F{blue}-- %m --%f'
  
# Permit expensive completions to cache info and therefore be usable.
if [[ "$(uname)" == "Darwin" ]]; then
  zstyle ':completion::complete:*' use-cache on
  zstyle ':completion::complete:*' cache-path ~/Library/Caches/zsh/compcache
elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
  zstyle ':completion::complete:*' use-cache on
  zstyle ':completion::complete:*' cache-path $XDG_CACHE_HOME/zsh/compcache
fi

# When listing directories, treat foo//bar as foo/bar, not foo/*/bar.
zstyle ':completion:*' squeeze-slashes true

# When completing the names of man pages, group them by section.
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true

# Group completions under cute headings.
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' group-name ''

# 0 -- vanilla completion (abc => abc)
# 1 -- smart case completion (abc => Abc)
# 2 -- word flex completion (abc => A-big-Car)
# 3 -- full flex completion (abc => ABraCadabra)
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'

zmodload zsh/complist

# Include hidden files in autocomplete:
_comp_options+=(globdots)

# Use vim keys in tab complete menu:
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -v '^?' backward-delete-char

# }}}
# -------- FZF {{{
# ----------------

if (( $+commands[fzf] )); then
  FZF_FILE_HIGHLIGHTER='cat'
  (( $+commands[highlight] )) && FZF_FILE_HIGHLIGHTER='highlight -lO ansi'
  (( $+commands[bat]       )) && FZF_FILE_HIGHLIGHTER='bat --color=always'
  export FZF_FILE_HIGHLIGHTER

  FZF_DIR_HIGHLIGHTER='ls -l --color=always 2> /dev/null || ls -lG 2> /dev/null'
  (( $+commands[tree] )) && FZF_DIR_HIGHLIGHTER='tree -CtrL 2'
  (( $+commands[exa]  )) && FZF_DIR_HIGHLIGHTER='exa --color=always -TL2'
  export FZF_DIR_HIGHLIGHTER

  FZF_DEFAULT_COMMAND='(git ls-tree -r --name-only HEAD ||
           find . -type f -print -o -type l -print | sed s/^..//) 2> /dev/null'
  (( $+commands[ag] )) && FZF_DEFAULT_COMMAND='ag --ignore .git -g "" 2>/dev/null'
  (( $+commands[fd] )) && FZF_DEFAULT_COMMAND='fd --type f --follow --exclude .git 2>/dev/null'
  export FZF_DEFAULT_COMMAND
  export FZF_DEFAULT_OPTS=" 
  --height 80%
  --extended
  --ansi
  --reverse
  --cycle
  --bind alt-p:preview-up,alt-n:preview-down
  --bind ctrl-u:half-page-up
  --bind ctrl-d:half-page-down
  --bind alt-u:preview-page-up
  --bind alt-d:preview-page-down
  --bind alt-a:select-all,ctrl-r:toggle-all
  --bind ctrl-s:toggle-sort
  --bind ?:toggle-preview,alt-w:toggle-preview-wrap
  --bind 'alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
  --preview \"($FZF_FILE_HIGHLIGHTER {} || $FZF_DIR_HIGHLIGHTER {}) 2>/dev/null | head -200\"
  --preview-window right:50%
  "

  # FZF: Ctrl - T
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_CTRL_T_OPTS="
  --preview \"($FZF_FILE_HIGHLIGHTER {} || $FZF_DIR_HIGHLIGHTER {}) 2>/dev/null | head -200\"
  --bind 'enter:execute(echo {})+abort'
  --bind 'alt-e:execute($EDITOR {} >/dev/tty </dev/tty)'
  --preview-window right:50%
  "

  # FZF: Ctrl - R
  SHELL_HIGHLIGHTER="bat --color=always -l bash"
  export FZF_CTRL_R_OPTS="
  --preview 'echo {} | tr -s \" \" | cut -d\" \" -f3- | $SHELL_HIGHLIGHTER'
  --preview-window 'down:2:wrap'
  --exact
  --expect=ctrl-x
  "

  # FZF: Alt - C
  FZF_ALT_C_COMMAND="command find -L . -mindepth 1 -name '.git' -prune \
      -o -type d -print 2> /dev/null | cut -b3-"
  (( $+commands[fd] )) && FZF_ALT_C_COMMAND='command fd --type d --follow --exclude .git 2>/dev/null'
  export FZF_ALT_C_COMMAND

  export FZF_ALT_C_OPTS="
  --exit-0
  --bind 'enter:execute(echo {})+abort'
  --preview '($FZF_DIR_HIGHLIGHTER {}) | head -200 2>/dev/null'
  --preview-window=right:50%
  "

fi

# }}}
# -------- Functions {{{
# ----------------------

# Trim functions
function ltrim() { sed 's/^\s\+//g' }
function rtrim() { sed 's/\s\+$//g' }
function trim()  { ltrim | rtrim    }

# pet utilities:
# * Alt-S - select snippet
# * pet-add-prev alias to add previous cmd as new snippet
function pet-select() {
  BUFFER=$(pet search --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle redisplay
}
zle -N pet-select
stty -ixon
bindkey '^[s' pet-select

function pet-add-prev() {
  PREV=$(fc -lrn | head -n 1)
  sh -c "pet new `printf %q "$PREV"`"
}

# }}}
# -------- Color Definitions {{{
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White
# }}}
# -------- Aliases Expansion Functions {{{
# -----------------------------------------

# array with expandable aliases
typeset -a ealiases
ealiases=()

ealias() {
  alias $@
  args="$@"
  args=${args%%\=*}
  ealiases+=(${args##* })
}

function containsElement () {
  local e match="$1"
  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# functionality
expand-alias() {
  local queryItem=$(echo $LBUFFER | rev | cut -d' ' -f1 | rev)
  containsElement $queryItem ${ealiases[@]} && zle _expand_alias
  zle self-insert
}
zle -N expand-alias

bindkey " " expand-alias

# }}}
# -------- Aliases: General {{{
# ---------------------------

alias reload!="source $ZSH_CONFIG"

# Verbosity and settings that you pretty much just always are going to want.
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -v"
alias mkdir="mkdir -pv"

# Create a new directory and enter it
function md() {
    mkdir -pv "$@" && cd "$@"
}

# Helpers
alias grep='grep --color=auto'
alias df='df -h' # disk free, in Gigabytes, not bytes
alias du='du -h -c' # calculate disk usage for a folder
alias rmf="rm -rf"

ealias ka="killall"
ealias sdn="sudo shutdown -h now"
ealias sdr="sudo shutdown -r now"

# editor aliases
alias f="$FILE"
alias e="$EDITOR"
alias v="$EDITOR"
alias vi="$EDITOR"
alias vv="fzf | xargs -I% $EDITOR %"
alias vg="git ls-tree -r --name-only HEAD | fzf | xargs -I% $EDITOR %"

# Filesystem aliases
ealias ..='cd ..'
ealias ...='cd ../..'
ealias ....="cd ../../.."
ealias .....="cd ../../../.."
alias cd.='\cd ..'
alias cd..='\cd ..'

# Changing "ls" to "exa" if "exa" is installed
if (( $+commands[exa] )); then
  alias ls='exa --color=always --group-directories-first' # my preferred listing
  alias la='exa -a --color=always --group-directories-first'  # all files and dirs
  alias ll='exa -la --color=always --group-directories-first'  # long format
  alias l='exa -l --color=always --group-directories-first'  # long format
  alias lt='exa -aT --color=always --group-directories-first' # tree listing
elif [[ "$OSTYPE" == "darwin"* ]]; then # for MacOSX and bsd version of ls
  alias ls="ls -G"
  alias la="ls -AG"
  alias ll="ls -lAFhG"
  alias l="ls -lFhG"
  alias lt="tree -aC --dirsfirst"
else
  alias ls="ls --color=always --group-directories-first"
  alias la="ls -A --color=always --group-directories-first"
  alias ll="ls -lAFh --color=always --group-directories-first"
  alias l="ls -lFh --color=always --group-directories-first"
  alias lt="tree -aC --dirsfirst"
fi

alias weather='curl http://wttr.in/Plovdiv'

wd() {
  case $1 in
    full)
      curl "http://wttr.in/Пловдив?m&lang=bg"
      ;;
    day)
      curl "http://wttr.in/Пловдив?m&lang=bg&format=v2"
      ;;
    moon)
      curl "http://wttr.in/Moon?m&lang=bg"
      ;;
    '')
      curl "http://wttr.in/Пловдив?m&lang=bg&format=%l:+%c+%C+%t,+%h,+%w,+%P"
      ;;
    *)
      curl "http://wttr.in/$1?m&lang=bg&format=v2"
  esac
}

alias external-ip="dig +short myip.opendns.com @resolver1.opendns.com"

# }}}
# -------- Aliases: Colors {{{
# ----------------------------

# Colorize commands when possible.
alias grep="grep --color=auto"
alias diff="diff --color=auto"

# Set grc alias for available commands.
if (( $+commands[grc] )); then
  [[ -f /etc/grc.conf ]]           && grc_conf='/etc/grc.conf'
  [[ -f /usr/local/etc/grc.conf ]] && grc_conf='/usr/local/etc/grc.conf'
  if [ ! -z "$grc_conf" ]; then
      for cmd in $(grep '^# ' "$grc_conf" | cut -f 2 -d ' '); do
          if (( $+commands[$cmd] )) &&  [ "$cmd" != "ls" ]; then
              alias $cmd="grc --colour=auto $cmd"
          fi
      done
  fi
  unset grc_conf cmd
fi

(( $+commands[bat] )) && alias cat="bat --plain --wrap character"

# }}}
# -------- Aliases: Suffix/Extension {{{
# --------------------------------------

# starts one or multiple args as programs in background
background() {
  for ((i=2; i<=$#; i++)); do
    ${@[1]} ${@[$i]} &> /dev/null &
  done
}

# Aliases for file extensions.
# Automatically open certain extensions with specified program.
alias -s {md,txt,TXT,java,xml,json,js,go,kt,conf,cfg}=$EDITOR
(( $+commands[mupdf]       )) && alias -s {pdf,PDF}=mupdf
(( $+commands[zathura]     )) && alias -s {pdf,PDF}=zathura

(( $+commands[sxiv]        )) && alias -s {jpg,JPG,png,PNG,jpeg,JPEG}='background sxiv'
(( $+commands[sxiv]        )) && alias -s {gif,GIF}='background sxiv -a'

(( $+commands[vlc]         )) && alias -s {avi,AVI,mp4,MP4,mkv,MKV,mpeg,MPEG,mov,MOV}='background mpv'
(( $+commands[mpv]         )) && alias -s {avi,AVI,mp4,MP4,mkv,MKV,mpeg,MPEG,mov,MOV}='background mpv'

(( $+commands[chromium]    )) && alias -s {html,HTML}='background chromium'
(( $+commands[firefox]     )) && alias -s {html,HTML}='background firefox'

(( $+commands[unzip]       )) && alias -s {zip,ZIP,war,WAR}='unzip -l'
(( $+commands[java]        )) && alias -s {jar,JAR}='java -jar'
(( $+commands[tar]         )) && alias -s {bz2,gz,tgz,TGZ}='tar -tf'
(( $+commands[libreoffice] )) && alias -s {ods,ODS,odt,ODT,odp,ODP,doc,DOC,docx,DOCX,xls,XLS,xlsx,XLSX,xlsm,XLSM,ppt,PPT,pptx,PPTX,csv,CSV}='background libreoffice'

# }}}
# -------- Aliases: Global  {{{
# -----------------------------
# Global alias are those aliases that can be used in more than one command. You can use it more
# than once in a single command or use it anywhere within the command as it fits, except at the
# very beginning.
# 
# You can create global aliases of frequently used commands like those after the |(pipe) symbol,
# or you can assign your IP address or some text that might come often when you are working.

# You can name your global alias however you want but I prefer writing in capital as it
# distinguishes them from normal aliases. Also, it will come handy when we talk about the global
# alias expansion later on.

ealias -g G='| grep'
ealias -g L='| less'
alias -g grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
ealias -g A1="| awk '{print \$1}'"
ealias -g A2="| awk '{print \$2}'"
ealias -g A3="| awk '{print \$3}'"
ealias -g H='| head'
ealias -g H2='| head -n 20'
ealias -g X='| xargs -I%'
ealias -g ...="../.."
ealias -g ....="../../.."
ealias -g .....="../../../.."

# }}}
# -------- Aliases: Git {{{
# -------------------------

if (( $+commands[git] )); then
  (( $+commands[hub] )) && alias git='hub'

  git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
  }

  # Git aliases
  ealias g="git"
  ealias gst='git status'
  ealias gs='git status'
  ealias gl='git ln'
  ealias gr='git remotes'
  ealias gc='git commit'
  ealias gca='git commit -a'
  ealias gcm='git commit -m'
  ealias gcam='git commit -am'
  ealias gdic='git diff --cached'
  ealias gdi='git diff'

  if (( $+commands[fzf] )); then
    gm() {
      local query="${@:-}"
      local preview_highlighter=""
      (( $+commands[diff-so-fancy] )) && preview_highlighter=" | diff-so-fancy | less -RX"
      (( $+commands[delta] )) && preview_highlighter=" | delta --dark --minus-color='#4d0100' --plus-color='#014000' --tabs 2"
      local preview_cmd="echo {} | sed 's/^\s\+//g' | xargs -I% git diff $(git_branch)..% $preview_highlighter"
      git branch -a | grep -v "^*" | fzf -1 -q "$query" --preview="$preview_cmd | head -300" --preview-window=right:70% --bind "alt-e:execute($preview_cmd >/dev/tty </dev/tty)" | cli-prompt "Merge ${BIRed}{}${Color_Off} into ${BIGreen}$(git_branch)${Color_Off}?" | xargs -I% git merge % $(git_branch)
    }

    gf() {
      local query="${@:-}"
      git remote | fzf -1 -q "$query" -m --preview='git ls-remote --get-url {}' --preview-window=down:2:wrap | xargs -I% git fetch %
    }

    gp() {
      local query="${@:-}"
      git remote | fzf -1 -q "$query" -m --preview='git ls-remote --get-url {}' --preview-window=down:2:wrap | xargs -I% git push % $(git_branch)
    }
  fi
fi

# }}}
# -------- Aliases: Tools {{{
# ---------------------------

# Tmux attach
(( $+commands[tmux] )) && \
  tm() {
    [[ $TMUX ]] && return 1 # already in tmux session
    # if session name param is specified - try to attach to it, 
    # otherwise create session with that name
    [[ -n $1 ]] && (tmux attach-session -t $1 || tmux new-session -s $1) && return 0
    # if no name is specified - attach to any session
    # if none exist - create session with name default
    tmux attach-session || tmux new-session -s default
  }

# Misc tools
(( $+commands[youtube-viewer] )) && ealias ytv="youtube-viewer"
(( $+commands[youtube-dl]     )) && ealias yt="youtube-dl --add-metadata -i"
(( $+commands[youtube-dl]     )) && ealias yta="yt -x -f bestaudio/best"
(( $+commands[ffmpeg]         )) && alias ffmpeg="ffmpeg -hide_banner"

# Find all custom-defined scripts, present fuzzy finder and open the chosen one in default editor
[[ $+commands[fd] && $+commands[fzf] && -d $HOME/.local/bin ]] && 
  se() { fd -t f . ~/.local/bin | fzf | xargs $EDITOR ;}

# Pacman/Yay aliases
if (( $+commands[yay] )); then
  ealias yau="yay -Syua"
  ealias yar="yay -Rns"
fi

# Systemctl
if (( $+commands[systemctl] )); then
  ealias sc='sudo systemctl'
  ealias scu='systemctl --user'
fi

# Journalctl
(( $+commands[journalctl] )) && ealias -g jou='sudo journalctl -b -n 200 -f'

# Maven aliases
if (( $+commands[mvn] )); then
  ealias mdeps="mvn dependency:tree"
  ealias mcp="mvn clean package"
fi

if (( $+commands[wg] && $+commands[wg-quick] )); then
  ealias vpnup="sudo wg-quick up wg0"
  ealias vpndown="sudo wg-quick down wg0"
  ealias vpns="sudo wg"
fi

(( $+commands[reflector] )) && 
  alias reflect='sudo reflector --latest 200 --threads 8 --verbose --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist'

# }}}
# -------- Pacman Trap {{{
# ------------------------
# from https://wiki.archlinux.org/index.php/Zsh#On-demand_rehash
# This will solve the problem of zsh automatically rehashes after package installation
# and this way the new binary will be visible in PATH automatically.
# A pacman hook is needed as well: /etc/pacman.d/hooks/zsh.hook
# [Trigger]
# Operation = Install
# Operation = Upgrade
# Operation = Remove
# Type = Package
# Target = usr/bin/*
# 
# [Action]
# Depends = zsh
# Depends = procps-ng
# When = PostTransaction
# Exec = /usr/bin/pkill zsh --signal=USR1
catch_signal_usr1() {
  trap catch_signal_usr1 USR1
  rehash
}
trap catch_signal_usr1 USR1
# }}}

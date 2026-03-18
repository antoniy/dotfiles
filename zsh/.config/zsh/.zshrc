# vim: foldmethod=marker
#  _________  _   _    __              _     _________    _    ____
# |__  / ___|| | | |  / _| ___  _ __  | |   |__  / ___|  / \  / ___|
#   / /\___ \| |_| | | |_ / _ \| '__| | |     / /|___ \ / _ \| |
#  / /_ ___) |  _  | |  _| (_) | |    | |___ / /_ ___) / ___ \ |___
# /____|____/|_| |_| |_|  \___/|_|    |_____/____|____/_/   \_\____|
# 
# -------- General {{{1

ZSH_CONFIG="$ZDOTDIR/.zshrc"

export LC_ALL=en_US.UTF-8

# Use neovim for vim if present.
(( $+commands[nvim] )) && alias vim="nvim" vimdiff="nvim -d"

export EDITOR='nvim'

[ -z "$TMUX" ] && export TERM=xterm-256color

[[ -e ~/.terminfo ]] && export TERMINFO_DIRS=~/.terminfo:/usr/share/terminfo

export GPG_TTY=$(tty)

if [[ "$OSTYPE" == "darwin"* ]]; then # for MacOSX
  export PINENTRY_USER_DATA="USE_CURSES=1"
fi

# Hide Docker legacy commands
export DOCKER_HIDE_LEGACY_COMMANDS=true


[ -e "/opt/homebrew/bin/brew" ] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Start ssh-agent if not running (macOS manages the agent via Keychain automatically)
if [[ "$OSTYPE" != "darwin"* ]]; then
  if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    ssh-agent -t 1h > "$XDG_RUNTIME_DIR/ssh-agent.env"
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
    ssh-add
  fi
  if [[ ! "$SSH_AUTH_SOCK" ]]; then
    source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
  fi
fi

# -------- ZSH Config {{{1

setopt no_bg_nice
setopt no_hup
unsetopt list_beep
setopt local_options
setopt local_traps
setopt prompt_subst

HISTFILE="${ZDOTDIR:-$HOME}/.zhistory"  # The path to the history file.
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

# Display how long tasks take. Disabled (negative value) — set to a positive number of seconds to enable.
export REPORTTIME=-1

# Load zmv program module
autoload -U zmv

# load colors function - used for prompt coloring
autoload -U colors && colors

# -------- Vim Mode {{{1

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
# -------- Plugins {{{1
# -------- Initialize plugin manager {{{2
if [[ ! -f $ZDOTDIR/.zinit/bin/zinit.zsh ]]; then
  print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma-continuum/zinit)…%f"
  command mkdir -p $ZDOTDIR/.zinit
  command git clone https://github.com/zdharma-continuum/zinit.git $ZDOTDIR/.zinit/bin && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%F" || \
    print -P "%F{160}▓▒░ The clone has failed.%F"
fi
source "$HOME/.config/zsh/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# -------- Plugin: fzf {{{2
# General-purpose fuzzy finder. Powers Ctrl-T (file picker) and many custom
# fzf-driven functions throughout this config (git branch picker, etc.).
zinit ice from"gh-r" as"program" atload'eval "$(fzf --zsh)"'
zinit light junegunn/fzf

# -------- Plugin: zsh-autosuggestions {{{2
# Fish-like inline suggestions as you type, drawn from history.
# Accept the suggestion with Ctrl-Space; keep typing to ignore it.
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions
bindkey '^ ' autosuggest-accept # accept auto suggestion with Ctrl-Space

# -------- Plugin: zsh-completions {{{2
# Extra completion definitions for hundreds of tools not covered by zsh itself.
zinit ice wait lucid blockf atpull'zinit creinstall -q .'
zinit light zsh-users/zsh-completions

# -------- Plugin: zsh-history-substring-search {{{2
# Up/Down (and Alt-j/k) search history by the substring already typed.
# Fuzzy mode: "ab c" matches anything containing *ab*c*.
HISTORY_SUBSTRING_SEARCH_FUZZY='true'
zinit ice wait lucid
zinit light zsh-users/zsh-history-substring-search

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

# -------- Plugin: fast-syntax-highlighting {{{2
# Syntax highlighting in the command line as you type — commands, flags,
# paths, strings. Faster than the standard zsh-syntax-highlighting.
zinit ice wait lucid atinit"zpcompinit; zpcdreplay"
zinit light zdharma-continuum/fast-syntax-highlighting

# -------- Plugin: zsh-diff-so-fancy {{{2
# Prettier git diffs in the terminal. Adds the `git dsf` command.
zinit ice wait"1" lucid as"program" pick"bin/git-dsf"
zinit load zdharma-continuum/zsh-diff-so-fancy

# -------- Plugin: zoxide {{{2
# Smart cd replacement that tracks frecency (frequency + recency) of visited
# directories. Use `j <query>` to jump, `ji` for interactive fzf picker.
zinit ice from"gh-r" as"program" atload'eval "$(zoxide init zsh --cmd j)"'
zinit light ajeetdsouza/zoxide

# -------- Plugin: atuin {{{2
# SQLite-backed shell history with rich metadata (exit code, duration, cwd).
# Replaces Ctrl-R with a searchable TUI. Up-arrow keeps history-substring-search.
zinit ice from"gh-r" as"program" atload'eval "$(atuin init zsh --disable-up-arrow)"'
zinit light atuinsh/atuin

# -------- Plugin: direnv {{{2
# Per-directory environment variables. Automatically loads/unloads .envrc
# files when entering/leaving a directory.
zinit ice from"gh-r" as"program" mv"direnv* -> direnv" atload'eval "$(direnv hook zsh)"'
zinit light direnv/direnv

# -------- CLI tools {{{2
# bat: cat replacement with syntax highlighting and git integration.
zinit ice from"gh-r" as"program" pick"*/bat"
zinit light sharkdp/bat

# fd: fast and user-friendly find replacement; used in fzf default command.
zinit ice from"gh-r" as"program" pick"*/fd"
zinit light sharkdp/fd

# eza: modern ls replacement with icons, git status, and tree view.
zinit ice from"gh-r" as"program" pick"eza"
zinit light eza-community/eza

# ripgrep: extremely fast grep replacement; used in the ff alias.
zinit ice from"gh-r" as"program" pick"*/rg"
zinit light BurntSushi/ripgrep

# delta: syntax-highlighting pager for git diffs.
zinit ice from"gh-r" as"program" pick"*/delta"
zinit light dandavison/delta

# -------- Completions {{{1

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

# -------- FZF {{{1

if (( $+commands[fzf] )); then
  FZF_FILE_HIGHLIGHTER='cat'
  (( $+commands[highlight] )) && FZF_FILE_HIGHLIGHTER='highlight -lO ansi'
  (( $+commands[bat]       )) && FZF_FILE_HIGHLIGHTER='bat --color=always'
  export FZF_FILE_HIGHLIGHTER

  FZF_DIR_HIGHLIGHTER='ls -l --color=always 2> /dev/null || ls -lG 2> /dev/null'
  (( $+commands[tree] )) && FZF_DIR_HIGHLIGHTER='tree -CtrL 2'
  (( $+commands[eza]  )) && FZF_DIR_HIGHLIGHTER='eza --color=always -TL2'
  export FZF_DIR_HIGHLIGHTER

  FZF_DEFAULT_COMMAND='(git ls-tree -r --name-only HEAD ||
           find . -type f -print -o -type l -print | sed s/^..//) 2> /dev/null'
  (( $+commands[ag] )) && FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g "" 2>/dev/null'
  (( $+commands[fd] )) && FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git 2>/dev/null'
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

fi

# -------- Aliases {{{1
# -------- Aliases: Expansion Functions {{{

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

if [[ -e $ZDOTDIR/.zshrc_local ]]; then
    source $ZDOTDIR/.zshrc_local
fi

# -------- Aliases: General {{{2

alias reload!="source $ZSH_CONFIG"

# Verbosity and settings that you pretty much just always are going to want.
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -v"
alias mkdir="mkdir -pv"
alias dh='dirs -v'
ealias p="ps aux | grep"

(( $+commands[sudo] )) && ealias s="sudo"

# Create a new directory and enter it
function md() {
    mkdir -pv "$@" && cd "$@"
}

# Helpers
alias df='df -h' # disk free, in Gigabytes, not bytes
alias du='du -h -c' # calculate disk usage for a folder
ealias rmf="rm -rf"
ealias pss="ps aux | grep "

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
ealias ......="cd ../../../../.."
alias cd.='cd ..'
alias cd..='cd ..'

# Changing "ls" to "eza" if installed
if (( $+commands[eza] )); then
  alias ls='eza --color=always --group-directories-first' # my preferred listing
  alias la='eza -a --color=always --group-directories-first'  # all files and dirs
  alias ll='eza -lga --color=always --group-directories-first'  # long format
  alias l='eza -lg --color=always --group-directories-first'  # long format
  alias lt='eza -aT --color=always --group-directories-first' # tree listing
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

# -------- Aliases: Colors {{{2

# Colorize commands when possible.
alias grep="grep --color=auto"
alias diff="diff --color=auto"

(( $+commands[bat] )) && alias cat="bat --plain --wrap character"

# -------- Aliases: Suffix/Extension {{{2

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

(( $+commands[brave]       )) && alias -s {html,HTML}='background brave'
(( $+commands[chromium]    )) && alias -s {html,HTML}='background chromium'
(( $+commands[firefox]     )) && alias -s {html,HTML}='background firefox'

(( $+commands[unzip]       )) && alias -s {zip,ZIP,war,WAR}='unzip -l'
(( $+commands[java]        )) && alias -s {jar,JAR}='java -jar'
(( $+commands[tar]         )) && alias -s {bz2,gz,tgz,TGZ}='tar -tf'
(( $+commands[libreoffice] )) && alias -s {ods,ODS,odt,ODT,odp,ODP,doc,DOC,docx,DOCX,xls,XLS,xlsx,XLSX,xlsm,XLSM,ppt,PPT,pptx,PPTX,csv,CSV}='background libreoffice'

# -------- Aliases: Global  {{{2
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
# alias -g grep='grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn}'
ealias -g A1="| awk '{print \$1}'"
ealias -g A2="| awk '{print \$2}'"
ealias -g A3="| awk '{print \$3}'"
ealias -g H='| head'
ealias -g H2='| head -n 20'
ealias -g X='| xargs -I%'
ealias -g ...="../.."
ealias -g ....="../../.."
ealias -g .....="../../../.."

# -------- Aliases: Git {{{2

if (( $+commands[git] )); then
  # Git aliases
  ealias g="git"
  ealias gst='git status'
  ealias gs='git status'
  ealias gb='git branch'
  ealias gl='git ln'
  ealias gre='git remotes'
  ealias gco='git checkout'
  ealias gcob='git checkout -b'
  ealias gc='git commit'
  ealias gca='git commit -a'
  ealias gcm='git commit -m'
  ealias gcam='git commit -am'
  ealias gdi='git diff'
  ealias gdic='git diff --cached'
  ealias ga='git add'
  ealias gaa='git add -A'
  ealias gau='git add -u'
  ealias gp='git push'
  ealias gpom='git push origin master'
  ealias gpo='git push origin'
  ealias gf='git fetch'
  ealias gfo='git fetch origin'
  ealias gm='git merge'
  ealias gmo='git merge origin/'
  ealias gmom='git merge origin/master'
  ealias gr='git restore'
  ealias grs='git restore --staged'
  ealias gss='git stash'
  ealias gssp='git stash pop'
fi

# -------- Aliases: Tools {{{2

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
(( $+commands[ffmpeg]         )) && alias ffmpeg="ffmpeg -hide_banner"

# Find all custom-defined scripts, present fuzzy finder and open the chosen one in default editor
[[ $+commands[fd] && $+commands[fzf] && -d $HOME/.local/bin ]] && 
  se() { fd -t f . ~/.local/bin | fzf | xargs $EDITOR ;}

# Pacman/Yay/Paru aliases
if (( $+commands[paru] )); then
  alias paru="paru --bottomup"
  # ealias yay="paru"
elif (( $+commands[yay] )); then
  ealias yau="yay -Syua"
  ealias yar="yay -Rns"
fi

# Systemctl
if (( $+commands[systemctl] )); then
  ealias sc='sudo systemctl'
  ealias scu='systemctl --user'
fi

if (( $+commands[docker] )); then
  ealias dk='docker'
  ealias dkp='docker ps'
  ealias dc='docker compose'
  ealias dcu='docker compose up -d'
  ealias dcp='docker compose pull'
  ealias dkprune='docker system prune -a --volumes'

  if (( $+commands[fzf] && $+commands[xargs] )); then
    alias dke="docker ps --format '{{.Names}}' | fzf | xargs -I{} -o docker exec -it {} /bin/bash"
    alias dkl="docker ps --format '{{.Names}}' | fzf | xargs -I{} -o docker logs -f {}"
  fi
fi

# Journalctl
(( $+commands[journalctl] )) && ealias -g jou='sudo journalctl -b -n 200 -f'

# Maven aliases
if (( $+commands[mvn] )); then
  ealias mdeps="mvn dependency:tree"
  ealias mcp="mvn clean package"
  ealias mbe="mvn -Dbuild.env=local-prod"
fi

if (( $+commands[wg] && $+commands[wg-quick] )); then
  ealias wgu="sudo wg-quick up wg0"
  ealias wgd="sudo wg-quick down wg0"
  ealias wgs="sudo wg"
fi

(( $+commands[reflector] )) && 
  alias reflect='sudo reflector --latest 200 --threads 8 --verbose --protocol http --protocol https --sort rate --save /etc/pacman.d/mirrorlist'

# Unflac alias for Various Artists albums - include track performer in the audio file names
(( $+commands[unflac] )) &&
  alias unflacva='unflac -n "{{- printf .Input.TrackNumberFmt .Track.Number}}. {{.Track.Performer}} - {{.Track.Title | Elem}}"'

(( $+commands[speedtest-cli] )) && ealias spt="speedtest-cli --bytes --simple"

(( $+commands[nnn] )) && alias n="nnn -e"

if (( $+commands[beet] )); then
  ealias bei="beet import "
  alias imp="beet -c ~/.config/beets/collection-config.yaml import -s "
fi

if (( $+commands[brew] )); then
  ealias br="brew "
  ealias brs="brew search "
  ealias bri="brew install "
  ealias brci="brew install --cask "
fi

# (( $+commands[mpv] )) && ealias horizont="mpv http://stream.bnr.bg:8011/horizont.aac"
(( $+commands[mpv] )) && ealias horizont="mpv https://lb-hls.evpn.bg/2032/fls/Horizont.stream/playlist.m3u8"

(( $+commands[picocom] )) && ealias hpswitch="sudo picocom -b 9600 -f h --omap delbs /dev/ttyUSB0"

(( $+commands[rg] )) && alias ff="rg --files | rg -S "

if (( $+commands[apt] )); then
  ealias aps="apt search"
  ealias api="sudo apt install"
  ealias apu="sudo apt update"
  ealias apuu="sudo apt upgrade"
  ealias apr="sudo apt purge"
fi

ealias gabi="curl -X POST -s \"https://cms.gabieli.com/app/dir\" | jq -r '.cargos[] | select(.sourceCountryCode == \"DE\") | .cargos[:10] | (map(keys) | add | unique) as \$cols | map(. as \$row | \$cols | map(\$row[.])) as \$rows | \$cols, \$rows[] | @tsv'"

# -------- Pacman Trap {{{1
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
# -------- Prompt {{{1
if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
else
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
    local symbol="❯"
    [[ $EUID == 0 ]] && symbol="#"
    PS1+="$host%{$fg[magenta]%} $symbol %{$reset_color%}% "
  }

  # add prompt generator function to precmd hooks
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd set_prompt
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"


ealias dnsr="sudo killall -9 mDNSResponder && sudo killall -9 mDNSResponderHelper"

[[ -d ~/.config/emacs/bin ]] && export PATH="$PATH:~/.config/emacs/bin"

# Day/night terminal theme toggle.
#
# Single source of truth: ~/.config/theme/current  (contains "light" or "dark").
# `theme [light|dark|toggle]` writes that file and pushes the change to:
#   iTerm2 (current window) · tmux (server-wide) · bat (this shell+children)
#   · claude (settings.json, new sessions) · htop (htoprc, next launch).  nvim
#   follows on focus; starship follows the terminal palette for free.

typeset -g THEME_FILE="$HOME/.config/theme/current"

# ============================================================================
# Theme map — EDIT HERE to change your day/night themes.
#   iterm  : exact name of an imported iTerm2 color preset
#            (Settings → Profiles → Colors → Presets)
#   bat    : a theme name from `bat --list-themes`
#   claude : slug of ~/.claude/themes/<slug>.json (applied as custom:<slug>)
#   htop   : color_scheme number (0 Default · 1 Mono · 2 Black-on-White
#            · 3 Light Terminal · 4 MC · 5 Black Night · 6 Broken Gray)
# tmux colours live in ~/.config/tmux/theme-{light,dark}.conf
# nvim colours live in the "Day/night" block of init.vim (g:theme_* vars)
# ============================================================================
typeset -gA THEME_LIGHT=(
  iterm  github-light
  bat    GitHub
  claude custom:github-light
  htop   3
)
typeset -gA THEME_DARK=(
  iterm  catppuccin-mocha
  bat    'Catppuccin Mocha'
  claude custom:catppuccin-mocha
  htop   0
)

# Current mode, defaulting to dark when the state file is missing/garbage.
theme-current() {
  local m; m=$(cat "$THEME_FILE" 2>/dev/null)
  [[ "$m" == light || "$m" == dark ]] && print -r -- "$m" || print -r -- dark
}

# Export BAT_THEME for this shell and its children (fzf previews, etc.).
# bat config must NOT set --theme or it would override this.
if [[ "$(theme-current)" == light ]]; then export BAT_THEME="$THEME_LIGHT[bat]"
else                                       export BAT_THEME="$THEME_DARK[bat]"; fi

# Emit the iTerm2 colour-preset escape. Inside tmux, wrap it in a DCS
# passthrough sequence (doubling the leading ESC) so it reaches iTerm2;
# requires `set -g allow-passthrough on` in tmux.
_theme_iterm() {
  local seq="\e]1337;SetColors=preset=$1\a"
  if [[ -n "$TMUX" ]]; then printf '\ePtmux;\e%b\e\\' "$seq"
  else                      printf '%b' "$seq"; fi
}

# Rewrite the color_scheme line in htoprc to scheme number $1. htop has no live
# theme reload — it reads htoprc only at launch and rewrites it on exit — so this
# is a no-op for a running htop; the `htop` wrapper below re-syncs at next launch.
_theme_htop_sync() {
  local scheme="$1" rc="${HTOPRC:-$HOME/.config/htop/htoprc}"
  [[ -f "$rc" ]] || return 0
  grep -q "^color_scheme=$scheme\$" "$rc" && return 0   # already in sync
  local tmp="${rc}.tmp.$$"
  if sed "s/^color_scheme=.*/color_scheme=$scheme/" "$rc" >| "$tmp" 2>/dev/null; then
    mv "$tmp" "$rc"
  else
    rm -f "$tmp"
  fi
}

theme() {
  local mode="${1:-toggle}"
  case "$mode" in
    toggle)      [[ "$(theme-current)" == dark ]] && mode=light || mode=dark ;;
    light|dark)  ;;
    *)           print -u2 "usage: theme [light|dark|toggle]"; return 1 ;;
  esac

  # Per-tool theme identifiers for this mode.
  local -A t
  if [[ "$mode" == light ]]; then t=("${(@kv)THEME_LIGHT}"); else t=("${(@kv)THEME_DARK}"); fi

  mkdir -p "${THEME_FILE:h}"
  print -r -- "$mode" > "$THEME_FILE"

  # A long-lived tmux server may predate `allow-passthrough on` in tmux.conf;
  # ensure it's on now so the iTerm2 escape below isn't swallowed by tmux.
  [[ -n "$TMUX" ]] && tmux set -g allow-passthrough on 2>/dev/null

  # iTerm2 palette (current window only). Name must match an imported preset.
  _theme_iterm "$t[iterm]"

  # tmux status bar — theme file is named by mode; repaint immediately.
  if tmux info &>/dev/null; then
    tmux source-file "$HOME/.config/tmux/theme-$mode.conf" 2>/dev/null
    tmux refresh-client -S 2>/dev/null
  fi

  # bat (this shell + children).
  export BAT_THEME="$t[bat]"

  # htop — rewrite htoprc so the next launch comes up in the right colours.
  _theme_htop_sync "$t[htop]"

  # Claude Code — new sessions pick this up; a live session needs /theme.
  local cfg="$HOME/.claude/settings.json"
  if [[ -f "$cfg" ]] && (( $+commands[jq] )); then
    local tmp="${cfg}.tmp.$$"
    if jq --arg th "$t[claude]" '.theme = $th' "$cfg" >| "$tmp" 2>/dev/null; then
      mv "$tmp" "$cfg"
    else
      rm -f "$tmp"
    fi
  fi

  print -r -- "theme → $mode   (nvim: updates on focus · claude: run /theme in a live session · htop: next launch)"
}

# Print the iTerm2 colour-preset name for a mode (default: current mode).
# The iTerm2 hotkey script (~/.dotfiles/iterm/theme-toggle.py) calls this so
# preset names stay defined in exactly one place — the THEME_* maps above.
theme-iterm-preset() {
  local m="${1:-$(theme-current)}"
  [[ "$m" == light ]] && print -r -- "$THEME_LIGHT[iterm]" || print -r -- "$THEME_DARK[iterm]"
}

# Print the htop color_scheme number for a mode (default: current mode).
theme-htop-scheme() {
  local m="${1:-$(theme-current)}"
  [[ "$m" == light ]] && print -r -- "$THEME_LIGHT[htop]" || print -r -- "$THEME_DARK[htop]"
}

# Wrap htop so it always launches in the current theme's colours. This is the
# robust hook: htop overwrites htoprc on exit, so a change made by `theme` while
# htop was running would be clobbered — re-syncing here fixes it on next launch.
htop() {
  _theme_htop_sync "$(theme-htop-scheme)"
  command htop "$@"
}

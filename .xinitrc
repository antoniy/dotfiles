#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources &

# 1. Set default keyboard leyout
# 2. Set both caps lock keys to toggle caps behavior
# 3. Make caps lock act as Ctrl when pressed with other key
setxkbmap -model pc104 -layout us,bg -variant ,phonetic \
    -option grp:lctrl_lwin_toggle \
    -option shift:both_capslock \
    -option caps:ctrl_modifier &

# Set caps lock (single key press) behavior to be Escape
killall xcape 2>/dev/null ; xcape -e 'Caps_Lock=Escape' &

# Set key repeat delay and interval
xset r rate 300 50 &

# Start common tools
dunst &
compton &
/usr/lib/geoclue-2.0/demos/agent &
redsihft-gtk &
nm-applet &

exec i3

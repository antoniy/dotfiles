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

# Set wallpaper
feh --bg-scale $HOME/.config/wall.jpg

# Start common tools
sxhkd -m 1 & # bind keys with sxhkd
dunst & # notification daemon
compton & # window decorator for transperancy etc.
/usr/lib/geoclue-2.0/demos/agent & # geoclue agent to know current location for redshift sunset check
# $HOME/.config/polybar/launch.sh & # launch polybar
redsihft &> /dev/null & # change color temperature at sunset
nm-applet & # network manager applet
xbanish & # hide cursor when mouse pressed
xsetroot -cursor_name left_ptr # set the cursor style to left ptr from an 'X'

exec xmonad

#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources &

## test for an existing bus daemon, just to be safe
# if test -z "$DBUS_SESSION_BUS_ADDRESS" ; then
#     ## if not found, launch a new one
#     eval `dbus-launch --sh-syntax`
#     echo "D-Bus per-session daemon address is: $DBUS_SESSION_BUS_ADDRESS"
# fi

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

# set trackball accel speed
# hint: check all available devices and IDs with `xinput list`. Check all props with `xinput list-props 17`
#xinput --set-prop "Logitech ERGO M575" "libinput Accel Speed" -0.7 &

# Set wallpaper
feh --bg-scale $HOME/.config/wall.jpg

# Start common tools
# sxhkd -m 1 & # bind keys with sxhkd
dunst & # notification daemon
picom & # compositor for transperancy etc.
#/usr/lib/geoclue-2.0/demos/agent & # geoclue agent to know current location for redshift sunset check
# $HOME/.config/polybar/launch.sh & # launch polybar
redshift &> /dev/null & # change color temperature at sunset
nm-applet & # network manager applet
#xbanish & # hide cursor when mouse pressed
xsetroot -cursor_name left_ptr # set the cursor style to left ptr from an 'X'

# Need that due to very slow loading of some apps. 
# Ref: https://github.com/flatpak/xdg-desktop-portal-gtk/issues/72
dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

# exec dbus-launch --sh-syntax --exit-with-session xmonad
# exec dbus-launch --autolaunch=$(cat /var/lib/dbus/machine-id) xmonad
exec xmonad

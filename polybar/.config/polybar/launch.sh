#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Configure tray monitor
# Note: see available outputs with "polybar --list-monitors"
tray_output="DVI-I-1"

for m in $(polybar --list-monitors | cut -d":" -f1); do
  if [[ $m == $tray_output ]]; then
    TRAY_POSITION=right
  else 
    TRAY_POSITION=none
  fi
	WIRELESS=$(ls /sys/class/net/ | grep ^wl | awk 'NR==1{print $1}') MONITOR=$m polybar --reload mainbar-i3 &
done

# for m in outputs; do
# 	WIRELESS=$(ls /sys/class/net/ | grep ^wl | awk 'NR==1{print $1}') MONITOR=$m polybar --reload mainbar-i3 &
# done

echo "Bars launched..."

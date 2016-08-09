#!/bin/bash

# Requirements: i3lock, wmctrl

# Must be PNG file 
wallpaper="~/.i3wm-config/screensaver/Extra-Background-006.png"

lock() {
	i3lock -ti $wallpaper
}

close_safely() {
	# Kill screensaver script
	pkill xscreen-lock.sh && rm -f /tmp/xscreen-lock

	# Try to close apps safely
	for app in $(wmctrl -l|awk '{print $1}'); do
		wmctrl -i -c $app
	done
	running=1
	timeout=60
	while [ $running -ge 1 ]; do
		running=$(wmctrl -l|wc -l)
		sleep 5
		if [ $timeout -eq 0 ]; then
			running=0
		fi
		timeout=$(expr $timeout - 5)
	done
}

case "$1" in
	lock)
		lock
	;;
	logout)
		close_safely && i3-msg exit
	;;
	suspend)
		lock && systemctl suspend
	;;
	hibernate)
		lock && systemctl hibernate
	;;
	reboot)
		close_safely && systemctl reboot
	;;
	shutdown)
		close_safely && systemctl poweroff
	;;
	*)
		echo "Usage: $0 {lock|logout|suspend|hibernate|reboot|shutdown}"
		exit 2
esac

exit 0

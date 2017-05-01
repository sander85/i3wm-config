#!/bin/bash

# Requirements: xssstate, i3lock

# Set timeout for turning off monitor(s)
otimeout="300"
# Set timeout for screensaver
timeout="60"

if [ -f "/tmp/xscreen-lock" ]; then
	exit 0
fi
touch /tmp/xscreen-lock

# Use xset s $otimeout to control the timeout when this will run.
xset s $otimeout

cmd="i3lock"
# Check if the 1st argument is file
if [ $# -eq 1 ] && [ -f $1 ]; then
	mime=$(file --mime-type $1 | cut -d \  -f2)
	# Check if it's a PNG file
	if [ $(echo $mime|grep -i png|wc -l) -eq 1 ]; then
		cmd="i3lock -ti $1"
	fi
fi

while true
do
	# Get monitor's state
	monitor_state=$(xset q|grep "Monitor is"|awk '{print $3}')

	# If some blocker programs are found then disable screensaver
	if [ $monitor_state == "On" ]; then
		blockers=$(ps aux|grep -E 'vlc'|grep -v grep|wc -l)
		if [ $blockers -gt 0 ]; then
			xset s off
		else
			xset s $otimeout
		fi
	fi

	if [ $(xssstate -s) != "disabled" ] && [ $monitor_state == "On" ]; then
		# First turn off screen(s)
		tosleep=$(($(xssstate -t) / 1000))
		if [ $tosleep -le 0 ]; then
			xset dpms force off
			# And then lock the screen with screensaver
			sleep $timeout
			tosleep=$(($(xssstate -t) / 1000))
			if [ $tosleep -le 0 ]; then
				$cmd
			fi
		else
			sleep $tosleep
		fi
	else
		sleep 10
	fi
done

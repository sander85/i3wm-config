#!/bin/bash

# Requirements: xssstate, i3lock

if [ -f "/tmp/xscreen-lock" ]; then
	exit 0
fi
touch /tmp/xscreen-lock

# Use xset s $time to control the timeout when this will run.
xset s 300

# Check if the 1st argument is file
if [ -f $1 ]; then
	mime=$(file --mime-type $1 | cut -d \  -f2)
	# Check if it's a PNG file
	if [ $(echo $mime|grep -i png|wc -l) -eq 1 ]; then
		cmd="i3lock -i $1"
	else
		cmd="i3lock"
	fi
fi

while true
do
	if [ $(xssstate -s) != "disabled" ];
	then
		tosleep=$(($(xssstate -t) / 1000))
		if [ $tosleep -le 0 ];
		then
			$cmd
		else
			sleep $tosleep
		fi
	else
		sleep 10
	fi
done

#!/bin/sh

# This a small script to make your live easier.

# Variables
screen_1='Save-Watch'
screen_2='Local-Server'
screen_kill='kill'
parameter_1=$1

# Fuctions

# Start the sessions
start_sessions() {
	screen -dmS $screen_1 npm run watch
	screen -dmS $screen_2 php artisan serve
}

# Kills the sessions
kill_session_1() {
	screen -X -S $screen_1 kill
}

kill_session_2() {
	screen -X -S $screen_2 kill
}

# Check foreach sessions if it isn't kill yet
check_sessions() {
	if screen -ls | grep -q $screen_1; then
		kill_session_1
	else
		echo "\n\e[38;5;226mScreen (\e[39m$screen_1\e[38;5;226m) was already killed\e[39m"
	fi

	if screen -ls | grep -q $screen_2; then
		kill_session_2
	else
		echo "\n\e[38;5;226mScreen (\e[39m$screen_2\e[38;5;226m) was already killed\e[39m"
	fi
}

# Main

# Checked if the first parameter eqaul is to screen_kill
if [ "$parameter_1" = "$screen_kill" ]; then
	check_sessions
	echo "\n\e[31mAll the screens are killed now\e[39m\n"
else
	# Restarts all sesions if the sessions already exits if not than start the sessions
	if screen -ls | grep -q -e $screen_1 -e $screen_2; then
		check_sessions
		start_sessions
		echo "\n\e[38;5;202mThe screens have been successfully restarted\e[39m\n"
	else
		start_sessions
		echo "\n\e[92mThe screens have been successfully started\e[39m\n"
	fi
fi

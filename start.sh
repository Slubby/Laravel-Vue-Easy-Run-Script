#!/bin/sh

# This a small script to make your life easier.

# Variables
screen_1='Save-Watch'
screen_2='Local-Server'



# Fuctions

#all the commands
help() {
echo "
Usage: `basename $0` <command> [<options>]

The following commands are:
	 base:	help | info
	setup: 	new [<Project-name>]
	  run: 	start | restart | stop
"
}

# info about the commands
info() {
echo "
Info about the following command title's:
	setup:	Setup for a new laravel project.
	  run:	Runs watch and serve for laravel.
"
}

# error message
help_error() {
	echo "Try to use (`basename $0` $1) or (`basename $0`).\n"
}

# Start the sessions
start_sessions() {
	screen -dmS $screen_1 npm run watch-poll
	screen -dmS $screen_2 php artisan serve
}

# Kills the sessions
kill_session_1() {
	# kill the screen
	screen -X -S $screen_1 kill
}

kill_session_2() {
	screen -X -S $screen_2 kill
}

# Check foreach sessions if it isn't kill yet
check_sessions() {
	# Checks if the screen is running
	if screen -ls | grep -q $screen_1; then
		kill_session_1
	else
		echo "\n\e[38;5;226mScreen (\e[39m$screen_1\e[38;5;226m) was already stopped.\e[39m"
	fi

	if screen -ls | grep -q $screen_2; then
		kill_session_2
	else
		echo "\n\e[38;5;226mScreen (\e[39m$screen_2\e[38;5;226m) was already stopped.\e[39m"
	fi
}



# Main
commands="${1}"

# Gets the script with the given commands
case ${commands} in

	# Makes new laravel project, with name and no name
	new)
		# Checks if the project doesn't exist already 
		if [ ! -d "$2" ]; then
			# Check if a name has been given
			# Shows the PATH where the project is going to be installed
			if [ -z "$2" ]; then 
				echo "\n\e[38;5;226mDo you want to install laravel in: (\e[39m${PWD}\e[38;5;226m)\e[39m"
			else
				echo "\n\e[38;5;226mDo you want to install laravel in: (\e[39m${PWD}/$2\e[38;5;226m)\e[39m"
			fi
			# Asks the user if he wants to install the project with the given PATH 
			read -r -p "Are You Sure? [Y/n] " input
			echo
			# Checks the given answer
			case $input in
				[yY][eE][sS]|[yY])
					# Full installs laravel with npm
					laravel new $2
					cd $2
					npm install

					echo "\n\e[92mLaravel is now ready to go.\e[39m\n"
				;;
				[nN][oO]|[nN])
					exit 1
				;;
				# if the user answer isn't (yes, no, y, n or in caps)
				*)
					echo "\e[38;5;226mInvalid input. Use [\e[39mY/n\e[38;5;226m]\e[39m\n"
					exit 1
				;;
			esac
		else
			echo "\n\e[38;5;226mThis laravel project already exists.\e[39m\n"
		fi 
	;;

	# starts the screens
	start)
		# Checks if screen is installed	
		if ! [ -x "$(command -v screen)" ]; then
  			echo '\n\e[31mYou havent installed screen yet. \n\e[38;5;226mTry (\e[39mnpm install screen\e[38;5;226m) to install it.\n'
		else
			# Chech if the screen not already running
			if screen -ls | grep -q -e $screen_1 -e $screen_2; then
				echo "\n\e[38;5;226mThe screens have already started.\e[39m" 
				help_error restart
			else
				start_sessions
				echo "\n\e[92mThe screens have been successfully started.\e[39m\n"
			fi
		fi
	;;

	# restart the screens
	restart)
		# Checks if screen is installed
		if ! [ -x "$(command -v screen)" ]; then
  			echo '\n\e[31mYou havent installed screen yet. \n\e[38;5;226mTry (\e[39mnpm install screen\e[38;5;226m) to install it.\n'
		else
			# check is the screen running
			if screen -ls | grep -q -e $screen_1 -e $screen_2; then
				check_sessions
				start_sessions
				echo "\n\e[38;5;202mThe screens have been successfully restarted\e[39m\n"
			else
				echo "\n\e[38;5;226mThere were no screens to restart.\e[39m" 
				help_error start
			fi
		fi
	;;

	# Stops the screens
	stop)
		# Checks if screen is installed
		if ! [ -x "$(command -v screen)" ]; then
  			echo '\n\e[31mYou havent installed screen yet. \n\e[38;5;226mTry (\e[39mnpm install screen\e[38;5;226m) to install it.\n'
		else
			# check is the screen running
			if screen -ls | grep -q -e $screen_1 -e $screen_2; then
				check_sessions
				echo "\n\e[31mAll the screens are stop now\e[39m\n"
			else
				echo "\n\e[38;5;226mThere were no screens to stop\e[39m"
				help_error start
			fi
		fi
	;;

	# Info about the commands
	info)
		info
	;;

	# If no commands are in the list
    *)  
      	help
    ;; 
esac
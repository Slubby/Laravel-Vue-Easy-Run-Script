#!/bin/sh

# This a small script to make your life easier.

# Variables
screen_name_builder='Save-Watch'
screen_name_server='Local-Server'



# Fuctions

# All the commands
help() {
echo "
Usage: `basename $0` <command> [<options>]

The following commands are:
	 base:	help | info (i)
	setup: 	new (n) [-n <project name> -v <laravel version>]
	  run: 	start (s) [-b -s] | restart (r) [-b -s] | stop (p)
"
}

# Info about the commands
info() {
echo "
Info about the following command title's:
	setup:	Setup for a new laravel project. 
		-n:	Project name
		-v:	Laravel version. Example: -v ^7.0

	  run:	Runs watch and serve for laravel.
	  	-b:	Doesn't stat the build screen
	  	-s:	Doesn't stat the server screen
"
}

# Error message
help_error() {
	echo "Try to use (`basename $0` $1) or (`basename $0`).\n"
}

# Start the screens
start_screens() {
	if [ $1 = true ]; then
		screen -dmS $screen_name_builder npm run watch-poll
	fi

	if [ $2 = true ]; then
		screen -dmS $screen_name_server php artisan serve
	fi
}

# Check foreach screens if it isn't kill yet
check_screens() {
	# Checks if the screen is running
	if screen -ls | grep -q $screen_name_builder; then
		kill_screen_builder
	fi

	if screen -ls | grep -q $screen_name_server; then
		kill_screen_server
	fi
}

# Kills the screens
kill_screen_builder() {
	screen -X -S $screen_name_builder kill
}

kill_screen_server() {
	screen -X -S $screen_name_server kill
}



# Main
path=${PWD}
commands=${1}

# Gets the script with the given commands
case ${commands} in

	# Makes new laravel project, with name and no name
	[nN][eE][wW])
		shift

		while getopts n:v: options; do
			case ${options} in
				n) name=${OPTARG};;
				v) version=":${OPTARG}";;
			esac
		done

		# Checked if the project doesn't exist already 
		if [ ! -d "$name" ]; then

			# Checked if name is set
			if [ -z $name ]; then

				# If name is not set
				${name:=${path##*/}}

				# Checked if the folder is empty
				if [ -z "$(ls -A)" ]; then
					cd ..
				else
					echo "\n\e[38;5;226mThis project is not empty.\e[39m\n"
					exit 1
				fi
			fi

			# Asks the user if he wants to install the project with the given PATH 
			echo "\n\e[38;5;226mDo you want to install laravel in: (\e[39m$path/$name\e[38;5;226m)\e[39m"
			read -r -p "Are You Sure? [Y/n] " input
			echo

			# Checks the given answer
			case ${input:-y} in
				[yY][eE][sS]|[yY])
					# Full installs laravel with npm
					composer create-project --prefer-dist laravel/laravel$version $name
					cd $name
					# npm install

					echo "\n\e[92mLaravel is now ready to go.\e[39m\n"
					exit 1
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
			echo "\n\e[38;5;226mThis project already exists.\e[39m\n"
		fi 
	;;

	# starts the screens
	[sS][tT][aA][rR][tT]|[sS])

		# Checks if screen is installed	
		if ! [ -x "$(command -v screen)" ]; then
  			echo '\n\e[31mYou havent installed screen yet. \n\e[38;5;226mTry (\e[39mapt install screen\e[38;5;226m) to install it.\n'
		else

			# Chech if the screen not already running
			if screen -ls | grep -q -e $screen_name_builder -e $screen_name_server; then
				echo "\n\e[38;5;226mThe screens have already started.\e[39m" 
				help_error restart
			else
				shift
				builder=true
				server=true

				while getopts bs: options; do
					case ${options} in
						b) builder=false;;
						s) server=false;;
					esac
				done

				start_screens $builder $server
				echo "\n\e[92mThe screens have been successfully started.\e[39m\n"
			fi
		fi
	;;

	# restart the screens
	[rR][eE][sS][tT][aA][rR][tT]|[rR])
		# Checks if screen is installed
		if ! [ -x "$(command -v screen)" ]; then
  			echo '\n\e[31mYou havent installed screen yet. \n\e[38;5;226mTry (\e[39mapt install screen\e[38;5;226m) to install it.\n'
		else
			# check is the screen running
			if screen -ls | grep -q -e $screen_name_builder -e $screen_name_server; then
				shift
				builder=true
				server=true

				while getopts bs: options; do
					case ${options} in
						b) builder=false;;
						s) server=false;;
					esac
				done

				check_screens
				start_screens $builder $server
				echo "\n\e[38;5;202mThe screens have been successfully restarted\e[39m\n"
			else
				echo "\n\e[38;5;226mThere were no screens to restart.\e[39m" 
				help_error start
			fi
		fi
	;;

	# Stops the screens
	[sS][tT][oO][pP]|[pP])
		# Checks if screen is installed
		if ! [ -x "$(command -v screen)" ]; then
  			echo '\n\e[31mYou havent installed screen yet. \n\e[38;5;226mTry (\e[39mapt install screen\e[38;5;226m) to install it.\n'
		else
			# check is the screen running
			if screen -ls | grep -q -e $screen_name_builder -e $screen_name_server; then
				check_screens
				echo "\n\e[31mAll the screens are stopped now\e[39m\n"
			else
				echo "\n\e[38;5;226mThere were no screens to stop\e[39m"
				help_error start
			fi
		fi
	;;

	# Info about the commands
	[iI][nN][fF][oO]|[iI])
		info
	;;

	# If no commands are in the list
    *)  
      	help
    ;; 
esac

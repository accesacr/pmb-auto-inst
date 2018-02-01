#!/bin/bash
SOURCE_DIR=/var/www/fixmystreet/
SOURCE_APP_DIR=/var/www/fixmystreet/fixmystreet
MOUNTED_DIR=/var/www/exposed-app/
MOUNTED_APP_DIR=/var/www/exposed-app/fixmystreet

# Checks if a folder mounted from host is found (hardcoded folder name)
# If it's found the app is going to run from that persistent folder (exposed to the host for develpment)
# If not found then the app is going to run from non-persistent folder (not exposed to the host)
if test -d "$MOUNTED_DIR"; then
	echo "Mounted directory found: executing from mounted dir."
	if ! test -d "$MOUNTED_APP_DIR"; then
		# If the app's code is not found it is copied into the mounted folder
		echo "Source code not found on mounted folder: copying contents."
		cp -R $SOURCE_APP_DIR $MOUNTED_APP_DIR
	fi
	cd $MOUNTED_APP_DIR
else
	# If mounted folder is not found then it's going to execute from local non-persistent folder
	cd $SOURCE_APP_DIR
	echo "Mounted directory not found: executing from local dir."
fi
/etc/init.d/postgresql start
# su pormibarrio
# bin/cron-wrapper script/fixmystreet_app_server.pl -d --fork -r --restart_directory .

su -c "bin/cron-wrapper script/fixmystreet_app_server.pl -d --fork -r --restart_directory ." "pormibarrio"
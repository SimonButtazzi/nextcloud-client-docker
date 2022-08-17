#!/bin/sh

LOG_DATE_FORMAT="%m-%d %H:%M:%S"

[ -z $NC_USER ] && echo "[ERROR] Username NC_USER (required) is empty." | ts "${LOG_DATE_FORMAT}"
[ -z $NC_PASS ] && echo "[ERROR] Password NC_PASS (required) is empty." | ts "${LOG_DATE_FORMAT}"
[ -z $NC_URL ] && echo "[ERROR] Nextcloud URL NC_URL (required) is empty." | ts "${LOG_DATE_FORMAT}"

if [ -z $NC_USER ] || [ -z $NC_PASS ] || [ -z $NC_URL ]; then
  echo "[ERROR] Configuration is incomplete. Exit." | ts "${LOG_DATE_FORMAT}"
  exit 1
fi

getent group $USER_GID > /dev/null || addgroup -g $USER_GID $USER
getent passwd $USER_UID > /dev/null || adduser -u $USER_UID $USER -D -H -G $USER

[ -d /settings ] || mkdir -p /settings
chown -R $USER_UID:$USER_GID /settings

# check exclude file exists
if [ -e "/settings/exclude" ]; then
	EXCLUDE="/settings/exclude"
else
	echo "[INFO]  exclude file not found!" | ts "${LOG_DATE_FORMAT}"
fi
# check unsyncedfolders file exists
if [ -e "/settings/unsyncfolders" ]; then
	UNSYNCEDFOLDERS="/settings/unsyncfolders"
else
	echo "[INFO]  unsync file not found!" | ts "${LOG_DATE_FORMAT}"
fi

[ "$NC_PATH" ] && echo "[INFO]  Remote root folder overriden to $NC_PATH" | ts "${LOG_DATE_FORMAT}"

[ "$NC_SILENT" == true ] && echo "[INFO]  Silent mode enabled" | ts "${LOG_DATE_FORMAT}"
[ "$NC_HIDDEN" == true ] && echo "[INFO]  Sync hidden files enabled" | ts "${LOG_DATE_FORMAT}"
[ "$NC_TRUST_CERT" == true ] && echo "[INFO]  Trust any SSL certificate" | ts "${LOG_DATE_FORMAT}"
[ "$WATCH_FOLDER" == true ] && echo "[INFO]  Trigger sync by changes in local folder" | ts "${LOG_DATE_FORMAT}"
[ "$WATCH_FOLDER" == true ] && echo "[INFO]  Delay triggered sync by ${NC_DELAY}s" | ts "${LOG_DATE_FORMAT}"

while true
do

	set --
	[ "$NC_HIDDEN" ] && set -- "$@" "-h"
	[ "$NC_SILENT" == true ] && set -- "$@" "--silent"
	[ "$NC_TRUST_CERT" == true ] && set -- "$@" "--trust"
	[ "$NC_PATH" ] && set -- "$@" "--path" "$NC_PATH"
	[ "$EXCLUDE" ] && set -- "$@" "--exclude" "$EXCLUDE"
	[ "$UNSYNCEDFOLDERS" ] && set -- "$@" "--unsyncedfolders" "$UNSYNCEDFOLDERS"
	set -- "$@" "--non-interactive" "-u" "$NC_USER" "-p" "$NC_PASS" "$NC_SOURCE_DIR" "$NC_URL"
	
	if [ "$WATCH_FOLDER" = true ] ; then
    echo "[INFO]  Listening ${NC_INTERVAL}s for changes in $NC_SOURCE_DIR to start sync from $NC_URL to $NC_SOURCE_DIR" | ts "${LOG_DATE_FORMAT}"
    sudo -u \#$USER_UID -g \#$USER_GID inotifywait --timeout ${NC_INTERVAL} --exclude .*.db -e close_write -e delete -e move "$NC_SOURCE_DIR" ; sleep ${NC_DELAY} ; sudo -u \#$USER_UID -g \#$USER_GID nextcloudcmd "$@"
  else
    echo "[INFO]  Start sync from $NC_URL to $NC_SOURCE_DIR" | ts "${LOG_DATE_FORMAT}"
    sudo -u \#$USER_UID -g \#$USER_GID nextcloudcmd "$@"
	fi
	
	echo "[INFO]  Sync done" | ts "${LOG_DATE_FORMAT}"

	#check if exit!
	if [ "$NC_EXIT" = true ] ; then
		echo "[INFO]  NC_EXIT is true so exiting... bye!" | ts "${LOG_DATE_FORMAT}"
		exit
	fi
	
	if [ "$WATCH_FOLDER" != true ] ; then 
        echo "[INFO]  Wait ${NC_INTERVAL}s until next sync" | ts "${LOG_DATE_FORMAT}"
        sleep ${NC_INTERVAL}
	fi

done

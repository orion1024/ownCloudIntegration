#!/bin/sh

# ----------------------------------------------------------------------
# 	Executed on the proxmox server to reset the integration platform
#	Author : orion1024
# 	Date : 2016
# ----------------------------------------------------------------------

# We get the script name
SCRIPT_NAME=`basename "$0"`
# And the directory containing the script
CUR_DIR=`dirname "$0"`
# Whether script is named "myscript.ext" or "myscript", log file will be "myscript.log" and located at the same place
LOG_FILE=$CUR_DIR/${SCRIPT_NAME%.*}.log

#-------------------------

echo ---- Script begins ---- >> $LOG_FILE

echo Script executed just now !! >> $LOG_FILE

echo qm rollback 110 Clean_state 2>&1 >> $LOG_FILE

echo ---- Script ends ---- >> $LOG_FILE


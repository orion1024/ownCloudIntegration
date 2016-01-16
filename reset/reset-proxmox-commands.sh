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


# This script was generated automatically
echo Script executed just now !! >> $RESET_SCRIPT_LOG

#!/bin/bash

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

echo ---- Script begins ---- 2>&1 | tee  "$LOG_FILE"


echo Script executed just now !! 2>&1 | tee  "$LOG_FILE"

if [[ $1 != "" && $2 != "" ]]; then
	# we loop through each ID
	VM_LIST=$1
	SNAP_NAME=$2

	for VM_ID in ${VM_LIST/,/ } ; do
		echo Resetting VM with ID $VM_ID... 2>&1 | tee  "$LOG_FILE"
		qm rollback $VM_ID $SNAP_NAME 2>&1 | tee  "$LOG_FILE"
		echo Starting VM with ID $VM_ID... 2>&1 | tee  "$LOG_FILE"
		qm start $VM_ID 2>&1 | tee  "$LOG_FILE"
	done
else
	echo Missing parameter. Usage : $SCRIPT_NAME vmid1[,vmid2,...] snapshot_name 2>&1 | tee  "$LOG_FILE"
fi

echo ---- Script ends ---- 2>&1 | tee  "$LOG_FILE"


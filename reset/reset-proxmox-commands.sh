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

# Unless specified otherwise, exit with code 0
EXIT_CODE=0

echo ---- Script $SCRIPT_NAME begins ---- 2>&1 | tee  "$LOG_FILE"


echo Script executed just now !! 2>&1 | tee  "$LOG_FILE"

if [[ $1 != "" && $2 != "" ]]; then
	# we loop through each ID
	VM_LIST=$1
	SNAP_NAME=$2

	for VM_ID in ${VM_LIST//,/ } ; do
		echo Resetting VM with ID $VM_ID... 2>&1 | tee  "$LOG_FILE"
		qm rollback $VM_ID $SNAP_NAME 2>&1 | tee  "$LOG_FILE"
		
		# If at least one command failed, steps failed
		EXIT_CODE=$(($EXIT_CODE || ${PIPESTATUS[0]}))
		
	done
	
	# Not needed anymore since snapshots are done with the VM powered on.
	# for VM_ID in ${VM_LIST//,/ } ; do
		
		# echo Starting VM with ID $VM_ID... 2>&1 | tee  "$LOG_FILE"
		# qm start $VM_ID 2>&1 | tee  "$LOG_FILE"
		
		# # If at least one command failed, steps failed
		# EXIT_CODE=$(($EXIT_CODE || ${PIPESTATUS[0]}))
		
	# done
else
	echo Missing parameter. Usage : $SCRIPT_NAME vmid1[,vmid2,...] snapshot_name 2>&1 | tee  "$LOG_FILE"
	EXIT_CODE=1
fi

echo ---- Script $SCRIPT_NAME ends with exit code $EXIT_CODE ----- 2>&1 | tee  "$LOG_FILE"

exit $EXIT_CODE

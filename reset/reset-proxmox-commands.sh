#!/bin/bash

# ----------------------------------------------------------------------
# 	Executed on the proxmox server to reset the integration platform
#	Rollback & suspend all VM, then resume them all at once.
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
		
		# If at least one command failed, step failed
		EXIT_CODE=$(($EXIT_CODE || ${PIPESTATUS[0]}))
		
		# We don't want to start them yet, so we suspend the VM right after the rollback.
		# This way they will all start at the same time, without any rollback (which is an heavy IO process) slowing them down.
		# This avoid having a VM trying to connect
		qm suspend $VM_ID 2>&1 | tee  "$LOG_FILE"
		
		# If at least one command failed, step failed
		EXIT_CODE=$(($EXIT_CODE || ${PIPESTATUS[0]}))
		
		if [[ $EXIT_CODE != "0" ]]; then
			echo "Error detected, aborting." | tee  "$LOG_FILE"
			break
		fi
	done
	
	if [[ $EXIT_CODE == "0" ]]; then

		for VM_ID in ${VM_LIST//,/ } ; do
			
			echo Resuming VM with ID $VM_ID... 2>&1 | tee  "$LOG_FILE"
			qm resume $VM_ID 2>&1 | tee  "$LOG_FILE"
			
			# If at least one command failed, step failed
			EXIT_CODE=$(($EXIT_CODE || ${PIPESTATUS[0]}))
			
			if [[ $EXIT_CODE != "0" ]]; then
				echo "Error detected, aborting." | tee  "$LOG_FILE"
				break
			fi
		done
	fi
else
	echo Missing parameter. Usage : $SCRIPT_NAME vmid1[,vmid2,...] snapshot_name 2>&1 | tee  "$LOG_FILE"
	EXIT_CODE=1
fi

echo ---- Script $SCRIPT_NAME ends with exit code $EXIT_CODE ----- 2>&1 | tee  "$LOG_FILE"

exit $EXIT_CODE

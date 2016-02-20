#!/bin/bash

# -------------------------------------------------------------
# 	Send commands to proxmox to reset the integration platform
#	Author : orion1024
# 	Date : 2016
# --------------------------------------------------------------

# IP or resolvable name of proxmox server
PROXMOX_HOST=192.168.255.254

# User on proxmox that will be used to execute the commands.
# It must have the necessary privileges of course
# NB : authentification will be key-based, no password.
# The keys must have been set up properly for both the user executing *this* script (should be jenkins)
# and the remote user on proxmox.

PROXMOX_USER=root

# Name of the script sent to PROXMOX
RESET_SCRIPT_FILE=reset-proxmox-commands.sh
# Name of its log
RESET_SCRIPT_LOG=${RESET_SCRIPT_FILE%.*}.log

# We get the script name
SCRIPT_NAME=`basename "$0"`
# And the directory containing the script
REL_CUR_DIR=`realpath "$0"`
CUR_DIR=`dirname "$REL_CUR_DIR"`

# Whether script is named "myscript.ext" or "myscript", log file will be "myscript.log" and located at the same place
LOG_FILE=$CUR_DIR/${SCRIPT_NAME%.*}.log

cd "$CUR_DIR"

#-------------------------

# Unless specified otherwise, exit with code 0
EXIT_CODE=0

echo ----- Script $SCRIPT_NAME begins ----- 2>&1 | tee  "$LOG_FILE"
echo Commands sent to proxmox are in $RESET_SCRIPT_FILE 2>&1 | tee  "$LOG_FILE"

if [[ $1 = "" || $2 = "" ]]; then
        echo Missing parameter. Usage : $SCRIPT_NAME vmid1[,vmid2,...] snapshot_name [slave1,slave2,...] 2>&1 | tee "$LOG_FILE"
		EXIT_CODE=1
else
        VM_LIST=$1
		SNAP_NAME=$2
		SLAVE_LIST=$3		# optional
		
		# Setting the executable flag before sending it...
		chmod +x  $RESET_SCRIPT_FILE 2>&1 | tee  "$LOG_FILE"

		# Sending the script...
		echo Sending script... 2>&1 | tee  "$LOG_FILE"
		echo Command is : scp -P 29998 $RESET_SCRIPT_FILE $PROXMOX_USER@$PROXMOX_HOST:./scripts/reset/$RESET_SCRIPT_FILE 2>&1 | tee  "$LOG_FILE"
		scp -P 29998 $RESET_SCRIPT_FILE $PROXMOX_USER@$PROXMOX_HOST:./scripts/reset/$RESET_SCRIPT_FILE 2>&1 | tee  "$LOG_FILE"

		# Now executing the script
		echo Executing script on $PROXMOX_HOST with user $PROXMOX_USER... 2>&1 | tee  "$LOG_FILE"
		echo Command is : ssh -p 29998 $PROXMOX_USER@$PROXMOX_HOST ./scripts/reset/$RESET_SCRIPT_FILE $VM_LIST $SNAP_NAME $SLAVE_LIST 2>&1 | tee  "$LOG_FILE"

		ssh -p 29998 $PROXMOX_USER@$PROXMOX_HOST ./scripts/reset/$RESET_SCRIPT_FILE $VM_LIST $SNAP_NAME $SLAVE_LIST 2>&1 | tee  "$LOG_FILE"
		
		# Uses remote command exit code for our own exit code
		EXIT_CODE=${PIPESTATUS[0]}
fi

echo ---- Script $SCRIPT_NAME ends with exit code $EXIT_CODE ----- 2>&1 | tee  "$LOG_FILE"

exit $EXIT_CODE


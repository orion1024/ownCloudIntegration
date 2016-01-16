#!/bin/sh

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
PROXMOX_USER=jenkins

# Name of the script sent to PROXMOX
RESET_SCRIPT_FILE=reset-proxmox-commands.sh

# We get the script name
SCRIPT_NAME=`basename "$0"`
# And the directory containing the script
CUR_DIR=`dirname "$0"`
# Whether script is named "myscript.ext" or "myscript", log file will be "myscript.log" and located at the same place
LOG_FILE=$CUR_DIR/${SCRIPT_NAME%.*}.log

#-------------------------

echo Commands sent to proxmox are in $RESET_SCRIPT_FILE >> $LOG_FILE

echo Content of the script is : >> $LOG_FILE
echo -BEGIN-  >> $LOG_FILE
cat $RESET_SCRIPT_FILE  >> $LOG_FILE
echo -END-  >> $LOG_FILE

# Sending the script...
echo Sending script...  >> $LOG_FILE
echo Command is : scp -p -P 29998 $RESET_SCRIPT_FILE $PROXMOX_USER@$PROXMOX_HOST:./scripts/$RESET_SCRIPT_FILE  >> $LOG_FILE
scp -p -P 29998 $RESET_SCRIPT_FILE $PROXMOX_USER@$PROXMOX_HOST:./scripts/$RESET_SCRIPT_FILE  >> $LOG_FILE

# Now executing the script
echo Executing script on $PROXMOX_HOST with user $PROXMOX_USER...  >> $LOG_FILE
echo Command is : ssh -p 29998 $PROXMOX_USER@$PROXMOX_HOST ./scripts/$RESET_SCRIPT_FILE

ssh -p 29998 $PROXMOX_USER@$PROXMOX_HOST ./scripts/$RESET_SCRIPT_FILE  >> $LOG_FILE


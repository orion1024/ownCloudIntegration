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

# IP or resolvable name of the Jenkins server. NB : one of SSH key of the account running this script must be authorized on jenkins for the authentication to work.
JENKINS_HOST=192.168.255.253

#-------------------------

# Unless specified otherwise, exit with code 0
EXIT_CODE=0

echo ---- Script $SCRIPT_NAME begins ---- 2>&1 | tee  "$LOG_FILE"


echo Script executed just now !! 2>&1 | tee  "$LOG_FILE"

if [[ $1 != "" && $2 != "" ]]; then
	# We loop through each ID
	VM_LIST=$1
	SNAP_NAME=$2
	SLAVE_LIST=$3		# optional
	
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
	
	#If a list of slave is specified, we disconnect those from jenkins before starting the VM back.
	if [[ $SLAVE_LIST != "" ]]; then
		
		echo Slave list detected. We will disconnect them from Jenkins 2>&1 | tee "$LOG_FILE"
		curl http://$JENKINS_HOST:8080/jnlpJars/jenkins-cli.jar -O

		if [[ -e jenkins-cli.jar ]]; then
		
			for SLAVE_NAME in ${SLAVE_LIST//,/ } ; do
			
				echo Disconnecting slave  $SLAVE_NAME... 2>&1 | tee  "$LOG_FILE"
				java -jar jenkins-cli.jar -s http://$JENKINS_HOST:8080/ disconnect-node $SLAVE_NAME 2>&1 | tee  "$LOG_FILE"
				
				# If at least one command failed, step failed
				EXIT_CODE=$(($EXIT_CODE || ${PIPESTATUS[0]}))
				
				if [[ $EXIT_CODE != "0" ]]; then
					echo "Error detected, aborting." | tee  "$LOG_FILE"
					break
				fi
			done
		else
			echo Could not fetch the Jenkins CLI JAR at http://$JENKINS_HOST:8080/jnlpJars/jenkins-cli.jar 2>&1 | tee  "$LOG_FILE"
			EXIT_CODE=1
		fi
	fi
	
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

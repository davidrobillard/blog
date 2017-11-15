#!/bin/sh 

# /backup/scripts/backup_runner.sh
#
# $Id: backup_runner.sh,v 1.2 2009/08/17 20:57:22 drobilla Exp $
#
# Script called by crontab to avoid useless mails is your inbox. 
#
# Felix Langelier & David Robillard, Jun. 14th, 2007.

umask 022
PATH="/bin:/usr/bin:/usr/local/bin"
export PATH

if [ $# -ne 2 ]; then
	echo "Usage: $0 <configuration_file> <hourly|daily|weekly|monthly>"
	echo "Ex: $0 /backup/conf/client.company.com daily"
	exit
fi

CONFIG_FILE=$1
PERIOD=$2

if [ ! -f ${CONFIG_FILE} ]; then
	echo "ERROR: Could not find ${CONFIG_FILE}."
	exit 1
fi

echo ${PERIOD} | egrep 'hourly|daily|weekly|monthly' 2>&1 >/dev/null

if [ $? -ne 0 ]; then
	echo "ERROR: Bad period value. Available values are <hourly|daily|weekly|monthly>."
	exit 1
fi

# Check if this script is running by root.
if [ `id -u` -ne 0 ]; then
        echo "ERROR: You must be root to execute this script."
        exit 1
fi

# Check if rsnapshot is available and executable.
if [ ! -x `which rsnapshot` ]; then
	echo "ERROR: Could not locate rsnapshot."
	exit 1
fi

# Run the the backup and redirect the output and errors on /dev/null.
rsnapshot -c ${CONFIG_FILE} -v ${PERIOD} > /tmp/rsnap-out.$$ 2>&1 

# If the the previous command failed print an error.
if [ $? -ne 0 ]; then
	cat /tmp/rsnap-out.$$	
fi

# Remove the the rsnapshot output.
rm /tmp/rsnap-out.$$

# EOF
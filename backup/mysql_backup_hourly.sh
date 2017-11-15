#!/bin/sh

# /export/backup/scripts/mysql_backup_hourly.sh
#
# $Id: mysql_backup_hourly.sh,v 1.1 2013/02/22 18:20:30 drobilla Exp drobilla $
#
# Backup all MySQL databases on various hosts ever hour.
#
# David Robillard, April 8th, 2009.

PATH="/bin:/usr/bin:/usr/local/bin"
export PATH

# We only want root to be able to check our MySQL dump files.
# So we switch the umask to 0077.
umask 0077

# MYSQL_USER
# Username of the backup user located inside all our MySQL instances.
# Make sure this user is created and has access to the entire MySQL setup.
# mysql> create user 'backup'@'angel.company.com' identified by 'change_me';
# mysql> grant all on *.* to 'backup'@'angel.company.com';
# mysql> flush privileges;
#
MYSQL_USER="backup"

# MYSQL_PASS
# Password used to connect with the ${MYSQL_USER} user.
#
MYSQL_PASS="change_me"

# MYSQL_HOST_LIST
# Space seperated list of all FQDN machines running MySQL.
#
MYSQL_HOST_LIST="jedi.company.com r2d2.company.com"

# DATE
# Today's date with time stamp.
#
DATE=`date '+%Y.%m.%d-%H:%M'`

# Test to see if all host resolve?
for FQDN in ${MYSQL_HOST_LIST}; do

	OUTPUT=`dig +short ${FQDN}. a`

	if [ "x${OUTPUT}" = "x" ]; then
		echo "ERROR: Could not resolve host ${FQDN}."
		continue
	fi

	# Dump all MySQL instances seperately from the same MySQL host.
	DBLIST=`mysql -h${FQDN} -u${MYSQL_USER} -p${MYSQL_PASS} -B -N -e "show databases" | sed 's/ /%/g'`
	
	for DB in ${DBLIST}; do
		mysqldump -h${FQDN} -u${MYSQL_USER} -p${MYSQL_PASS}  --add-drop-table -B ${DB} -v > ${FQDN}.${DB}.${DATE}.sql

		if [ "$?" -eq "0" ]; then
			gzip ${FQDN}.${DB}.${DATE}.sql
		else
			echo "ERROR: A problem occured with mysqldump on host ${FQDN} and DB ${DB}."
		fi
	done
done

# EOF

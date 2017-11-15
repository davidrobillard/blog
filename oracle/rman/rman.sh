#!/bin/sh

# rman.sh
#
# $Id: rman.sh,v 1.1 2010/09/15 14:46:19 oracle Exp oracle $
#
# Perform backups with Oracle RMAN.
# Oracle instances can be running in archivelog mode or not.
# Backup files are sent to disk and another script ships them to tape.
# This script is known to work with RedHat Enterprise Linux.
#
# Backup format used:
# %d = Database name.
# %u = 8 Char. name composed of compressed representations of the backup set number and time of it's creation.
# %p = Backup piece number within the backup set.
# %c = Copy number of the backup piece within a set of duplexed backup pieces.
# %U = Alias for `%u_%p_%c'.
# %T = Time in YYYYMMDD format.
#
# For example, to perform an online full backup of the instance "orcl", use the following:
#
# rman.sh -s orcl -o online
#
# David Robillard, October 5th, 2005.

umask 022
PATH="/bin:/usr/bin"
export PATH

# NAME
# Name of the current script.
#
NAME=`basename $0 | cut -d'.' -f1`

# CONF
# Full path to the configuration file.
#
CONF="/usr/home/oracle/scripts/${NAME}/${NAME}.conf"

#########################################################################################
# FUNCTIONS.										#
#########################################################################################

# f_print_usage()
# Print usage message and exit.
#
f_print_usage() {
	printf "\nUsage: ${NAME}.sh -t {catalog|daily|prod} -n <database name to backup>\n"

	printf "\nWhere:\t-s: Database name to backup.\n"
	printf "\t-t: Type of backup. Either catalog, daily or prod. If using daily, then you must use meta as the database name.\n"
	printf "\nExample: ${NAME}.sh -t catalog -n meta\n\n"

	exit
}
# END of f_print_usage()


# f_clean_directory()
# Clean directory listed in $1 and keep $2 number of files.
#
f_clean_directory() {
	if [ $# -ne 3 ]; then
		echo "ERROR: Function f_clean_directory() reqiures three options. Bailing out." | tee -a ${LOGFILE}
		echo "ERROR: Usage: f_clean_directory <directory> <keep> <pattern>." | tee -a ${LOGFILE}
		exit 1
	else
		DIRECTORY="$1"
		KEEP="$2"
		PATTERN="$3"
	fi

	echo "${DIRECTORY}" | grep '^/' 2>&1 >/dev/null

	if [ $? -ne 0 ]; then
		echo "ERROR: The directory ${DIRECTORY} is not an absolute path. Bailing out at f_clean_directory()." | tee -a ${LOGFILE}
		exit 1
	fi

	echo ${KEEP} | egrep '^[0-9]{1,3}$' 2>&1 >/dev/null

	if [ $? -ne 0 ]; then
		echo "ERROR: Illegal value for KEEP variable: ${KEEP}. Bailing out at f_clean_directory()." | tee -a ${LOGFILE}
		exit 1
	fi

	echo "${PATTERN}" | grep '^/' 2>&1 >/dev/null

	if [ $? -eq 0 ]; then
		echo "ERROR: Please do not specify a full path for PATTERN in f_clean_directory()." | tee -a ${LOGFILE}
		exit 1
	fi

	FILES=`find ${DIRECTORY} -type f -iname "${PATTERN}*" -print | wc -l`

	cd ${DIRECTORY}
	if [ "${FILES}" -gt "${KEEP}" ]; then

		HEAD=`echo "${FILES} - ${KEEP}" | bc`

		for FILE in `ls -1tr ${PATTERN}* | head -${HEAD}`; do
			rm ${FILE}
		done
	fi
}
# END of f_clean_directory()


#########################################################################################
# MAIN.											#
#########################################################################################

# Make sure only oracle executes the script.

if [ `id -nu` == "oracle" ]; then
	source ~/.bash_profile
else
	echo "ERROR: Only the oracle user can run this script."
	exit 1
fi

# Check if the configuration file is ok?

if [ "x${CONF}" == "x" ]; then
	echo "ERROR: Please set the CONF variable in ${NAME}."
	exit 1

elif [ ! -f "${CONF}" ]; then
	echo "ERROR: Could not find the configuration file ${CONF}."
	exit 1

elif [ -z "${CONF}" ]; then

	echo "ERROR: Configuration file ${CONF} is empty."
	exit 1
fi

# The configuration file is ok, so source it.

source ${CONF}

if [ $? -ne "0" ]; then
	echo "ERROR: There is a problem with the configuration file."
	exit 1
fi

# Check to see if we have everything on the command line.

if [ $# -ne 4 ]; then
	f_print_usage
fi

while getopts "t:n:" OPTIONS; do

	case ${OPTIONS} in
		n)	DB_NAME="${OPTARG}"
		;;

		t)	BACKUP_TYPE="${OPTARG}"

			echo ${BACKUP_TYPE} | egrep -i '(catalog|daily|prod)' 2>&1 >/dev/null

			if [ $? -ne 0 ]; then
				echo "ERROR: Illegal backup type value (${BACKUP_TYPE}). Bailing out."
				echo "NOTE: Backup type must be one of: catalog, daily or prod."
				exit 1
			else
				BACKUP_TYPE=`echo ${BACKUP_TYPE} | tr '[:upper:]' '[:lower:]'`
			fi
		;;

		*)	f_print_usage
		;;
	esac
done

# Check if we have LOGDIR and if we can write to it?

if [ "x${LOGDIR}" == "x" ]; then
	echo "ERROR: Please configure LOGDIR in ${CONF}."
	exit 1

elif [ ! -d "${LOGDIR}" ]; then
	echo "ERROR: The log directory does not exist."
	echo "ERROR: Please create ${LOGDIR}."
	exit 1

elif [ ! -w "${LOGDIR}" ]; then
	echo "ERROR: The oracle user cannot write to ${LOGDIR}."
	exit 1
fi

# Setup logfile.

LOGFILE="${LOGDIR}/${DB_NAME}.${BACKUP_TYPE}.${DATE}.log"

if [ -f ${LOGFILE} ]; then
	mv ${LOGFILE} ${LOGFILE}.$$
fi

echo -e "##\n# Script ${NAME}.sh on ${HOSTNAME}. Backup type: ${BACKUP_TYPE}. Database name: ${DB_NAME}.\n##\n" >> ${LOGFILE}
echo -e "Started on `date`.\n" >> ${LOGFILE}

# Clean the log directory.

f_clean_directory ${LOGDIR} ${KEEP} ${DB_NAME}.${BACKUP_TYPE}

# Check to see if we can communicate with DB_NAME.

tnsping ${DB_NAME} 2>&1 >/dev/null

if [ $? -ne 0 ]; then
	echo -e "ERROR: The following error happened while running tnsping ${DB_NAME}:\n" | tee -a ${LOGFILE}
	tnsping ${DB_NAME} >> ${LOGFILE}
	exit 1
fi

# Get passwords from PASSWD_FILE.

if [ "x${PASSWD_FILE}" = "x" ]; then
	echo "ERROR: Please set PASSWD_FILE in ${CONF}. Bailing out." | tee -a ${LOGFILE}
	exit 1

elif [ ! -f ${PASSWD_FILE} ]; then
	echo "ERROR: Could not find ${PASSWD_FILE}. Bailing out." | tee -a ${LOGFILE}
	exit 1

elif [ -z ${PASSWD_FILE} ]; then
	echo "ERROR: The ${PASSWD_FILE} is empty." | tee -a ${LOGFILE}
	exit 1
fi

SHA1CHECK=`sha1sum ${PASSWD_FILE} | cut -d" " -f1`

if [ "${SHA1HASH}" = "${SHA1CHECK}" ]; then

	grep "^${DB_NAME}_SYS_PASSWD=" ${PASSWD_FILE} 2>&1 >/dev/null

	if [ $? -ne 0 ]; then
		echo "ERROR: Could not locate variable ${DB_NAME}_SYS_PASSWD in ${PASSWD_FILE}. Bailing out." | tee -a ${LOGFILE}
		exit 1
	fi

	grep "^RMAN_PASSWD=" ${PASSWD_FILE} 2>&1 >/dev/null

	if [ $? -ne 0 ]; then
		echo "ERROR: Could not locate variable RMAN_PASSWD in ${PASSWD_FILE}. Bailing out." | tee -a ${LOGFILE}
		exit 1
	fi

	SYS_PASSWD=`grep "^${DB_NAME}_SYS_PASSWD=" ${PASSWD_FILE} | cut -d"'" -f2`
	RMAN_PASSWD=`grep "^RMAN_PASSWD=" ${PASSWD_FILE} | cut -d"'" -f2`

else
	echo "ERROR: Password file SHA1 mismatch. Expected ${SHA1HASH} but received ${SHA1CHECK}. Bailing out." | tee -a ${LOGFILE}
	exit 1
fi

# Perform backup.

ERROR="0"

case ${BACKUP_TYPE} in

	# Backup the repository catalog.
	catalog)
		if [ "x${CATALOG}" == "x" ]; then
			echo "ERROR: Please set CATALOG to the full path of the catalog.rman file in ${CONF}." | tee -a ${LOGFILE}
			exit 1

		elif [ ! -f ${CATALOG} ]; then
			echo "ERROR: Could not find ${CATALOG}." | tee -a ${LOGFILE}
			exit 1
		fi

		rman target / nocatalog log ${LOGFILE} append @${CATALOG} using ${DB_NAME} 2>&1 >${LOGFILE}
	;;

	# Daily backup of the dev, test and pre-production databases.
	daily)
		if [ "x${DAILY}" == "x" ]; then
			echo "ERROR: Please set DAILY to the daily stored script name in the ${CONF} file." | tee -a ${LOGFILE}
			exit 1
		fi

		rman target sys/${SYS_PASSWD}@${DB_NAME} catalog rman/${RMAN_PASSWD}@${RCVCAT} log ${LOGFILE} append script ${DAILY} using ${DB_NAME}
	;;

	# Daily backup of the production databases.
	prod)
		if [ "x${PROD}" == "x" ]; then
			echo "ERROR: Please set PROD to the production stored script name in the ${CONF} file." | tee -a ${LOGFILE}
			exit 1
		fi

		rman target sys/${SYS_PASSWD}@${DB_NAME} catalog rman/${RMAN_PASSWD}@${RCVCAT} log ${LOGFILE} append script ${PROD} using ${DB_NAME}
	;;

	*)	echo "ERROR: Bad BACKUP_TYPE value from command line. Bailing out." | tee -a ${LOGFILE}
		exit 1
	;;
esac

# Handle SQL*Plus errors during backup.

if [ ${ERROR} -ne 0 ]; then
	echo "ERROR: An ERROR occured with ${DB_NAME}. Check the database status ASAP." | tee -a ${LOGFILE}
fi

# Check if any RMAN-xxxxx or ORA-xxxxx messages have appeared in the logfile.

egrep 'RMAN-|ORA-' ${LOGFILE} >/dev/null 2>&1

if [ $? -eq 0 ]; then
	echo -e "WARNING: Investigate those RMAN- or ORA- messages from the log file:\n"
	egrep 'RMAN-|ORA-' ${LOGFILE}
fi

# Close logfile.

echo -e "\nFinished on `date`.\n\n# EOF" >> ${LOGFILE}

# Check the entire log so that we have an email sent by cron(8).

cat ${LOGFILE}

# EOF

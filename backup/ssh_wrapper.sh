#!/bin/sh

# /backup/scripts/ssh_wrapper.sh
#
# $Id: ssh_wrapper.sh,v 1.1 2009/08/17 20:59:33 drobilla Exp $
#
# Wrapper ssh script for rsnapshot.
#
# David Robillard, Aug. 12th, 2009.

umask 022
PATH="/bin:/usr/bin"
export PATH

KEY="/backup/key/id_dsa"

if [ `id -u` -ne 0 ]; then
        echo "ERROR: Only root can run this script."
        exit 1
fi

if [ ! -f ${KEY} ]; then
	echo "ERROR: Could not locate the ssh key ${KEY}. Bailing out."
	exit 2
fi

ssh -i ${KEY} $*

# EOF

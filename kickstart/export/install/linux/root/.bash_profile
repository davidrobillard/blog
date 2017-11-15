# /root/.bash_profile
#
# $Id: .bash_profile,v 1.1 2012/05/17 14:41:18 root Exp $
# 
# Environment configuration for the root user.
#
# David Robillard, April 19th, 2012.

umask 022

PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"
export PATH

MANPATH="/usr/share/man:/usr/local/share/man"
export MANPATH

PS1='[\u@\h] \W {\!}# '
export PS1

if [ -f /root/.aliases ]; then
	source /root/.aliases
fi

# EOF

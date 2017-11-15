# .bash_profile
#
# $Id: .bash_profile,v 1.1 2012/05/17 14:30:17 root Exp $
#
# Initialization file for the bash(1) shell.
#
# David Robillard, March 4th, 2006.

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi

# Get user defined aliases.
if [ -f ~/.aliases ]; then
	source ~/.aliases
fi

unset USERNAME

BLOCKSIZE=K
export BLOCKSIZE

EDITOR=vi
export EDITOR

PAGER=less
export PAGER

PATH="/bin:/usr/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/local/sbin:/usr/libexec:/usr/X11R6/bin"
export PATH

MANPATH="/usr/share/man:/usr/local/share/man"
export MANPATH

PS1="[\u@\h] \W {\!}$ "
export PS1

# EOF

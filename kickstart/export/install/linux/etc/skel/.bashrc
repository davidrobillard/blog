# .bashrc
#
# $Id: .bashrc,v 1.1 2012/05/17 14:37:15 root Exp $
#
# David Robillard, May 16th, 2012.

# Source global definitions
if [ -f /etc/bashrc ]; then
	source /etc/bashrc
fi

# User specific aliases and functions
if [ -f ~/.aliases ]; then
	source ~/.aliases
fi

# EOF

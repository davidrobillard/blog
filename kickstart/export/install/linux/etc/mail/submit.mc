divert(-1)
# /etc/mail/submit.mc
#
# Copyright (c) 2001-2003 Sendmail, Inc. and its suppliers.
#       All rights reserved.
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the sendmail distribution.
#
# David Robillard, April 23rd, 2012.
divert(0)dnl

include(`/usr/share/sendmail-cf/m4/cf.m4')dnl
VERSIONID(`$Id: submit.mc,v 1.1 2012/05/24 18:31:29 root Exp $')dnl
define(`confCF_VERSION', `Submit')dnl
define(`__OSTYPE__',`')dnl dirty hack to keep proto.m4 from complaining
define(`_USE_DECNET_SYNTAX_', `1')dnl support DECnet
define(`confTIME_ZONE', `USE_TZ')dnl
define(`confDONT_INIT_GROUPS', `True')dnl
define(`confPID_FILE', `/var/run/sm-client.pid')dnl
define(`confBIND_OPTS', `WorkAroundBrokenAAAA')dnl
FEATURE(`use_ct_file')dnl
FEATURE(`msp', `[127.0.0.1]')dnl

dnl # EOF

divert(-1)
# /etc/mail/sendmail.mc
#
# This is the sendmail macro config file for m4. If you change this
# file, don't forget to regenerate the /etc/mail/sendmail.cf file.
# To do this, run the following :
#
# sudo make -C /etc/mail
#
# David Robillard, March 9th, 2012.
divert(0)

include(`/usr/share/sendmail-cf/m4/cf.m4')dnl
VERSIONID(`$Id: sendmail.mc,v 1.1 2012/05/17 16:01:35 root Exp $')dnl
OSTYPE(`linux')dnl
DOMAIN(generic)dnl
DAEMON_OPTIONS(`Port=587, Addr=127.0.0.1, Name=MSA, M=E')dnl
DAEMON_OPTIONS(`Port=25, Addr=127.0.0.1, Name=MTA')dnl
FEATURE(`no_default_msa')dnl
FEATURE(nullclient, `mailhub.company.com')dnl

dnl # EOF

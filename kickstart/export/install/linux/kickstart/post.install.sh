#!/bin/sh

# kickstart.post.sh
#
# $Id: post.install.sh,v 1.10 2012/07/11 19:28:50 drobilla Exp drobilla $
#
# Post CentOS & RedHat Kickstart configuration script.
# Called from the %post kickstart file.
#
# David Robillard, April 17th, 2012.

umask 022

PATH="/bin:/usr/bin:/usr/local/bin:/sbin:/usr/sbin:/usr/local/sbin"
export PATH

ARCH=`uname -i`

AUTOFS_LDAP_AUTH_CONF="/etc/autofs_ldap_auth.conf"

BACKUP_GID="5008"

BACKUP_PASSWD='$6$6EJsssss$lBfQqjGrst6cx4rj8du3M5UvFzOTwiSAPnS//UwdhX4cGiWFz1y5/GKLys03qdIrYhPdsFymVSGYHfE9qYJ/3.'

BOS_CA_CERT="/etc/pki/tls/certs/rootca.crt"

DNS1="192.168.1.24"

DNS2="192.168.1.53"

DOMAIN="company.com"

EMAIL_LIST="kickstart@company.com"

FQDN=`hostname`

HOSTS="/etc/hosts"

IDMAPD_CONF="/etc/idmapd.conf"

JAVA_MAN_MAN1_DIR="/usr/local/share/man/man1"

KDUMP_CONF="/etc/kdump.conf"

KRB5_CONF="/etc/krb5.conf"

LOGFILE="/root/kickstart.post.log"

LOGROTATE_NTPD="/etc/logrotate.d/ntpd"

LOGROTATE_SUDO="/etc/logrotate.d/sudo"

NSLCD_CONF="/etc/nslcd.conf"

NSSWITCH_CONF="/etc/nsswitch.conf"

NTP_CONF="/etc/ntp.conf"

OPENLDAP_LDAP_CONF="/etc/openldap/ldap.conf"

OS_RELEASE="6"

PAM_LDAP_CONF="/etc/pam_ldap.conf"

PAM_SSHD="/etc/pam.d/sshd"

PAM_SYSTEM_AUTH="/etc/pam.d/system-auth-ac"

PANIC_PASSWD='$6$r3Qiyr.sssso8AVIT.jWxM/cHu/aOiGpGh8I0DxT2RkVSNBDJ0ozM5obOQKLDPJ66dznRNdVaDlY.edbaAiKBLJBapptrK0'

PANIC_UID="5009"

PANIC_GID="${BACKUP_GID}"

RESOLV_CONF="/etc/resolv.conf"

# RH_USERNAME="drobilla@company.com"

# RH_PASSWD="ChangeMe"

ROOT_ALIASES="/root/.aliases"

ROOT_BASH_PROFILE="/root/.bash_profile"

RSSH="/usr/bin/rssh"

RSYSLOG_CONF="/etc/rsyslog.conf"

SELINUX_CONFIG="/etc/selinux/config"

SENDMAIL_MC="/etc/mail/sendmail.mc"

SHELLS="/etc/shells"

SKEL_ALIASES="/etc/skel/.aliases"

SKEL_BASH_PROFILE="/etc/skel/.bash_profile"

SKEL_BASHRC="/etc/skel/.bashrc"

SNMPD_CONF="/etc/snmp/snmpd.conf"

SSHD_CONFIG="/etc/ssh/sshd_config"

SUBMIT_MC="/etc/mail/submit.mc"

SUDO_LDAP_CONF="/etc/sudo-ldap.conf"

SUDOERS="/etc/sudoers"

SYSCONFIG_AUTOFS="/etc/sysconfig/autofs"

SYSCONFIG_NTPD="/etc/sysconfig/ntpd"

SYSCTL_CONF="/etc/sysctl.conf"

URL_LINUX_INSTALL="http://kickstart.company.com/"

OS_NAME="centos"

grep -i centos /etc/redhat-release 2>&1 >/dev/null

if [ "$?" -eq "0" ]; then
        OS_NAME="centos"
else
        OS_NAME="redhat"
fi

URL_LINUX_RPMS="${URL_LINUX_INSTALL}/repository/${OS_NAME}/${OS_RELEASE}/${ARCH}"

printf "##\n# Starting post-install configuration of `hostname` on `date`.\n##\n\n" >> ${LOGFILE}

##
# Configure DNS resolver.
##

echo -n "Configuring ${RESOLV_CONF}..." >> ${LOGFILE}

cp ${RESOLV_CONF} ${RESOLV_CONF}.kickstart >/dev/null 2>&1

printf "# ${RESOLV_CONF}\n#\n# DNS resolver configuration.\n#\n# David Robillard, May 16th, 2012.\n\n" > ${RESOLV_CONF}
printf "domain ${DOMAIN}\nsearch ${DOMAIN}\nnameserver ${DNS1}\nnameserver ${DNS2}\n\n# EOF\n" >> ${RESOLV_CONF}

echo " done." >> ${LOGFILE}

##
# Install a default /etc/hosts file.
##

echo -n "Installing ${HOSTS}..." >> ${LOGFILE}

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${HOSTS} -O ${HOSTS}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${HOSTS}." | tee -a ${LOGFILE}
fi

echo " done." >> ${LOGFILE}

##
# Disable a few services.
##

echo -n "Disabling several services: " >> ${LOGFILE}

echo -n "auditd " >> ${LOGFILE}
chkconfig auditd off >/dev/null 2>&1

echo -n "iptables " >> ${LOGFILE}
chkconfig iptables off >/dev/null 2>&1

echo -n "ip6tables " >> ${LOGFILE}
chkconfig ip6tables off >/dev/null 2>&1

echo -n "matahari-* " >> ${LOGFILE}
for MATAHARI in matahari-broker matahari-host matahari-network matahari-service matahari-sysconfig; do
        chkconfig ${MATAHARI} off >/dev/null 2>&1
done

echo -n "netconsole " >> ${LOGFILE}
chkconfig netconsole off >/dev/null 2>&1

echo -n "ntpdate " >> ${LOGFILE}
chkconfig ntpdate off >/dev/null 2>&1

echo -n "qpidd " >> ${LOGFILE}
chkconfig qpidd off >/dev/null 2>&1

echo -n "rdisc " >> ${LOGFILE}
chkconfig rdisc off >/dev/null 2>&1

echo -n "restorecond " >> ${LOGFILE}
chkconfig restorecond off >/dev/null 2>&1

echo -n "saslauthd " >> ${LOGFILE}
chkconfig saslauthd off >/dev/null 2>&1

echo "done." >> ${LOGFILE}

##
# Configure /etc/skel files.
##

echo -n "Configuring /etc/skel files..." >> ${LOGFILE}

echo -n " .bash_profile" >> ${LOGFILE}

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SKEL_BASH_PROFILE} -O ${SKEL_BASH_PROFILE}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${SKEL_BASH_PROFILE}." | tee -a ${LOGFILE}
fi

echo -n " .aliases" >> ${LOGFILE}

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SKEL_ALIASES} -O ${SKEL_ALIASES}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${SKEL_ALIASES}." | tee -a ${LOGFILE}
fi

echo -n " .bashrc" >> ${LOGFILE}

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SKEL_BASHRC} -O ${SKEL_BASHRC}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${SKEL_BASHRC}." | tee -a ${LOGFILE}
fi

echo -n " .bash_logout" >> ${LOGFILE}

touch /etc/skel/.bash_logout

echo " done." >> ${LOGFILE}

##
# Configure root's environment.
##

echo -n "Configuring environment for root..." >> ${LOGFILE}

echo -n " .ssh" >> ${LOGFILE}

mkdir /root/.ssh >/dev/null 2>&1

echo -n " .bash_profile" >> ${LOGFILE}

cp /root/.bash_profile /root/.bash_profile.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${ROOT_BASH_PROFILE} -O ${ROOT_BASH_PROFILE}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${ROOT_BASH_PROFILE}." | tee -a ${LOGFILE}
fi

echo -n " .aliases" >> ${LOGFILE}

cp /root/.aliases /root/.aliases.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${ROOT_ALIASES} -O ${ROOT_ALIASES}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${ROOT_ALIASES}." | tee -a ${LOGFILE}
fi

echo " done." >> ${LOGFILE}

##
# Install rssh and /usr/bin/rssh into /etc/shells.
##

echo -n 'Configuring rssh(1): rpm upgrade' >> ${LOGFILE}

rpm -U --force ${URL_LINUX_RPMS}/rssh.rpm >/dev/null 2>&1

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${URL_LINUX_RPMS}/rssh.rpm" | tee -a ${LOGFILE}
fi

grep -w ${RSSH} ${SHELLS} >/dev/null 2>&1

if [ "$?" -ne "0" ]; then

        echo -n " ${SHELLS}." >> ${LOGFILE}

        echo ${RSSH} >> ${SHELLS}
else
        echo "${SHELLS} already contains ${RSSH}." >> ${LOGFILE}
fi

echo " done." >> ${LOGFILE}

##
# Create the backup user and group.
##

echo -n "Creating the backup group..." >> ${LOGFILE}

groupadd -g ${BACKUP_GID} backup >/dev/null 2>&1

if [ "$?" -ne "0" ]; then

        echo "ERROR : problem creating the backup group." | tee -a ${LOGFILE}
else
        echo " done." >> ${LOGFILE}
fi

echo -n "Creating the backup user..." >> ${LOGFILE}

useradd -c "Remote Backup User" -d /home/backup -o -u 0 -g ${BACKUP_GID} -m -s /usr/bin/rssh -p "${BACKUP_PASSWD}" backup

echo " done." >> ${LOGFILE}

##
# Create the panic user. This user has the backup group created above.
##

echo -n "Creating the panic user..." >> ${LOGFILE}

useradd -c "Panic User" -d /home/panic -u ${PANIC_UID} -g ${PANIC_GID} -G root,wheel -m -s /bin/bash -p "${PANIC_PASSWD}"  panic

echo " done." >> ${LOGFILE}

##
# Setup /etc/banner and /etc/issue.
##

echo -n "Configuring /etc/banner " >> ${LOGFILE}

echo "Restricted Access." > /etc/banner

echo -n "and /etc/issue" >> ${LOGFILE}

cp /etc/banner /etc/issue

echo " done." >> ${LOGFILE}

##
# Configure SSH server.
##

echo -n "Configuring /etc/ssh/sshd_config..." >> ${LOGFILE}

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SSHD_CONFIG} -O ${SSHD_CONFIG}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${SSHD_CONFIG}." | tee -a ${LOGFILE}
else
        chkconfig sshd on
fi

echo " done." >> ${LOGFILE}

##
# Configure NTP.
##

echo -n "Configuring NTP..." >> ${LOGFILE}

echo -n " /etc/ntp.conf" >> ${LOGFILE}

cp /etc/ntp.conf /etc/ntp.conf.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${NTP_CONF} -O ${NTP_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${NTP_CONF}." | tee -a ${LOGFILE}
fi

echo -n " /etc/sysconfig/ntpd" >> ${LOGFILE}

cp /etc/sysconfig/ntpd /etc/sysconfig/ntpd.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SYSCONFIG_NTPD} -O ${SYSCONFIG_NTPD}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${SYSCONFIG_NTPD}." | tee -a ${LOGFILE}
fi

echo -n " /var/log/ntpd.log" >> ${LOGFILE}

touch /var/log/ntpd.log

echo -n " /etc/logrotate.d/ntpd" >> ${LOGFILE}

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${LOGROTATE_NTPD} -O ${LOGROTATE_NTPD}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${LOGROTATE_NTPD}." | tee -a ${LOGFILE}
fi

chkconfig ntpd on

echo " done." >> ${LOGFILE}

##
# Configure /etc/rsyslog.conf
##

echo -n "Configuring /etc/rsyslog.conf..." >> ${LOGFILE}

cp /etc/rsyslog.conf /etc/rsyslog.conf.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${RSYSLOG_CONF} -O ${RSYSLOG_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${RSYSLOG_CONF}." | tee -a ${LOGFILE}
fi

mkdir -p /var/spool/rsyslog

chkconfig rsyslog on

echo " done." >> ${LOGFILE}

##
# Configure Kerberos.
##

echo -n "Configuring Kerberos..." >> ${LOGFILE}

mv ${KRB5_CONF} ${KRB5_CONF}.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${KRB5_CONF} -O ${KRB5_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${URL_LINUX_INSTALL}${KRB5_CONF}" | tee -a ${LOGFILE}
fi

echo " done." >> ${LOGFILE}

##
# Configure autofs(8).
##

echo -n "Configuring autofs(8)" >> ${LOGFILE}

echo -n " /etc/autofs_ldap_auth.conf" >> ${LOGFILE}

mv /etc/auto.master /etc/auto.master.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${AUTOFS_LDAP_AUTH_CONF} -O ${AUTOFS_LDAP_AUTH_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${AUTOFS_LDAP_AUTH_CONF}." | tee -a ${LOGFILE}
else
        sed -i.kickstart -e "s/changeme/${FQDN}/g" ${AUTOFS_LDAP_AUTH_CONF}

        chmod 600 ${AUTOFS_LDAP_AUTH_CONF} ${AUTOFS_LDAP_AUTH_CONF}.kickstart
fi

echo -n " ${SYSCONFIG_AUTOFS}" >> ${LOGFILE}

mv ${SYSCONFIG_AUTOFS} ${SYSCONFIG_AUTOFS}.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SYSCONFIG_AUTOFS} -O ${SYSCONFIG_AUTOFS}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${SYSCONFIG_AUTOFS}." | tee -a ${LOGFILE}
fi

chkconfig autofs on
chkconfig nfslock on

echo " done." >> ${LOGFILE}

##
# Configure rpc.idmapd(8).
##

echo -n 'Configure rpc.idmapd(8)...' >> ${LOGFILE}

cp /etc/idmapd.conf /etc/idmapd.conf.kickstart

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${IDMAPD_CONF} -O ${IDMAPD_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${IDMAPD_CONF}." | tee -a ${LOGFILE}
fi

chkconfig rpcidmapd on

echo " done." >> ${LOGFILE}

##
# Enable various NFS client daemons.
##

echo -n 'Enabling rpc.gssd(8) and rpcbind(8) daemons...' >> ${LOGFILE}

chkconfig rpcgssd on
chkconfig rpcbind on

echo " done." >> ${LOGFILE}

##
# Configure OpenLDAP client.
##

echo -n "Configuring OpenLDAP client..." >> ${LOGFILE}

echo -n " /etc/openldap/ldap.conf" >> ${LOGFILE}

cp /etc/openldap/ldap.conf /etc/openldap/ldap.conf.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${OPENLDAP_LDAP_CONF} -O ${OPENLDAP_LDAP_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${OPENLDAP_LDAP_CONF}." | tee -a ${LOGFILE}
fi

echo -n " /etc/nslcd.conf" >> ${LOGFILE}

cp /etc/nslcd.conf /etc/nslcd.conf.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${NSLCD_CONF} -O ${NSLCD_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not fetch ${NSLCD_CONF}." | tee -a ${LOGFILE}
fi

chmod 600 ${NSLCD_CONF}

echo -n " ${BOS_CA_CERT}" >> ${LOGFILE}

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${BOS_CA_CERT} -O ${BOS_CA_CERT}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${BOS_CA_CERT}." | tee -a ${LOGFILE}
fi

chkconfig nslcd on

echo " done." >> ${LOGFILE}

##
# Configure pam_ldap authentication.
##

echo -n "Configuring pam_ldap and pam_krb5 authentication..." >> ${LOGFILE}

echo -n " ${PAM_SYSTEM_AUTH}" >> ${LOGFILE}

cp /etc/pam.d/system-auth-ac /etc/pam.d/system-auth-ac.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${PAM_SYSTEM_AUTH} -O ${PAM_SYSTEM_AUTH}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${PAM_SYSTEM_AUTH}." | tee -a ${LOGFILE}
fi

echo -n " ${PAM_SSHD}" >> ${LOGFILE}

cp /etc/pam.d/sshd /etc/pam.d/sshd.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${PAM_SSHD} -O ${PAM_SSHD}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${PAM_SSHD}." | tee -a ${LOGFILE}
fi

echo -n " ${PAM_LDAP_CONF}" >> ${LOGFILE}

cp /etc/pam_ldap.conf /etc/pam_ldap.conf.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${PAM_LDAP_CONF} -O ${PAM_LDAP_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${PAM_LDAP_CONF}." | tee -a ${LOGFILE}
fi

echo " done." >> ${LOGFILE}

##
# Configure /etc/nsswitch.conf.
##

echo -n "Configuring /etc/nsswitch.conf..." >> ${LOGFILE}

cp /etc/nsswitch.conf /etc/nsswitch.conf.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${NSSWITCH_CONF} -O ${NSSWITCH_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${NSSWITCH_CONF}." | tee -a ${LOGFILE}
fi

echo " done." >> ${LOGFILE}

##
# Configure sudo(8).
##

# Not required as of CentOS 6.4.
#
# echo -n 'Configuring sudo(8): rpm upgrade' >> ${LOGFILE}
#
# rpm -U --force ${URL_LINUX_RPMS}/sudo.rpm >/dev/null 2>&1
#
# if [ "$?" -ne "0" ]; then
#       echo "ERROR : could not install ${URL_LINUX_RPMS}/sudo.rpm" | tee -a ${LOGFILE}
# fi

echo -n " /etc/sudoers" >> ${LOGFILE}

cp /etc/sudoers /etc/sudoers.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SUDOERS} -O ${SUDOERS}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${SUDOERS}." | tee -a ${LOGFILE}
fi

chown root:root ${SUDOERS}
chmod 440 ${SUDOERS}

echo -n " /var/log/sudo.log" >> ${LOGFILE}

touch /var/log/sudo.log

echo -n " /etc/logrotate.d/sudo" >> ${LOGFILE}

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${LOGROTATE_SUDO} -O ${LOGROTATE_SUDO}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${LOGROTATE_SUDO}." | tee -a ${LOGFILE}
fi

echo -n " /etc/sudo-ldap.conf" >> ${LOGFILE}

cp ${SUDO_LDAP_CONF} ${SUDO_LDAP_CONF}.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SUDO_LDAP_CONF} -O ${SUDO_LDAP_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${SUDO_LDAP_CONF}." | tee -a ${LOGFILE}
fi

echo " done." >> ${LOGFILE}

##
# Configure sendmail(8).
##

echo -n 'Configuring sendmail(8)...' >> ${LOGFILE}

rpm -e postfix >/dev/null 2>&1

echo -n " sendmail.mc" >> ${LOGFILE}

cp ${SENDMAIL_MC} ${SENDMAIL_MC}.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SENDMAIL_MC} -O ${SENDMAIL_MC}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${SENDMAIL_MC}." | tee -a ${LOGFILE}
fi

echo -n " submit.mc" >> ${LOGFILE}

cp ${SUBMIT_MC} ${SUBMIT_MC}.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SUBMIT_MC} -O ${SUBMIT_MC}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${SUBMIT_MC}." | tee -a ${LOGFILE}
fi

make -C /etc/mail >/dev/null 2>&1

chkconfig sendmail on

echo " done." >> ${LOGFILE}

##
# Disable SELinux.
##

echo -n "Disabling SELinux..." >> ${LOGFILE}

cp /etc/selinux/config /etc/selinux/config.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SELINUX_CONFIG} -O ${SELINUX_CONFIG}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${SELINUX_CONFIG}." | tee -a ${LOGFILE}
fi

echo " done." >> ${LOGFILE}

##
# Disable IPv6.
##

echo -n "Disabling IPv6..." >> ${LOGFILE}

cp ${SYSCTL_CONF} ${SYSCTL_CONF}.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SYSCTL_CONF} -O ${SYSCTL_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${SYSCTL_CONF}." | tee -a ${LOGFILE}
fi

echo " done" >> ${LOGFILE}

##
# Configure snmpd(8).
##

echo -n 'Configuring snmpd(8)...' >> ${LOGFILE}

cp ${SNMPD_CONF} ${SNMPD_CONF}.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${SNMPD_CONF} -O ${SNMPD_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${SNMPD_CONF}." | tee -a ${LOGFILE}
fi

chkconfig snmpd on

echo " done." >> ${LOGFILE}

##
# Install Java.
##

echo -n "Installing Java JRE..." >> ${LOGFILE}

rpm -U --force ${URL_LINUX_RPMS}/jre.rpm >/dev/null 2>&1

if [ "$?" -ne "0" ]; then

        echo "ERROR : could not install ${URL_LINUX_RPMS}/jre.rpm" | tee -a ${LOGFILE}

else
        chkconfig jexec off >/dev/null 2>&1

        JAVA_MAN_DIR=`rpm -ql jre | egrep man1 | grep -v JP | head -1`

        if [ "x${JAVA_MAN_DIR}" = "x" ]; then

                printf "\nERROR : could not find the Java man/man1 directory." | tee -a ${LOGFILE}
                echo "ERROR : please create the man symbolic links manually." | tee -a ${LOGFILE}

        else
                find ${JAVA_MAN_DIR} -type f | while read LINE; do ln -s ${LINE} ${JAVA_MAN_MAN1_DIR} >/dev/null 2>&1; done
        fi
fi

echo " done." >> ${LOGFILE}

##
# Configure serial console.
##

echo -n "Configuring serial console..." >> ${LOGFILE}

cp /boot/grub/grub.conf /boot/grub/grub.conf.kickstart

# First, edit /boot/grub/grub.conf to enable the serial console.

cat <<-EOF > /root/grub.conf.header
# /boot/grub/grub.conf
#
# Grub configuration file. See grub(8).
#
# David Robillard, April 20th, 2012.

serial -unit=1 --speed=9600
terminal --timeout=8 console serial
EOF

egrep -v '^#' /boot/grub/grub.conf | sed -e "/^splash/d" | sed "/kernel/s/$/ console=tty console=ttyS0,9660n8/" > /root/grub.conf.footer

cat /root/grub.conf.header /root/grub.conf.footer > /boot/grub/grub.conf

printf "\n# EOF\n" >> /boot/grub/grub.conf

rm /root/grub.conf.header /root/grub.conf.footer

# Then, add ttyS0 to /etc/securetty.

echo ttyS0 >> /etc/securetty

echo " done." >> ${LOGFILE}

##
# Create several RCS directories.
##

mkdir -p /etc/RCS /etc/sysconfig/RCS /etc/sysconfig/network-scripts/RCS /etc/ssh/RCS /etc/snmp/RCS

##
# Configure a remote kdump directory.
##

echo -n "Configuring kernel crash dump..." >> ${LOGFILE}

echo -n " ${KDUMP_CONF}" >> ${LOGFILE}

cp ${KDUMP_CONF} ${KDUMP_CONF}.kickstart >/dev/null 2>&1

wget -q4a ${LOGFILE} ${URL_LINUX_INSTALL}${KDUMP_CONF} -O ${KDUMP_CONF}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not install ${KDUMP_CONF}." | tee -a ${LOGFILE}
fi

chkconfig kdump on

echo " done." >> ${LOGFILE}

##
# Update OS.
##

echo "Updating OS : " >> ${LOGFILE}

grep ^Red /etc/redhat-release >/dev/null 2>&1

# if [ "$?" -eq "0" ]; then     # This is a Red Hat machine, not a CentOS machine.
#
#       echo -n "RedHat " >> ${LOGFILE}
#
#       subscription-manager list >/dev/null 2>&1
#
#       if [ "$?" -eq "1" ]; then
#               subscription-manager register --username=${RH_USERNAME} --password=${RH_PASSWD}
#               subscription-manager subscribe --auto
#       fi
# else
#       echo -n "CentOS " >> ${LOGFILE}
# fi

echo -n "CentOS " >> ${LOGFILE}

yum -y -q update >/dev/null 2>&1

echo "done." >> ${LOGFILE}

# EOF
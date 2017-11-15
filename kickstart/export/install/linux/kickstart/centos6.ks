# /export/install/linux/kickstart/centos6.ks
#
# $Id: centos6.ks,v 1.2 2012/08/20 15:11:03 drobilla Exp $
#
# KickStart profile for CentOS 6.x
# See http://docs.redhat.com/docs/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/s1-kickstart2-options.html
#
# Note that we don't need to specify which network interface to
# use because the server has already fetched his kernel via PXE.
#
# David Robillard, April 12th, 2012.

# IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT #

# Change the network line for each and every client machine. It HAS to be unique!
# Configure the network interface. This HAS to be on a single line.

network --bootproto=static --ip=192.168.1.2 --netmask=255.255.255.0 --gateway=192.168.1.1 --nameserver 192.168.1.24,192.168.1.53 --hostname=oxygen.company.com

# IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT IMPORTANT #

# Specify that this is not an upgrade, but a fresh install.
install

# Use text installation as that's what I prefer.
text

# Do not configure the X server.
skipx

# Use UTF8 english as the installation language.
lang en_US.UTF-8

# Use the US keyboard as the installation keyboard map.
keyboard us

# Disable the firewall.
firewall --disabled

# Disable SELinux.
selinux --disabled

# Set our timezone to America, Montreal.
timezone America/Montreal

# Use HTTP as the installation protocol to fetch the installation media.
url --url http://kickstart.company.com/centos/6/x86_64

# Send installation logs to both a local file and the central syslog server.
logging --host=syslog.company.com --level=debug

# Enable shadow passwords with the SHA512 digest.
authconfig --enableshadow --passalgo=sha512 --kickstart

# Set the SHA512 encrypted root password.
rootpw --iscrypted $6$jyLPzasdasdasdaddepflQnn.SgV5jF1Eq54OD0TXFNYD51aExn1jMtn4kdQ50CoefR1mw.eID6tPQm.kVnqy9B6eo3Tzk2pJ1

# Remove any data in the master boot record.
zerombr

# Specify the location of the boot loader.
bootloader --location=mbr

# Remove all partitions on all the disk drives and initialize the disk label.
clearpart --all --initlabel

# Ignore the sdb disks as these are not OS disks.
# ignoredisk --drives=sdb

# OS disk /dev/md127 partitioning.
partition /boot --ondisk=md127 --label=/boot --fstype ext4 --size 512
partition pv.01 --ondisk=md127 --size 1 --grow
volgroup os pv.01
logvol /    --vgname=os --size 20480      --name=root --fstype ext4
logvol swap --vgname=os --size 66591      --name=swap --fstype swap
logvol /tmp --vgname=os --size 4096       --name=tmp  --fstype ext4
logvol /var --vgname=os --size 2048       --name=var  --fstype ext4
logvol /var/lib/mysql --vgname=os --size 20480    --name=sql  --fstype ext4
logvol /opt --vgname=os --size 1 --grow --name=opt  --fstype ext4

# This is only for VMware ESX.
#vmaccepteula

# Reboot at the end of the installation (or not :)
reboot

##
# List which packages to install?
# Refer to the /export/install/linux/centos/6/x86_64/repodata/*comps-*.xml file for a list of package groups.
##

%packages --nobase

@ Server Platform

# List of packages that we do NOT want installed.

-abrt*
-alsa-*
-atk
-avahi*
-b43-fwcutter
-cairo
-cdparanoia*
-cvs
-cups
-cyrus-sasl-plain
-dbus
-dhclient
-acpid
-blktrace
-bridge-utils
-cpuspeed
-cryptsetup-luks
-dmraid
-dosfstools
-ed
-efibootmgr
-foomatic*
-fprintd-pam
-gettext
-ghostscript*
-gnutls
-gstreamer*
-gtk2
-hicolor-icon-theme
-hunspell*
-iptables
-iptables-ipv6
-irqbalance
-iso-codes
-jasper-libs
-lcms-libs
-libmng
-libfontenc
-libXfont
-libjpeg
-libtiff
-libogg
-libtheora
-libvorbis
-liboil
-libpng
-libtasn1
-libthai
-libvisual
-libX*
-man-pages-overrides
-mesa-*
-microcode_ctl
-mlocate
-mtr
-mysql*
-nano
-openjpeg-libs
-pam_passwdqc
-pango
-pax
-pcmciautils
-perl-CGI
-perl-devel
-perl-ExtUtils-*
-perl-Test-*
-phonon-backend-gstreamer
-pinfo
-pixman
-plymouth
-pm-utils
-poppler*
-portreserve
-postfix
-prelink
-qt*
-rdate
-readahead
-redhat-lsb*
-rfkill
-rng-tools
-rsyslog-gnutls
-setuptool
-sos
-system-config-*
-systemtap-runtime
-tcpdump
-tcsh
-time
-tmpwatch
-urw-fonts
-usbutils
-vconfig
-wireless-tools
-xorg-x11-font-utils
-xorg-x11-drv-ati-firmware
-xml-common
-yum-plugin-security
-yum-utils

# List of packages that we want installed.
# This list already includes the packages required by Oracle.

aide
autofs
biosdevname
bzip2
compat-gcc-34
compat-gcc-34-c++
compat-libstdc++-296
compat-libstdc++-33
compat-libcap1
cyrus-sasl-gssapi
dialog
dmidecode
device-mapper
device-mapper-multipath
binutils
bind-utils
eject
elinks
ethtool
expat
file
finger
ftp
gcc
gcc-c++
glibc-devel
glibc-headers
gnupg2
iotop
kexec-tools
krb5-libs
krb5-workstation
ksh
libaio
libaio-devel
lsscsi
lvm2
mailx
make
man
man-pages
mdadm
net-snmp
net-snmp-devel
net-snmp-perl
net-snmp-utils
nfs4-acl-tools
nfs-utils
nfs-utils-lib
nscd
nss-pam-ldapd
ntp
ntpdate
openldap-clients
openssh-clients
pam_krb5
pam_ldap
parted
perl
python-dmidecode
rcs
rsync
rsyslog-gssapi
screen
sendmail
sendmail-cf
smartmontools
strace
sysstat
telnet
traceroute
tuned
unzip
vim-enhanced
wget
which
words
xorg-x11-xauth
xterm
xz
zip

##
# Pre-installation section.
##

# %pre
#
# #!/bin/sh
#
# PATH="/bin:/usr/bin:/sbin:/usr/sbin"
# export PATH
#
# echo "Welcome to Company :)"

##
# Post-installation section.
##

%post --log /root/kickstart.post.log --interpreter /bin/sh

PATH="/bin:/usr/bin:/sbin:/usr/sbin"
export PATH

KICKSTART_URL="http://kickstart.company.com/kickstart"
export KICKSTART_URL

POST_INSTALL_SCRIPT="post.install.sh"
export POST_INSTALL_SCRIPT

echo "Starting Kickstart post installation on `date`."

which wget >/dev/null 2>&1

if [ "$?" -ne "0" ]; then
        echo "ERROR : wget is not installed."
        echo "ERROR : the ${POST_INSTALL_SCRIPT} script will not run."
        exit 1
fi

echo "Downloading the post installation script..."

wget -q4 ${KICKSTART_URL}/${POST_INSTALL_SCRIPT} -O /root/${POST_INSTALL_SCRIPT}

if [ "$?" -ne "0" ]; then
        echo "ERROR : could not get ${POST_INSTALL_SCRIPT}."
        echo "ERROR : the ${POST_INSTALL_SCRIPT} script will not run."

        rm /root/${POST_INSTALL_SCRIPT} 2>&1 >/dev/null

        exit 1
fi

echo "Now running ${POST_INSTALL_SCRIPT}..."

sh /root/${POST_INSTALL_SCRIPT}

# EOF
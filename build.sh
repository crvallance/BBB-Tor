#!/bin/bash
#
# Licensed GPLv3
#
# Based on the debian image from here:
#  http://elinux.org/BeagleBoardDebian#BeagleBone.2FBeagleBone_Black
# Use the flasher from Robert (Linux) or win32 disk imager 
#  http://elinux.org/Beagleboard:Win32_Disk_Imager
#
# PORTAL of BONE configuration overview
#  
# ((Host))----[usb0]<[BBB]>[eth0]---((Internet))
#   usb0: 192.168.7.2
#        * anything from here can only reach 9040 (Tor proxy) or,
#        * the transparent Tor proxy 
#    eth0: DHCP
#        * Internet access. You're on your own
#
# STEP 1 !!! 
#   configure Internet access, we'll neet to install some basic tools.
#   (This should work out of the box on eth0)
#
# setup some loging stuff first so we can see when things go *boom*
# source: http://www.xensoft.com/content/use-exec-direct-all-bash-script-output-file-syslog-or-other-command
# location of named pipe
named_pipe=/tmp/$$.tmp
# 
# remove pipe on the exit signal
trap "rm -f $named_pipe" EXIT
# 
# create named pipe
mknod $named_pipe p
# 
# start logger process in background with stdin coming from named pipe
# also tell logger to append the script name to the syslog messages
# so we know where they came from
logger <$named_pipe -t [BBB-TOR] &
# 
# or maybe you wanted a log file and output to STDOUT
tee <$named_pipe /tmp/outfile &
# 
# redirect stderr and stdout to named_pipe
exec 1>$named_pipe 2>&1
# 
echo STDOUT captured
echo STDERR captured >&2
#
# set variables (mosburn made me do this)
HOSTIP="192.168.7.2"
# update debian
apt-get -y update && apt-get -y upgrade
#
# install ntp
apt-get -y install ntp
#
# remove default debian user and add new one
deluser --remove-home debian
adduser --disabled-password --gecos "" toruser
usermod -a -G admin toruser
# set password for toruser to "dummypass"
usermod -p '$6$m6GEKlNk$XndSWbqB299kqSFFGnPz6FxN8uawPKowMPBYdqYXjMtUxlUWJglrTX.MO3rQ6Z38sow606ZaNIhwao.SaYSnT1' toruser
# force user to change password upon login
chage -d 0 toruser
#
#remove and regen your ssh keys (can't be too careful these days)
sh -c "/bin/rm /etc/ssh/ssh_host_*"
dpkg-reconfigure openssh-server
#
#allow ipv4 forwarding (routing)
sed -i "/#net.ipv4.ip_forward=1/ s/# *//" /etc/sysctl.conf
# updatse sysctl with our new value so it persists
sysctl -p /etc/sysctl.conf
#
# add the router option in to udhcpd config so host machine knows it's gateway and dns
cat >> /etc/udhcpd.conf << __UDHCPD__
opt router $HOSTIP
option dns $HOSTIP
__UDHCPD__
#
# Let's get the repo setup for tor and install from latest
echo "deb     http://deb.torproject.org/torproject.org `lsb_release -cs` main" | sudo tee -a /etc/apt/sources.list
gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
apt-get -y update
apt-get -y install deb.torproject.org-keyring && apt-get -y install tor
#
# Let's puke out the config for tor and create the log file
cat >> /etc/tor/torrc << __TORRC__
AllowUnverifiedNodes middle,rendezvous
Log notice file /var/log/tor/notices.log
VirtualAddrNetwork 10.192.0.0/10
AutomapHostsSuffixes .onion,.exit
AutomapHostsOnResolve 1
TransPort 9040
TransListenAddress $HOSTIP
DNSPort 9053
DNSListenAddress $HOSTIP
__TORRC__
#
touch /var/log/tor/notices.log
chown debian-tor /var/log/tor/notices.log
chmod 644 /var/log/tor/notices.log
#
# Flush iptables
iptables -F
iptables -t nat -F
#
#  Setup iptables, and create some log files
#    Allow ssh and redirect others
#
iptables -t nat -A PREROUTING -i usb0 -p tcp --dport 22 -j REDIRECT --to-ports 22
iptables -t nat -A PREROUTING -i usb0 -p udp --dport 53 -j REDIRECT --to-ports 9053
iptables -t nat -A PREROUTING -i usb0 -p tcp --syn -j REDIRECT --to-ports 9040
#
iptables-save > /etc/iptables.up.rules
cat >> /etc/network/if-pre-up.d/iptables << __IPTABLES__
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.up.rules
__IPTABLES__
chmod +x /etc/network/if-pre-up.d/iptables
#
# Flush iptables again just so things don't get funky
iptables -F
iptables -t nat -F
#
#  Make sure tor service starts up 
#
update-rc.d tor defaults 
# Make sure that ntp is up and kicking before the tor service starts
# I had problems getting tor to come correctly w/o this 
# Manual service restart would work but that's not really the idea here...
sed -i '/^# Required-St/ s/$/ ntp/' /etc/init.d/tor
#
# set the time to UTC
rm /etc/localtime
ln -s /usr/share/zoneinfo/UTC /etc/localtime
#
# set hostname 
echo "B0N3D" > /etc/hostname
#
# move the messy log file in to your new home dir for review
# this is something of a disaster at the moment, sorry
chown toruser:toruser /tmp/outfile
mv /tmp/outfile /home/toruser/BBB-TOR-install.$$
#
# reboot to start using the BBB as a tor middler
#shutdown -r now


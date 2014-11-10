#!/bin/bash
#
#<UDF name="hostname" label="Hostname">
#<UDF name="fqdn" label="Fully qualified domain name">
#<UDF name="admin_username" label="Username for sys admin">
#<UDF name="admin_password" label="Password for sys admin">

set -e

# redirect stdout and stderr to a log file
exec >/var/log/stackscript.log 2>&1

IPV4ADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }')
IPV6ADDR=$(/sbin/ifconfig eth0 | awk '/inet6.*global/ { print $2 }')

hostnamectl set-hostname $HOSTNAME
echo $IPV4ADDR $FQDN $HOSTNAME >> /etc/hosts
echo $IPV6ADDR $FQDN $HOSTNAME >> /etc/hosts

# set the timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

yum update -y

# we need git for cloning repos
yum install -y git

useradd -G wheel $ADMIN_USERNAME
echo $ADMIN_PASSWORD | passwd --stdin lightster

# disable the ability to SSH in as root
sed -i 's@^[\s#]*PermitRootLogin\s*\(no\|yes\|without-password\)*\s*$@PermitRootLogin no@g' /etc/ssh/sshd_config
systemctl restart sshd

RETURN_DIR=$(pwd)
cd /home/$ADMIN_USERNAME
git clone https://github.com/lightster/.ssh.git .ssh 
cd .ssh
bin/sshk-update
chown -R $ADMIN_USERNAME:$ADMIN_USERNAME .
cd $RETURN_DIR
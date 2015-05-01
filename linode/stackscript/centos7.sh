#!/bin/bash
#
#<UDF name="keeper_password" label="Password for keeper">

# prevent the script from running multiple times
# (a workaround for Linode StackScript bug with CentOS 7 image)
[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :

set -e

KEEPER_USERNAME="boxkeeper"
KEEPER_HOMEDIR="/home/$KEEPER_USERNAME"
KEEPER_SSHDIR="$KEEPER_HOMEDIR/.ssh"
KEEPER_KEYS="$KEEPER_SSHDIR/authorized_keys"

# redirect stdout and stderr to a log file
exec >>/var/log/stackscript.log 2>&1

yum update -y

# we need git for cloning repos
yum install -y git

useradd -G wheel $KEEPER_USERNAME
echo "$KEEPER_USERNAME:$KEEPER_PASSWORD" | chpasswd

# install .ssh repo
RETURN_DIR=$(pwd)
cd /home/$ADMIN_USERNAME
git clone https://github.com/lightster/.ssh.git .ssh 
cd .ssh
bin/sshk-update
chown -R $ADMIN_USERNAME:$ADMIN_USERNAME .
git remote set-url origin git@github.com:lightster/.ssh.git
cd $RETURN_DIR

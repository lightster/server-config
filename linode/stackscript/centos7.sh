#!/bin/bash
#
#<UDF name="admin_username" label="Username for sys admin">
#<UDF name="admin_password" label="Password for sys admin">

# prevent the script from running multiple times
# (a workaround for Linode StackScript bug with CentOS 7 image)
[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :

set -e

# redirect stdout and stderr to a log file
exec >>/var/log/stackscript.log 2>&1

yum update -y

# we need git for cloning repos
yum install -y git

useradd -G wheel $ADMIN_USERNAME
echo $ADMIN_PASSWORD | passwd --stdin $ADMIN_USERNAME

# install .ssh repo
RETURN_DIR=$(pwd)
cd /home/$ADMIN_USERNAME
git clone https://github.com/lightster/.ssh.git .ssh 
cd .ssh
bin/sshk-update
chown -R $ADMIN_USERNAME:$ADMIN_USERNAME .
git remote set-url origin git@github.com:lightster/.ssh.git
cd $RETURN_DIR

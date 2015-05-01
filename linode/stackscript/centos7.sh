#!/bin/bash
#
#<UDF name="keeper_password" label="Password for keeper">

if [ "$LINODE_ID" != "" ] ; then
    # prevent the script from running multiple times
    # (a workaround for Linode StackScript bug with CentOS 7 image)
    [ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :
fi

set -e
set -u
set -x

KEEPER_USERNAME="boxkeeper"
KEEPER_HOMEDIR="/home/$KEEPER_USERNAME"
KEEPER_SSHDIR="$KEEPER_HOMEDIR/.ssh"
KEEPER_KEYS="$KEEPER_SSHDIR/authorized_keys"

# redirect stdout and stderr to a log file
exec >>/var/log/stackscript.log 2>&1

yum update -y

useradd -G wheel $KEEPER_USERNAME
echo "$KEEPER_USERNAME:$KEEPER_PASSWORD" | chpasswd

mkdir -p $KEEPER_SSHDIR
chmod 0700 $KEEPER_SSHDIR
touch $KEEPER_KEYS
chmod 0600 $KEEPER_KEYS
curl -sS https://raw.githubusercontent.com/lightster/.ssh/master/id_rsa.lightster-air.pub \
    https://raw.githubusercontent.com/lightster/.ssh/master/id_rsa.lightster-air.pub \
    > $KEEPER_KEYS
chown -R $KEEPER_USERNAME:$KEEPER_USERNAME $KEEPER_SSHDIR

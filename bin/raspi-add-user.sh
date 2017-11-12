#!/usr/bin/env bash

#
# Create a user and group if they don't exist and configure passwordless login
#

# Check parameters
if [ ! $# -eq 3 ]; then
    echo "Use $0 <user> <group> <host>"
    exit -1
fi

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

user=$1
group=$2
host=$3
login="ssh pi@${host}.local"

# Create group
${login} -q "getent group ${group}"
if [ $? != 0 ]; then
	${info} ${host} "Creating group for ${group}"
	${login} "sudo addgroup ${group}"
fi

# Create user
${login} -q "id -u ${user}"
if [ $? == 1 ]; then
	${info} ${host} "Creating user for ${user}"
	${login} -t "sudo adduser --home /home/${user} --ingroup ${group} ${user}" << EOF
${user}




y
EOF
fi

# Create password
${login} -t "sudo passwd ${user}"

# Setup passwordless login
${bin_dir}/raspi-configure-ssh.sh ${user} ${host}

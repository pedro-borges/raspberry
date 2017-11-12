#!/usr/bin/env bash

#
# Create a user and group if they don't exist and configure passwordless login
#

# Check parameters
if [ ! $# -eq 3 ]; then
    echo "Use $0 <user> <group> <host>"
    exit -1
fi

run_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${run_dir}/../conf/environment
user=$1
group=$2
host=$3
login=pi@${host}.local

# Create group
ssh -q ${login} "getent group ${group}"
if [ $? != 0 ]; then
	printf "${info}[${host}] Creating group for ${group}${reset}"
	ssh ${login} "sudo addgroup ${group}"
fi

# Create user
ssh -q ${login} "id -u ${user}"
if [ $? == 1 ]; then
	printf "${info}[${host}] Creating user for ${user}${reset}"
	ssh -t ${login} "sudo adduser --home /home/${user} --ingroup ${group} ${user}" << EOF
${user}




y
EOF
fi

# Create password
ssh -t ${login} "sudo passwd ${user}"

# Setup passwordless login for user upsource
${run_dir}/raspi-configure-ssh.sh ${user} ${host}

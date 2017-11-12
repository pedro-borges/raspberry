#!/usr/bin/env bash

run_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${run_dir}/../conf/environment

# Check parameters
if [ ! $# -eq 2 ]; then
    echo "Use $0 <user> <host>"
    exit -1
fi

user=$1
host=$2
login="${user}@${host}.local"

# Create a local ssh key par if none exists
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    printf "${info}Generating ssh key pair${reset}"
    ssh_keygen
fi

key=$(cat ~/.ssh/id_rsa.pub | head -n 1)
 ${login} -q -T -o numberOfPasswordPrompts=0 exit
if [ $? != 0 ]; then
	printf "${info}[${host}] Setting passwordless ssh login for ${login}${reset}"

	# Setup passwordless login
	echo "install -d -m 700 .ssh; echo ${key} >> .ssh/authorized_keys; chmod 600 .ssh/authorized_keys" | ${login} -q -T > /dev/null
fi
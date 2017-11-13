#!/usr/bin/env bash

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

# Check parameters
if [ ! $# -eq 2 ]; then
    ${error} "Use ${script_name} <user> <host>"
    exit -1
fi

user=$1
host=$2
login="ssh ${user}@${host}.local"

# Create a local ssh key par if none exists
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    ${info} "Generating ssh key pair"
    ssh_keygen
fi

key=$(cat ~/.ssh/id_rsa.pub | head -n 1)
${login} -q -T -o numberOfPasswordPrompts=0 "exit"
if [ $? != 0 ]; then
	${info} ${host} "Setting passwordless ssh login for ${login}"

	# Setup passwordless login
	echo "install -d -m 700 .ssh; echo ${key} >> .ssh/authorized_keys; chmod 600 .ssh/authorized_keys" | ${login} -q -T > /dev/null
fi
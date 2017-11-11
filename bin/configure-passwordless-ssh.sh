#!/usr/bin/env bash

# Check parameters
if [ ! $# -eq 2 ]; then
    echo "Use $0 <user> <host>"
    exit -1
fi

user=$1
host=$2
login=${user}@${host}.local
run_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${run_dir}/../conf/environment

# Create a local ssh key par if none exists
if [ ! -f ~/.ssh/id_rsa.pub ]; then
    printf "${begin}Generating ssh key pair${reset}"
    ssh_keygen
fi

# Push our local ssh public key to the remote to be used as an authorized key
printf "${begin}[${host}] Setting passwordless ssh login for ${login}${reset}"
ssh ${login} "install -d -m 700 ~/.ssh"
cat ~/.ssh/id_rsa.pub | ssh ${login} "tee ~/.ssh/authorized_keys.tmp > /dev/null"
ssh ${login} "sort ~/.ssh/authorized_keys | sort | uniq > ~/.ssh/authorized_keys.tmp"
ssh ${login} "mv ~/.ssh/authorized_keys.tmp ~/.ssh/authorized_keys"

#!/usr/bin/env bash

# Check parameters
if [ ! $# -eq 1 ]; then
    echo "Use $0 <host>"
    exit -1
fi

run_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${run_dir}/../conf/environment
host=$1
login=pi@${host}.local

# Setup passwordless login for user pi
${run_dir}/configure-passwordless-ssh.sh pi ${host}

# Disable IPv6
ssh ${login} "cat /etc/sysctl.conf" | grep -q "$(head -n 3 ${run_dir}/../root/etc/sysctl.conf | tail -n 1)"
if [ $? != 0 ]; then
    printf "${begin}[${host}] Disabling IPv6${reset}"
    cat ${run_dir}/../root/etc/sysctl.conf | ssh ${login} "sudo tee -a /etc/sysctl.conf > /dev/null"
    printf "${begin}[${host}] Restarting network"
    ssh ${login} "sudo service networking restart"
fi

# Update packages
cat ${run_dir}/../root/etc/apt/sources.list | ssh ${login} "sudo tee /etc/apt/sources.list > /dev/null"

printf "${begin}[${host}] Updating packages${reset}"
ssh ${login} "sudo apt-get -o Acquire::ForceIPv4=true update"

printf "${begin}[${host}] Upgrading packages${reset}"
ssh ${login} "sudo apt-get -o Acquire::ForceIPv4=true upgrade -y"

printf "${begin}[${host}] Installing JAVA${reset}"
ssh ${login} "sudo apt-get -o Acquire::ForceIPv4=true install oracle-java8-jdk -y"
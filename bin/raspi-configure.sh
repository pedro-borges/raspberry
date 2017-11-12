#!/usr/bin/env bash

# Check parameters
if [ ! $# -eq 1 ]; then
    echo "Use $0 <host>"
    exit -1
fi

run_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${run_dir}/../conf/environment
host=$1
login="ssh pi@${host}.local"

# Setup passwordless login for user pi
${run_dir}/raspi-configure-ssh.sh pi ${host}

# Disable IPv6
${login} "cat /etc/sysctl.conf" | grep -q "$(head -n 3 ${run_dir}/../root/etc/sysctl.conf | tail -n 1)"
if [ $? != 0 ]; then
    printf "${info}[${host}] Disabling IPv6${reset}"
    cat ${run_dir}/../root/etc/sysctl.conf | ${login} "sudo tee -a /etc/sysctl.conf > /dev/null"
    printf "${info}[${host}] Restarting network${reset}"
    ${login} "sudo service networking restart"
fi

# Update packages
cat ${run_dir}/../root/etc/apt/sources.list | ${login} "sudo tee /etc/apt/sources.list > /dev/null"

printf "${info}[${host}] Updating packages${reset}"
${login} "sudo apt-get -o Acquire::ForceIPv4=true update"

printf "${info}[${host}] Upgrading packages${reset}"
${login} "sudo apt-get -o Acquire::ForceIPv4=true upgrade -y"

# Install java 8
${login} "java -version"
if [ $? != 0 ]; then
	printf "${info}[${host}] Installing JAVA${reset}"
	${host} "sudo apt-get -o Acquire::ForceIPv4=true install oracle-java8-jdk -y"
fi

printf "${info}[${host}] Configuration finnished${reset}"

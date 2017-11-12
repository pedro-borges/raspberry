#!/usr/bin/env bash

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

# Check parameters
if [ ! $# -eq 1 ]; then
    echo "Use $0 <host>"
    exit -1
fi

host=$1
login="ssh pi@${host}.local"

# Setup passwordless login for user pi
${bin_dir}/raspi-configure-ssh.sh pi ${host}

# Disable IPv6
${login} "cat /etc/sysctl.conf" | grep -q "$(head -n 3 ${root_dir}/etc/sysctl.conf | tail -n 1)"
if [ $? != 0 ]; then
    ${info} ${host} "Disabling IPv6"
    cat ${root_dir}/etc/sysctl.conf | ${login} "sudo tee -a /etc/sysctl.conf > /dev/null"
    ${info} ${host} "Restarting network"
    ${login} "sudo service networking restart"
fi

# Update packages
cat ${root_dir}/etc/apt/sources.list | ${login} "sudo tee /etc/apt/sources.list > /dev/null"

${info} ${host} "Updating packages"
${login} "sudo apt-get -o Acquire::ForceIPv4=true update"

${info} ${host} "Upgrading packages"
${login} "sudo apt-get -o Acquire::ForceIPv4=true upgrade -y"

# Install java 8
${login} "java -version"
if [ $? != 0 ]; then
	${info} ${host} "Installing JAVA"
	${host} "sudo apt-get -o Acquire::ForceIPv4=true install oracle-java8-jdk -y"
fi

${info} ${host} "Configuration finnished"

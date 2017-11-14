#!/usr/bin/env bash

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

# Check parameters
if [ ! $# -eq 1 ]; then
    ${error} "Use ${script_name} <host>"
    exit -1
fi

host=$1
login="ssh pi@${host}.local"

# Setup passwordless login for user pi
${bin_dir}/raspi-configure-ssh.sh pi ${host}

# Add data directory
if [ -d "/data" ]; then
	${info} ${host} "Creating data directory in /data for external volume"
	${login} "sudo mkdir -p /data; sudo chmod 1777 /data"
fi

# Disable IPv6
${login} "cat /etc/sysctl.conf" | grep -q "$(head -n 3 ${root_dir}/etc/sysctl.conf | tail -n 1)"
if [ $? != 0 ]; then
    ${info} ${host} "Disabling IPv6"
    cat ${root_dir}/etc/sysctl.conf | ${login} "sudo tee -a /etc/sysctl.conf > /dev/null"
    ${info} ${host} "Restarting network"
    ${login} "sudo service networking restart"
fi

# Setup noip
noip_url="http://pedrocborges:Ho97qi6Yu2kP@dynupdate.no-ip.com/nic/update?hostname=pedroborges.ddns.net"
noip_cron="0 * * * * pi curl --user-agent 'curl/7.52.1 uk.pcb.services+noip@gmail.com' ${noip_url}"
${login} "grep \"${noip_url}\" /etc/crontab"
if [ $? != 0 ]; then
	${info} ${host} "Adding noip trigger to crontab on every hour"
	${login} "sudo cp -n /etc/crontab /etc/crontab.bak"
	echo ${noip_cron} | ${login} "sudo tee -a /etc/crontab"
fi

# Update packages
cat ${root_dir}/etc/apt/sources.list | ${login} "sudo tee /etc/apt/sources.list > /dev/null"

${info} ${host} "Updating packages"
${login} "sudo apt-get -o Acquire::ForceIPv4=true update"

${info} ${host} "Upgrading packages"
${login} "sudo apt-get -o Acquire::ForceIPv4=true upgrade -y"

# Install java 8
#${login} "java -version"
#if [ $? != 0 ]; then
#	${info} ${host} "Installing JAVA"
#	${host} "sudo apt-get -o Acquire::ForceIPv4=true install oracle-java8-jdk -y"
#fi

${login} "docker --version"
if [ $? != 0 ]; then
	${info} ${host} "Installing docker"
	${login} "curl -sSL https://get.docker.com | sh"
	${login} "sudo usermod -aG docker pi"
fi

${info} ${host} "Configuration finnished"

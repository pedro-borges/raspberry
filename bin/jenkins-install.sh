#!/usr/bin/env bash

#
# Install jenkins
#

# Check parameters
if [ ! $# -eq 1 ]; then
    echo "Use $0 <host>"
    exit -1
fi

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

host=$1
login="ssh pi@${host}.local"
url_jenkins_debian="http://pkg.jenkins-ci.org/debian-stable"

# Add LTS key
${info} ${host} "Registering jenkins-ci.org key"
${login} "wget -q -O - ${url_jenkins_debian}/jenkins-ci.org.key | sudo apt-key add -"

# Add Jenkins deb repo
config_row="deb ${url_jenkins_debian} binary"
${login} "grep \"${config_row}\" ${file_sources_list}"
if [ $? != 0 ]; then
	${info} ${host} "Adding jenkins package list"
	echo ${config_row} | ${login} "tee -a ${file_sources_list} > /dev/null"
fi

# Update lists and install jenkins
${info} ${host} "Updating package lists"
${login} "sudo apt-get update"
${info} ${host} "Installing jenkins"
${login} "sudo apt-get install jenkins -y"
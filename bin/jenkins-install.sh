#!/usr/bin/env bash

#
# Install jenkins
#

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

# Check parameters
if [ ! $# -eq 1 ]; then
    echo "Use $0 <host>"
    exit -1
fi

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
	echo ${config_row} | ${login} "sudo tee -a ${file_sources_list} > /dev/null"
fi

# Update lists and install jenkins
${info} ${host} "Updating package lists"
${login} "sudo apt-get update"
${info} ${host} "Installing jenkins"
${login} "sudo apt-get install jenkins -y"

# Configure jenkins to listen on all interfaces
jenkins_config="/etc/default/jenkins"
${info} ${host} "Updating configuration"
${login} "sudo cp -n ${jenkins_config} ${jenkins_config}.bak"
${login} "sudo sed -i '/HTTP_HOST=*/c\HTTP_HOST=0.0.0.0' ${jenkins_config}"
${login} "sudo sed -i '/AJP_HOST=*/c\AJP_HOST=0.0.0.0' ${jenkins_config}"
${login} "sudo sed -i '/#JAVA_ARGS=*/c\JAVA_ARGS=\"-Xmx768m\"' ${jenkins_config}"

# Restart jenkins
${info} ${host} "Restarting jenkins"
${login} "sudo service jenkins restart"
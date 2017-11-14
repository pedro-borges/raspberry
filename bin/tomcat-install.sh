#!/usr/bin/env bash

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

# Check parameters
if [ ! $# -eq 1 ]; then
    ${error} "Use ${script_name} <host>"
    exit -1
fi

host=$1
login="ssh pi@${host}.local"

# Install tomcat8
${info} ${host} "Installing tomcat8"
${login} "sudo apt-get -o Acquire::ForceIPv4=true install tomcat8 -y"

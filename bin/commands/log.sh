#!/usr/bin/env bash

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../conf/environment

# Check parameters
if [ $# -lt 2 ]; then
    ${error} "Use ${script_name} [colour] <host> <message>"
    exit -1
fi

if [ $# -eq 2 ]; then
	printf "${1}${2}${reset}"
fi

if [ $# -eq 3 ]; then
	printf "${1}[${2}] ${3}${reset}"
fi

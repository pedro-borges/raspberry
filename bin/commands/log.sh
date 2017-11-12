#!/usr/bin/env bash

# Check parameters
if [ $# -lt 2 ]; then
    echo "Use $0 [colour] <host> <message>"
    exit -1
fi

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../conf/environment

if [ $# -eq 2 ]; then
	printf "${1}${2}${reset}"
fi

if [ $# -eq 3 ]; then
	printf "${1}[${2}] ${3}${reset}"
fi

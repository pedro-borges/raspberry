#!/usr/bin/env bash

# Check parameters
if [ ! $# < 2 ]; then
    echo "Use $0 [level] <host> <message>"
    exit -1
fi

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../../conf/environment

if [ $# == 2 ]; then
	printf "${1}${2}${reset}"
fi

if [ $# == 3 ]; then
	printf "${1}[${2}] ${3}${reset}"
fi

#!/usr/bin/env bash

#
# Shutdown the farm
#

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

# Issue shutdown command on each farm instance
for host in $(cat ${conf_dir}/farm); do
	ssh pi@${host}.local "sudo shutdown $*"
done
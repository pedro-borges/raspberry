#!/usr/bin/env bash

#
# Shutdown the farm
#

run_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${run_dir}/../conf/environment

# Issue shutdown command on each farm instance
for host in $(cat ${run_dir}/../conf/farm); do
	ssh pi@${host}.local "sudo shutdown $*"
done
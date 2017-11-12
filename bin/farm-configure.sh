#!/usr/bin/env bash

#
# Configure a farm of raspis in one go
#

run_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${run_dir}/../conf/environment

# Run raspi-configure.sh for the farm
for host in $(cat ${run_dir}/../conf/farm); do
    ${run_dir}/raspi-configure.sh $host
done
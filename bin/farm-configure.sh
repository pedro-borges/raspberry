#!/usr/bin/env bash

#
# Configure a farm of raspis in one go
#

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

# Run raspi-configure.sh for the farm
for host in $(cat ${conf_dir}/farm); do
    ${bin_dir}/raspi-configure.sh $host
done
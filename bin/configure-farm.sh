#!/usr/bin/env bash

#
# Configure a farm of raspis in one go
#

# Check parameters
if [ $# -eq 0 ]; then
    echo "Use $0 <host 1>...[host n]"
    exit -1
fi

run_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${run_dir}/../conf/environment

# Run configure-raspi.sh for the farm
for host in $*; do
    ${run_dir}/configure-raspi.sh $host
done
#!/usr/bin/env bash

# Check parameters
if [ ! $# -eq 1 ]; then
    echo "Use $0 <host>"
    exit -1
fi

run_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${run_dir}/../conf/environment
host=$1
login=pi@${host}.local
postgres_version="9.6"
fstab=${run_dir}/../root/etc/fstab
pg_hba=${run_dir}/../root/etc/postgresql/main/pg_hba.conf

# Install PostgreSQL
printf "${begin}[${host}] Installing PostgreSQL${reset}"
ssh ${login} "sudo apt-get -o Acquire::ForceIPv4=true install postgresql-${postgres_version} -y"

# Setup password for PostgreSQL
printf "${begin}[${host}] Setting up password for user postgres${reset}"
ssh -t ${login} "sudo passwd postgres"

# Push our local ssh public key to the remote to be used as an authorized key
${run_dir}/configure-passwordless-ssh.sh postgres ${host}

# Configure local network access
ssh ${login} "sudo cat /etc/postgresql/${postgres_version}/main/pg_hba.conf" | grep -q "$(head -n 1 ${pg_hba})"
if [ $? != 0 ]; then
	printf "${begin}[${host}] Configuring local network access to postgres${reset}"
	cat ${pg_hba} | ssh ${login} "sudo tee -a /etc/postgresql/${postgres_version}/main/pg_hba.conf > /dev/null"
	restart_postgres="1"
fi

# Add the DB hard drive to the fstab
ssh ${login} "cat /etc/fstab" | grep -q "$(head -n 1 ${run_dir}/../root/etc/fstab)"
if [ $? != 0 ]; then
	printf "${begin}[${host}] Mounting /dev/sda1 under /data${reset}"
	ssh ${login} "sudo mkdir -p /data"
	ssh ${login} "sudo chown postgres:postgres /data"
    cat ${fstab} | ssh ${login} "sudo tee -a /etc/fstab > /dev/null"
	ssh ${login} "sudo mount /dev/sda1"
	restart_postgres="1"
fi

#todo move postgres data directory

if [ ${restart_postgres} == "1" ]; then
	printf "${begin}[${host}]$ Restarting postgres service{reset}"
	ssh ${login} "sudo service postgresql restart"
fi
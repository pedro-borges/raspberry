#!/usr/bin/env bash

# Check parameters
if [ ! $# -eq 2 ]; then
    echo "Use $0 <host> <volume>"
    exit -1
fi

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

host=$1
login="ssh pi@${host}.local"
postgres_version="9.6"

# Check if the external hd is in the fstab
data_directory=/data
volume=/dev/$2
fstab="${volume}1	${data_directory}	ext4	defaults	0	3"
${login} "cat /etc/fstab" | grep -q "${volume}1"
if [ $? != 0 ]; then
	${info} ${host} "Mounting ${volume}1 under ${data_directory}"

	# Create mount point
	${login} "sudo mkdir -p ${data_directory}"

	# Setup access rights
	${login} "sudo chmod 1777 ${data_directory}"

	# Add external hd to fstab
    echo ${fstab} | ${login} "sudo tee -a /etc/fstab > /dev/null"

    # Manually mount external hd
	${login} "sudo mount /dev/sda1"
fi

# Stop postgres
${info} ${host} "Installing PostgreSQL"
${login} "sudo service postgresql stop"

# Symbolic link postgres folder to external drive
${login} "sudo mkdir -p ${data_directory}/postgres"
${login} "sudo chmod 777 ${data_directory}/postgres"
${login} "sudo ln -s /var/lib/postgres /data/postgres"

# Install PostgreSQL
${info} ${host} "Installing PostgreSQL"
${login} "sudo apt-get -o Acquire::ForceIPv4=true install postgresql-${postgres_version} -y"

# Check for postgres local network access
pg_hba=${run_dir}/../root/etc/postgresql/main/pg_hba.conf
${login} "sudo cat /etc/postgresql/${postgres_version}/main/pg_hba.conf" | grep -q "$(head -n 1 ${pg_hba})"
if [ $? != 0 ]; then
	${info} ${host} "Configuring local network access to postgres"

	# Configure postgres local network access
	cat ${pg_hba} | ${login} "sudo tee -a /etc/postgresql/${postgres_version}/main/pg_hba.conf > /dev/null"
fi

# Change permissions for postgres directory
${login} "chown postgres:postgres /data/postgres"
${login} "chmod 700 /data/postgres"

# Start postgres
${login} "sudo service postgresql start"
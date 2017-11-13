#!/usr/bin/env bash

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

# Check parameters
if [ ! $# -eq 1 ]; then
    ${error} "Use ${script_name} <host>"
    exit -1
fi

host=$1
login="ssh pi@${host}.local"
postgres_version="9.6"

# Add postgres user
${bin_dir}/raspi-add-user.sh postgres postgres postgres

# Symbolic link postgres folder to external drive
${login} "sudo mkdir -p ${data_dir}/postgresql"
${login} "sudo chown postgres:postgres ${data_dir}/postgresql"
${login} "sudo ln -s ${data_dir}/postgresql /var/lib/postgresql"

# Install PostgreSQL
${info} ${host} "Installing PostgreSQL"
${login} "sudo apt-get -o Acquire::ForceIPv4=true install postgresql-${postgres_version} -y"

# Check for postgres local network access
pg_hba=${root_dir}/etc/postgresql/main/pg_hba.conf
postgres_hba="/etc/postgresql/${postgres_version}/main/pg_hba.conf"
${login} "sudo cat ${postgres_hba}" | grep -q "$(head -n 1 ${pg_hba})"
if [ $? != 0 ]; then
	${info} ${host} "Configuring postgres"

	# Backup configuration
	${login} "sudo cp -n ${postgres_hba} ${postgres_hba}.bak"

	# Configure postgres local network access
	cat ${pg_hba} | ${login} "sudo tee -a ${postgres_hba} > /dev/null"
fi

# Setup password and passwordless login for postgres user
ssh postgres@${host}.local -q -T -o numberOfPasswordPrompts=0 "exit"
if [ $? != 0 ]; then
	${info} ${host} "Setting up password for postgres user"
	${login} -q -t "sudo passwd postgres"
	${bin_dir}/raspi-configure-ssh.sh postgres ${host}
fi

# Start postgres
${info} ${host} "Starting postgres"
${login} "sudo service postgresql start"
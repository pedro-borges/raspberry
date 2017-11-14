# Raspberry pi setup scripts

### `install-sd.sh <volume>`
#####(needs sudo)

Installs a fresh image into an sd card and configures headless boot based on the files in the boot folder.

Boot up the device with the freshly created sd card and setup its hostname and change pi user's password. 

### `raspi-configure.sh <host>`

Sets up a freshly installed system
1. Configure passwordless ssh access for the pi user.
2. Update package catalog
3. Upgrade packages
4. Install docker

Alternatively you can run `configure-farm.sh` to do this for all hosts in `conf/farm`.

### `postgres-install.sh <host> <volume>`

Installs postgresq on a host.

### `jenkins-install.sh <host>`

Installs jenkins docker on a host.

### `shutdown-farm.sh`

Issues a shutdown command to all farm instances. Arguments can be passed through.
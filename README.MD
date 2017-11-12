# Raspberry pi setup scripts

### `install-sd.sh <volume>`
#####(needs sudo)

Installs a fresh image into an sd card and configures headless boot based on the files in the boot folder.

Boot up the device with the freshly created sd card and setup its hostname andpi user password. 

### `raspi-configure.sh <host>`

Sets up a freshly installed system
1. Configure passwordless ssh access for the pi user.
2. Update package catalog
3. Upgrade packages
4. Install Java

Alternatively you can run `configure-farm.sh` to do this for all hosts in `conf/farm`.

### `postgres-install.sh <host> <volume>`

Installs postgres and configures a new external volume for it to use.
1. Setup external volume
2. Add symbolic link from postgres folder to external volume
3. Install postgres
4. Setup password for postgres user
5. Configure passwordless ssh access for the postgres user
6. Accept connections from local network

### `jetbrains-install.sh <host> <url>`

Installs a package from jetbrains.

### `shutdown-farm.sh`

Issues a shutdown command to all farm instances. Arguments can be passed through.
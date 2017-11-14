#!/usr/bin/env bash

#
# This script will write the raspbian image to the supplied volume downloading it if necessary
#
# It will then setup headless configuration for the following services
#
# sshd
# wi-fi
#

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

# Check parameters
if [ ! $# -eq 1 ]; then
    ${error} "Use sudo ${script_name} <volume>"
    exit -1
fi

# Check if run with sudo
if [ $(id -u) != 0 ]; then
    ${error} "Use sudo ${script_name} ${1}"
	exit -1
fi

disk=/dev/${1}

# Check if volume is present
if [ ! -b ${disk} ]; then
    ${error} "Block device ${disk} does not exist"
    exit -1
fi

boot_mountpoint="/Volumes/boot"
cd ${downloads_dir}
if [ ! -d raspbian_boot ]; then
	${info} "Creating mountpoint ${boot_mountpoint}"
    mkdir -p ${boot_mountpoint}
fi

# Download latest image if not present
${info} "Checking for latest raspberry pi image from https://downloads.raspberrypi.org/raspbian_lite_latest"
wget -N -nv --show-progress https://downloads.raspberrypi.org/raspbian_lite_latest
if [ "raspbian.img" -ot "raspbian_lite_latest" ]; then
	${info} "Extracting archive"
	rm -f raspbian.img
    unzip -q raspbian_lite_latest
    mv *raspbian*.img raspbian.img
    touch raspbian.img
fi

# Unmount the volume
${info} "Unmounting ${disk}"
diskutil unmountDisk ${disk}

# Write image to volume
if [ -c /dev/r${1} ]; then
	${info} "Writing image to /dev/r${1} hit ctrl-t for progress"
	dd bs=1m if=raspbian.img of=/dev/r${1} conv=sync
else
	if [ -b /dev/${1} ]; then
		${info} "Writing image to /dev/${1} hit ctrl-t for progress"
		dd bs=1m if=raspbian.img of=/dev/${1} conv=sync
	fi
fi

# Copy headless boot files
${info} "Copying headless configuration to boot partition"
cp -fv ${boot_dir}/* ${boot_mountpoint}

# Unmount boot partition
${info} "Unmounting /dev/${disk}s1"
diskutil unmountDisk /dev/${disk}s1

# Eject the volume
${info} "Ejecting disk"
diskutil eject ${disk}

${info} "Installation complete:"
echo "Boot up your device to setup its hostname and pi user password before running raspi-configure.sh on it."
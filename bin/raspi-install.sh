#!/usr/bin/env bash

#
# This script will write the raspbian image to the supplied volume downloading it if necessary
#
# It will then setup headless configuration for the following services
#
# sshd
# wi-fi
#

# Check parameters
if [ ! $# -eq 1 ]; then
    ${error} "Use sudo ${script_name} <volume>"
    echo $0 "disk2 for /dev/disk2"
    exit -1
fi

# Check if run with sudo
if [ $(id -u) != 0 ]; then
    ${error} "Needs super-user privileges"
    echo "Use sudo ${script_name} <volume>"
	exit -1
fi

source $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/../conf/environment

disk=/dev/$1

# Check if volume is present
if [ ! -b ${disk} ]; then
    ${error} "Volume $1 is not connected"
    exit -1
fi

if [ ! -d /tmp/raspi/boot ]; then
    mkdir -p /tmp/raspi/boot
fi

# Unmount the volume
diskutil unmountDisk ${disk}

# Download latest image if not present
if [ ! -f /tmp/raspi/raspbian.img ]; then
    ${info} "Downloading latest raspberry pi image from https://downloads.raspberrypi.org/raspbian_lite_latest"
    wget -nv --show-progress https://downloads.raspberrypi.org/raspbian_lite_latest -O /tmp/raspi/raspbian.zip
    unzip -q /tmp/raspi/raspbian.zip -d /tmp/raspi
    mv /tmp/raspi/*raspbian*.img /tmp/raspi/raspbian.img
    rm -f /tmp/raspi/raspbian.zip
fi

# Write image to volume
${info} "Writing image to /dev/r$1 hit ctrl-t for progress"
dd bs=1m if=/tmp/raspi/raspbian.img of=/dev/r$1 conv=sync

# Mount the boot partition
mount -t msdos ${disk}s1 /tmp/raspi/boot

# Copy headless boot files
${info} "Copying headless configuration files"
cp -fv ${boot_dir}/* /tmp/raspi/boot

# Unmount the volume
diskutil unmountDisk ${disk}

# Eject the volume
diskutil eject ${disk}

${info} "Installation complete:"
echo "Boot up your device to setup its hostname and pi user password before running raspi-configure.sh on it."
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
    echo "Use $0 <volume>"
    echo $0 "disk2 for /dev/disk2"
    exit -1
fi

run_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source ${run_dir}/../conf/environment

# Check if volume is present
if [ ! -b /dev/$1 ]; then
    printf "${red}[ERROR] Volume $1 is not connected${reset}"
    exit -1
fi

if [ ! -d /tmp/raspi/boot ]; then
    mkdir -p /tmp/raspi/boot
fi

# Unmount the volume
diskutil unmountDisk /dev/$1

# Download latest image if not present
if [ ! -f /tmp/raspi/raspbian.img ]; then
    printf "${begin}Downloading latest raspberry pi image from https://downloads.raspberrypi.org/raspbian_lite_latest${reset}"
    wget -nv --show-progress https://downloads.raspberrypi.org/raspbian_lite_latest -O /tmp/raspi/raspbian.zip
    unzip -q /tmp/raspi/raspbian.zip -d /tmp/raspi
    mv /tmp/raspi/*raspbian*.img /tmp/raspi/raspbian.img
    rm -f /tmp/raspi/raspbian.zip
fi

# Write image to volume
printf "${begin}Writing image to /dev/r$1 hit ctrl-t for progress${reset}"
dd bs=1m if=/tmp/raspi/raspbian.img of=/dev/r$1 conv=sync

# Mount the boot partition
mount -t msdos /dev/$1s1 /tmp/raspi/boot

# Copy headless boot files
printf "${begin}Copying headless configuration files${reset}"
cp -fv ${run_dir}/../boot/* /tmp/raspi/boot

# Unmount the volume
diskutil unmountDisk /dev/$1

# Eject the volume
diskutil eject /dev/$1
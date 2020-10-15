#!/bin/bash

set -e

OKGREEN='\033[92m'
# WARNING='\033[93m'
FAIL='\033[91m'
OKBLUE='\033[94m'
UNDERLINE='\033[4m'
ENDC='\033[0m'

echo "Starting eMMC Flashing Service"

if [ $# -ne 1 ]; then
    echo "$0": "usage: ./flash_emmc.sh [ PATH_TO_IMG ]"
    exit 0
fi

img=$1
echo "Searching for BCM devices on USB ..."
if [[ $(lsusb | grep BCM) -ne 0 ]]; then
    echo -e "${FAIL} ✘ ${ENDC} failed: could not find BCM device on USB."
    exit 1
fi
echo -e "${OKGREEN} ✓ ${ENDC} complete"

echo "Sending boot code ..."
sudo ./rpiboot
echo -e "${OKGREEN} ✓ ${ENDC} complete"

diskutil list
read -rp 'Specify disk write location (ie /dev/disk2): ' disk
echo "Unmounting $disk ..."
diskutil unmountDisk "$disk"
echo -e "${OKGREEN} ✓ ${ENDC} complete"
echo "Flashing $img to $disk..."
pv "$img" | sudo dd bs=1m of="$disk"
echo -e "${OKGREEN} ✓ ${ENDC} complete"

echo "Copying public ssh key to buffer ... "
cat ~/.ssh/id_rsa.pub | pbcopy
echo -e "${OKGREEN} ✓ ${ENDC} complete"
echo "Opening node user data ..."
vi /Volumes/HypriotOS/user-data

diskutil unmountDisk "$disk"

echo -e "${OKGREEN} ✓ ${ENDC} Completed eMMC Flashing Service"
#!/bin/sh
#parted -s -a optimal -- /dev/pmem4 mklabel gpt mkpart primary ext4 2MiB -4096s
parted -s -a optimal -- /dev/pmem4 mklabel gpt mkpart primary 2MiB -4096s
mkfs.ext4 -b 4096 -E stride=512 -F /dev/pmem4p1
fdisk -l /dev/pmem4

parted -s -a optimal -- /dev/pmem3 mklabel gpt mkpart primary ext4 1MiB -4096s
mkfs.ext4 -b 4096 -F /dev/pmem4p1
fdisk -l /dev/pmem3

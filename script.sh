#!/bin/bash
ls /sys/firmware/efi/efifvars
ip link
ping -c 3 archlinux.org
timedatectl set-ntp true
STR=$'g\nn\n1\n\n+512M\nt\n1\nn\n\n\n\nw'
echo "$STR" | fdisk /dev/sda
mkfs.vfat -F 32 /dev/sda1
mkfs.btrfs /dev/sda2
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
pacstrap /mnt base linux linux-firmware base-devel vim
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ./chroot.sh

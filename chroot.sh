#!/bin/sh
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc
echo en_US.UTF-8 UTF-8 << /etc/locale.gen
locale-gen
touch /etc/hostname
echo ucr_localhost << /etc/hostname
mkinitcpio -P
passwd
pacman -S networkmanager grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=esp --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

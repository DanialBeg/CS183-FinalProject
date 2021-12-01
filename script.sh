#!/bin/bash
ls /sys/firmware/efi/efifvars
ip link
ping -c 3 archlinux.org
timedatectl set-ntp true
# STR=$'g\nn\n1\n\n+512M\nt\n1\nn\n\n\n\nw'
STR=$'o\nn\np\n1\n\n+128M\na\nn\np\n2\n\n\nw'
echo "$STR" | fdisk /dev/sda
# mkfs.vfat -F 32 /dev/sda1
mkfs.ext4 /dev/sda1
mkfs.btrfs /dev/sda2
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
pacstrap /mnt base linux linux-firmware base-devel vim networkmanager grub efibootmgr firefox git xorg xfce4 flatpak libreoffice wget
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt << "EOT"
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
hwclock --systohc
echo en_US.UTF-8 UTF-8 > /etc/locale.gen
locale-gen
touch /etc/hostname
echo ucr_localhost > /etc/hostname
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
passwd
root
root
systemctl enable NetworkManager
wget https://zoom.us/client/latest/zoom_x86_64.pkg.tar.xz
pacman -U zoom_x86_64.pkg.tar.xz
EOT

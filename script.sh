#!/bin/bash

# NETWORKING
# ip link output shows us that our network interface will be output and we 
# confirm connection to the internet using ping. 
ip link
ping -c 3 archlinux.org
# ================================================================================

# CONFIRM SYSTEM TIME IS CORRECT
timedatectl set-ntp true
# ================================================================================

# PARTITIONING THE SYSTEM
# fdisk is a command line interface (CLI) tool that can be used to partition the drives.
# For our systems, the computers will be using a non NVME SSD, so they typically are sd<x> drives
# STR variable holds the input that will be piped to fdisk, to set up two partitions for the system
# First partition will be our boot partition, or where the GRUB bootloader will reside. GRUB will boot the OS. 
# Second partition will be our root filesystem, where all user data will be.
STR=$'o\nn\np\n1\n\n+128M\na\nn\np\n2\n\n\nw'
echo "$STR" | fdisk /dev/sda
# ================================================================================

# MAKING FILESYSTEMS
# Filesystems determine how data storage will work for a partition. mkfs = make filesystem command
# ext4 (extend 4) will be used for our bootloader.
# btrfs was used for the root fs for snapshot capability. Incase something goes wrong with use computer can restore to previous state.
mkfs.ext4 /dev/sda1
mkfs.btrfs /dev/sda2
# ================================================================================

# MOUNTING THE DRIVES
# Mounting is necessary in order to access and modify the newly formatted filesystems on /dev/sda1 and /dev/sda2. 
# Mounting will attach the filesystems to /mnt and /mnt/boot for /dev/sda2 and /dev/sda1 respectively. 
# At this point, files on the desired machine are readible by the live iso.
# This sets us up for the chroot. 
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
# ================================================================================

# READYING THE SYSTEM
# pacstrap is an arch specific command that allows us to install software into the system instead of chrooting and then installing
# The necessary packages are base, linux, and linux firmware which will get the kernel and other necessary software to have a bare functioning system
# Other software is useful software and bare minimum for working system for students
# fstab is a config file where we can automatically mount the SSD everytime the device is recognized. (It's useful for any storage device.)
pacstrap /mnt base linux linux-firmware base-devel vim networkmanager grub efibootmgr firefox git xorg xfce4 flatpak libreoffice wget pulseaudio
genfstab -U /mnt >> /mnt/etc/fstab
# ================================================================================

# CHROOT
# The chroot (change root directory) command changes the root directory of a calling process to a specified path.
# This allows us to effectively enter and modify the actual system where Arch Linux will be installed
# Commands will be fed until end of transmission, so comments can't be added in the EOT block
# First, timezone and system locale is set up
# Hostname is given to computer 
# The GRUB bootloader will be installed to /dev/sda and a configuration file will be generated to accompany it. The default settings are kept for GRUB.
# root and 'student' users are made
# Some services are enabled to run upon every boot, such as NetworkManager for internet connection and pulseaudio for audio.
# Zoom is installed and shows an example of how some proprietary software is installed when not present in official repository. 
# .bash_profile is updated so that everytime user logs in, the desktop environment is loaded.
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
systemctl enable pulseaudio
wget https://zoom.us/client/latest/zoom_x86_64.pkg.tar.xz
pacman -U --noconfirm zoom_x86_64.pkg.tar.xz
rm zoom_x86_64.pkg.tar.xz
useradd -m -G wheel -s /bin/bash student
passwd student
ucr
ucr
touch /home/student/.bash_profile
echo exec startxfce4 >> /home/student/.bash_profile
EOT
# ================================================================================

# FINALIZING
# Unmount all mounted partitions on /mnt and /mnt/boot
# If drives are still mounted, reboot won't be smooth
# Reboot, and GRUB will appear. GRUB will boot into OS.
# If CD is not removed, in the Live Arch CD GRUB, select "Boot Existing OS"
umount -R /mnt
reboot
# ================================================================================

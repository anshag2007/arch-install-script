#!/bin/bash

echo -n "i hope you have already paritioned your disks and have enough space to install arch"

echo -n "default keymap is going to be en_us qwerty"

pacman -Syy

echo "Enter the parition to be used for root (/) [ex: /dev/sda2]:"
read rootpart 
mkfs.ext4 $rootpart
echo "Enter the parition to be used for boot (/boot) [ex: /dev/sda1]:"
read bootpart 
mkfs.fat -F 32 $bootpart

echo "Specify the swap parition: "
read swappart
mkswap $swappart

mount $rootpart /mnt
mount $bootpart --mkdir /mnt/boot
    swapon $swappart
pacstrap -K /mnt base linux-zen linux-firmware intel-ucode neovim man-db man-pages texinfo networkmanager sudo fish kitty nano
genfstab -U /mnt >> /mnt/etc/fstab
mv after.sh /mnt
arch-chroot /mnt /after.sh

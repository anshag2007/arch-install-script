#!/bin/bash

echo -n "i hope you have already paritioned your disks and have enough space to install arch"

echo -n "default keymap is going to be en_us qwerty"

pacman -Syy

echo "Enter the parition to be used for root (/) [ex: /dev/sda2]:"
read rootpart 
echo -n "The following parition will be formatted, are you sure you want to proceed? [y/n] "
read conf
n = 0
while [ n -ne 1 ]
do
if [ $conf == "y" ] 
then 
    mkfs.ext4 $rootpart
    n = 1
elif [ $conf == "n" ]
then
    echo -n "operation cancelled"
    n = 0
    exit
else 
    echo "not a valid choice"
    n = 0
fi
done 

echo "Enter the parition to be used for boot (/boot) [ex: /dev/sda1]:"
read bootpart 
echo -n "Would you like to leave the parition as is (any) or format it? (f): "
read conf
if [ $conf == "f" ] 
then 
    mkfs.fat -F 32 $bootpart
fi

echo "Would you like to enable swap? [y/n]: "
read conf
if [ $conf == "y" ]
then
    echo "Specify the swap parition: "
    read swappart
    mkswap $swappart
    sp = 1
else
    echo -n "No swap selected"
    sp = 0
fi

mount $rootpart /mnt
mount $bootpart --mkdir /mnt/boot
if [ $sp == 1 ]
then
    swapon $swappart
fi

pacstrap -K /mnt base linux-zen linux-firmware intel-ucode neovim man-db man-pages texinfo networkmanager sudo fish kitty nano
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "Enter your hostname: "
read host
echo $host > /etc/hostname
systemctl enable NetworkManager.service
mkinitcpio -P
passwd

bootctl install

uuid=$(blkid -s UUID -o value "$rootpart")
cat <<EOF > /boot/EFI/loader/entries/arch.conf
title   Arch Linux
linux   /vmlinuz-linux-zen
initrd  /initramfs-linux-zen.img
options root=UUID=$uuid rw
EOF

echo "Enter your username: "
read usern
useradd -m $usern
passwd $usern
echo "$usern ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "Enable multilib? [y/any]: "
read ext
if [ $ext == "y" ]
then
echo <<EOF >> /etc/pacman.conf
[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
fi

pacman -Syy

pacman -S --needed --noconfirm xorg i3 xdg-users-dir alsa-utils brightnessctl fastfetch feh firefox flameshot fzf git github-cli gparted gtk-layer-shell gvfs gvfs-mtp htop jdk-openjdk luarocks lxappearance ly mpv mpd ncmpcpp mpc mate-polkit networkmanager-openvpn network-manager-applet nodejs npm obs-studio pacman-contrib pavucontrol picom playerctl pipewire pulseaudio python-pip qemu-full ripgrep thunar tree tmux ttf-hanazono virt-manager vlc wine-gecko wine-mono wine-staging xclip xfce4-notifyd xfce4-power-manager yt-dlp

systemctl enable ly.service 

#!/usr/bin/env bash

set -xe

if [ "$(id -u)" -ne 0 ]; then
    exit 1
fi

if ! grep -- installation-cd-minimal /etc/nixos/configuration.nix; then
    exit 1
fi

# Partitioning
wipefs --all /dev/vda
fdisk /dev/vda <<EOF
o
n
p
1
2048
+500M
n
p
2


w
EOF

# Filesystems
mkfs.fat -F 32 /dev/vda1
mkfs.ext4 /dev/vda2

# Mount
mount /dev/vda2 /mnt
mkdir /mnt/boot
mount /dev/vda1 /mnt/boot

# Swap
dd if=/dev/zero of=/mnt/.swapfile bs=1024 count=2M
chmod 600 /mnt/.swapfile
mkswap /mnt/.swapfile
swapon /mnt/.swapfile

# Config
nixos-generate-config --root /mnt
cp configuration.nix /mnt/etc/nixos/configuration.nix

# Install
cd /mnt
nixos-install

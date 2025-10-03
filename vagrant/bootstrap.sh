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
g
n
1
2048
+500M
t
1
n
2


w
EOF

# Filesystems
mkfs.fat -F 32 /dev/vda1
mkfs.ext4 /dev/vda2

# Mount
mount /dev/vda2 /mnt
mkdir /mnt/boot
mount -o umask=077 /dev/vda1 /mnt/boot

# Swap
dd if=/dev/zero of=/mnt/.swapfile bs=1024 count=2M
chmod 600 /mnt/.swapfile
mkswap /mnt/.swapfile
swapon /mnt/.swapfile

# Channels
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --update

# Config
nixos-generate-config --root /mnt
cp configuration.nix /mnt/etc/nixos/configuration.nix

# Install
cd /mnt
nixos-install --no-root-passwd

# Dotfiles
nixos-enter -c 'mkdir /home/vagrant/github'
nixos-enter -c 'git clone https://github.com/jukuisma/dotfiles /home/vagrant/github/dotfiles'
nixos-enter -c 'chown -R vagrant:users /home/vagrant/github'

poweroff

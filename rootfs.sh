#!/usr/bin/env bash
set -e

. config.sh

CURRENT_DIR="$(pwd)"

#https://cdimage.ubuntu.com/ubuntu-base/releases/jammy/release/ubuntu-base-22.04.4-base-amd64.tar.gz

sudo rm -rf /tmp/rootfs ${CURRENT_DIR}/rootfs.img
sudo mkdir -p /tmp/rootfs

dd if=/dev/zero of=${CURRENT_DIR}/rootfs.img bs=1M count=10000
mkfs.ext4 ${CURRENT_DIR}/rootfs.img

sudo mount -o loop ${CURRENT_DIR}/rootfs.img /tmp/rootfs

sudo debootstrap --arch=$UBUNTU_ARCH --variant=minbase $UBUNTU_CODENAME /tmp/rootfs $UBUNTU_MIRROR

sudo mount --bind /dev /tmp/rootfs/dev
sudo mount --bind /run /tmp/rootfs/run
sudo chroot /tmp/rootfs mount none -t proc /proc
sudo chroot /tmp/rootfs mount none -t sysfs /sys
sudo chroot /tmp/rootfs mount none -t devpts /dev/pts

sudo chroot /tmp/rootfs << EOF
export DEBIAN_FRONTEND=noninteractive

echo "deb $UBUNTU_MIRROR $UBUNTU_CODENAME main restricted universe multiverse
deb $UBUNTU_MIRROR $UBUNTU_CODENAME-security main restricted universe multiverse
deb $UBUNTU_MIRROR $UBUNTU_CODENAME-updates main restricted universe multiverse" > /etc/apt/sources.list

echo "$NAME" > /etc/hostname

echo "APT::Install-Recommends "false";
APT::Install-Suggests "false";
" > /etc/apt/apt.conf.d/99recommended

apt update
apt install -y libterm-readline-gnu-perl systemd-sysv

dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id

dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

apt upgrade -y

apt install -y --install-recommends \
sudo \
casper \
discover \
laptop-detect \
os-prober \
network-manager \
resolvconf \
net-tools \
wireless-tools \
grub-common \
grub-gfxpayload-lists \
grub-pc \
grub-pc-bin \
grub2-common \
locales \
nano 

apt install -y --install-recommends \
software-properties-common \
gpg-agent \
apt-transport-https

apt install -y $KERNEL_PACKAGE

apt install -y --install-recommends \
ubiquity \
ubiquity-casper \
ubiquity-frontend-gtk \
ubiquity-slideshow-ubuntu \
ubiquity-ubuntu-artwork

dpkg-reconfigure locales
dpkg-reconfigure resolvconf

echo "[main]
rc-manager=resolvconf
plugins=ifupdown,keyfile
dns=dnsmasq

[ifupdown]
managed=false
" > /etc/NetworkManager/NetworkManager.conf

dpkg-reconfigure network-manager

truncate -s 0 /etc/machine-id

rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl

EOF

sudo chroot /tmp/rootfs umount /proc
sudo chroot /tmp/rootfs umount /sys
sudo chroot /tmp/rootfs umount /dev/pts
sudo umount /tmp/rootfs/dev
sudo umount /tmp/rootfs/run

sudo umount -R /tmp/rootfs
sudo rm -rf /tmp/rootfs

#sudo e2fsck -f ${CURRENT_DIR}/rootfs.img
#sudo resize2fs -M ${CURRENT_DIR}/rootfs.img

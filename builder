#!/usr/bin/env bash
set -e

. config

CURRENT_DIR="$(pwd)"

if mount | grep -q /tmp/rootfs/proc; then
    sudo chroot /tmp/rootfs umount /proc > /dev/null
fi

if mount | grep -q /tmp/rootfs/sys; then
    sudo chroot /tmp/rootfs umount /sys > /dev/null
fi

if mount | grep -q /tmp/rootfs/dev/pts; then
    sudo chroot /tmp/rootfs umount /dev/pts > /dev/null
fi

if mount | grep -q /tmp/rootfs/run; then
    sudo umount /tmp/rootfs/run > /dev/null
fi

if mount | grep -q /tmp/rootfs/dev; then
    sudo umount /tmp/rootfs/dev > /dev/null
fi

if mount | grep -q /tmp/rootfs; then
    sudo umount /tmp/rootfs > /dev/null
fi

sudo rm -rf ${CURRENT_DIR}/*.iso

sudo mkdir -p /tmp/rootfs /tmp/image/{casper,isolinux,install}
sudo cp -v ${CURRENT_DIR}/rootfs.img /tmp/rootfs.img

sudo mount -o loop /tmp/rootfs.img /tmp/rootfs

sudo mount --bind /dev /tmp/rootfs/dev
sudo mount --bind /run /tmp/rootfs/run
sudo chroot /tmp/rootfs mount none -t proc /proc
sudo chroot /tmp/rootfs mount none -t sysfs /sys
sudo chroot /tmp/rootfs mount none -t devpts /dev/pts

echo SET DEFAULT CONFIGURATIONS
sudo chroot /tmp/rootfs << EOF
export DEBIAN_FRONTEND=noninteractive
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id
dpkg-divert --local --rename --add /sbin/initctl
ln -s /bin/true /sbin/initctl

echo "[org.gnome.desktop.interface:Pantheon]
cursor-theme='$CURSOR_THEME'
gtk-theme='$SYSTEM_THEME'
icon-theme='$ICON_THEME'

[org.gnome.desktop.wm.preferences:Pantheon]
theme='$SYSTEM_THEME'
button-layout=':minimize,maximize,close'

[org.gnome.desktop.sound:Pantheon]
theme-name='elementary'

[org.gnome.desktop.peripherals.touchpad:Pantheon]
natural-scroll=true
tap-to-click=true

[org.gnome.desktop.session:Pantheon]
idle-delay=900" > /usr/share/glib-2.0/schemas/99_$NAME.gschema.override
EOF

#glib-compile-schemas /usr/share/glib-2.0/schemas

echo ADD PERSONAL PACKAGE ARCHIVES
sudo chroot /tmp/rootfs << EOF
for ppa in $PERSONAL_PACKAGE_ARCHVES; do
    add-apt-repository -y "\$ppa"
done
EOF

echo UPDATE REPOSITORIES
sudo chroot /tmp/rootfs << EOF
apt update > /dev/null
EOF

echo INSTALL PACKAGES
sudo chroot /tmp/rootfs << EOF
if [ -n "$INSTALL_PACKAGES" ]; then
    apt install -y $INSTALL_PACKAGES
fi
if [ -n "$REMOVE_PACKAGES" ]; then
    apt remove -y $REMOVE_PACKAGES
fi
EOF

echo CLEAN UP
sudo chroot /tmp/rootfs << EOF
apt autoremove -y
apt autoclean -y
apt clean -y
truncate -s 0 /etc/machine-id
rm /sbin/initctl
dpkg-divert --rename --remove /sbin/initctl
rm -rf /tmp/* /var/lib/apt/lists/* /var/cache/apt/archives/* ~/.bash_history
EOF

sudo chroot /tmp/rootfs umount /proc
sudo chroot /tmp/rootfs umount /sys
sudo chroot /tmp/rootfs umount /dev/pts
sudo umount /tmp/rootfs/dev
sudo umount /tmp/rootfs/run

sudo cp /tmp/rootfs/boot/vmlinuz-**-**-generic /tmp/image/casper/vmlinuz
sudo cp /tmp/rootfs/boot/initrd.img-**-**-generic /tmp/image/casper/initrd

touch /tmp/image/ubuntu

cat <<EOF > /tmp/image/isolinux/grub.cfg

search --set=root --file /ubuntu

insmod all_video

set default="0"
set timeout=30

menuentry "${GRUB_LIVEBOOT_LABEL}" {
linux /casper/vmlinuz boot=casper nopersistent toram quiet splash ---
initrd /casper/initrd
}

menuentry "${GRUB_INSTALL_LABEL}" {
linux /casper/vmlinuz boot=casper only-ubiquity quiet splash ---
initrd /casper/initrd
}

menuentry "Check disc for defects" {
linux /casper/vmlinuz boot=casper integrity-check quiet splash ---
initrd /casper/initrd
}

menuentry "Test memory Memtest86+ (BIOS)" {
linux16 /install/memtest86+
}

menuentry "Test memory Memtest86 (UEFI, long load time)" {
insmod part_gpt
insmod search_fs_uuid
insmod chain
loopback loop /install/memtest86
chainloader (loop,gpt1)/efi/boot/BOOTX64.efi
}
EOF

sudo chroot /tmp/rootfs dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee > /tmp/image/casper/filesystem.manifest
sudo cp -v /tmp/image/casper/filesystem.manifest /tmp/image/casper/filesystem.manifest-desktop

PACKAGE_REMOVE="ubiquity casper discover laptop-detect os-prober"

for pkg in $PACKAGE_REMOVE; do
    sudo sed -i "/$pkg/d" /tmp/image/casper/filesystem.manifest-desktop
done

sudo mksquashfs /tmp/rootfs /tmp/image/casper/filesystem.squashfs \
    -noappend -no-duplicates -no-recovery \
    -wildcards \
    -e "var/cache/apt/archives/*" \
    -e "var/lib/apt/lists/*" \
    -e "root/*" \
    -e "root/.*" \
    -e "tmp/*" \
    -e "tmp/.*" \
    -e "swapfile"
echo $(sudo du -sx --block-size=1 /tmp/rootfs | cut -f1) > /tmp/image/casper/filesystem.size

cat <<EOF > /tmp/image/README.diskdefines
#define DISKNAME  ${GRUB_LIVEBOOT_LABEL}
#define TYPE  binary
#define TYPEbinary  1
#define ARCH  amd64
#define ARCHamd64  1
#define DISKNUM  1
#define DISKNUM1  1
#define TOTALNUM  0
#define TOTALNUM0  1
EOF

cd /tmp/image

grub-mkstandalone \
    --format=x86_64-efi \
    --output=isolinux/bootx64.efi \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=isolinux/grub.cfg"

(
    cd /tmp/image/isolinux && \
    dd if=/dev/zero of=efiboot.img bs=1M count=10 && \
    sudo mkfs.vfat efiboot.img && \
    LC_CTYPE=C mmd -i efiboot.img efi efi/boot && \
    LC_CTYPE=C mcopy -i efiboot.img ./bootx64.efi ::efi/boot/
)

grub-mkstandalone \
    --format=i386-pc \
    --output=isolinux/core.img \
    --install-modules="linux16 linux normal iso9660 biosdisk memdisk search tar ls" \
    --modules="linux16 linux normal iso9660 biosdisk search" \
    --locales="" \
    --fonts="" \
    "boot/grub/grub.cfg=isolinux/grub.cfg"

cat /usr/lib/grub/i386-pc/cdboot.img isolinux/core.img > isolinux/bios.img

sudo /bin/bash -c "(find . -type f -print0 | xargs -0 md5sum | grep -v -e 'md5sum.txt' -e 'bios.img' -e 'efiboot.img' > md5sum.txt)"

sudo xorriso \
    -as mkisofs \
    -iso-level 3 \
    -full-iso9660-filenames \
    -volid "$NAME" \
    -eltorito-boot boot/grub/bios.img \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    --eltorito-catalog boot/grub/boot.cat \
    --grub2-boot-info \
    --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
    -eltorito-alt-boot \
    -e EFI/efiboot.img \
    -no-emul-boot \
    -append_partition 2 0xef isolinux/efiboot.img \
    -output "${CURRENT_DIR}/$NAME.iso" \
    -m "isolinux/efiboot.img" \
    -m "isolinux/bios.img" \
    -graft-points \
       "/EFI/efiboot.img=isolinux/efiboot.img" \
       "/boot/grub/bios.img=isolinux/bios.img" \
       "."

sudo chmod 777 $CURRENT_DIR/$NAME.iso

sleep 1

sudo umount /tmp/rootfs

sudo rm -rf /tmp/rootfs /tmp/image /tmp/rootfs.img
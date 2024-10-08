#!/usr/bin/env bash
export UBUNTU_CODENAME="noble"
export UBUNTU_VERSION="24.04.1"
export UBUNTU_ARCH="amd64"
export UBUNTU_MIRROR="http://us.archive.ubuntu.com/ubuntu/"
export KERNEL_PACKAGE="linux-generic"
export NAME="devos"
export GRUB_LIVEBOOT_LABEL="Try Ubuntu without installing"
export GRUB_INSTALL_LABEL="Install Ubuntu"
export INSTALL_PACKAGES="alsa-base alsa-utils anacron at-spi2-core bc ca-certificates chrome-gnome-shell fonts-cantarell fonts-dejavu-core fonts-freefont-ttf foomatic-db-compressed-ppds gdm3 ghostscript gnome-backgrounds gnome-color-manager gnome-control-center gnome-menus gnome-online-accounts gnome-session gnome-session-canberra gnome-settings-daemon gnome-shell gnome-shell-extensions gnome-themes-extra gnome-tweaks gnome-user-share gsettings-desktop-schemas gstreamer1.0-alsa gstreamer1.0-plugins-base-apps gstreamer1.0-pulseaudio inputattach language-selector-common libatk-adaptor libnotify-bin libsasl2-modules libu2f-udev mutter network-manager openprinting-ppds printer-driver-pnm2ppa pulseaudio rfkill software-properties-gtk spice-vdagent ssh-askpass-gnome system-config-printer-common system-config-printer-udev tracker ubuntu-drivers-common ubuntu-release-upgrader-gtk unzip update-manager update-notifier vanilla-gnome-default-settings wireless-tools wpasupplicant xdg-desktop-portal-gnome xdg-user-dirs xdg-user-dirs-gtk xkb-data xorg zenity zip zsync plymouth-theme-ubuntu-gnome-logo tilix"
export REMOVE_PACKAGES="zutty"

export SYSTEM_THEME="Arc-Dark"
export ICON_THEME="ubuntu-mono-dark"
export CURSOR_THEME="Breeze_Snow"
export META_PACKAGE=""

export BATTERY_LOW="20"
export BATTERY_CRITICAL="5"

#sudo nano /etc/UPower/UPower.conf
# zutty yelp
# vanilla-gnome-desktop vanilla-gnome-default-settings
# ubuntu-desktop-minimal plymouth-theme-ubuntu-gnome-logo

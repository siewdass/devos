#!/usr/bin/env bash

. config.sh

CURRENT_DIR="$(pwd)"

rm -rf $NAME-desktop.deb

mkdir -p /tmp/meta/DEBIAN

echo "Package: $NAME-desktop
Version: 0.01
Architecture: amd64
Maintainer: any <siewdass@gmail.com>
Installed-Size: 13
Depends: $META_PACKAGE
Section: metapackages
Priority: optional
Description: ${NAME^} Meta Package" > /tmp/meta/DEBIAN/control

dpkg-deb -Z xz -b /tmp/meta ${CURRENT_DIR}/packages/$NAME-desktop.deb

rm -rf /tmp/meta

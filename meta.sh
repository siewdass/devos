#!/usr/bin/env bash

. config.sh

CURRENT_DIR="$(pwd)"

rm -rf $NAME-desktop.deb

mkdir -p /tmp/meta/DEBIAN /tmp/meta/usr/share/glib-2.0/schemas

EXTENSIONS="["
cd ${CURRENT_DIR}/extensions &&
for filename in *; do
  if [ "$EXTENSIONS" == "[" ]; then
		EXTENSIONS+="'${filename::-4}'"
	else
		EXTENSIONS+=", '${filename::-4}'"
	fi
done
EXTENSIONS+="]"

echo "Package: $NAME-desktop
Version: 0.01
Architecture: amd64
Maintainer: any <siewdass@gmail.com>
Installed-Size: 13
Depends: $META_PACKAGE
Section: metapackages
Priority: optional
Description: ${NAME^} Meta Package" > /tmp/meta/DEBIAN/control

echo "[org.gnome.desktop.interface]
gtk-theme = '$SYSTEM_THEME'
icon-theme = '$ICON_THEME'
cursor_theme = '$CURSOR_THEME'

[org.gnome.shell]
enabled-extensions = $EXTENSIONS

[org.gnome.shell.extensions.user-theme]
name = '$SYSTEM_THEME'" > /tmp/meta/usr/share/glib-2.0/schemas/${NAME}-settings.gschema.override

dpkg-deb -Z xz -b /tmp/meta ${CURRENT_DIR}/packages/$NAME-desktop.deb > /dev/null

rm -rf /tmp/meta

echo ${CURRENT_DIR}/packages/$NAME-desktop.deb

#!/usr/bin/env bash
mkdir -p packages
dpkg-deb -Z xz -b meta packages/devos-desktop.deb

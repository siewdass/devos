#!/usr/bin/env bash
set -e

. config.sh

qemu-system-x86_64 -boot d -cdrom ${NAME}.iso -smp 4 -m 4096 -enable-kvm 2>/dev/null

#!/bin/bash
# Create initramfs from rootfs

cd /home/shaffinx/Documents/ShaffinX_OS_CLI/rootfs
find . | cpio -H newc -o | gzip > ../build/initramfs.img

echo "Initramfs created: build/initramfs.img"
ls -lh ../build/initramfs.img

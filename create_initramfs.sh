#!/bin/bash
# Create initramfs from rootfs

cd /home/shaffinx/Documents/ShaffinX_OS_CLI/rootfs
find . | cpio -H newc -o | gzip > ../build/initramfs.img

echo "Initramfs created: build/initramfs.img"
ls -lh ../build/initramfs.img

# Also sync installer to iso/installer (they both need to be updated)
echo ""
echo "Syncing installer to iso/installer..."
cd /home/shaffinx/Documents/ShaffinX_OS_CLI
cp -v rootfs/installer/install.sh iso/installer/install.sh
echo "Installer synced successfully"

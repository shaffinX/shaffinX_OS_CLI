#!/bin/bash
# Generate bootable ISO for ShaffinX OS

echo "Creating ShaffinX OS bootable ISO..."

cd /home/shaffinx/Documents/ShaffinX_OS_CLI

# Generate the ISO using grub-mkrescue
grub-mkrescue -o ShaffinX_OS_v1.0.iso iso/

if [ $? -eq 0 ]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║           ISO Created Successfully!                       ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo ""
    ls -lh ShaffinX_OS_v1.0.iso
    echo ""
    echo "You can now:"
    echo "  1. Test in QEMU: qemu-system-x86_64 -cdrom ShaffinX_OS_v1.0.iso -m 512M"
    echo "  2. Burn to USB: dd if=ShaffinX_OS_v1.0.iso of=/dev/sdX bs=4M"
    echo "  3. Test in VirtualBox/VMware"
    echo ""
else
    echo "ERROR: Failed to create ISO"
    exit 1
fi

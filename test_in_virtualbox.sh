#!/bin/bash
# VirtualBox Test Script for ShaffinX OS
# This script helps you quickly test the OS in VirtualBox

VM_NAME="ShaffinX_OS_Test"
ISO_PATH="/home/shaffinx/Documents/ShaffinX_OS_CLI/ShaffinX_OS_v1.0.iso"
DISK_SIZE=2048  # 2GB in MB

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║         ShaffinX OS VirtualBox Test Setup                 ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Check if VirtualBox is installed
if ! command -v VBoxManage &> /dev/null; then
    echo "ERROR: VirtualBox is not installed or VBoxManage is not in PATH"
    exit 1
fi

# Check if ISO exists
if [ ! -f "$ISO_PATH" ]; then
    echo "ERROR: ISO file not found at $ISO_PATH"
    exit 1
fi

# Check if VM already exists
if VBoxManage list vms | grep -q "\"$VM_NAME\""; then
    echo "VM '$VM_NAME' already exists."
    echo -n "Do you want to delete it and create a new one? (yes/no): "
    read CONFIRM
    if [ "$CONFIRM" = "yes" ]; then
        echo "Deleting existing VM..."
        VBoxManage unregistervm "$VM_NAME" --delete 2>/dev/null || true
    else
        echo "Aborted. Please delete the VM manually or use a different name."
        exit 0
    fi
fi

echo "Creating new VM: $VM_NAME"
echo ""

# Create VM
VBoxManage createvm --name "$VM_NAME" --ostype "Linux_64" --register

# Configure VM
echo "Configuring VM..."
VBoxManage modifyvm "$VM_NAME" \
    --memory 1024 \
    --vram 16 \
    --cpus 1 \
    --boot1 dvd \
    --boot2 disk \
    --boot3 none \
    --boot4 none \
    --graphicscontroller vmsvga \
    --audio none

# Create and attach hard disk
echo "Creating virtual hard disk..."
DISK_PATH="$HOME/VirtualBox VMs/$VM_NAME/${VM_NAME}.vdi"
VBoxManage createhd --filename "$DISK_PATH" --size $DISK_SIZE --format VDI

# Add storage controllers
VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$DISK_PATH"

VBoxManage storagectl "$VM_NAME" --name "IDE Controller" --add ide
VBoxManage storageattach "$VM_NAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$ISO_PATH"

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║         VM Created Successfully!                          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "VM Configuration:"
echo "  Name:        $VM_NAME"
echo "  Memory:      1024 MB"
echo "  Video:       16 MB"
echo "  Disk:        2 GB VDI"
echo "  ISO:         Attached"
echo ""
echo "Starting VM..."
echo ""

# Start VM
VBoxManage startvm "$VM_NAME"

echo ""
echo "VM is starting!"
echo ""
echo "Installation Instructions:"
echo "  1. Select 'Install ShaffinX OS CLI' from the boot menu"
echo "  2. Enter '/dev/sda' when prompted for the target disk"
echo "  3. Type 'yes' to confirm installation"
echo "  4. Create your user account and set passwords"
echo "  5. Reboot when installation completes"
echo ""
echo "After Installation:"
echo "  - Remove ISO: VBoxManage storageattach '$VM_NAME' --storagectl 'IDE Controller' --port 0 --device 0 --type dvddrive --medium none"
echo "  - Start VM:   VBoxManage startvm '$VM_NAME'"
echo "  - Delete VM:  VBoxManage unregistervm '$VM_NAME' --delete"
echo ""

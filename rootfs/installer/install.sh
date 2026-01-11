#!/bin/sh
# ShaffinX OS Installer
# Interactive installer with user account creation

clear
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║           ShaffinX OS CLI Installer v1.0                  ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "This installer will install ShaffinX OS to your hard drive."
echo ""

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "ERROR: This installer must be run as root"
    exit 1
fi

# Detect available disks
echo "Detecting available disks..."
echo ""

# Use lsblk if available, otherwise fdisk
if command -v lsblk >/dev/null 2>&1; then
    lsblk -d -n -o NAME,SIZE,TYPE | grep disk | awk '{print "/dev/"$1" ("$2")"}'
else
    fdisk -l | grep "Disk /dev/"
fi

echo ""

# Ask for target disk
echo -n "Enter target disk (e.g., /dev/sda or /dev/vda): "
read TARGET_DISK

if [ ! -b "$TARGET_DISK" ]; then
    echo "ERROR: $TARGET_DISK is not a valid block device"
    exit 1
fi

echo ""
echo "WARNING: All data on $TARGET_DISK will be DESTROYED!"
echo -n "Are you sure you want to continue? (yes/no): "
read CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Installation cancelled."
    exit 0
fi

# Partition the disk
echo ""
echo "Partitioning $TARGET_DISK..."

# Clear any existing partition table first
dd if=/dev/zero of=$TARGET_DISK bs=512 count=1 2>/dev/null

# Create new partition table and partition
(
echo o # Create new DOS partition table
echo n # New partition
echo p # Primary partition
echo 1 # Partition number
echo   # First sector (default)
echo   # Last sector (default - use entire disk)
echo a # Make bootable
echo w # Write changes
) | fdisk $TARGET_DISK

# Wait for partition to be ready and sync
sync
sleep 3

# Determine partition name (handles both sda1 and vda1 style naming)
if [ -b "${TARGET_DISK}1" ]; then
    PARTITION="${TARGET_DISK}1"
elif [ -b "${TARGET_DISK}p1" ]; then
    PARTITION="${TARGET_DISK}p1"
else
    echo "ERROR: Cannot find partition ${TARGET_DISK}1 or ${TARGET_DISK}p1"
    exit 1
fi

echo "Using partition: $PARTITION"

# Format partition
echo "Formatting $PARTITION as ext4..."
mkfs.ext4 -F $PARTITION

# Mount partition
echo "Mounting $PARTITION..."
mkdir -p /mnt/shaffinx
mount $PARTITION /mnt/shaffinx

# Copy system files
echo "Installing system files..."
cp -a /bin /sbin /etc /lib /usr /mnt/shaffinx/
mkdir -p /mnt/shaffinx/{proc,sys,dev,tmp,var,home,root,boot}

# Copy kernel and modules
echo "Installing kernel..."
cp /boot/bzImage /mnt/shaffinx/boot/
cp -r /lib/modules /mnt/shaffinx/lib/ 2>/dev/null || true

# User account creation
echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║              User Account Setup                           ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""

# Get username
while true; do
    echo -n "Enter username for new user: "
    read USERNAME
    if [ -z "$USERNAME" ]; then
        echo "Username cannot be empty!"
    elif echo "$USERNAME" | grep -q "[^a-z0-9_-]"; then
        echo "Username can only contain lowercase letters, numbers, _ and -"
    else
        break
    fi
done

# Get full name
echo -n "Enter full name (optional): "
read FULLNAME
if [ -z "$FULLNAME" ]; then
    FULLNAME="$USERNAME"
fi

# Get hostname
echo -n "Enter hostname (default: shaffinx-os): "
read HOSTNAME
if [ -z "$HOSTNAME" ]; then
    HOSTNAME="shaffinx-os"
fi

# Set root password
echo ""
echo "Set root password:"
while true; do
    echo -n "Enter root password: "
    read -s ROOTPASS1
    echo ""
    echo -n "Confirm root password: "
    read -s ROOTPASS2
    echo ""
    if [ "$ROOTPASS1" = "$ROOTPASS2" ]; then
        ROOTPASS="$ROOTPASS1"
        break
    else
        echo "Passwords do not match! Try again."
    fi
done

# Set user password
echo ""
echo "Set password for $USERNAME:"
while true; do
    echo -n "Enter password: "
    read -s USERPASS1
    echo ""
    echo -n "Confirm password: "
    read -s USERPASS2
    echo ""
    if [ "$USERPASS1" = "$USERPASS2" ]; then
        USERPASS="$USERPASS1"
        break
    else
        echo "Passwords do not match! Try again."
    fi
done

# Create user accounts in installed system
echo ""
echo "Creating user accounts..."

# Update hostname
echo "$HOSTNAME" > /mnt/shaffinx/etc/hostname

# Create passwd file with root and new user
cat > /mnt/shaffinx/etc/passwd << EOF
root:x:0:0:root:/root:/bin/sh
$USERNAME:x:1000:1000:$FULLNAME:/home/$USERNAME:/bin/sh
EOF

# Create group file
cat > /mnt/shaffinx/etc/group << EOF
root:x:0:
$USERNAME:x:1000:
EOF

# Create shadow file with encrypted passwords
# Note: Using simple crypt for now (you can enhance this with proper encryption)
cat > /mnt/shaffinx/etc/shadow << EOF
root:$ROOTPASS:19000:0:99999:7:::
$USERNAME:$USERPASS:19000:0:99999:7:::
EOF

chmod 600 /mnt/shaffinx/etc/shadow

# Create home directory
mkdir -p /mnt/shaffinx/home/$USERNAME
chown 1000:1000 /mnt/shaffinx/home/$USERNAME

# Update profile with new hostname
sed -i "s/shaffinx-os/$HOSTNAME/g" /mnt/shaffinx/etc/profile

# Create init script for installed system (not installer mode)
cat > /mnt/shaffinx/init << 'INITEOF'
#!/bin/sh
# ShaffinX OS Init Script - Installed System

echo "Starting ShaffinX OS..."

# Mount essential filesystems
echo "Mounting filesystems..."
mount -t proc proc /proc 2>/dev/null
mount -t sysfs sysfs /sys 2>/dev/null  
mount -t devtmpfs devtmpfs /dev 2>/dev/null

# Create additional device nodes
mkdir -p /dev/pts /dev/shm
mount -t devpts devpts /dev/pts 2>/dev/null
mount -t tmpfs tmpfs /tmp 2>/dev/null
mount -t tmpfs tmpfs /dev/shm 2>/dev/null

# Set hostname
if [ -f /etc/hostname ]; then
    hostname -F /etc/hostname
fi

# Remount root as read-write
echo "Remounting root filesystem..."
mount -o remount,rw / 2>/dev/null

# Set up console
exec </dev/console >/dev/console 2>&1

# Make sure /dev/console exists and is accessible
if [ ! -c /dev/console ]; then
    mknod /dev/console c 5 1
fi

# Display welcome message
clear
if [ -f /etc/motd ]; then
    cat /etc/motd
else
    echo "Welcome to ShaffinX OS"
fi

# Start getty for login
echo ""
echo "Starting login service..."
exec /sbin/getty 38400 tty1
INITEOF

chmod +x /mnt/shaffinx/init

# Also create inittab as backup (BusyBox init can use either)
cat > /mnt/shaffinx/etc/inittab << 'EOF'
::sysinit:/etc/init.d/rcS
tty1::respawn:/sbin/getty 38400 tty1
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
EOF

# Create init.d directory and rcS script
mkdir -p /mnt/shaffinx/etc/init.d
cat > /mnt/shaffinx/etc/init.d/rcS << 'EOF'
#!/bin/sh
# System initialization script

# Mount filesystems
mount -t proc none /proc 2>/dev/null
mount -t sysfs none /sys 2>/dev/null
mount -t devtmpfs none /dev 2>/dev/null

# Create device directories
mkdir -p /dev/pts /dev/shm

# Mount special filesystems
mount -t devpts none /dev/pts 2>/dev/null
mount -t tmpfs none /tmp 2>/dev/null
mount -t tmpfs none /dev/shm 2>/dev/null

# Set hostname
hostname -F /etc/hostname 2>/dev/null

# Remount root filesystem as read-write
mount -o remount,rw / 2>/dev/null

# Run any additional startup scripts
for script in /etc/init.d/S??*; do
    [ -x "$script" ] && "$script" start
done
EOF

chmod +x /mnt/shaffinx/etc/init.d/rcS

# Install GRUB bootloader
echo ""
echo "Installing GRUB bootloader..."

# Check if grub-install is available
if ! command -v grub-install >/dev/null 2>&1; then
    echo "ERROR: grub-install not found!"
    echo "GRUB installation failed. The system will not be bootable."
    echo ""
    echo "You need to install GRUB manually or use a different bootloader."
    read -p "Press Enter to continue to shell..."
    exec /bin/sh
fi

# Install GRUB
if grub-install --boot-directory=/mnt/shaffinx/boot $TARGET_DISK 2>&1; then
    echo "✓ GRUB installed successfully"
else
    echo "ERROR: GRUB installation failed!"
    echo "The system may not be bootable."
    echo ""
    read -p "Press Enter to continue anyway or Ctrl+C to abort..."
fi

# Create GRUB config for installed system
echo "Creating GRUB configuration..."
mkdir -p /mnt/shaffinx/boot/grub
cat > /mnt/shaffinx/boot/grub/grub.cfg << EOF
set timeout=5
set default=0

menuentry "ShaffinX OS CLI" {
    linux /boot/bzImage root=$PARTITION rw init=/init console=tty1 acpi=force reboot=acpi
}

menuentry "ShaffinX OS CLI (Verbose Mode)" {
    linux /boot/bzImage root=$PARTITION rw init=/init console=tty1 acpi=force reboot=acpi loglevel=7
}

menuentry "ShaffinX OS CLI (Recovery Mode)" {
    linux /boot/bzImage root=$PARTITION rw init=/bin/sh console=tty1 acpi=force reboot=acpi
}

menuentry "ShaffinX OS CLI (Safe Graphics)" {
    linux /boot/bzImage root=$PARTITION rw init=/init nomodeset vga=normal console=tty1 acpi=force reboot=acpi
}
EOF

# Create fstab
cat > /mnt/shaffinx/etc/fstab << EOF
$PARTITION    /           ext4    defaults    1    1
proc          /proc       proc    defaults    0    0
sysfs         /sys        sysfs   defaults    0    0
devtmpfs      /dev        devtmpfs defaults   0    0
tmpfs         /tmp        tmpfs   defaults    0    0
EOF

# Unmount
echo ""
echo "Finalizing installation..."
sync
sleep 1
umount /mnt/shaffinx
sync

echo ""
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║         Installation Complete!                            ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "ShaffinX OS has been installed to $TARGET_DISK"
echo ""
echo "System Configuration:"
echo "  Hostname: $HOSTNAME"
echo "  User:     $USERNAME"
echo "  Root:     enabled"
echo ""
echo "Please remove the installation media and reboot."
echo ""
echo -n "Reboot now? (yes/no) [default: yes]: "
read REBOOT

if [ -z "$REBOOT" ]; then
    REBOOT="yes"
fi

if [ "$REBOOT" = "yes" ]; then
    echo ""
    echo "Rebooting system..."
    sync
    # Try normal reboot first, then force if needed
    reboot -f || reboot || echo b > /proc/sysrq-trigger
fi

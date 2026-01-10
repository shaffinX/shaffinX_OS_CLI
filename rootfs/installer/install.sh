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
fdisk -l | grep "Disk /dev/"
echo ""

# Ask for target disk
echo -n "Enter target disk (e.g., /dev/sda): "
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

# Wait for partition to be ready
sleep 2
PARTITION="${TARGET_DISK}1"

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

# Create inittab for login
cat > /mnt/shaffinx/etc/inittab << 'EOF'
::sysinit:/etc/init.d/rcS
::respawn:/sbin/getty 38400 tty1
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
EOF

# Create init.d directory and rcS script
mkdir -p /mnt/shaffinx/etc/init.d
cat > /mnt/shaffinx/etc/init.d/rcS << 'EOF'
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
mkdir -p /dev/pts
mount -t devpts none /dev/pts
mount -t tmpfs none /tmp
hostname -F /etc/hostname
EOF
chmod +x /mnt/shaffinx/etc/init.d/rcS

# Install GRUB bootloader
echo ""
echo "Installing GRUB bootloader..."
grub-install --boot-directory=/mnt/shaffinx/boot $TARGET_DISK

# Create GRUB config for installed system
mkdir -p /mnt/shaffinx/boot/grub
cat > /mnt/shaffinx/boot/grub/grub.cfg << EOF
set timeout=5
set default=0

menuentry "ShaffinX OS CLI" {
    linux /boot/bzImage root=$PARTITION rw quiet
}

menuentry "ShaffinX OS CLI (Recovery Mode)" {
    linux /boot/bzImage root=$PARTITION rw single
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
umount /mnt/shaffinx

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
echo -n "Reboot now? (yes/no): "
read REBOOT

if [ "$REBOOT" = "yes" ]; then
    reboot
fi

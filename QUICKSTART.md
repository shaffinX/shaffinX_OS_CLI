# ShaffinX OS CLI - Quick Start Guide

## VirtualBox Display Size Fix

### Method 1: Scale the Window
1. Start your VM
2. Click **View** → **Virtual Screen 1** → **Scale to 200%** (or higher)
3. Or just maximize the VirtualBox window

### Method 2: Increase VM Display Settings
1. Power off the VM
2. **Settings** → **Display**
3. Set **Video Memory** to **32 MB**
4. Enable **VBoxVGA** or **VMSVGA** graphics controller
5. Start the VM

### Method 3: Use Full Screen
- Press **Right Ctrl + F** to enter full screen mode
- Press **Right Ctrl + F** again to exit

---

## Installation Process

### Step 1: Boot from ISO
1. Start VM with ShaffinX_OS_v1.0.iso attached
2. GRUB menu appears → Select "Install ShaffinX OS CLI"
3. System boots and shows welcome message

### Step 2: Start Installer
You'll see:
```
  1) Install ShaffinX OS to hard disk
  2) Enter live shell (manual mode)

Select option (1-2) [default: 1]:
```

**Type `1` and press Enter** to start installation

### Step 3: Follow Installation Prompts
The installer will ask for:

1. **Target disk**: `/dev/sda` (usually)
2. **Confirmation**: Type `yes` to proceed
3. **Username**: Your desired username (lowercase, no spaces)
4. **Full name**: Your full name (optional)
5. **Hostname**: System name (default: shaffinx-os)
6. **Root password**: Password for root account (type twice)
7. **User password**: Password for your user account (type twice)

### Step 4: Complete Installation
- Installer will partition disk, copy files, install GRUB
- When done, type `yes` to reboot
- **Remove ISO** from VM settings before reboot

### Step 5: First Boot
- System boots from hard disk
- Shows login prompt
- Login with your username and password
- Enjoy your custom OS!

---

## Troubleshooting

### Screen Too Small
- **Maximize VirtualBox window** (easiest solution)
- Or use View → Scale to 200%
- The text console is 80x25 characters (standard for CLI)

### Installer Doesn't Start
- Make sure you press **1** and then **Enter**
- Or manually run: `/installer/install.sh`

### Can't See Text
- Try "Verbose Mode" from GRUB menu
- Check VirtualBox display settings

### Installation Fails
- Make sure VM has a virtual hard disk attached
- Disk should be at least 2 GB
- Check that you typed `yes` (not `y`) for confirmation

---

## Manual Installation

If automatic installer doesn't work, you can run it manually:

```bash
# At the shell prompt, type:
/installer/install.sh
```

---

## Testing Without Installation

Select option **2** to enter live shell mode and explore:

```bash
# Try these commands:
ls                    # List files
shaffinx-info        # System information
help                 # Show help
uname -a             # Kernel info
free -h              # Memory usage
```

---

## After Installation

### Login
- Username: (what you entered during installation)
- Password: (what you entered during installation)

### Available Commands
All standard Unix commands from BusyBox:
- File operations: `ls`, `cp`, `mv`, `rm`, `mkdir`, `cat`, `grep`
- System: `ps`, `top`, `free`, `df`, `mount`
- Network: `ping`, `wget`, `ifconfig`
- Text: `vi`, `sed`, `awk`, `less`
- Custom: `shaffinx-info`, `help`

### Add Your Own Commands
Put scripts in: `/usr/local/bin/`

---

## Next Steps

1. **Test the OS** - Boot and install in VirtualBox
2. **Customize** - Add your own commands and tools
3. **Expand** - Add package manager, networking, services
4. **Deploy** - Burn to USB or deploy to real hardware

---

## File Locations

- **ISO file**: `ShaffinX_OS_v1.0.iso`
- **Custom commands**: `rootfs/usr/local/bin/`
- **System config**: `rootfs/etc/`
- **Init script**: `rootfs/init`
- **Installer**: `iso/installer/install.sh`

---

## Rebuild After Changes

```bash
# 1. Make changes to rootfs/
# 2. Rebuild initramfs
bash create_initramfs.sh

# 3. Recreate ISO
bash create_iso.sh
```

---

## Support

For issues or questions, check:
- Implementation plan: `implementation_plan.md`
- Task list: `task.md`
- This guide: `QUICKSTART.md`

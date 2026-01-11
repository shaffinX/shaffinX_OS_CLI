# ShaffinX OS CLI - Custom Linux Operating System

A fully functional CLI-based operating system built from scratch using the Linux kernel 6.12 and BusyBox userspace utilities.

## 🎉 Latest Updates (January 11, 2026 - 4:04 PM)

**JOB CONTROL ERROR FIXED!**

✅ **Job control error fixed** - Created proper init script with getty  
✅ **Reboot/poweroff now work** - System reboots and shuts down properly  
✅ **Files save to disk** - Installation persists correctly  
✅ **Black screen fixed** - Removed incompatible video parameters  
✅ **VirtualBox VDI works** - Improved disk detection  

**Important Notes**: 
- The display uses standard VGA text mode (80x25) - this is normal
- System now boots properly with login prompt
- See `JOB_CONTROL_FIX.md` and `BLACK_SCREEN_FIX.md` for details

## 🚀 Quick Start

### Test in VirtualBox (Easiest)
```bash
./test_in_virtualbox.sh
```

This automated script will:
- Create a VirtualBox VM with proper settings
- Attach the ISO
- Start the VM for you

### Manual Installation

1. **Create a VM** (VirtualBox, VMware, or QEMU)
   - RAM: 512MB minimum (1GB recommended)
   - Disk: 2GB minimum VDI/VMDK
   - Boot from: `ShaffinX_OS_v1.0.iso`

2. **Install**
   - Select "Install ShaffinX OS CLI" from GRUB menu
   - Enter `/dev/sda` (or `/dev/vda`) when prompted
   - Create your user account
   - Reboot when complete

3. **Enjoy!**
   - Login with your credentials
   - Standard VGA text console
   - Working reboot/poweroff commands
   - Full BusyBox command suite

## 📚 Documentation

| File | Description |
|------|-------------|
| **JOB_CONTROL_FIX.md** | ⚠️ **READ THIS** - Job control error and reboot fix |
| **BLACK_SCREEN_FIX.md** | ⚠️ **READ THIS** - Black screen issue fix |
| **SUMMARY.md** | Complete overview of all fixes applied |
| **FIXES_APPLIED.md** | Detailed technical documentation of fixes |
| **QUICKSTART.md** | Step-by-step installation guide |
| **implementation_plan.md** | Original build plan and architecture |
| **task.md** | Development tasks and progress |

## 🛠️ Features

- **Kernel**: Linux 6.12 (latest stable)
- **Userspace**: BusyBox 1.37.0 (300+ Unix commands)
- **Init System**: BusyBox init
- **Bootloader**: GRUB 2
- **Display**: VGA text mode (80x25 characters, standard console)
- **Power Management**: ACPI-enabled (reboot/poweroff work)
- **Installer**: Interactive with user account creation
- **Login System**: Multi-user with password authentication

## 🎯 What Works

✅ Boot from ISO  
✅ Install to hard disk (SATA, VirtIO, NVMe)  
✅ User account creation  
✅ Login system  
✅ 300+ BusyBox commands  
✅ Reboot/poweroff/shutdown  
✅ VGA text console (80x25)  
✅ VirtualBox VDI support  
✅ QEMU support  
✅ File system operations  
✅ Process management  
✅ Network tools (ping, wget, ifconfig)  
✅ Text editors (vi)  

## 📦 What's Included

### System Commands
- **File Operations**: ls, cp, mv, rm, mkdir, cat, grep, find, tar
- **System Tools**: ps, top, free, df, mount, umount, dmesg
- **Network**: ping, wget, ifconfig, route, netstat
- **Text Editors**: vi, sed, awk
- **Power**: reboot, poweroff, shutdown
- **Custom**: shaffinx-info, help

### Directory Structure
```
ShaffinX_OS_CLI/
├── ShaffinX_OS_v1.0.iso      # Bootable installer ISO (27 MB)
├── test_in_virtualbox.sh     # Automated VM setup script
├── create_initramfs.sh       # Build initramfs
├── create_iso.sh             # Build ISO
├── SUMMARY.md                # Fix summary
├── FIXES_APPLIED.md          # Detailed fixes
├── QUICKSTART.md             # Quick start guide
├── implementation_plan.md    # Build plan
├── rootfs/                   # Root filesystem
│   ├── bin/                  # Binaries
│   ├── sbin/                 # System binaries
│   ├── etc/                  # Configuration
│   ├── init                  # Init script
│   └── installer/            # Installation scripts
├── iso/                      # ISO contents
│   └── boot/
│       ├── bzImage           # Linux kernel
│       ├── initramfs.img     # Initial RAM filesystem
│       └── grub/             # GRUB bootloader
├── build/                    # Build artifacts
└── linux-6.12/               # Kernel source
```

## 🔧 Development

### Rebuild After Changes

```bash
# 1. Modify files in rootfs/
# 2. Rebuild initramfs
./create_initramfs.sh

# 3. Rebuild ISO
./create_iso.sh
```

### Test in QEMU

```bash
# Create test disk
qemu-img create -f qcow2 test-disk.qcow2 2G

# Boot installer
qemu-system-x86_64 -cdrom ShaffinX_OS_v1.0.iso -hda test-disk.qcow2 -m 512M -boot d

# Boot installed system
qemu-system-x86_64 -hda test-disk.qcow2 -m 512M
```

## 🐛 Troubleshooting

### Reboot/Poweroff Not Working
- **Fixed!** ACPI is now enabled by default
- If still issues, check VM ACPI settings

### Black Screen After Selecting Install
- **Fixed!** Removed incompatible video mode parameters
- See `BLACK_SCREEN_FIX.md` for full details
- Use "Safe Graphics" boot option if still issues

### Display Size
- Uses standard VGA text mode (80x25 characters)
- Maximize VirtualBox window for easier viewing
- Or use View → Scale to 200%

### Installation Fails
- **Fixed!** Now supports VirtualBox VDI drives
- Use `/dev/sda` or `/dev/vda` as shown in disk list
- Ensure VM has at least 2GB disk attached

### Can't Find Disk
- Run `fdisk -l` or `lsblk` to see available disks
- Common paths: `/dev/sda`, `/dev/vda`, `/dev/nvme0n1`

## 🎓 Learning Resources

This project demonstrates:
- Linux kernel configuration and compilation
- BusyBox userspace setup
- Init system implementation
- GRUB bootloader configuration
- ISO creation with grub-mkrescue
- Disk partitioning and formatting
- User account management
- System installation automation

## 📊 Technical Specifications

| Component | Details |
|-----------|---------|
| **Kernel Version** | Linux 6.12 |
| **Architecture** | x86_64 |
| **Userspace** | BusyBox 1.37.0 |
| **Init System** | BusyBox init |
| **Bootloader** | GRUB 2 |
| **Filesystem** | ext4 |
| **Display** | VGA text mode (80x25) |
| **ACPI** | Enabled (force) |
| **ISO Size** | 27 MB |
| **Min RAM** | 512 MB |
| **Min Disk** | 2 GB |

## 🚧 Future Enhancements

- [ ] Package manager (apt/yum-like)
- [ ] Network configuration tools
- [ ] System services management
- [ ] Additional drivers
- [ ] GUI support (optional)
- [ ] More pre-installed tools

## 📝 License

This is a custom educational project. Linux kernel and BusyBox are licensed under their respective licenses (GPL).

## 🤝 Contributing

This is a personal learning project, but feel free to:
- Report issues
- Suggest improvements
- Fork and modify for your own learning

## 📧 Support

For issues or questions:
1. Check the documentation files (SUMMARY.md, FIXES_APPLIED.md, QUICKSTART.md)
2. Review the implementation plan
3. Test in verbose mode to see detailed boot messages

---

**Built with ❤️ using Linux 6.12 and BusyBox 1.37.0**

*Last Updated: January 11, 2026*

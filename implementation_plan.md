# ShaffinX OS CLI - Implementation Plan

Build a fully functional CLI-based Linux operating system from scratch using the Linux kernel 6.12, culminating in a bootable ISO installer.

## User Review Required

> [!IMPORTANT]
> **Build Approach Decision Required**
> 
> This plan uses **BusyBox** for userspace utilities (lightweight, single binary). Alternative approaches include:
> - **Linux From Scratch (LFS)**: Build every component from source (more educational, larger)
> - **Alpine Linux approach**: Use musl libc instead of glibc (smaller, faster)
> - **Buildroot/Yocto**: Automated build systems (more complex setup)
> 
> Please confirm if BusyBox approach is acceptable or if you prefer a different method.

> [!IMPORTANT]
> **Init System Choice**
> 
> This plan implements a **simple custom init script** for maximum simplicity. Alternatives:
> - **BusyBox init**: More features, still lightweight
> - **systemd**: Full-featured but heavy for CLI-only OS
> - **runit/s6**: Lightweight supervision suites
> 
> Please confirm your preference.

> [!WARNING]
> **ISO Type Decision**
> 
> This plan creates a **Live ISO with installer** that:
> - Boots into a live environment
> - Provides an installation script to install to disk
> 
> Alternative: Create a **direct installer ISO** that only installs (no live environment).
> 
> Which approach do you prefer?

---

## Proposed Changes

### Phase 1: Kernel Compilation

Build and install the configured Linux kernel with modules.

#### [MODIFY] [/home/shaffinx/Documents/ShaffinX_OS_CLI/linux-6.12/.config](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/linux-6.12/.config)

The kernel configuration file will be reviewed and optimized for a CLI-only system:
- Disable unnecessary GUI/graphics drivers
- Enable essential filesystem support (ext4, vfat, iso9660)
- Enable necessary networking modules
- Optimize for smaller size if needed

#### Build Scripts

**[NEW]** [build_kernel.sh](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/build_kernel.sh)

Script to compile the kernel with proper settings:
- Set number of parallel jobs based on CPU cores
- Compile kernel image (bzImage)
- Compile and install modules
- Copy kernel to build directory

**Commands to execute:**
```bash
cd linux-6.12
make -j$(nproc)
make modules
make modules_install INSTALL_MOD_PATH=../rootfs
cp arch/x86/boot/bzImage ../build/
```

---

### Phase 2: Root Filesystem Creation

Create a minimal but functional root filesystem with essential utilities.

#### Directory Structure

**[NEW]** [create_rootfs.sh](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/create_rootfs.sh)

Script to create the standard Linux directory hierarchy:
```
rootfs/
├── bin/
├── sbin/
├── etc/
├── proc/
├── sys/
├── dev/
├── home/
├── root/
├── tmp/
├── var/
├── usr/
│   ├── bin/
│   ├── sbin/
│   └── lib/
└── lib/
```

#### BusyBox Integration

**[NEW]** [build_busybox.sh](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/build_busybox.sh)

Download, configure, and build BusyBox (provides ~400 Unix utilities in one binary):
- Download latest stable BusyBox
- Configure for static compilation
- Build and install to rootfs
- Create symlinks for all applets

#### Init System

**[NEW]** [rootfs/init](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/rootfs/init)

Custom init script (executable) that:
- Mounts essential filesystems (proc, sys, dev)
- Sets up hostname
- Configures network (if needed)
- Spawns login shell

```bash
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
mount -t devtmpfs none /dev
# ... additional setup
exec /bin/sh
```

#### System Configuration Files

**[NEW]** [rootfs/etc/fstab](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/rootfs/etc/fstab)

Filesystem table for mounting partitions.

**[NEW]** [rootfs/etc/passwd](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/rootfs/etc/passwd)

User account database (root user).

**[NEW]** [rootfs/etc/group](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/rootfs/etc/group)

Group database.

**[NEW]** [rootfs/etc/hostname](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/rootfs/etc/hostname)

System hostname: `shaffinx-os`

**[NEW]** [rootfs/etc/inittab](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/rootfs/etc/inittab)

Init configuration (if using BusyBox init).

**[NEW]** [rootfs/etc/profile](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/rootfs/etc/profile)

Shell environment configuration.

#### InitramFS Creation

**[NEW]** [create_initramfs.sh](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/create_initramfs.sh)

Script to package the root filesystem into an initramfs (initial RAM filesystem):
```bash
cd rootfs
find . | cpio -H newc -o | gzip > ../build/initramfs.img
```

---

### Phase 3: Bootloader Configuration

Set up GRUB2 bootloader for both live ISO and installed system.

#### GRUB Installation

**[NEW]** [setup_grub.sh](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/setup_grub.sh)

Script to:
- Install GRUB utilities (if not present)
- Create GRUB configuration directory
- Generate boot menu entries

#### GRUB Configuration

**[NEW]** [iso/boot/grub/grub.cfg](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/iso/boot/grub/grub.cfg)

GRUB menu configuration:
```
menuentry "ShaffinX OS CLI" {
    linux /boot/bzImage root=/dev/ram0 rw
    initrd /boot/initramfs.img
}
```

---

### Phase 4: ISO Creation

Create a bootable ISO image with installer functionality.

#### ISO Directory Structure

**[NEW]** [prepare_iso.sh](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/prepare_iso.sh)

Script to create ISO directory structure:
```
iso/
├── boot/
│   ├── grub/
│   │   └── grub.cfg
│   ├── bzImage
│   └── initramfs.img
└── installer/
    └── install.sh
```

#### Installer Script

**[NEW]** [iso/installer/install.sh](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/iso/installer/install.sh)

Installation script that:
- Detects available disks
- Partitions target disk
- Formats partitions
- Copies system files
- Installs GRUB to disk
- Configures fstab for installed system

#### ISO Generation

**[NEW]** [create_iso.sh](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/create_iso.sh)

Script using `grub-mkrescue` or `xorriso` to create bootable ISO:
```bash
grub-mkrescue -o ShaffinX_OS.iso iso/
```

Alternative using xorriso:
```bash
xorriso -as mkisofs \
    -o ShaffinX_OS.iso \
    -b boot/grub/i386-pc/eltorito.img \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    iso/
```

---

### Phase 5: Master Build Script

**[NEW]** [build_all.sh](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/build_all.sh)

Master script that orchestrates the entire build process:
1. Build kernel
2. Build BusyBox
3. Create root filesystem
4. Create initramfs
5. Setup GRUB
6. Prepare ISO structure
7. Generate bootable ISO

---

### Supporting Files

**[NEW]** [README.md](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/README.md)

Documentation covering:
- Project overview
- Build requirements
- Build instructions
- Testing instructions
- Customization guide

**[NEW]** [.gitignore](file:///home/shaffinx/Documents/ShaffinX_OS_CLI/.gitignore)

Ignore build artifacts:
- `build/`
- `rootfs/`
- `iso/`
- `*.iso`
- `busybox-*/`

---

## Verification Plan

### Automated Tests

1. **Build Verification**
   ```bash
   ./build_all.sh
   ```
   Verify all scripts complete without errors.

2. **ISO Integrity Check**
   ```bash
   file ShaffinX_OS.iso
   # Should show: ISO 9660 CD-ROM filesystem
   ```

3. **QEMU Boot Test**
   ```bash
   qemu-system-x86_64 -cdrom ShaffinX_OS.iso -m 512M -boot d
   ```
   Verify system boots to shell prompt.

4. **Installation Test**
   ```bash
   qemu-system-x86_64 -cdrom ShaffinX_OS.iso -hda test_disk.img -m 512M -boot d
   ```
   Run installer script and verify installation to virtual disk.

5. **Installed System Boot Test**
   ```bash
   qemu-system-x86_64 -hda test_disk.img -m 512M
   ```
   Boot from installed system and verify functionality.

### Manual Verification

1. **Core Utilities Test**: Verify essential commands work (ls, cat, grep, etc.)
2. **Filesystem Operations**: Test file creation, deletion, permissions
3. **Network Stack**: Test network configuration (if networking enabled)
4. **Package Size**: Verify ISO size is reasonable (<100MB for minimal system)

### Success Criteria

- ✅ ISO boots successfully in QEMU
- ✅ Shell prompt appears and accepts commands
- ✅ Basic utilities function correctly
- ✅ Installer successfully installs to disk
- ✅ Installed system boots independently
- ✅ System is stable and doesn't crash

---

## Build Requirements

The following tools must be installed on the build system:

**Essential:**
- `gcc`, `make`, `binutils` (kernel compilation)
- `bc`, `flex`, `bison` (kernel build dependencies)
- `cpio`, `gzip` (initramfs creation)
- `grub-mkrescue` or `xorriso` (ISO creation)
- `grub-pc-bin` (GRUB BIOS modules)

**Testing:**
- `qemu-system-x86_64` (virtual machine testing)

**Optional:**
- `git` (version control)
- `wget` or `curl` (downloading BusyBox)

---

## Project Structure

```
ShaffinX_OS_CLI/
├── linux-6.12/              # Kernel source (existing)
├── linux-6.12.tar.xz        # Kernel archive (existing)
├── build/                   # Build artifacts (created)
│   ├── bzImage
│   └── initramfs.img
├── rootfs/                  # Root filesystem (created)
├── iso/                     # ISO staging directory (created)
├── busybox-*/              # BusyBox source (downloaded)
├── build_kernel.sh          # Kernel build script
├── build_busybox.sh         # BusyBox build script
├── create_rootfs.sh         # Rootfs creation script
├── create_initramfs.sh      # Initramfs packaging script
├── setup_grub.sh            # GRUB setup script
├── prepare_iso.sh           # ISO preparation script
├── create_iso.sh            # ISO generation script
├── build_all.sh             # Master build script
├── README.md                # Documentation
└── ShaffinX_OS.iso         # Final bootable ISO (generated)
```

---

## Timeline Estimate

- **Phase 1** (Kernel): ~30-60 minutes (compilation time)
- **Phase 2** (Rootfs): ~20-30 minutes
- **Phase 3** (Bootloader): ~10 minutes
- **Phase 4** (ISO): ~5 minutes
- **Phase 5** (Testing): ~15-30 minutes

**Total**: ~1.5-2.5 hours for complete build and verification

---

## Next Steps After Approval

1. Create all build scripts
2. Create system configuration files
3. Execute kernel compilation
4. Build userspace components
5. Generate bootable ISO
6. Test in virtual machine
7. Document the process in walkthrough

# Inferno OS Boot Image Creation

This directory contains files and instructions for creating bootable
floppy images for Inferno OS on legacy PC hardware (e.g., Lucent Brick 20).

## Prerequisites

- macOS with Homebrew, or Linux
- mtools (`brew install mtools` on macOS)
- QEMU for testing (`brew install qemu` on macOS)

## Quick Start

### 1. Build the toolchain and kernel

```bash
# Set up environment
export ROOT=/path/to/inferno-os
export PATH="$ROOT/MacOSX/amd64/bin:$PATH"

# Build host tools (run from repo root)
./makemk.sh
mk nuke
mk install

# Build the brick20 kernel
cd os/pc
mk CONF=brick20
```

### 2. Create a bootable floppy image

```bash
cd boot_image

# Create blank floppy image and format as FAT12
dd if=/dev/zero of=floppy.img bs=512 count=2880
mformat -i floppy.img -f 1440 -v "INFERNO" ::

# Save FAT header, merge with boot sector code
dd if=floppy.img of=fat_header.bin bs=1 count=62
dd if=../os/boot/pc/pbs of=pbs_padded.bin bs=512 count=1 conv=sync
cat fat_header.bin > new_boot.bin
dd if=pbs_padded.bin bs=1 skip=62 >> new_boot.bin

# Write merged boot sector back (preserving FAT header)
dd if=new_boot.bin of=floppy.img bs=512 count=1 conv=notrunc

# Set _volid to root directory LBA (19 for 1.44MB floppy)
printf '\x13\x00\x00\x00' | dd of=floppy.img bs=1 seek=39 conv=notrunc

# Add boot signature
printf '\x55\xAA' | dd of=floppy.img bs=1 seek=510 conv=notrunc

# Compress kernel and copy files
gzip -c -9 ../os/pc/ibrick20 > ibrick20.gz
mcopy -i floppy.img ../os/boot/pc/9load ::
mcopy -i floppy.img ibrick20.gz ::ibrick20
mcopy -i floppy.img plan9.ini ::

# Verify
mdir -i floppy.img ::
```

### 3. Test with QEMU

```bash
# Basic test (text mode)
qemu-system-i386 -fda floppy.img -boot a -nographic

# With IDE hard drive and RTL8139 network
qemu-system-i386 -fda floppy.img -hda test_hd.img -boot a \
    -net nic,model=rtl8139 -net user -nographic
```

## plan9.ini Configuration

The `plan9.ini` file configures the boot process:

```ini
bootfile=fd0!dos!ibrick20
console=0
baud=9600
```

- `bootfile`: Path to kernel (device!filesystem!file)
- `console=0`: Use first serial port for console
- `baud=9600`: Serial port speed

## Boot Process

1. **BIOS** loads boot sector (pbs) from floppy
2. **pbs** finds and loads 9load from FAT filesystem
3. **9load** reads plan9.ini, decompresses and loads kernel
4. **Kernel** boots with embedded root filesystem

## Using the Live System

After boot, you'll get an Inferno shell. Common operations:

```
; bind -a '#S' /dev           # Bind storage devices
; ls /dev/sd*                  # List IDE drives
; bind -a '#l' /net            # Bind ethernet
; cat /net/ether0/addr         # Show MAC address

# Mount a DOS/FAT partition
; dossrv
; mount -A /chan/dossrv /n/dos /dev/sdC0/data

# Configure network (if DHCP available)
; ip/dhcp
```

## Supported Hardware

The brick20 kernel includes drivers for:

- **Ethernet**: DEC Tulip, Intel 82557, NS DP83815, Realtek 8139, 3Com, VIA Rhine
- **Storage**: IDE/ATA, Floppy
- **Serial**: 8250 UART

## Files

- `plan9.ini` - Boot configuration
- `floppy.img` - Bootable 1.44MB floppy image (after creation)
- `ibrick20.gz` - Compressed kernel (after build)

## Notes

- The boot sector (pbs) uses CHS addressing, compatible with legacy BIOS
- Use `pbslba` instead for LBA mode (not recommended for floppies)
- The embedded root filesystem provides a minimal shell environment
- Additional utilities can be loaded from mounted filesystems

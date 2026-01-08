# Scripts

Utility scripts for HP Mini server management.

## Available Scripts

### mount-usb.sh

USB drive mounting utility for easy external storage management.

**Features:**
- Auto-detect USB drives
- Mount to organized location (`/home/shared/USB-Drives/`)
- Support for multiple filesystems (FAT32, exFAT, NTFS, ext4)
- Safe unmount all drives
- List available USB devices

**Usage:**

```bash
# List available USB devices
sudo ./mount-usb.sh list

# Auto-detect and mount USB drive
sudo ./mount-usb.sh mount

# Mount specific device
sudo ./mount-usb.sh mount /dev/sdb1

# Unmount all USB drives
sudo ./mount-usb.sh unmount

# Show help
sudo ./mount-usb.sh help
```

**Installation on HP Mini:**

```bash
# Copy script to server
scp scripts/mount-usb.sh adminq@hp-mini-server:/home/adminq/

# SSH into server
ssh adminq@hp-mini-server

# Make executable
chmod +x mount-usb.sh

# Move to system location (optional)
sudo mv mount-usb.sh /usr/local/bin/mount-usb
```

**Filesystem Support:**
- ✅ FAT32/vFAT (most USB drives)
- ✅ exFAT (large files > 4GB)
- ✅ NTFS (Windows drives) - requires `ntfs-3g`
- ✅ ext4/ext3/ext2 (Linux drives)

**Install NTFS support:**
```bash
sudo apt install ntfs-3g
```

---

## Creating New Scripts

When adding scripts to this folder:

1. **Use descriptive names:** `action-target.sh` format
2. **Include shebang:** `#!/bin/bash` at the top
3. **Add comments:** Describe purpose and usage
4. **Make executable:** `chmod +x script-name.sh`
5. **Test thoroughly:** Try edge cases
6. **Document:** Add entry to this README

**Template:**

```bash
#!/bin/bash
#
# Script Name and Purpose
#
# Usage:
#   ./script-name.sh [arguments]
#

set -e  # Exit on error

# Your code here
```

---

## Script Standards

- **Shell:** Use Bash (`#!/bin/bash`)
- **Error Handling:** Use `set -e` or check return codes
- **User Feedback:** Echo progress and errors
- **Colors:** Use ANSI colors for better visibility
- **Help:** Include `-h` or `help` command
- **Root Check:** Verify sudo/root if needed

---

## Contributing

Found a bug or have an improvement? Open an issue or pull request!

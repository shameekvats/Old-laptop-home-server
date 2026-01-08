#!/bin/bash
#
# USB Drive Mount Script for HP Mini Server
# Mounts USB drives to /home/shared/USB-Drives/
#
# Usage:
#   sudo ./mount-usb.sh list           # List available USB devices
#   sudo ./mount-usb.sh mount          # Auto-detect and mount USB drive
#   sudo ./mount-usb.sh mount /dev/sdb1 # Mount specific device
#   sudo ./mount-usb.sh unmount        # Unmount all USB drives
#

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base mount directory
MOUNT_BASE="/home/shared/USB-Drives"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script must be run as root${NC}"
    echo "Usage: sudo $0 [command]"
    exit 1
fi

# Create base mount directory if it doesn't exist
mkdir -p "$MOUNT_BASE"

# Function to list available USB devices
list_devices() {
    echo -e "${BLUE}Available USB storage devices:${NC}"
    echo ""
    
    # Find USB storage devices
    for device in /dev/sd[b-z][0-9]*; do
        if [ -e "$device" ]; then
            # Get device info
            device_name=$(basename "$device")
            size=$(lsblk -ndo SIZE "$device" 2>/dev/null || echo "unknown")
            label=$(blkid -s LABEL -o value "$device" 2>/dev/null || echo "no label")
            fstype=$(blkid -s TYPE -o value "$device" 2>/dev/null || echo "unknown")
            
            # Check if mounted
            mount_point=$(findmnt -n -o TARGET "$device" 2>/dev/null || echo "not mounted")
            
            echo -e "${GREEN}$device${NC}"
            echo "  Size: $size"
            echo "  Label: $label"
            echo "  Filesystem: $fstype"
            echo "  Status: $mount_point"
            echo ""
        fi
    done
    
    # Check if no devices found
    if ! ls /dev/sd[b-z][0-9]* 1> /dev/null 2>&1; then
        echo -e "${YELLOW}No USB storage devices found.${NC}"
        echo "Plug in a USB drive and try again."
    fi
}

# Function to auto-detect USB device
detect_usb_device() {
    # Find first unmounted USB partition
    for device in /dev/sd[b-z][0-9]*; do
        if [ -e "$device" ]; then
            # Check if not mounted
            if ! findmnt -n "$device" > /dev/null 2>&1; then
                echo "$device"
                return 0
            fi
        fi
    done
    
    return 1
}

# Function to mount USB device
mount_device() {
    local device=$1
    
    # If no device specified, try to auto-detect
    if [ -z "$device" ]; then
        echo -e "${BLUE}Auto-detecting USB device...${NC}"
        device=$(detect_usb_device)
        if [ -z "$device" ]; then
            echo -e "${RED}Error: No unmounted USB device found${NC}"
            echo "Available devices:"
            list_devices
            exit 1
        fi
        echo -e "${GREEN}Found: $device${NC}"
    fi
    
    # Check if device exists
    if [ ! -e "$device" ]; then
        echo -e "${RED}Error: Device $device does not exist${NC}"
        exit 1
    fi
    
    # Get device label or create default name
    label=$(blkid -s LABEL -o value "$device" 2>/dev/null || echo "")
    if [ -z "$label" ]; then
        # Use device name if no label
        label="USB-$(basename $device)"
    fi
    
    # Create mount point
    mount_point="$MOUNT_BASE/$label"
    mkdir -p "$mount_point"
    
    # Check if already mounted
    if findmnt -n "$device" > /dev/null 2>&1; then
        existing_mount=$(findmnt -n -o TARGET "$device")
        echo -e "${YELLOW}Warning: $device is already mounted at $existing_mount${NC}"
        return 0
    fi
    
    # Detect filesystem type
    fstype=$(blkid -s TYPE -o value "$device" 2>/dev/null || echo "auto")
    
    echo -e "${BLUE}Mounting $device to $mount_point${NC}"
    
    # Mount with appropriate options based on filesystem
    case "$fstype" in
        vfat|fat32|exfat)
            # FAT filesystems - mount with relaxed permissions
            mount -t "$fstype" -o uid=1000,gid=1000,umask=000 "$device" "$mount_point"
            ;;
        ntfs)
            # NTFS - use ntfs-3g if available
            if command -v ntfs-3g &> /dev/null; then
                ntfs-3g -o uid=1000,gid=1000,umask=000 "$device" "$mount_point"
            else
                mount -t ntfs -o uid=1000,gid=1000,umask=000 "$device" "$mount_point"
            fi
            ;;
        ext4|ext3|ext2)
            # Linux filesystems - standard mount
            mount -t "$fstype" "$device" "$mount_point"
            chmod 777 "$mount_point"
            ;;
        *)
            # Auto-detect
            mount "$device" "$mount_point"
            chmod 777 "$mount_point"
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Successfully mounted $device to $mount_point${NC}"
        
        # Show mount info
        size=$(df -h "$mount_point" | awk 'NR==2 {print $2}')
        used=$(df -h "$mount_point" | awk 'NR==2 {print $3}')
        avail=$(df -h "$mount_point" | awk 'NR==2 {print $4}')
        
        echo ""
        echo "Mount Information:"
        echo "  Device: $device"
        echo "  Mount Point: $mount_point"
        echo "  Filesystem: $fstype"
        echo "  Size: $size"
        echo "  Used: $used"
        echo "  Available: $avail"
    else
        echo -e "${RED}✗ Failed to mount $device${NC}"
        rmdir "$mount_point" 2>/dev/null
        exit 1
    fi
}

# Function to unmount all USB drives
unmount_all() {
    echo -e "${BLUE}Unmounting all USB drives...${NC}"
    
    unmounted=0
    
    # Find all mounted drives in USB-Drives folder
    for mount_point in "$MOUNT_BASE"/*; do
        if [ -d "$mount_point" ]; then
            if findmnt -n "$mount_point" > /dev/null 2>&1; then
                device=$(findmnt -n -o SOURCE "$mount_point")
                echo -e "${BLUE}Unmounting $device from $mount_point${NC}"
                
                umount "$mount_point"
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✓ Successfully unmounted $device${NC}"
                    rmdir "$mount_point" 2>/dev/null
                    unmounted=$((unmounted + 1))
                else
                    echo -e "${RED}✗ Failed to unmount $device${NC}"
                fi
            fi
        fi
    done
    
    if [ $unmounted -eq 0 ]; then
        echo -e "${YELLOW}No mounted USB drives found${NC}"
    else
        echo -e "${GREEN}Unmounted $unmounted device(s)${NC}"
    fi
}

# Function to show help
show_help() {
    echo "USB Drive Mount Script for HP Mini Server"
    echo ""
    echo "Usage:"
    echo "  $0 list                  List available USB devices"
    echo "  $0 mount                 Auto-detect and mount USB drive"
    echo "  $0 mount /dev/sdb1       Mount specific device"
    echo "  $0 unmount               Unmount all USB drives"
    echo "  $0 help                  Show this help message"
    echo ""
    echo "Examples:"
    echo "  sudo $0 list             # See all USB devices"
    echo "  sudo $0 mount            # Auto-mount first USB drive"
    echo "  sudo $0 mount /dev/sdb1  # Mount specific partition"
    echo "  sudo $0 unmount          # Safely eject all USB drives"
    echo ""
    echo "Mount Location: $MOUNT_BASE"
}

# Main script logic
case "${1:-help}" in
    list)
        list_devices
        ;;
    mount)
        mount_device "$2"
        ;;
    unmount)
        unmount_all
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Error: Unknown command '$1'${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac

exit 0

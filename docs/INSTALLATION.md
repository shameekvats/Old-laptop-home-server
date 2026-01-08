# Installation Guide

Complete step-by-step guide to installing Debian 12 on old laptops/netbooks and configuring them as headless file servers.

**Target Hardware:** This guide uses an HP Mini netbook as the reference example, but works with any 32-bit laptop or netbook.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Part 1: Download Debian](#part-1-download-debian)
- [Part 2: Create Bootable USB](#part-2-create-bootable-usb)
- [Part 3: Install Debian](#part-3-install-debian)
- [Part 4: First Boot](#part-4-first-boot)
- [Part 5: Post-Installation](#part-5-post-installation)

---

## Prerequisites

### Hardware Required
- Old laptop or netbook (32-bit or 64-bit)
- 8GB+ USB drive (will be erased)
- Ethernet cable (optional, recommended for initial setup)
- Mac or Linux computer (for creating bootable USB)

**Note:** This guide assumes 32-bit (i386) hardware. For 64-bit laptops, download the amd64 ISO instead.

### Information Needed
- WiFi network name (SSID)
- WiFi password
- Desired hostname (e.g., `hp-mini-server`)
- User account name and password

### Time Required
- **Total:** 60-90 minutes
- Download: 10 minutes
- USB creation: 5 minutes
- Installation: 30-40 minutes
- Configuration: 15-30 minutes

---

## Part 1: Download Debian

### Step 1.1: Choose Correct Architecture

⚠️ **CRITICAL:** HP Mini uses 32-bit Intel Atom CPU - you MUST download the **i386** version, NOT amd64.

**Error if wrong:** "kernel requires x86-64 but only detected i686 CPU"

### Step 1.2: Download ISO

**Network Installer (Recommended - 400MB)**
- Direct link: https://cdimage.debian.org/debian-cd/current/i386/iso-cd/
- Download: `debian-12.x.x-i386-netinst.iso`
- Requires internet during installation

**Full DVD (If WiFi won't work - 4GB)**
- Direct link: https://cdimage.debian.org/debian-cd/current/i386/iso-dvd/
- Download: `debian-12.x.x-i386-DVD-1.iso`
- Includes all packages offline

**Verify:** Filename MUST contain `i386`

---

## Part 2: Create Bootable USB

### Method A: Using balenaEtcher (Easiest)

**Step 2A.1: Install balenaEtcher**
```bash
# On Mac with Homebrew
brew install --cask balenaetcher
```

Or download from: https://www.balena.io/etcher/

**Step 2A.2: Create Bootable USB**
1. Insert USB drive
2. Open balenaEtcher
3. "Flash from file" → Select Debian ISO
4. "Select target" → Choose USB drive
5. "Flash!" → Enter password
6. Wait 5 minutes
7. Eject when done

---

### Method B: Using dd Command (Advanced)

```bash
# Find USB drive
diskutil list
# Note the disk number (e.g., /dev/disk4)

# Unmount USB
diskutil unmountDisk /dev/diskX

# Write ISO (CAREFUL - will erase USB!)
sudo dd if=~/Downloads/debian-12.*.iso of=/dev/rdiskX bs=1m

# Eject
diskutil eject /dev/diskX
```

---

## Part 3: Install Debian

### Step 3.1: Boot from USB

1. **Insert bootable USB** into HP Mini
2. **Power on** HP Mini
3. **Press F9** repeatedly (or ESC, then F9)
4. **Select USB drive** from boot menu
5. Press **Enter**

**Troubleshooting:** If F9 doesn't work, try ESC, F2, F10, or F12

### Step 3.2: Start Installer

1. Debian boot menu appears
2. Select: **"Graphical install"**
3. Press Enter

---

### Step 3.3: Installation Wizard

#### Language & Location
- Language: English (or your preference)
- Location: United States (or your country)
- Keyboard: American English

#### Network Configuration

**If using ethernet (recommended):**
- Should auto-configure
- Continue to hostname

**If network fails:**
- Select: **"Do not configure the network at this time"**
- You'll configure WiFi after first boot
- This is normal if using WiFi without firmware

#### Hostname
- Enter: `hp-mini-server` (or your choice)
- Domain: Leave blank

#### User Accounts

**Root password:**
- Enter strong password
- Re-enter to confirm
- **WRITE IT DOWN!**

**New user:**
- Full name: Your name
- Username: `adminq` (or your choice)
- Password: Enter password
- **WRITE IT DOWN!**

#### Disk Partitioning
- Select: **"Guided - use entire disk"**
- Select: Internal hard drive (usually /dev/sda)
- Partitioning: **"All files in one partition"**
- Confirm: **"Finish partitioning and write changes"**
- Write changes? **Yes**

#### Package Manager

**If you configured network:**
- Mirror country: Select closest
- Mirror: `deb.debian.org`
- HTTP proxy: Leave blank

**If no network:**
- This section skipped automatically
- Packages installed from USB only

#### Software Selection

**With network connection:**
- ✅ SSH server (MUST HAVE)
- ✅ Standard system utilities (MUST HAVE)
- ✅ Xfce desktop environment
- ❌ Uncheck everything else

**Without network:**
- ✅ Standard system utilities only
- Install desktop/SSH after first boot

**Installation progress:** Wait 20-40 minutes

#### GRUB Bootloader
- Install GRUB? **Yes**
- Device: `/dev/sda`

#### Finish
- Installation complete!
- **Remove USB drive**
- Press Continue to reboot

---

## Part 4: First Boot

### Step 4.1: Login

**With desktop installed:**
- Login screen appears
- Username: `adminq` (your user)
- Password: (your password)
- Desktop loads

**Without desktop (text mode):**
- Text login prompt
- Login as root or your user
- Continue to post-installation

### Step 4.2: Fix Sudo (If Not Working)

If `sudo` returns "not in sudoers file":

```bash
# Become root
su -

# Add user to sudo group
usermod -aG sudo adminq

# Exit root
exit

# Log out and back in
# Or reboot: sudo reboot
```

### Step 4.3: Connect to Network

**If installed with ethernet:**
- Already connected, skip to Step 4.4

**If need to configure:**

```bash
# Check if NetworkManager installed
which nmcli

# If not installed:
su -
apt install network-manager network-manager-gnome
systemctl enable NetworkManager
systemctl start NetworkManager
exit

# Bring up ethernet
sudo ip link set enp0s3 up  # Replace with your interface name
sudo dhclient enp0s3

# Or use WiFi (requires firmware - see next section)
```

---

## Part 5: Post-Installation

### Step 5.1: Update System

```bash
sudo apt update
sudo apt upgrade -y
```

### Step 5.2: Fix Repositories (If Package Not Found Errors)

```bash
# Add contrib section for WiFi firmware
sudo nano /etc/apt/sources.list
```

Ensure lines include `contrib`:
```
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
```

Save: `Ctrl+O`, Enter, `Ctrl+X`

```bash
sudo apt update
```

### Step 5.3: Install WiFi Firmware

```bash
# Install Broadcom BCM4312 firmware
sudo apt install firmware-b43-installer -y

# Reboot to load driver
sudo reboot
```

### Step 5.4: Connect to WiFi

**Via GUI:**
1. Look for network icon (bottom-right)
2. Click → Enable WiFi
3. Select your network
4. Enter password

**Via Command Line:**
```bash
# Enable WiFi radio
sudo nmcli radio wifi on

# List networks
sudo nmcli device wifi list

# Connect
sudo nmcli device wifi connect "YourSSID" password "YourPassword"

# Set auto-connect
sudo nmcli connection modify "YourSSID" connection.autoconnect yes

# Verify
ip addr show wlan0
ping -c 3 google.com
```

**Disconnect ethernet cable** - you're now wireless!

### Step 5.5: Get IP Address

```bash
ip addr show wlan0 | grep "inet "
# Note the IP address (e.g., 192.168.100.50)
```

### Step 5.6: Test SSH from Another Computer

```bash
# From Mac/Linux terminal
ssh adminq@192.168.100.50  # Use your actual IP

# Accept fingerprint: yes
# Enter password
# You should be connected!
```

---

## ✅ Installation Complete!

Your HP Mini now has:
- ✅ Debian 12 installed
- ✅ Desktop environment (if selected)
- ✅ WiFi working
- ✅ SSH accessible

**Next Steps:**
- [Configuration Guide](CONFIGURATION.md) - Set up headless operation, FileBrowser, Samba
- [Troubleshooting](TROUBLESHOOTING.md) - If you encountered issues

---

## Common Installation Issues

### Network Failed During Install
**Solution:** Select "Do not configure network" and set up WiFi after first boot

### Missing Firmware Warning
**Solution:** Click "Continue without firmware" - install after first boot

### Wrong Architecture Error
**Solution:** Downloaded amd64 instead of i386 - download correct ISO

### Boot Device Not Found
**Solution:** Check BIOS boot order, ensure USB is first

---

**Need help?** Check the [Troubleshooting Guide](TROUBLESHOOTING.md)

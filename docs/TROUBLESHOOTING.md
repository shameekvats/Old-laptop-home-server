# Troubleshooting Guide

Common issues and solutions for HP Mini Server setup.

## Table of Contents

- [Installation Issues](#installation-issues)
- [Network Problems](#network-problems)
- [Service Issues](#service-issues)
- [Access Problems](#access-problems)
- [Performance Issues](#performance-issues)

---

## Installation Issues

### Wrong Architecture Error

**Symptom:** "kernel requires x86-64 but only detected i686 CPU"

**Cause:** Downloaded 64-bit (amd64) ISO instead of 32-bit (i386)

**Solution:**
1. Download correct ISO: `debian-12.x.x-i386-netinst.iso`
2. Recreate bootable USB
3. Verify filename contains `i386`

---

### Network Configuration Failed During Install

**Symptom:** "Network autoconfiguration failed" or "DHCP timeout"

**Cause:** WiFi firmware not included in installer

**Solution:**
- Select: **"Do not configure the network at this time"**
- Continue installation
- Configure WiFi after first boot

**Alternative:** Use ethernet cable during installation

---

### Missing Firmware Warning

**Symptom:** Installer asks for firmware files (b43-open/ucode15.fw, b43/ucode15.fw)

**Cause:** Broadcom WiFi firmware not on installation media

**Solution:**
- Click: **"Continue without loading firmware"**
- Install firmware after first boot: `sudo apt install firmware-b43-installer`

---

### Package Not Found Errors

**Symptom:** `apt install` returns "Unable to locate package"

**Cause:** Repository missing `contrib` section

**Solution:**
```bash
sudo nano /etc/apt/sources.list
```

Ensure lines include `contrib`:
```
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
```

Save and update:
```bash
sudo apt update
```

---

## Network Problems

### WiFi Disabled on Boot

**Symptom:** WiFi radio disabled after reboot, must manually enable

**Cause:** BCM4312 hardware quirk

**Solution:** Create auto-enable script (see [Configuration Guide](CONFIGURATION.md#3-enable-wifi-on-boot))

**Verify:**
```bash
# Check if rc.local exists
ls -la /etc/rc.local

# Check if service is enabled
sudo systemctl is-enabled rc-local.service

# Check logs
sudo journalctl -u rc-local.service
```

---

### WiFi Not Connecting

**Symptom:** WiFi shows networks but won't connect

**Cause:** Multiple possible causes

**Diagnosis:**
```bash
# Check driver loaded
lsmod | grep b43

# Check interface status
ip link show wlan0

# Check for blocks
sudo /usr/sbin/rfkill list all

# Check NetworkManager
sudo systemctl status NetworkManager
```

**Solutions:**

**If driver not loaded:**
```bash
sudo modprobe b43
sudo apt install firmware-b43-installer -y
sudo reboot
```

**If interface down:**
```bash
sudo ip link set wlan0 up
```

**If blocked:**
```bash
sudo rfkill unblock wifi
```

---

### No Default Gateway

**Symptom:** Can ping router but not internet

**Diagnosis:**
```bash
ip route show
# Should show: default via 192.168.x.1
```

**Solution:**
```bash
# Add default gateway (replace with your router IP)
sudo ip route add default via 192.168.100.1 dev wlan0

# Restart NetworkManager
sudo systemctl restart NetworkManager
```

---

### IP Address Changes

**Symptom:** IP address different after reboot

**Solution:** Set static IP or DHCP reservation

**DHCP Reservation (Recommended):**
1. Access router admin panel
2. Find HP Mini MAC address: `ip link show wlan0`
3. Reserve IP for that MAC address

**Static IP:**
```bash
sudo nmcli connection modify "YourWiFiName" \
  ipv4.addresses "192.168.100.50/24" \
  ipv4.gateway "192.168.100.1" \
  ipv4.dns "8.8.8.8" \
  ipv4.method "manual"

sudo nmcli connection down "YourWiFiName"
sudo nmcli connection up "YourWiFiName"
```

---

## Service Issues

### SSH Connection Refused

**Symptom:** `ssh: connect to host 192.168.100.50 port 22: Connection refused`

**Diagnosis:**
```bash
# Check SSH running
sudo systemctl status ssh

# Check SSH listening
sudo ss -tulpn | grep 22
```

**Solutions:**

**If not running:**
```bash
sudo systemctl start ssh
sudo systemctl enable ssh
```

**If firewall blocking:**
```bash
sudo ufw allow ssh
sudo ufw reload
```

---

### FileBrowser Not Accessible

**Symptom:** Browser shows "Can't connect to server" at http://192.168.100.50:8080

**Diagnosis:**
```bash
# Check service status
sudo systemctl status filebrowser

# Check port listening
sudo ss -tulpn | grep 8080
```

**Solutions:**

**If not running:**
```bash
sudo systemctl start filebrowser
sudo systemctl enable filebrowser
```

**If database locked:**
```bash
sudo systemctl stop filebrowser
# Check config, then restart
sudo systemctl start filebrowser
```

**Check logs:**
```bash
sudo journalctl -u filebrowser -n 50
```

---

### Samba Share Not Visible

**Symptom:** Can't see HPMini-Files in Finder

**Diagnosis:**
```bash
# Check Samba running
sudo systemctl status smbd nmbd

# Test configuration
testparm -s
```

**Solutions:**

**If not running:**
```bash
sudo systemctl start smbd nmbd
sudo systemctl enable smbd nmbd
```

**If password not set:**
```bash
sudo smbpasswd -a adminq
```

**Manual connection:**
- Finder → `Cmd+K`
- Enter: `smb://192.168.100.50`
- Username: `adminq`
- Password: (samba password)

---

### System Suspends When Lid Closed

**Symptom:** Can't SSH after closing lid

**Diagnosis:**
```bash
grep HandleLid /etc/systemd/logind.conf
```

**Solution:**
```bash
sudo nano /etc/systemd/logind.conf
```

Uncomment and set:
```ini
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
```

Apply:
```bash
sudo systemctl restart systemd-logind
```

---

## Access Problems

### Forgot Password

**Root password forgotten:**
1. Reboot to GRUB menu
2. Press `e` on Debian entry
3. Find line starting with `linux`
4. Add `init=/bin/bash` at end
5. Press `Ctrl+X` to boot
6. Run: `mount -o remount,rw /`
7. Run: `passwd root`
8. Enter new password
9. Run: `reboot -f`

**User password forgotten (with root access):**
```bash
su -
passwd adminq
```

**FileBrowser password forgotten:**
```bash
sudo systemctl stop filebrowser
sudo filebrowser users update admin -d /etc/filebrowser/filebrowser.db --password newpassword123
sudo systemctl start filebrowser
```

---

### SSH Host Key Changed

**Symptom:** Warning about host key mismatch

**Cause:** Reinstalled system with same IP

**Solution (on Mac/client):**
```bash
ssh-keygen -R 192.168.100.50
```

Then reconnect and accept new key.

---

### Permission Denied Errors

**Symptom:** Can't write files via Samba or FileBrowser

**Diagnosis:**
```bash
ls -ld /home/shared
ls -l /home/shared/
```

**Solution:**
```bash
# Fix ownership
sudo chown -R adminq:adminq /home/shared

# Fix permissions
sudo chmod -R 775 /home/shared
```

---

## Performance Issues

### Very Slow Boot

**Normal:** 90 seconds from power-on to accessible

**If longer:**
- Check WiFi enable delay (15 seconds in rc.local)
- Check systemd services: `systemd-analyze blame`
- Disable unnecessary services

---

### Slow File Transfers

**Expected speeds:**
- WiFi 802.11g: ~25 Mbps real-world
- ~3 MB/s for large files

**If slower:**
- Check WiFi signal strength: `nmcli device wifi list`
- Move HP Mini closer to router
- Check for interference
- Use ethernet cable for large transfers

---

### High CPU Usage

**Check:**
```bash
top
```

**Common causes:**
- Desktop effects (if GUI running)
- Multiple file transfers
- Web browser open on HP Mini

**Solutions:**
- Use headless (close GUI apps)
- Limit concurrent transfers
- Upgrade to SSD (if HDD bottleneck)

---

## Getting Help

### Check Logs

```bash
# System log
sudo journalctl -xe

# Service-specific
sudo journalctl -u ssh
sudo journalctl -u filebrowser
sudo journalctl -u smbd

# Kernel messages
dmesg | tail -50
```

### System Information

```bash
# Debian version
cat /etc/debian_version

# Kernel version
uname -a

# Services status
sudo systemctl status ssh filebrowser smbd

# Network status
ip addr
nmcli device status
```

### Useful Commands

```bash
# Restart network
sudo systemctl restart NetworkManager

# Restart all services
sudo systemctl restart ssh filebrowser smbd nmbd

# Check disk space
df -h

# Check memory
free -h

# Check processes
top
```

---

## Still Having Issues?

1. Check [Installation Guide](INSTALLATION.md) for setup steps
2. Review [Configuration Guide](CONFIGURATION.md) for service setup
3. Search error messages online
4. Check Debian forums and wiki
5. Open an issue on GitHub

---

**Most Common Solutions:**
1. Reboot the system
2. Restart NetworkManager
3. Check IP address hasn't changed
4. Verify services are running
5. Check file permissions

Happy troubleshooting! 🔧

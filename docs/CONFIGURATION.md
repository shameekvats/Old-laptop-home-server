# Configuration Guide

Transform your fresh Debian installation into a fully functional headless file server.

## Table of Contents

- [Headless Operation](#headless-operation)
- [FileBrowser Setup](#filebrowser-setup)
- [Samba File Sharing](#samba-file-sharing)
- [USB Mount Script](#usb-mount-script)
- [Optional Enhancements](#optional-enhancements)

---

## Headless Operation

Configure the HP Mini to run without monitor, keyboard, or mouse.

### 1. Configure Auto-Login

```bash
sudo nano /etc/lightdm/lightdm.conf
```

Add under `[Seat:*]` section:
```ini
[Seat:*]
autologin-user=adminq
autologin-user-timeout=0
```

Save: `Ctrl+O`, Enter, `Ctrl+X`

### 2. Disable Lid Suspend

```bash
sudo nano /etc/systemd/logind.conf
```

Uncomment and set:
```ini
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
HandleLidSwitchDocked=ignore
```

Save and apply:
```bash
sudo systemctl restart systemd-logind
```

### 3. Enable WiFi on Boot

WiFi radio may be disabled on boot. Create auto-enable script:

```bash
sudo nano /etc/rc.local
```

Add content:
```bash
#!/bin/bash
sleep 15
/usr/bin/nmcli radio wifi on
exit 0
```

Save and make executable:
```bash
sudo chmod +x /etc/rc.local
```

Create systemd service:
```bash
sudo nano /etc/systemd/system/rc-local.service
```

Add:
```ini
[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable:
```bash
sudo systemctl enable rc-local.service
sudo systemctl daemon-reload
```

### 4. Test Headless Operation

```bash
sudo reboot
```

Wait 2 minutes, then from another computer:
```bash
ssh adminq@192.168.100.50
```

Close the lid - SSH should stay connected!

---

## FileBrowser Setup

Web-based file manager accessible from any browser.

### 1. Install FileBrowser

```bash
# Install curl if needed
sudo apt install curl -y

# Install FileBrowser
curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash
```

### 2. Create Folder Structure

```bash
# Create shared directory
sudo mkdir -p /home/shared

# Create subfolders
mkdir -p /home/shared/{Documents,Photos,Videos,Music,USB-Drives}

# Set ownership
sudo chown -R $USER:$USER /home/shared
sudo chmod -R 775 /home/shared
```

### 3. Configure FileBrowser

```bash
# Create config directory
sudo mkdir -p /etc/filebrowser

# Initialize database
sudo filebrowser config init -d /etc/filebrowser/filebrowser.db

# Configure settings
sudo filebrowser config set --address 0.0.0.0 -d /etc/filebrowser/filebrowser.db
sudo filebrowser config set --port 8080 -d /etc/filebrowser/filebrowser.db
sudo filebrowser config set --root /home/shared -d /etc/filebrowser/filebrowser.db

# Create admin user (password must be 12+ characters)
sudo filebrowser users add admin yourpassword123 -d /etc/filebrowser/filebrowser.db --perm.admin
```

### 4. Create Systemd Service

```bash
sudo nano /etc/systemd/system/filebrowser.service
```

Add:
```ini
[Unit]
Description=File Browser
After=network.target

[Service]
ExecStart=/usr/local/bin/filebrowser -d /etc/filebrowser/filebrowser.db
User=root
Group=root
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable filebrowser
sudo systemctl start filebrowser
sudo systemctl status filebrowser
```

### 5. Access FileBrowser

Open browser: **http://192.168.100.50:8080**

Login:
- Username: `admin`
- Password: (what you set)

**Change password** immediately in settings!

---

## Samba File Sharing

Native file sharing for Mac Finder and Windows Explorer.

### 1. Install Samba

```bash
sudo apt install samba samba-common-bin -y
```

### 2. Configure Samba

```bash
# Backup config
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

# Edit config
sudo nano /etc/samba/smb.conf
```

Add at the end:
```ini
[HPMini-Files]
   comment = HP Mini Shared Files
   path = /home/shared
   browseable = yes
   read only = no
   writable = yes
   guest ok = no
   valid users = adminq
   create mask = 0775
   directory mask = 0775
```

Save: `Ctrl+O`, Enter, `Ctrl+X`

### 3. Set Samba Password

```bash
sudo smbpasswd -a adminq
# Enter password twice (can be same as user password)
```

### 4. Start Samba

```bash
sudo systemctl enable smbd nmbd
sudo systemctl start smbd nmbd
sudo systemctl status smbd
```

### 5. Connect from Mac

**On Mac:**
1. Finder → `Cmd+K`
2. Enter: `smb://192.168.100.50`
3. Connect
4. Username: `adminq`
5. Password: (samba password)
6. Select: `HPMini-Files`

**Auto-mount on login:**
- System Preferences → Users & Groups → Login Items
- Add the mounted share
- Check "Remember password in keychain"

---

## USB Mount Script

Simple script to mount/unmount USB drives.

**Coming soon** - Script in development

Planned functionality:
- Auto-detect USB drive
- Mount to `/home/shared/USB-Drives/<label>`
- Accessible via FileBrowser and Samba
- Safe unmount command

---

## Optional Enhancements

### Static IP Address

Prevent IP address from changing:

**Option A: DHCP Reservation (Recommended)**
- Access router admin panel
- Find HP Mini's MAC address
- Reserve a static IP (e.g., 192.168.100.50) for that MAC

**Option B: Static IP on Device**
```bash
# Edit NetworkManager connection
sudo nmcli connection modify "YourWiFiName" \
  ipv4.addresses "192.168.100.50/24" \
  ipv4.gateway "192.168.100.1" \
  ipv4.dns "8.8.8.8,8.8.4.4" \
  ipv4.method "manual"

# Restart connection
sudo nmcli connection down "YourWiFiName"
sudo nmcli connection up "YourWiFiName"
```

### Firewall Setup

```bash
# Install UFW
sudo apt install ufw -y

# Allow SSH
sudo ufw allow ssh

# Allow FileBrowser
sudo ufw allow 8080/tcp

# Allow Samba
sudo ufw allow samba

# Enable firewall
sudo ufw enable
```

### Automatic Updates

```bash
# Install unattended-upgrades
sudo apt install unattended-upgrades -y

# Enable
sudo dpkg-reconfigure -plow unattended-upgrades
```

### Tailscale (Remote Access from Anywhere)

```bash
# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Authenticate
sudo tailscale up

# Get Tailscale IP
tailscale ip -4
```

Access from anywhere using Tailscale IP!

---

## Testing

### Verify All Services

```bash
# SSH
sudo systemctl status ssh

# FileBrowser
sudo systemctl status filebrowser

# Samba
sudo systemctl status smbd

# WiFi
nmcli device status
```

### Test Checklist

- [ ] Can SSH with lid closed
- [ ] FileBrowser accessible in browser
- [ ] Can upload file via FileBrowser
- [ ] Samba share appears in Finder
- [ ] Can create folder via Finder
- [ ] WiFi reconnects after reboot
- [ ] Services start on boot

---

## Configuration Files

Example configuration files are in the [`configs/`](../configs/) directory:
- `lightdm.conf.example` - Auto-login
- `logind.conf.example` - Lid behavior
- `smb.conf.example` - Samba share
- `rc.local.example` - WiFi enable script

---

**Configuration Complete!** 🎉

Your HP Mini is now a fully functional headless file server.

**Next:** [Troubleshooting Guide](TROUBLESHOOTING.md) for common issues

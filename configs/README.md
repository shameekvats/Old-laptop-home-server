# Configuration Examples

Example configuration files for HP Mini server setup.

## Important Notes

⚠️ **These are example configurations!**

- Replace placeholders with your actual values
- Backup original files before editing
- Test configurations before deployment
- Remove `.example` extension when deploying

## Available Configurations

### lightdm.conf.example

LightDM display manager configuration for auto-login.

**Purpose:** Enable automatic login on boot for headless operation

**Location on HP Mini:** `/etc/lightdm/lightdm.conf`

**Key Settings:**
- `autologin-user` - User to automatically log in
- `autologin-user-timeout` - Delay before login (0 = immediate)

**Usage:**
```bash
# Backup original
sudo cp /etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf.backup

# Copy example
sudo cp lightdm.conf.example /etc/lightdm/lightdm.conf

# Edit with your username
sudo nano /etc/lightdm/lightdm.conf

# Restart to apply
sudo systemctl restart lightdm
```

**Security Note:** Auto-login means anyone with physical access can access the desktop. Use only for dedicated server setups.

---

### logind.conf.example

Systemd login manager configuration for lid switch behavior.

**Purpose:** Prevent system suspension when laptop lid is closed

**Location on HP Mini:** `/etc/systemd/logind.conf`

**Key Settings:**
- `HandleLidSwitch` - What to do when lid is closed
- `HandleLidSwitchExternalPower` - Behavior when plugged in
- `HandleLidSwitchDocked` - Behavior when docked

**Values:**
- `suspend` - Suspend system (default)
- `hibernate` - Hibernate system
- `ignore` - Do nothing (headless mode)
- `poweroff` - Shut down
- `lock` - Lock screen

**Usage:**
```bash
# Backup original
sudo cp /etc/systemd/logind.conf /etc/systemd/logind.conf.backup

# Copy example
sudo cp logind.conf.example /etc/systemd/logind.conf

# No editing needed (ignore is already set)

# Restart service to apply
sudo systemctl restart systemd-logind
```

**Test:** Close lid, try SSH - should still be accessible

---

### rc.local.example

Boot script for WiFi radio enable workaround.

**Purpose:** Enable Broadcom BCM4312 WiFi radio on boot (hardware quirk fix)

**Location on HP Mini:** `/etc/rc.local`

**Key Components:**
- 15-second delay for hardware initialization
- `nmcli radio wifi on` command
- `exit 0` for proper systemd integration

**Usage:**
```bash
# Copy example
sudo cp rc.local.example /etc/rc.local

# Make executable
sudo chmod +x /etc/rc.local

# Enable rc-local service
sudo systemctl enable rc-local.service

# Test (reboot required)
sudo reboot
```

**After reboot:**
```bash
# Check if WiFi enabled
nmcli radio wifi
# Should output: enabled

# Check service status
sudo systemctl status rc-local.service
```

**Note:** The 15-second delay is essential. Reducing it may cause WiFi to remain disabled.

---

### smb.conf.example

Samba file sharing configuration.

**Purpose:** Share `/home/shared` folder via SMB/CIFS protocol for Mac Finder/Windows Explorer access

**Location on HP Mini:** `/etc/samba/smb.conf`

**Key Settings:**
- `[HPMini-Files]` - Share name (appears in Finder)
- `path` - Directory to share
- `valid users` - Who can access
- `writable` - Allow write access
- `create mask` - File permissions
- `directory mask` - Folder permissions

**Usage:**
```bash
# Backup original
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

# Edit original to add share
sudo nano /etc/samba/smb.conf

# Scroll to bottom, copy the [HPMini-Files] section from example

# Replace "adminq" with your username

# Set Samba password for user
sudo smbpasswd -a your-username

# Test configuration
testparm -s

# Restart Samba
sudo systemctl restart smbd nmbd
```

**Test from Mac:**
1. Finder → `Cmd+K`
2. Enter: `smb://your-server-ip`
3. Username: your-username
4. Password: (samba password you just set)

---

## General Configuration Workflow

### 1. Backup Original
Always backup before editing system files:
```bash
sudo cp /etc/path/to/file /etc/path/to/file.backup
```

### 2. Copy Example
```bash
sudo cp config-name.example /etc/path/to/actual/file
```

### 3. Edit for Your System
Replace placeholders:
- `adminq` → your username
- `YOUR_SERVER_IP` or example IPs → your actual server IP
- `your-password` → actual password
- `/home/shared` → your desired path

### 4. Verify Syntax
Test configuration before applying:
```bash
# Samba
testparm -s

# Systemd units
sudo systemd-analyze verify unit-name.service

# General syntax
cat /etc/path/to/file  # Visual check
```

### 5. Apply Changes
Restart relevant service:
```bash
sudo systemctl restart service-name
```

### 6. Test
Verify the change worked:
```bash
sudo systemctl status service-name
# Check logs
sudo journalctl -u service-name -n 20
```

### 7. Rollback if Needed
If something breaks:
```bash
sudo cp /etc/path/to/file.backup /etc/path/to/file
sudo systemctl restart service-name
```

---

## Configuration Checklist

Before deploying on HP Mini:

- [ ] Backed up original configuration
- [ ] Replaced all placeholders with actual values
- [ ] Removed `.example` extension (if copying whole file)
- [ ] Set correct file permissions
- [ ] Tested syntax (if applicable)
- [ ] Restarted relevant service
- [ ] Verified service is running
- [ ] Tested functionality
- [ ] Documented changes (in notes)

---

## File Permissions

Configuration files typically need root ownership:

```bash
# Most configs
sudo chown root:root /etc/path/to/file
sudo chmod 644 /etc/path/to/file

# Executable scripts (rc.local)
sudo chmod 755 /etc/rc.local
```

---

## Adding New Configurations

When adding new example configs:

1. **Remove sensitive data:**
   - Passwords → `YOUR_PASSWORD_HERE`
   - IPs → `192.168.1.xxx` or `your-server-ip`
   - Usernames → `your-username`
   - Network names → `your-wifi-name`

2. **Add comments:**
   ```ini
   # Comment explaining what this does
   # Default: original-value
   setting=new-value
   ```

3. **Include file location:**
   Add comment at top:
   ```bash
   # Configuration file for: Service Name
   # Location: /etc/path/to/actual/file
   # Purpose: What this configures
   ```

4. **Update this README:**
   Add section documenting the new config

5. **Test:**
   Verify config works on clean Debian system

---

## Troubleshooting

### Configuration Not Taking Effect

1. **Check service restarted:**
   ```bash
   sudo systemctl restart service-name
   ```

2. **Check for syntax errors:**
   ```bash
   sudo journalctl -u service-name -n 50
   ```

3. **Verify file location:**
   ```bash
   ls -la /etc/path/to/file
   ```

4. **Check permissions:**
   ```bash
   ls -l /etc/path/to/file
   # Should be owned by root
   ```

### Service Won't Start

1. **Check logs:**
   ```bash
   sudo journalctl -xe
   sudo systemctl status service-name
   ```

2. **Validate config:**
   Many services have test commands:
   ```bash
   testparm       # Samba
   nginx -t       # nginx
   apache2ctl -t  # Apache
   ```

3. **Restore backup:**
   ```bash
   sudo cp /etc/path/to/file.backup /etc/path/to/file
   sudo systemctl restart service-name
   ```

---

## Security Best Practices

1. **Backup before editing:** Always keep working copy
2. **Test on one service:** Don't change everything at once
3. **Document changes:** Keep notes of what you changed and why
4. **Use strong passwords:** Especially for Samba
5. **Limit access:** Use `valid users` in Samba, firewall rules, etc.
6. **Keep updated:** `sudo apt update && sudo apt upgrade`

---

## See Also

- [Configuration Guide](../docs/CONFIGURATION.md) - Detailed setup walkthrough
- [Troubleshooting Guide](../docs/TROUBLESHOOTING.md) - Common issues
- [Installation Guide](../docs/INSTALLATION.md) - Fresh install instructions

---

**Need Help?** Open an issue on GitHub with your configuration question!

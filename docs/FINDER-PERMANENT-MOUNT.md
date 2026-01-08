# Permanently Mount Samba Share in Mac Finder

Guide to automatically connect your HP Mini Samba share at login.

---

## Quick Method (Login Items)

### Step 1: Connect to Share

1. Open Finder
2. Press `Cmd+K` (or Go → Connect to Server)
3. Enter: `smb://192.168.100.50`
4. Click **Connect**
5. Username: `adminq`
6. Password: (your Samba password)
7. **Check:** "Remember this password in my keychain"
8. Click **Connect**

### Step 2: Add to Login Items

1. Open **System Settings/System Preferences**
2. Go to **General** → **Login Items** (or **Users & Groups** → **Login Items** on older macOS)
3. Under "Open at Login," click **+**
4. Select **HPMini-Files** (should appear under Locations in Finder)
5. Click **Add**

### Step 3: Test

1. Disconnect the share: Right-click HPMini-Files → Eject
2. Log out and log back in
3. Share should automatically reconnect

---

## Advanced Method (AppleScript Auto-Mount)

For more control or if Login Items doesn't work:

### Step 1: Save Credentials in Keychain

1. Connect once with "Remember this password" checked (as above)
2. Verify in **Keychain Access** → Search for your server IP
3. Should see network password entry

### Step 2: Create AppleScript

Open **Script Editor** and paste:

```applescript
tell application "Finder"
    try
        -- Check if already mounted
        if not (disk "HPMini-Files" exists) then
            -- Mount the share (credentials from Keychain)
            mount volume "smb://adminq@192.168.100.50/HPMini-Files"
        end if
    end try
end tell
```

### Step 3: Save as Application

1. **File** → **Export**
2. Save as: `MountHPMini.app`
3. Location: `~/Applications/` or anywhere
4. File Format: **Application**
5. Click **Save**

### Step 4: Add to Login Items

1. System Settings → General → Login Items
2. Click **+**
3. Navigate to `MountHPMini.app`
4. Click **Add**

---

## Command Line Method (Advanced)

### Create Auto-Mount Script

```bash
# Create script
nano ~/mount-hpmini.sh
```

Paste:

```bash
#!/bin/bash

# Wait for network (optional)
sleep 5

# Check if already mounted
if [ ! -d "/Volumes/HPMini-Files" ]; then
    # Mount using stored Keychain credentials
    osascript -e 'mount volume "smb://adminq@192.168.100.50/HPMini-Files"'
fi
```

Make executable:

```bash
chmod +x ~/mount-hpmini.sh
```

### Add to Login Items

1. Wrap script in Automator or use LaunchAgent (see below)

**OR**

2. System Settings → Login Items → Click **+** → Select `mount-hpmini.sh`

---

## LaunchAgent Method (Most Reliable)

### Step 1: Create LaunchAgent

```bash
nano ~/Library/LaunchAgents/com.user.mount-hpmini.plist
```

Paste:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.mount-hpmini</string>
    
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/osascript</string>
        <string>-e</string>
        <string>mount volume "smb://adminq@192.168.100.50/HPMini-Files"</string>
    </array>
    
    <key>RunAtLoad</key>
    <true/>
    
    <key>StandardErrorPath</key>
    <string>/tmp/mount-hpmini.err</string>
    
    <key>StandardOutPath</key>
    <string>/tmp/mount-hpmini.out</string>
</dict>
</plist>
```

### Step 2: Load LaunchAgent

```bash
launchctl load ~/Library/LaunchAgents/com.user.mount-hpmini.plist
```

### Step 3: Test

```bash
# Unmount
umount /Volumes/HPMini-Files

# Reload agent
launchctl unload ~/Library/LaunchAgents/com.user.mount-hpmini.plist
launchctl load ~/Library/LaunchAgents/com.user.mount-hpmini.plist

# Check if mounted
ls /Volumes/HPMini-Files
```

---

## Troubleshooting

### Share Doesn't Auto-Mount

**Check Keychain:**
1. Open **Keychain Access**
2. Search for your server IP or hostname
3. Double-click the entry
4. Click **Access Control**
5. Select: "Allow all applications to access this item"

**Test Manual Mount:**
```bash
# Terminal test
osascript -e 'mount volume "smb://adminq@192.168.100.50/HPMini-Files"'
```

If this prompts for password, credentials aren't in Keychain.

---

### Login Item Not Running

**Verify Login Item:**
1. System Settings → General → Login Items
2. Ensure item is checked/enabled
3. Try removing and re-adding

**Check Permissions:**
- macOS may ask to allow the script/app to run
- System Settings → Privacy & Security → allow the app

---

### IP Address Changed

**If HP Mini IP changes:**

Update all references to your server IP in:
- AppleScript
- LaunchAgent plist
- Keychain entries

**Better Solution:** Set static IP or DHCP reservation on router

---

### Mount Point Already Exists

If you see "already mounted" but can't access:

```bash
# Force unmount
diskutil unmount force /Volumes/HPMini-Files

# Try mounting again
osascript -e 'mount volume "smb://adminq@192.168.100.50/HPMini-Files"'
```

---

### Slow to Connect at Login

**Cause:** Mac tries to mount before WiFi fully connects

**Solution:** Add delay to script:

```bash
#!/bin/bash
sleep 10  # Wait for network
osascript -e 'mount volume "smb://adminq@192.168.100.50/HPMini-Files"'
```

---

## Recommended Method

**For most users:** Use **Quick Method (Login Items)**
- Simplest setup
- Uses native Keychain
- Reliable on modern macOS

**For advanced users:** Use **LaunchAgent Method**
- Most reliable
- Better error logging
- Can add retry logic

---

## Verify It Works

1. **Disconnect share:** Eject HPMini-Files in Finder
2. **Restart Mac**
3. **After login:** HPMini-Files should appear in Finder sidebar under "Locations"
4. **Test access:** Open share, browse files

---

## Alternative: Add to Finder Sidebar

Even without auto-mount, you can quick-access:

1. Connect to share manually once
2. Drag **HPMini-Files** to Finder sidebar under "Favorites"
3. Click to reconnect anytime (credentials from Keychain)

---

## Security Note

Auto-mounting uses Keychain to store credentials. This is secure but means anyone who logs into your Mac account can access the share.

**To require password each time:**
- Don't check "Remember password"
- Connect manually when needed

---

## See Also

- [Configuration Guide](CONFIGURATION.md) - Samba setup on HP Mini
- [Troubleshooting Guide](TROUBLESHOOTING.md) - Connection issues

---

Happy auto-mounting! 🗂️

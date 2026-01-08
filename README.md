# Old Laptop Home Server

![HP Mini Server](images/hp-mini-1.jpg)

Transform old laptops and netbooks into functional headless home servers for file sharing, remote access, and network storage.

## 📋 Project Overview

This project documents the complete process of converting legacy 32-bit laptops and netbooks into low-power, headless file servers accessible via SSH, web browser, and native file sharing. The guide uses an HP Mini netbook as the reference hardware, but **works with most old 32-bit laptops**.

### Key Features

- 🖥️ **Headless Operation** - Runs with lid closed, no monitor needed
- 📡 **WiFi Connectivity** - Wireless operation after initial setup
- 🔐 **SSH Access** - Remote terminal access from any device
- 🌐 **Web File Manager** - FileBrowser for browser-based file management
- 📁 **Samba Sharing** - Native Mac Finder/Windows Explorer integration
- 💾 **USB Storage Support** - Simple script for mounting external drives
- ⚡ **Low Power** - ~10-15W operation, perfect for 24/7 use

## 🖼️ Gallery

| Web Interface | Headless Setup | HP Mini Server |
|----------------|----------------|---------------|
| ![HP Mini](images/hp-mini-1.jpg) | ![Headless](images/hp-mini-2.jpg) | ![FileBrowser](images/hp-mini-3.jpg) |

## 🔧 Hardware Requirements

**Reference Hardware (HP Mini):**
| Component | Specification |
|-----------|---------------|
| **Model** | HP Mini (Netbook) |
| **CPU** | Intel Atom 1.60 GHz (32-bit) |
| **RAM** | 2 GB DDR2 |
| **WiFi** | Broadcom BCM4312 802.11b/g |
| **Storage** | 160-320GB HDD |
| **Power** | ~10-15W typical |

**Compatible With:**
- Any 32-bit (i686/i386) laptop or netbook
- 64-bit hardware (use amd64 Debian instead)
- Minimum 2GB RAM recommended
- WiFi or Ethernet connectivity

**Note:** This guide focuses on 32-bit hardware, as many modern distributions no longer support i386. Debian 12 still provides excellent 32-bit support!

## ✨ What You Get

### Access Methods

1. **SSH** - Command-line access
   ```bash
   ssh user@hp-mini-server.local
   ```

2. **FileBrowser** - Web interface at `http://hp-mini-server.local:8080`
   - Upload/download files
   - Create folders
   - Text editor
   - File preview

3. **Samba** - Native file sharing
   - Connect from Mac: `smb://hp-mini-server.local`
   - Appears in Finder sidebar
   - Drag-and-drop file operations

## 🚀 Quick Start

### Prerequisites

- Old laptop or netbook (32-bit or 64-bit)
- 8GB+ USB drive (for installation media)
- Ethernet cable (optional, for initial setup)
- WiFi network credentials
- 1-2 hours of time

### Installation Steps

1. **[Download Debian 12 (i386)](docs/INSTALLATION.md#download-debian)**
2. **[Create bootable USB](docs/INSTALLATION.md#create-bootable-usb)**
3. **[Install Debian](docs/INSTALLATION.md#install-debian)** (~30 minutes)
4. **[Configure system](docs/CONFIGURATION.md)** (~30 minutes)
5. **[Test and deploy](docs/CONFIGURATION.md#testing)**

**Full documentation:** [Installation Guide](docs/INSTALLATION.md)

## � Tested Hardware

### Confirmed Working
- ✅ **HP Mini** (Intel Atom N270, 2GB RAM) - Reference hardware for this guide
- ✅ **32-bit laptops** - Most Intel/AMD 32-bit CPUs
- ✅ **64-bit laptops** - Use amd64 Debian ISO instead

### Report Your Hardware
Tested this guide on different hardware? Please open an issue or PR to add your results!

**Format:**
```
- ✅/⚠️ Model Name (CPU, RAM) - Notes
```

---

## �📚 Documentation

- **[Installation Guide](docs/INSTALLATION.md)** - Step-by-step Debian installation
- **[Configuration Guide](docs/CONFIGURATION.md)** - Post-install setup and services
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[Project Journey](docs/PROJECT-JOURNEY.md)** - Detailed development log

## 🛠️ Software Stack

| Component | Purpose |
|-----------|---------|
| **Debian 12 (Bookworm)** | Base operating system (i386) |
| **Xfce Desktop** | Lightweight GUI (~500MB RAM) |
| **OpenSSH** | Remote access |
| **FileBrowser** | Web-based file manager |
| **Samba** | SMB/CIFS file sharing |
| **NetworkManager** | WiFi management |

## ⚙️ Features Implemented

- ✅ Auto-login on boot
- ✅ Lid close doesn't suspend
- ✅ WiFi auto-connect on boot
- ✅ SSH server enabled
- ✅ Web file manager (FileBrowser)
- ✅ Samba file sharing (Mac/Windows)
- ✅ Organized folder structure
- ⏳ USB mount script (in progress)

## 📊 Performance Expectations

- **Boot time:** ~90 seconds (power-on to fully accessible)
- **Power consumption:** 10-15W typical
- **WiFi speed:** ~25 Mbps real-world (802.11g limitation)
- **Concurrent users:** 2-3 (RAM limited)
- **Best for:** Light file sharing, personal cloud, home NAS

## 🎯 Use Cases

Perfect for:
- Personal file server
- Network attached storage (NAS)
- Media file repository
- Document sharing within household
- Learning Linux server administration
- Repurposing old hardware

## 🔐 Security Considerations

- Change default passwords immediately
- Use SSH keys instead of passwords (optional)
- Configure firewall if exposing to internet
- Keep system updated: `sudo apt update && sudo apt upgrade`
- Consider VPN (Tailscale) for remote access

## 🌍 Remote Access

For access from outside your home network, consider:
- **Tailscale** - Zero-config VPN (recommended)
- **Port forwarding** - Requires router configuration
- **Dynamic DNS** - For changing IP addresses

See [Configuration Guide](docs/CONFIGURATION.md#remote-access) for setup instructions.

## 📁 Repository Structure

```
.
├── README.md                    # This file
├── docs/
│   ├── INSTALLATION.md         # Installation guide
│   ├── CONFIGURATION.md        # Configuration guide
│   ├── TROUBLESHOOTING.md      # Common issues
│   └── PROJECT-JOURNEY.md      # Development history
├── scripts/
│   └── mount-usb.sh           # USB mount script (coming soon)
├── configs/
│   ├── lightdm.conf.example   # Auto-login config
│   ├── logind.conf.example    # Lid behavior config
│   └── smb.conf.example       # Samba config
├── images/                     # Project photos
└── .gitignore
```

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

**Ways to contribute:**
- Report hardware compatibility (open an issue with your laptop model)
- Submit documentation improvements
- Share troubleshooting solutions
- Add translation support

## 📝 License

This project documentation is released under the [MIT License](LICENSE). Free to use, modify, and share.

## 🙏 Acknowledgments

- Debian community for maintaining i386 support
- FileBrowser project for the excellent web interface
- Everyone who keeps old hardware alive and out of landfills

## 📧 Contact

**Author:** Shameek Vats  
**Project Type:** Open source tutorial  
**Status:** Operational and documented

---

⭐ **Found this helpful?** Star the repo and share with others looking to repurpose old laptops!

## 🔗 Useful Resources

- [Debian Installation Guide](https://www.debian.org/releases/bookworm/i386/)
- [FileBrowser Documentation](https://filebrowser.org/)
- [Samba Documentation](https://www.samba.org/samba/docs/)

---

**Last Updated:** January 8, 2026

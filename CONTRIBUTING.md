# Contributing to HP Mini Server Project

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Ways to Contribute

### 1. Documentation Improvements
- Fix typos or clarify instructions
- Add missing steps or explanations
- Improve troubleshooting guides
- Add translations

### 2. Code Contributions
- Improve existing scripts
- Add new utility scripts
- Fix bugs or errors
- Optimize performance

### 3. Hardware Testing
- Test on different HP Mini models
- Test with other 32-bit netbooks
- Report compatibility issues
- Share hardware specs

### 4. Issue Reporting
- Report bugs or errors
- Suggest new features
- Share configuration problems
- Document workarounds

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/HP-Mini-Server-Project.git
   ```
3. **Create a branch:**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Making Changes

### Documentation Changes

1. Edit relevant `.md` files in `docs/` or root
2. Follow existing formatting style
3. Test links and code blocks
4. Commit with clear message:
   ```bash
   git commit -m "docs: improve WiFi troubleshooting section"
   ```

### Code Changes

1. Edit or create scripts in `scripts/`
2. Follow bash scripting best practices
3. Test thoroughly on Debian system
4. Add comments for complex logic
5. Update script README if needed
6. Commit with clear message:
   ```bash
   git commit -m "feat: add automatic backup script"
   ```

### Configuration Examples

1. Edit or create files in `configs/`
2. Remove sensitive information (IPs, passwords, usernames)
3. Add comments explaining each setting
4. Use `.example` extension
5. Update relevant documentation
6. Commit:
   ```bash
   git commit -m "config: add nginx example configuration"
   ```

## Commit Message Guidelines

Follow conventional commit format:

- `docs:` - Documentation changes
- `feat:` - New features
- `fix:` - Bug fixes
- `config:` - Configuration examples
- `script:` - Script improvements
- `chore:` - Maintenance tasks

**Examples:**
```
docs: add section on static IP configuration
feat: add USB auto-mount script
fix: correct WiFi enable delay in rc.local
config: add FileBrowser systemd service example
```

## Pull Request Process

1. **Update documentation** if you changed functionality
2. **Test your changes** on real hardware if possible
3. **Update CHANGELOG** (if we add one later)
4. **Push to your fork:**
   ```bash
   git push origin feature/your-feature-name
   ```
5. **Create Pull Request** on GitHub
6. **Describe your changes** clearly in PR description

### Pull Request Checklist

- [ ] Changes are tested
- [ ] Documentation is updated
- [ ] Commit messages follow guidelines
- [ ] No sensitive information included (passwords, IPs)
- [ ] Code follows existing style
- [ ] Scripts include help/usage information

## Code Style Guidelines

### Shell Scripts

```bash
#!/bin/bash
#
# Script description
# Usage: ./script.sh [options]
#

set -e  # Exit on error

# Use descriptive variable names
mount_base="/home/shared"

# Add comments for complex logic
# Check if device is already mounted
if findmnt -n "$device" > /dev/null 2>&1; then
    echo "Already mounted"
fi

# Use functions for organization
function mount_device() {
    local device=$1
    # Function logic here
}
```

### Documentation

- Use clear, concise language
- Include code examples
- Add command output examples
- Explain **why**, not just **what**
- Use proper Markdown formatting

### Configuration Files

```ini
# Comment explaining what this setting does
# Default: value
SettingName=value

# Example for specific use case
# For HP Mini with 2GB RAM:
CacheSizeMB=256
```

## Sensitive Information

**Never commit:**
- Passwords or credentials
- IP addresses (use placeholders like `192.168.1.xxx`)
- Usernames (use `adminq` or `your-username`)
- SSH keys
- Personal email addresses
- Actual network names

**Use instead:**
- `YOUR_PASSWORD_HERE` or `********`
- `192.168.1.xxx` or `your-server-ip`
- `your-username` or generic names
- Example credentials clearly marked as examples
- `your-network-name` for WiFi SSIDs

## Testing Guidelines

### Before Submitting

1. **Scripts:**
   - Test on Debian 12 (32-bit) if possible
   - Test error conditions
   - Test with different inputs
   - Verify help/usage works

2. **Documentation:**
   - Check all links work
   - Verify code blocks are correct
   - Test commands on actual system
   - Ensure formatting renders correctly

3. **Configurations:**
   - Verify syntax is correct
   - Test on clean Debian install if possible
   - Document any dependencies

## Hardware Compatibility

If testing on different hardware:

### Report Format

**Model:** HP Mini 210
**CPU:** Intel Atom N455 1.66GHz (32-bit)
**RAM:** 1GB
**WiFi:** Realtek RTL8188CE
**Issues:** WiFi driver required `rtl8192ce` instead of `b43`
**Resolution:** Used `sudo apt install firmware-realtek`

## Getting Help

- **Questions:** Open an issue with "Question:" prefix
- **Discussions:** Use GitHub Discussions (if enabled)
- **Bugs:** Open an issue with detailed description
- **Features:** Open an issue with "Feature Request:" prefix

## Issue Template

```markdown
**Description:**
Clear description of issue or feature

**Hardware:**
- Model: HP Mini 210
- CPU: Intel Atom N455
- RAM: 1GB

**Software:**
- Debian Version: 12.x
- Kernel: (uname -r output)

**Steps to Reproduce:** (for bugs)
1. Step one
2. Step two
3. Error occurs

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Logs:** (if applicable)
```
Include relevant error messages
```

**Additional Context:**
Any other helpful information
```

## Recognition

Contributors will be acknowledged in:
- Project README
- Release notes (if we add them)
- GitHub contributors page

## Code of Conduct

### Our Standards

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what's best for the project
- Show empathy towards others

### Unacceptable Behavior

- Harassment or discrimination
- Trolling or insulting comments
- Personal attacks
- Publishing private information

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Questions?

Open an issue with your question or contact the maintainer!

---

**Thank you for contributing to the HP Mini Server Project!** 🎉

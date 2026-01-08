# Images

This folder contains images used in the HP Mini Server project documentation.

## Files

- **hp-mini-1.jpg** - HP Mini server hardware/setup
- **hp-mini-2.jpg** - Headless operation with lid closed
- **hp-mini-3.jpg** - FileBrowser web interface or system information

## Source Files

Original images are in HEIC format and excluded from git (see `.gitignore`). The JPG versions are generated using macOS `sips` command:

```bash
sips -s format jpeg hp-mini-X.HEIC --out images/hp-mini-X.jpg
```

## Adding New Images

1. Take photo in HEIC or JPG format
2. Convert to JPG if needed: `sips -s format jpeg source.HEIC --out images/name.jpg`
3. Optimize for web: `sips -Z 1920 images/name.jpg` (resize to max 1920px)
4. Add to git: `git add images/name.jpg`
5. Update documentation with image reference

## Image Guidelines

- **Format:** JPG or PNG
- **Max Size:** 1920px width for documentation
- **Naming:** Descriptive lowercase with hyphens (e.g., `hp-mini-setup.jpg`)
- **Privacy:** Don't include passwords, IP addresses, or personal information

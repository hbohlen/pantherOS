# Dank Linux Installation Guide

**Last Updated:** 2025-11-15 10:16:10  
**Author:** MiniMax Agent  
**Purpose:** Streamlined installation procedures for Dank Linux

## Quick Installation

### One-Command Installation
```bash
curl -fsSL https://install.danklinux.com | sh
```

**Supported Distributions:**
- Arch Linux + Derivatives
- Fedora + Derivatives  
- Ubuntu
- Debian
- openSUSE
- Gentoo

## Distribution-Specific Installation

### Arch Linux

#### Install Core Components
```bash
# Install AUR helper (if needed)
sudo pacman -S --needed git base-devel
paru -S yay  # or use your preferred AUR helper

# Install DMS and suite
paru -S dankmaterialshell-git dgop danksearch dankinstall

# Install display manager
sudo pacman -S greetd
```

#### Post-Installation Setup
```bash
# Enable greetd
sudo systemctl enable greetd
sudo systemctl start greetd

# Configure DMS
dms greeter enable
dms greeter sync
```

### Fedora

#### Install from COPR Repository
```bash
# Enable Dank Linux COPR
sudo dnf copr enable avengemedia/danklinux

# Install DMS and suite
sudo dnf install dankmaterialshell dgop danksearch dankinstall

# Install greetd
sudo dnf install greetd
```

#### Post-Installation Setup
```bash
# Enable greetd
sudo systemctl enable greetd
sudo systemctl start greetd

# Configure DMS
dms greeter enable
dms greeter sync
```

### Ubuntu/Debian

#### Manual Installation
```bash
# Install system dependencies
sudo apt update
sudo apt install greetd quickshell git curl wget

# Install Go (for danksearch)
sudo apt install golang-go

# Clone DMS repository
sudo git clone https://github.com/AvengeMedia/DankMaterialShell.git /opt/dankmaterialshell

# Install DMS
cd /opt/dankmaterialshell
sudo make install

# Install additional tools
sudo cp tools/dgop/target/release/dgop /usr/local/bin/
sudo cp tools/danksearch/danksearch /usr/local/bin/
sudo cp tools/dankinstall/dankinstall /usr/local/bin/
```

#### Set Up Greetd
```bash
# Configure greetd
sudo nano /etc/greetd/config.toml
```

Add to `/etc/greetd/config.toml`:
```toml
[terminal]
vt = 1

[default_session]
user = "greeter"
command = "dms-greeter --command niri"
```

### NixOS

#### Add to configuration.nix
```nix
{ pkgs, ... }: {
  # Add Dank Linux packages
  environment.systemPackages = with pkgs; [
    dankmaterialshell
    dgop
    danksearch  
    dankinstall
    greetd
    quickshell
  ];
  
  # Enable greetd service
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        user = "greeter";
        command = "dms-greeter --command niri";
      };
    };
  };
  
  # Start services
  systemd.services.greetd.enable = true;
}
```

#### Rebuild System
```bash
sudo nixos-rebuild switch
```

### openSUSE

#### Install Dependencies
```bash
# Add repository and install
sudo zypper addrepo https://download.opensuse.org/repositories/home:avengemedia/openSUSE_Leap_15.6/home:avengemedia.repo
sudo zypper refresh
sudo zypper install dankmaterialshell dgop danksearch dankinstall

# Install additional dependencies
sudo zypper install greetd quickshell golang
```

## Greeter Configuration

### Automated Setup (Recommended)

For dankinstall users:
```bash
# Complete automated setup
dms greeter install
dms greeter enable  
dms greeter sync

# Log out and log back in for group changes
```

For Arch/Fedora users:
```bash
# Automated setup
dms greeter enable
dms greeter sync
```

### Manual Setup

#### 1. Configure greetd
```bash
sudo nano /etc/greetd/config.toml
```

Basic configuration:
```toml
[terminal]
vt = 1

[default_session]
user = "greeter"
command = "dms-greeter --command niri"

# Alternative compositors:
# command = "dms-greeter --command Hyprland"
# command = "dms-greeter --command sway" 
```

#### 2. Disable Other Display Managers
```bash
sudo systemctl disable gdm lightdm sddm lxdm
```

#### 3. Enable greetd
```bash
sudo systemctl enable greetd
sudo systemctl start greetd
```

#### 4. Configure Permissions
```bash
# Add user to greeter group
sudo usermod -a -G greeter $USER

# Set up ACL permissions
sudo setfacl -m g:greeter:x ~/
sudo setfacl -m g:greeter:rx ~/.config/

# Log out and log back in
```

## Verification

### Check Installation
```bash
# Verify DMS installation
dms --version

# Check greetd status
systemctl status greetd

# Test DMS configuration
dms --validate-config
```

### Common Verification Commands
```bash
# Check if DMS is running
ps aux | grep dms

# Verify widget loading
dms --debug --list-widgets

# Test basic functionality
dms --reload
```

## Troubleshooting

### Greeter Issues

#### Greeter Won't Start
```bash
# Check greetd logs
sudo journalctl -u greetd -f

# Test greeter manually
sudo -u greeter dms-greeter --command niri

# Verify configuration
dms greeter check-config
```

#### Permission Errors
```bash
# Fix permissions
sudo chown -R greeter:greeter /var/cache/dms-greeter
sudo chmod -R 755 /var/cache/dms-greeter

# Re-run sync
dms greeter sync
```

### DMS Issues

#### DMS Won't Start
```bash
# Check DMS logs
journalctl -u dms -f

# Test configuration
dms --validate-config

# Check dependencies
ldd $(which dms)
```

#### Widget Loading Errors
```bash
# Validate widget configuration
dms --validate-widgets

# Debug specific widget
dms --debug --widget launcher

# Reload configuration
dms --reload
```

## Next Steps

After successful installation:

1. **Configure Keybindings**: Set up your preferred keybindings
2. **Customize Theme**: Apply your preferred color scheme  
3. **Install Applications**: Add your essential applications
4. **Setup Development**: Configure development environment if needed
5. **Import Settings**: Migrate settings from previous desktop environment

## Support

- **Documentation**: https://danklinux.com/docs/
- **GitHub**: https://github.com/AvengeMedia
- **Discord**: niri discord server (dms-* channels)

---

**Related Documents:**
- [Dank Linux Master Guide](./00_dank_linux_master_guide.md)
- [Compositor Setup](./03_compositor_setup.md)
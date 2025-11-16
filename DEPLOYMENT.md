# NixOS VPS Deployment Guide

## Overview
This guide covers deploying NixOS to your OVH VPS using the configuration in this repository.

## Prerequisites

### Local Machine (Your Laptop)
- Nix installed with flakes enabled
- SSH access to your VPS (current Fedora installation)
- 1Password CLI configured with service account token
- Your service account token: `export OP_SERVICE_ACCOUNT_TOKEN="your-token"`

### Target Server (OVH VPS)
- Fedora 42 (current installation)
- 200GB disk
- Root or sudo access
- At least 2GB RAM (we have 23GB)

## Deployment Steps

### Step 1: Export 1Password Service Account Token
```bash
export OP_SERVICE_ACCOUNT_TOKEN="your-service-account-token-here"
```

### Step 2: Verify Configuration Structure
```bash
cd ~/dev/pantherOS

# Verify files exist
ls -la flake.nix
ls -la hosts/servers/ovh-cloud/
```

Expected files:
- `flake.nix` - Main flake definition
- `hosts/servers/ovh-cloud/configuration.nix` - System configuration
- `hosts/servers/ovh-cloud/disko-config.nix` - Disk layout
- `hosts/servers/ovh-cloud/home.nix` - User configuration

### Step 3: Lock Flake (First Time Only)
```bash
nix flake lock
```

### Step 4: Verify the Configuration Builds
```bash
# Build the system configuration
nix build .#nixosConfigurations.ovh-cloud.config.system.build.nixosSystem

# Or test in a VM
nix run github:nix-community/nixos-anywhere -- --flake .#ovh-cloud --vm-test
```

### Step 5: Deploy to VPS via nixos-anywhere

**Method A: Password Authentication (for first-time setup)**
```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#ovh-cloud \
  --target-host root@<YOUR_VPS_IP_ADDRESS> \
  --disk-config hosts/servers/ovh-cloud/disko-config.nix
```

**Method B: SSH Key Authentication (recommended)**
```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#ovh-cloud \
  --target-host root@<YOUR_VPS_IP_ADDRESS> \
  --disk-config hosts/servers/ovh-cloud/disko-config.nix \
  -i ~/.ssh/id_ed25519
```

**Method C: Using SSH Password (via env variable)**
```bash
export SSHPASS="your-root-password"
nix run github:nix-community/nixos-anywhere -- \
  --flake .#ovh-cloud \
  --target-host root@<YOUR_VPS_IP_ADDRESS> \
  --disk-config hosts/servers/ovh-cloud/disko-config.nix \
  --env-password
```

### Step 6: Wait for Installation
The deployment will:
1. Partition the disk (EFI + Root)
2. Install NixOS base system
3. Apply configuration
4. Reboot automatically

**Duration:** ~5-10 minutes

### Step 7: Verify Deployment

**SSH into the new NixOS system:**
```bash
ssh hbohlen@<YOUR_VPS_IP_ADDRESS>
# OR if using Tailscale, once connected:
ssh hbohlen@ovh-cloud
```

**Check system status:**
```bash
# Verify NixOS
cat /etc/os-release

# Check services
systemctl status tailscaled
systemctl status sshd

# Verify packages
nix --version
claude --version
gh --version
op --version
```

### Step 8: Connect to Tailscale

**If not auto-connected:**
```bash
sudo tailscale up --authkey="$(cat /var/run/secrets/opnix-1password/op://pantherOS/tailscale/authKey | head -n 1)"
```

**Or manually:**
```bash
sudo tailscale up
# Follow authentication URL
```

### Step 9: Verify All Services

**Claude Code:**
```bash
# Set your API key
export ANTHROPIC_API_KEY="your-api-key"

# Test Claude
claude doctor
```

**1Password CLI:**
```bash
# Authenticate (one-time)
op signin

# Verify access
op vault list
```

**GitHub CLI:**
```bash
# Authenticate with GitHub
gh auth login

# Use token from 1Password
export GITHUB_TOKEN=$(op read op://pantherOS/github-pat/token)
echo $GITHUB_TOKEN | gh auth login --with-token
```

## Configuration Details

### Disk Layout
```
/dev/sda
├── /dev/sda1 (ESP) - 512MB, vfat, mounted at /boot
└── /dev/sda2 (root) - remaining space, ext4, mounted at /
```

### Enabled Services
- **OpenSSH**: Key-based authentication only
- **Tailscale**: VPN with auto-connect
- **1Password CLI**: Secret management
- **Claude Code**: AI coding assistant
- **GitHub CLI**: GitHub integration
- **Firewall**: Enabled with Tailscale access

### User Accounts
- **root**: SSH keys from 1Password (no password)
- **hbohlen**: Admin user with wheel group

### Secrets (via OpNix)
All secrets retrieved from 1Password vault:
- SSH public keys (yogaSSH, zephyrusSSH, phoneSSH, desktopSSH)
- Tailscale auth key
- GitHub PAT

### Network Access
- **Primary**: SSH over standard IP
- **VPN**: SSH over Tailscale (once connected)

## Troubleshooting

### Can't Connect After Reboot
```bash
# Check if SSH is running
systemctl status sshd

# Check firewall
sudo iptables -L

# Check Tailscale status
sudo tailscale status
```

### Tailscale Not Auto-Connecting
```bash
# Check systemd service
systemctl status tailscale-autoconnect

# Manual connection
sudo tailscale up --authkey="$(cat /var/run/secrets/opnix-1password/op://pantherOS/tailscale/authKey | head -n 1)"
```

### 1Password CLI Not Working
```bash
# Set service account token
export OP_SERVICE_ACCOUNT_TOKEN="your-token"

# Verify authentication
op whoami
```

### Configuration Changes
```bash
# Edit configuration
vim ~/dev/pantherOS/hosts/servers/ovh-cloud/configuration.nix

# Rebuild and switch
nixos-rebuild switch --flake ~/dev/pantherOS#ovh-cloud

# Or from remote
nixos-rebuild switch --flake git@github.com:youruser/pantherOS.git#ovh-cloud --target-host root@SERVER_IP
```

### Rollback
```bash
# List previous generations
sudo nix-env --list-generations

# Rollback to previous generation
sudo nix-env --rollback

# Or from GRUB menu (select previous entry)
```

## Post-Deployment

### Update Configurations
1. Clone this repo on the server: `git clone https://github.com/youruser/pantherOS.git`
2. Make changes to `hosts/servers/ovh-cloud/configuration.nix`
3. Rebuild: `nixos-rebuild switch --flake ./pantherOS#ovh-cloud`

### Add More Services
Edit `configuration.nix` and add:
```nix
# Example: Add nginx
services.nginx.enable = true;

# Example: Add docker
virtualisation.docker.enable = true;

# Rebuild
nixos-rebuild switch --flake .#ovh-cloud
```

### Backup Configuration
```bash
# Commit to git
git add .
git commit -m "Update configuration"
git push

# Or copy configuration
cp -r hosts/servers/ovh-cloud ~/backup-nixos-config-$(date +%Y%m%d)
```

## Useful Commands

### System Info
```bash
nixos-info                    # Show NixOS information
systemctl list-units --failed # Check failed services
journalctl -p err -b         # Check error logs
```

### Nix Commands
```bash
nix search nixpkgs PACKAGE    # Search for packages
nix-env -iA nixos.PACKAGE     # Install package (non-declarative)
nix-collect-garbage          # Clean old generations
nixos-rebuild build          # Build system without switching
```

### Service Management
```bash
systemctl restart SERVICENAME   # Restart service
systemctl edit SERVICENAME      # Edit service override
journalctl -u SERVICENAME -f    # Follow service logs
```

## Additional Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Wiki](https://nixos.wiki/)
- [nixos-anywhere Documentation](https://github.com/nix-community/nixos-anywhere)
- [OpNix Documentation](https://github.com/brizzbuzz/opnix)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

---

**Note:** This configuration is optimized for a remote development server with emphasis on:
- Security (key-only SSH, firewall)
- Convenience (Tailscale, 1Password, Claude Code)
- Maintainability (declarative configuration, flakes)
- Performance (minimal overhead, efficient tooling)

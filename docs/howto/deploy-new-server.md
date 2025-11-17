# How To: Deploy a New Server

> **Category:** How-To Guide  
> **Audience:** System Administrators, DevOps Engineers  
> **Last Updated:** 2025-11-17

This guide provides step-by-step instructions for deploying pantherOS to a new cloud VPS server.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Deployment Steps](#deployment-steps)
- [Verification](#verification)
- [Post-Deployment Configuration](#post-deployment-configuration)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Local Machine Requirements

- **Nix** installed with flakes enabled
  ```bash
  # Check if Nix is installed
  nix --version
  
  # Enable flakes (if not already enabled)
  mkdir -p ~/.config/nix
  echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
  ```

- **SSH access** to target server (root or sudo privileges)
- **Git** for cloning the repository
- **Your SSH public key** ready to add to configuration

### Target Server Requirements

- Any Linux distribution (will be replaced with NixOS)
- At least 200GB disk space (or adjust disko.nix)
- Minimum 2GB RAM (recommended: 4GB+)
- Internet connectivity

## Deployment Steps

### 1. Clone the Repository

```bash
git clone https://github.com/hbohlen/pantherOS.git
cd pantherOS
```

### 2. Review and Customize Configuration

Choose or create a host configuration for your server. Existing templates:
- `hosts/servers/ovh-cloud/` - OVH VPS template
- `hosts/servers/hetzner-cloud/` - Hetzner VPS template

**Review the configuration files:**

```bash
# System configuration
cat hosts/servers/ovh-cloud/configuration.nix

# Disk layout (IMPORTANT: adjust for your disk size)
cat hosts/servers/ovh-cloud/disko.nix

# User environment
cat hosts/servers/ovh-cloud/home.nix
```

### 3. Add Your SSH Key

**Edit the configuration file** to add your SSH public key:

```bash
vim hosts/servers/ovh-cloud/configuration.nix
```

**Find and update** the SSH keys section:

```nix
users.users.hbohlen.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAA... your-public-key-here"
];
```

> **Important:** Without a valid SSH key, you won't be able to access the server after deployment!

### 4. Adjust Disk Configuration (if needed)

If your server has a different disk size or layout:

```bash
vim hosts/servers/ovh-cloud/disko.nix
```

The default layout uses:
- 100MB for EFI
- 1GB for /boot
- Remaining space for root (with btrfs subvolumes)

### 5. Test Configuration Build

Before deploying, verify the configuration is valid:

```bash
# Check flake syntax
nix flake check

# Test build (doesn't deploy, just builds locally)
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel
```

If this succeeds, your configuration is valid.

### 6. Deploy to Server

Use **nixos-anywhere** for automated deployment:

```bash
# Replace YOUR_SERVER_IP with actual IP address
nix run github:nix-community/nixos-anywhere -- \
  --flake .#ovh-cloud \
  --target-host root@YOUR_SERVER_IP
```

**For password-based SSH access** (if no key is set up yet):

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#ovh-cloud \
  --target-host root@YOUR_SERVER_IP \
  --env-password
```

**What happens during deployment:**
1. Connects to target server via SSH
2. Partitions disk according to `disko.nix`
3. Installs NixOS base system
4. Applies your configuration from `configuration.nix`
5. Installs user environment from `home.nix`
6. Reboots into new NixOS system

**Expected duration:** 5-15 minutes depending on network speed

## Verification

### 1. Connect to the Server

Wait ~1 minute after reboot, then connect:

```bash
ssh hbohlen@YOUR_SERVER_IP
```

> Replace `hbohlen` with your configured username

### 2. Verify System

```bash
# Check NixOS version
cat /etc/os-release

# Verify services are running
systemctl status sshd

# Check Nix version
nix --version

# Verify shell
echo $SHELL
```

### 3. Test User Environment

```bash
# Check Home Manager
home-manager --version

# Test installed tools
starship --version
eza --version
ripgrep --version
gh --version
```

## Post-Deployment Configuration

### Update System Configuration

After initial deployment, you can make changes:

```bash
# 1. Edit configuration locally
vim hosts/servers/ovh-cloud/configuration.nix

# 2. Test build
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel

# 3. Deploy changes remotely
nixos-rebuild switch --flake .#ovh-cloud \
  --target-host hbohlen@YOUR_SERVER_IP \
  --use-remote-sudo
```

### Update User Environment

```bash
# Edit home.nix
vim hosts/servers/ovh-cloud/home.nix

# Deploy (from the server)
ssh hbohlen@YOUR_SERVER_IP
home-manager switch --flake .#ovh-cloud
```

### Rollback to Previous Generation

If something goes wrong:

```bash
# On the server
sudo nixos-rebuild switch --rollback

# Or select from GRUB menu at boot
```

## Troubleshooting

### Deployment Fails

**SSH Connection Issues:**
- Verify server is accessible: `ssh root@YOUR_SERVER_IP`
- Check firewall rules on target server
- Ensure correct IP address

**Disk Partitioning Errors:**
- Check disk size matches `disko.nix` configuration
- Verify disk device name (might be `/dev/vda` instead of `/dev/sda`)
- Review disko.nix for correct device path

**Build Failures:**
- Run `nix flake check` to verify configuration syntax
- Check error messages for missing or invalid options
- Review recent changes to configuration files

### Can't SSH After Deployment

**No SSH Key Configured:**
- You must add your SSH key before deployment
- If forgotten, you'll need console access to fix

**Wrong Username:**
- Check `users.users.<name>` in configuration.nix
- Default username in examples is `hbohlen`

**Firewall Blocking SSH:**
- SSH (port 22) should be open by default
- Check `networking.firewall.allowedTCPPorts` in configuration

### System Doesn't Boot

**GRUB Issues:**
- Access server console/VNC if available
- Select previous generation from GRUB menu
- Check boot partition configuration in disko.nix

**Kernel Panic:**
- Boot into previous generation
- Review hardware-specific modules needed
- Check dmesg logs for errors

### Configuration Errors

**Syntax Errors:**
```bash
# Validate Nix syntax
nix flake check
nixos-rebuild dry-build --flake .#ovh-cloud
```

**Module Not Found:**
- Check all imported modules exist
- Verify paths in `imports = [ ... ]`

## See Also

- [Operations Documentation](../ops/) - Hardware profiles and operational guides
- [Deployment Overview](../../DEPLOYMENT.md) - Original deployment documentation
- [Configuration Reference](../reference/configuration-summary.md) - What's configured
- [Infrastructure Documentation](../infra/) - NixOS concepts and tooling
- [nixos-anywhere Documentation](https://github.com/nix-community/nixos-anywhere)

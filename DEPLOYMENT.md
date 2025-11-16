# NixOS VPS Deployment Guide

**AI Agent Context**: Simple deployment guide for the minimal NixOS configuration.

## Overview
This guide covers deploying NixOS to an OVH VPS using the minimal configuration in this repository.

## Prerequisites

### Local Machine
- Nix installed with flakes enabled
- SSH access to target server
- Git (to clone this repository)

### Target Server (OVH VPS)
- Any Linux distribution (will be replaced)
- 200GB disk (or adjust disko.nix for your size)
- Root or sudo access
- At least 2GB RAM recommended

## Deployment Steps

### Step 1: Clone Repository
```bash
git clone https://github.com/hbohlen/pantherOS.git
cd pantherOS
```

### Step 2: Review and Customize Configuration

**AI Agent Context**: Before deploying, review and customize these files.

```bash
# Review system configuration
cat hosts/servers/ovh-cloud/configuration.nix

# Review disk layout (adjust if needed)
cat hosts/servers/ovh-cloud/disko.nix

# Review user configuration
cat hosts/servers/ovh-cloud/home.nix
```

**Important**: Add your SSH public key to `configuration.nix`:
```nix
users.users.hbohlen.openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAA... your-key-here"
];
```

### Step 3: Test Configuration Build
```bash
# Check flake syntax
nix flake check

# Test build (doesn't deploy)
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel
```

### Step 4: Deploy to Server

**Using nixos-anywhere (recommended):**
```bash
# Deploy with SSH key authentication
nix run github:nix-community/nixos-anywhere -- \
  --flake .#ovh-cloud \
  --target-host root@YOUR_SERVER_IP

# Or with password (will prompt)
nix run github:nix-community/nixos-anywhere -- \
  --flake .#ovh-cloud \
  --target-host root@158.69.218.24 \
  --disk-config hosts/servers/ovh-cloud/disko.nix \
  --env-password
```

**What happens during deployment:**
1. Connects to target server via SSH
2. Partitions disk according to disko.nix
3. Installs NixOS base system
4. Applies configuration from configuration.nix
5. Reboots into new NixOS system

**Duration:** ~5-15 minutes depending on network speed

### Step 5: Verify Deployment

**SSH into the new NixOS system:**
```bash
ssh hbohlen@YOUR_SERVER_IP
```

**Check system status:**
```bash
# Verify NixOS
cat /etc/os-release
# Should show: NixOS 25.05

# Check services
systemctl status sshd

# Verify packages
nix --version
fish --version
```

### Step 6: Test User Environment

```bash
# Check Home Manager
home-manager --version

# Verify shell
echo $SHELL
# Should show: /run/current-system/sw/bin/fish

# Test installed tools
starship --version
eza --version
ripgrep --version
```

## Configuration Details

**AI Agent Context**: What's actually configured in the system.

### Disk Layout (via disko.nix)
```
/dev/sda (default device, configurable)
├── ESP (100MB) - vfat, mounted at /boot/efi
├── Boot (1GB) - ext4, mounted at /boot
└── Root (remaining) - btrfs with subvolumes
    ├── root → /
    ├── home → /home
    └── var → /var
```

### Enabled Services
- **OpenSSH**: Key-based authentication only (password auth disabled)
- **Firewall**: Basic firewall enabled

### User Accounts
- **hbohlen**: Normal user with wheel, networkmanager, podman groups
- **Sudo**: Enabled for wheel group without password

### System Packages
- Basic tools: htop, unzip, zip, openssh
- Build tools: gcc, gnumake, pkg-config

### User Packages (via Home Manager)
- Shell: fish (with starship prompt)
- CLI tools: eza, ripgrep, bottom, zoxide
- Dev tools: gh, git, neovim, direnv, nix-direnv
- Utilities: 1password-cli (for secrets management)

### System Settings
- Timezone: UTC
- Locale: en_US.UTF-8
- Console: US keymap, Lat2-Terminus16 font

## Making Configuration Changes

### Update System Configuration

```bash
# 1. Edit configuration on your local machine
vim hosts/servers/ovh-cloud/configuration.nix

# 2. Test build
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel

# 3. Deploy changes
# Option A: From server (if repo is cloned there)
ssh hbohlen@SERVER_IP
cd /path/to/pantherOS
sudo nixos-rebuild switch --flake .#ovh-cloud

# Option B: Remote deployment
nixos-rebuild switch --flake .#ovh-cloud --target-host hbohlen@SERVER_IP --use-remote-sudo
```

### Update User Configuration

```bash
# Edit home.nix
vim hosts/servers/ovh-cloud/home.nix

# Deploy (after system rebuild)
home-manager switch --flake .#ovh-cloud
```

### Rollback to Previous Generation

```bash
# On the server
sudo nixos-rebuild switch --rollback

# Or select from GRUB menu at boot
```

## Troubleshooting

### Can't Connect After Deployment
```bash
# Check if SSH is accessible
ping SERVER_IP

# Try connecting with verbose output
ssh -v hbohlen@SERVER_IP

# Check if server rebooted successfully
# (may need console access via hosting provider)
```

### Build Errors

```bash
# Check flake syntax
nix flake check

# Show detailed errors
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel --show-trace
```

### Deployment Hangs

```bash
# If nixos-anywhere hangs, you may need to:
# 1. Check server is responsive
# 2. Verify SSH access
# 3. Check disk space on target
# 4. Review deployment logs
```

## Common Tasks

### Add System Package

```nix
# In configuration.nix
environment.systemPackages = with pkgs; [
  htop
  # Add your package here
  vim
];
```

### Add User Package

```nix
# In home.nix
home.packages = with pkgs; [
  starship
  # Add your package here
  bat
];
```

### Enable a Service

```nix
# In configuration.nix
services.nginx = {
  enable = true;
  # ... additional configuration
};
```

### Update All Packages

```bash
# Update flake inputs
nix flake update

# Review changes
git diff flake.lock

# Rebuild system
sudo nixos-rebuild switch --flake .#ovh-cloud
```

### Clean Old Generations

```bash
# Remove old system generations (keep last 5)
sudo nix-collect-garbage --delete-older-than 30d

# Or keep specific number
sudo nix-collect-garbage --delete-generations +5
```

## Useful Commands

### System Management
```bash
# View system information
nixos-version

# Check failed services
systemctl list-units --failed

# View system logs
journalctl -b  # current boot
journalctl -p err  # errors only
```

### Package Management
```bash
# Search for packages
nix search nixpkgs PACKAGE_NAME

# Show package info
nix-env -qa --description PACKAGE_NAME

# Build without switching
nixos-rebuild build --flake .#ovh-cloud
```

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [Home Manager](https://nix-community.github.io/home-manager/)
- [Disko](https://github.com/nix-community/disko)
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)

---

**AI Agent Context**: This deployment guide reflects the actual minimal configuration. Services like Tailscale, 1Password integration, Claude Code, and advanced features mentioned in other docs are NOT implemented in the current configuration.

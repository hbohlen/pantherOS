# OVH VPS Deployment Guide - PantherOS

This guide covers deploying NixOS to your OVH VPS using the configuration in this repository.

## Prerequisites

### On Your Laptop (CachyOS)
- [x] Nix installed with flakes enabled
- [x] 1Password CLI configured
- [x] Repository cloned: `~/dev/pantherOS`
- [x] SSH keys in 1Password for authentication

### On Your Phone
- [ ] Tailscale app installed (iOS/Android)
- [ ] Tailscale account (same as laptop)

### Target Server (OVH VPS)
- [ ] Fedora 42 (current installation)
- [ ] 200GB disk
- [ ] Root SSH access configured
- [ ] At least 2GB RAM (yours has 23GB)

## Step 1: Setup Tailscale for Remote Access

### Install Tailscale on CachyOS Laptop

```bash
# Install Tailscale
sudo pacman -S tailscale

# Enable and start the service
sudo systemctl enable --now tailscaled

# Connect to your Tailscale network
sudo tailscale up
```

**Follow the auth URL** that appears to log into your Tailscale account.

### Install Tailscale on Your Phone

- **iOS**: Download "Tailscale" from App Store
- **Android**: Download "Tailscale" from Google Play Store

**Log in with the same account** as your laptop.

### Verify Tailscale Connection

**On your laptop:**
```bash
# Check Tailscale status
tailscale status
```

**On your phone:**
- Open Tailscale app
- You should see your laptop listed with a Tailscale IP (100.x.x.x)

**Note the Tailscale IP** of your laptop (e.g., `100.64.12.45`)

## Step 2: Prepare the Configuration

### Navigate to Repository
```bash
cd ~/dev/pantherOS
```

### Verify Configuration Files Exist
```bash
# Check files exist
ls -la flake.nix
ls -la hosts/servers/ovh-cloud/

# Expected files:
# - flake.nix
# - hosts/servers/ovh-cloud/configuration.nix
# - hosts/servers/ovh-cloud/disko.nix
# - hosts/servers/ovh-cloud/home.nix
```

## Step 3: Configure VPS for Rescue Mode

### In OVH Control Panel:
1. Go to your VPS → **Boot** tab
2. Select **Rescue** mode
3. Choose **Rescue OS** (e.g., "rescue64")
4. Click **Restart** to apply
5. Wait for reboot (2-3 minutes)
6. **Note the rescue root password** displayed

### SSH into Rescue Mode:
```bash
# Get the VPS IP from OVH control panel
ssh root@<YOUR_VPS_IP_ADDRESS>
# Use the rescue password when prompted
```

### Verify You're in Rescue Mode:
```bash
cat /etc/os-release
# Should show the rescue OS (e.g., Ubuntu/Fedora rescue)
```

## Step 4: Deploy from Your Laptop via Phone

### SSH to Your Laptop from Phone

**Using Tailscale IP:**
```bash
# SSH to laptop using Tailscale
ssh <username>@<tailscale-ip>

# Example:
ssh hbohlen@100.64.12.45
```

### Export 1Password Token
```bash
# Get your 1Password service account token from 1Password
# Then export it:
export OP_SERVICE_ACCOUNT_TOKEN="your-service-account-token-here"

# Verify it's set:
echo $OP_SERVICE_ACCOUNT_TOKEN
```

### Run Deployment
```bash
# Navigate to repository
cd dev/pantherOS

# Deploy NixOS to VPS
nix run github:nix-community/nixos-anywhere -- \
  --flake .#ovh-cloud \
  --target-host root@<YOUR_VPS_IP_ADDRESS> \
  --disk-config hosts/servers/ovh-cloud/disko.nix
```

### What Happens During Deployment:

1. **Connects** to VPS via SSH
2. **Partitions** disk:
   - `/dev/sda1` - EFI System Partition (100MB vfat)
   - `/dev/sda2` - Boot partition (1GB ext4)
   - `/dev/sda3` - Btrfs system partition (remaining space)
3. **Creates Btrfs subvolumes**:
   - `root` → `/`
   - `home` → `/home`
   - `var` → `/var`
4. **Installs** NixOS base system
5. **Applies** your configuration (SSH, Tailscale, Podman, etc.)
6. **Reboots** automatically into NixOS

**Duration:** ~5-10 minutes

## Step 5: Post-Deployment

### Exit Rescue Mode in OVH Control Panel:
1. Go to **Boot** tab
2. Select **Hard disk** (not rescue)
3. Restart VPS

### SSH into New NixOS System:
```bash
# Wait 2-3 minutes for reboot to complete
ssh hbohlen@<YOUR_VPS_IP_ADDRESS>

# Or via Tailscale (once connected)
ssh hbohlen@ovh-cloud  # If you've set up hostname resolution
```

### Verify NixOS Installation:
```bash
# Check OS
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

## Step 6: Connect Tailscale on VPS

**If not auto-connected:**
```bash
# Manual connection (if needed)
sudo tailscale up --authkey="$(cat /var/run/secrets/opnix-1password/op://pantherOS/tailscale/authKey | head -n 1)"

# Or follow the URL
sudo tailscale up
```

## Configuration Summary

### Disk Layout
```
/dev/sda
├── /dev/sda1 (ESP) - 100MB vfat, mounted at /boot/efi
├── /dev/sda2 (boot) - 1GB ext4, mounted at /boot
└── /dev/sda3 (root) - Btrfs with subvolumes:
    ├── root → /
    ├── home → /home
    └── var → /var
```

### Enabled Services
- **OpenSSH**: Key-based authentication only
- **Tailscale**: VPN with auto-connect
- **1Password CLI**: Secret management
- **Claude Code**: AI coding assistant
- **GitHub CLI**: GitHub integration
- **Podman**: Container runtime with Btrfs storage
- **Firewall**: Enabled with Tailscale access

### User Accounts
- **root**: SSH keys from 1Password (no password)
- **hbohlen**: Admin user with wheel group

### Secrets (via OpNix)
All secrets retrieved from 1Password vault:
- SSH public keys (yogaSSH, zephyrusSSH, phoneSSH, desktopSSH)
- Tailscale auth key
- GitHub PAT
- API keys (Claude, OpenAI, etc.)

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

### Mobile Connection Issues

**If SSH from phone drops during deployment:**

1. **Use tmux to maintain session:**
   ```bash
   # On laptop before SSH from phone:
   tmux new -s deploy

   # Run deployment command
   # Detach: Ctrl+B, then D

   # From phone, reattach:
   ssh <username>@<laptop-ip>
   tmux attach -t deploy
   ```

2. **Use `nohup` to background:**
   ```bash
   # On laptop:
   cd dev/pantherOS
   nohup nix run github:nix-community/nixos-anywhere -- \
     --flake .#ovh-cloud \
     --target-host root@<YOUR_VPS_IP_ADDRESS> \
     --disk-config hosts/servers/ovh-cloud/disko.nix \
     > deploy.log 2>&1 &

   # Check progress:
   tail -f deploy.log
   ```

## Alternative: Deploy Directly from Laptop

**If you prefer not to use your phone:**

```bash
# On your CachyOS laptop
cd dev/pantherOS

# Export token
export OP_SERVICE_ACCOUNT_TOKEN="your-service-account-token"

# Deploy
nix run github:nix-community/nixos-anywhere -- \
  --flake .#ovh-cloud \
  --target-host root@<YOUR_VPS_IP_ADDRESS> \
  --disk-config hosts/servers/ovh-cloud/disko.nix
```

**Benefits:**
- More reliable connection
- Full terminal control
- No mobile battery concerns

## Additional Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixOS Wiki](https://nixos.wiki/)
- [nixos-anywhere Documentation](https://github.com/nix-community/nixos-anywhere)
- [OpNix Documentation](https://github.com/brizzbuzz/opnix)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Tailscale Documentation](https://tailscale.com/kb/)

---

**Note:** This configuration is optimized for a remote development server with emphasis on:
- Security (key-only SSH, firewall)
- Convenience (Tailscale, 1Password, Claude Code)
- Maintainability (declarative configuration, flakes)
- Performance (minimal overhead, efficient tooling)

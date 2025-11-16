# NixOS VPS Configuration - Quick Start

## 📦 What Was Created

### Configuration Files
```
~/dev/pantherOS/
├── flake.nix                              # Main flake with all inputs
├── deploy.sh                              # Automated deployment script
├── DEPLOYMENT.md                          # Full deployment guide
└── hosts/servers/ovh-cloud/
    ├── configuration.nix                  # System configuration
    ├── disko-config.nix                   # Disk layout (EFI + ext4)
    └── home.nix                           # User configuration
```

### Installed Software
- **Claude Code** (via nix-ai-tools)
- **GitHub CLI** (gh)
- **1Password CLI** (_1password)
- **Tailscale** (with auto-connect)
- **Fish Shell** + Starship prompt
- Development tools: git, neovim, ripgrep, fd, bat, exa, etc.

### Security Features
- ✅ SSH key-only authentication (no passwords)
- ✅ Firewall enabled
- ✅ Tailscale VPN for secure access
- ✅ 1Password for secret management
- ✅ Sudo access without password (wheel group)

## 🚀 Quick Deployment

### From Your Local Machine (with Nix installed)

```bash
# 1. Set your 1Password token
export OP_SERVICE_ACCOUNT_TOKEN="your-token"

# 2. Deploy
./deploy.sh --host root@YOUR_VPS_IP

# 3. Wait for installation (~5-10 minutes)
# The server will reboot automatically

# 4. Connect via SSH
ssh hbohlen@YOUR_VPS_IP

# 5. Connect to Tailscale (once SSH'd in)
sudo tailscale up

# 6. Now you can also access via Tailscale
ssh hbohlen@ovh-cloud
```

### With SSH Key
```bash
./deploy.sh --host root@YOUR_VPS_IP --key ~/.ssh/id_ed25519
```

## 🔑 Initial Setup (After First Boot)

### 1. Authenticate GitHub CLI
```bash
# Get token from 1Password
export GITHUB_TOKEN=$(op read op://pantherOS/github-pat/token)
echo $GITHUB_TOKEN | gh auth login --with-token
```

### 2. Configure Claude Code
```bash
# Get API key from Anthropic console
export ANTHROPIC_API_KEY="your-api-key"

# Test Claude
claude doctor
```

### 3. Verify 1Password
```bash
op signin
op vault list
```

## 🔧 Common Commands

```bash
# Rebuild system (after config changes)
nixos-rebuild switch --flake .#ovh-cloud

# Update system
sudo nixos-rebuild switch --upgrade

# Rollback
sudo nixos-rebuild switch --rollback

# Check system status
systemctl status tailscaled sshd

# View logs
journalctl -u tailscaled -f

# List Nix generations
nix-env --list-generations
```

## 📁 Directory Structure

```
/home/hbohlen/
├── dev/                    # Development projects root
│   └── your-projects/
├── .nix-profile/           # User-level Nix packages
└── .config/               # Application configs
    └── home-manager/      # Home Manager configuration
```

## 🌐 Network Access

### Primary (Direct IP)
- SSH: `ssh hbohlen@YOUR_VPS_IP`
- After deployment, find IP: `ip addr show`

### Via Tailscale (Recommended)
1. Connect Tailscale: `sudo tailscale up`
2. Access: `ssh hbohlen@ovh-cloud`
3. Access from any Tailscale device on your network

## 🛠️ Configuration Management

### Edit Configuration
```bash
vim hosts/servers/ovh-cloud/configuration.nix
```

### Rebuild After Changes
```bash
nixos-rebuild switch --flake .#ovh-cloud
```

### Update from Git
```bash
git pull
nixos-rebuild switch --flake .#ovh-cloud
```

## 🔐 Secrets

All secrets stored in 1Password vault (`pantherOS`):
- SSH public keys (yogaSSH, zephyrusSSH, phoneSSH, desktopSSH)
- Tailscale auth key
- GitHub PAT

Accessed via OpNix in configuration.

## 📚 Resources

- **Full Deployment Guide**: `DEPLOYMENT.md`
- **NixOS Manual**: https://nixos.org/manual/nixos/stable/
- **nixos-anywhere**: https://github.com/nix-community/nixos-anywhere
- **Home Manager**: https://nix-community.github.io/home-manager/

## 🐛 Troubleshooting

### Can't SSH after reboot
```bash
# Check from OVH console or IPMI
# Verify IP hasn't changed
ip addr show

# Check SSH service
systemctl status sshd
```

### Tailscale not connecting
```bash
# Check service
systemctl status tailscaled

# Check logs
journalctl -u tailscaled

# Manual connect
sudo tailscale up --authkey="$(cat /var/run/secrets/opnix-1password/op://pantherOS/tailscale/authKey | head -n 1)"
```

### Build fails
```bash
# Clean build cache
nix-collect-garbage

# Rebuild
nixos-rebuild build --flake .#ovh-cloud
```

---

**✅ Configuration is complete and ready to deploy!**

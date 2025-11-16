# NixOS Configuration Summary

**AI Agent Context**: This document summarizes the ACTUAL NixOS configuration.

**Last Updated**: 2025-11-16  
**Configuration**: Minimal NixOS for OVH Cloud VPS

---

## Overview

This repository contains a minimal, working NixOS configuration for a single OVH Cloud VPS server. The configuration is declarative, maintainable, and focused on simplicity.

## Core Files

### 1. flake.nix
**Status**: ✅ Implemented  
**Purpose**: Main flake definition

**Inputs**:
- `nixpkgs` (nixos-unstable)
- `home-manager` (master)
- `nixos-hardware`
- `disko` (disk partitioning)
- `nixos-anywhere` (remote installation)
- `nix-ai-tools` (imported but not used)
- `opnix` (imported but not configured)

**Outputs**:
- Single host: `nixosConfigurations.ovh-cloud`

### 2. hosts/servers/ovh-cloud/configuration.nix
**Status**: ✅ Implemented  
**Purpose**: System configuration

**Features**:
- Boot: GRUB on /dev/sda
- Network: DHCP, hostname "ovh-cloud"
- SSH: Enabled, key-only auth, no root login
- User: hbohlen (wheel, networkmanager, podman groups)
- Timezone: UTC
- Locale: en_US.UTF-8
- Packages: Basic dev tools (htop, gcc, make, etc.)

### 3. hosts/servers/ovh-cloud/disko.nix
**Status**: ✅ Implemented  
**Purpose**: Declarative disk partitioning

**Layout**:
- ESP: 100MB, vfat, /boot/efi
- Boot: 1GB, ext4, /boot
- Root: Remaining space, btrfs
  - Subvolumes: root (/), home (/home), var (/var)
  - Mount options: noatime, space_cache=v2

### 4. hosts/servers/ovh-cloud/home.nix
**Status**: ✅ Implemented  
**Purpose**: User environment via Home Manager

**Includes**:
- Fish shell with starship prompt
- Git configuration
- CLI tools: eza, ripgrep, zoxide, direnv
- Dev tools: gh, neovim, 1password-cli
- Shell completions for op and gh

---

## System Packages

### Installed System-Wide
- htop (process monitor)
- unzip, zip (compression)
- openssh (SSH client/server)
- gcc, gnumake, pkg-config (build tools)

### Installed for User (via Home Manager)
- starship (prompt)
- eza (modern ls)
- ripgrep (fast grep)
- gh (GitHub CLI)
- bottom (system monitor)
- 1password-cli (secrets management)
- git (version control)
- neovim (editor)
- fish (shell)
- zoxide (directory jumper)
- direnv, nix-direnv (environment management)

---

## Services

### Enabled
- **SSH**: Port 22, key-only authentication
- **NetworkManager**: Basic network configuration

### NOT Enabled
- Tailscale (not configured)
- Datadog (not configured)
- Podman (user in group but service not enabled)
- OpNix (module imported but not configured)

---

## NOT Implemented

**AI Agent Context**: These features are mentioned in planning docs but NOT implemented:

- ❌ Multiple host configurations
- ❌ Desktop environment (Niri, DankMaterialShell)
- ❌ Modular architecture (modules/, profiles/)
- ❌ OpNix secrets management (imported but not configured)
- ❌ Tailscale VPN
- ❌ Datadog monitoring
- ❌ Container services (Podman not configured)
- ❌ Security hardening modules
- ❌ Hardware-specific optimizations
- ❌ Custom I/O schedulers
- ❌ Btrfs compression
- ❌ Automated deployment scripts

---

## Deployment

### Prerequisites
- Nix with flakes enabled
- SSH access to target server
- Target server with any Linux OS

### Deploy Command
```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#ovh-cloud \
  --target-host root@SERVER_IP
```

### Update Configuration
```bash
# On server (if repo is cloned there)
sudo nixos-rebuild switch --flake .#ovh-cloud

# Or remotely
nixos-rebuild switch --flake .#ovh-cloud --target-host hbohlen@SERVER_IP --use-remote-sudo
```

---

## Directory Structure

```
pantherOS/
├── flake.nix                    # Main flake
├── flake.lock                   # Locked dependencies
├── hosts/
│   └── servers/
│       └── ovh-cloud/           # Single server config
│           ├── configuration.nix
│           ├── disko.nix
│           └── home.nix
├── README.md                    # Repository overview
├── DEPLOYMENT.md                # Deployment guide
└── system_config/
    └── 03_PANTHEROS_NIXOS_BRIEF.md  # Configuration brief
```

---

## Configuration Values

### System
- **stateVersion**: "25.05"
- **allowUnfree**: true

### User
- **username**: hbohlen
- **homeDirectory**: /home/hbohlen
- **home.stateVersion**: "24.11"

### Network
- **hostname**: ovh-cloud
- **useDHCP**: true

### Boot
- **loader**: GRUB
- **device**: /dev/sda
- **kernelParams**: ["console=ttyS0"]

### Security
- **sudo.wheelNeedsPassword**: false
- **openssh.permitRootLogin**: "no"
- **openssh.passwordAuthentication**: false

---

## Next Steps

### To Add Features

1. **Enable a Service**:
   ```nix
   # In configuration.nix
   services.SERVICE_NAME.enable = true;
   ```

2. **Add System Package**:
   ```nix
   # In configuration.nix
   environment.systemPackages = with pkgs; [ PACKAGE_NAME ];
   ```

3. **Add User Package**:
   ```nix
   # In home.nix
   home.packages = with pkgs; [ PACKAGE_NAME ];
   ```

### To Add More Hosts

1. Create directory: `hosts/HOSTNAME/`
2. Add: `configuration.nix`, `disko.nix`, `home.nix`
3. Add to `flake.nix`:
   ```nix
   nixosConfigurations.HOSTNAME = nixpkgs.lib.nixosSystem { ... };
   ```

---

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Disko Documentation](https://github.com/nix-community/disko)
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)

---

**AI Agent Note**: This summary reflects the ACTUAL implementation. Many planning documents in this repository describe features that are NOT implemented. Always verify against the actual configuration files.

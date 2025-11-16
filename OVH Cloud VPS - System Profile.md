# OVH Cloud VPS – NixOS System Profile

**AI Agent Context**: This document describes the actual NixOS configuration for the OVH Cloud VPS server.

## Host Identity

- **Hostname:** `ovh-cloud`
- **Provider:** OVH Cloud (OpenStack/KVM virtualized)
- **Virtualization:** KVM
- **Architecture:** x86_64

## Operating System

- **Distribution:** NixOS 25.05 (unstable)
- **Configuration Management:** Nix Flakes
- **Init System:** systemd
- **Package Manager:** Nix
- **User Shell:** Fish (with starship prompt)

## Hardware Resources

**AI Agent Context**: Virtual hardware allocated by OVH hypervisor.

- **vCPUs:** Allocated by hypervisor (check actual allocation)
- **Architecture:** x86_64

## Memory

- **RAM:** Allocated by hypervisor (check actual allocation)
- **Swap:** Managed by NixOS configuration if configured

## Storage Configuration

**AI Agent Context**: Storage managed by disko.nix for declarative disk partitioning.

### Disk Layout (defined in disko.nix)

- **Primary Disk:** `/dev/sda` (default, configurable via lib.mkDefault)
- **Partition Scheme:** GPT

### Partitions

1. **EFI System Partition**
   - Size: `100M`
   - Type: `EF00`
   - Filesystem: `vfat`
   - Mount: `/boot/efi`
   - Options: `umask=0077`

2. **Boot Partition**
   - Size: `1G`
   - Type: `8300`
   - Filesystem: `ext4`
   - Mount: `/boot`
   - Options: `noatime`

3. **Btrfs Root Partition**
   - Size: `100%` (remaining space)
   - Type: `8300`
   - Filesystem: `btrfs`
   - Mount Options: `noatime`, `space_cache=v2`
   
   **Btrfs Subvolumes:**
   - `root` → `/` (root filesystem)
   - `home` → `/home` (user home directories)
   - `var` → `/var` (variable data)

## Network Configuration

**AI Agent Context**: Networking managed by NixOS configuration.

- **Hostname:** `ovh-cloud`
- **DHCP:** Enabled (`networking.useDHCP = true`)
- **Firewall:** Managed by NixOS (configuration available in configuration.nix)

## Services

**AI Agent Context**: Core services enabled in NixOS configuration.

### SSH Service
- **Enabled:** Yes
- **Root Login:** Disabled (`permitRootLogin = "no"`)
- **Authentication:** SSH keys only (password auth disabled)
- **Interactive Auth:** Disabled (keyboard and challenge-response)

## User Configuration

**AI Agent Context**: System users defined in configuration.nix.

### Admin User: hbohlen
- **Type:** Normal user
- **Groups:** `wheel`, `networkmanager`, `podman`
- **SSH Access:** Via authorized_keys (keys to be added)
- **Sudo:** Enabled without password (wheel group)

## System Settings

**AI Agent Context**: Basic system configuration.

- **Timezone:** UTC
- **Locale:** en_US.UTF-8
- **Console Keymap:** US
- **Console Font:** Lat2-Terminus16

## Installed Packages

**AI Agent Context**: System-level packages in environment.systemPackages.

### System Tools
- htop (process monitor)
- unzip, zip (compression)
- openssh (SSH client)
- gcc, gnumake, pkg-config (build tools)

### User Packages (Home Manager)
- starship (prompt)
- eza (ls replacement)
- ripgrep (fast grep)
- gh (GitHub CLI)
- bottom (system monitor)
- 1password-cli (secrets management)
- git, neovim, fish
- zoxide (directory jumper)
- direnv, nix-direnv (environment management)

## Configuration Files

**AI Agent Context**: Location of NixOS configuration files.

- **Flake:** `/flake.nix` (defines nixosConfigurations.ovh-cloud)
- **System Config:** `/hosts/servers/ovh-cloud/configuration.nix`
- **Disk Config:** `/hosts/servers/ovh-cloud/disko.nix`
- **Home Manager:** `/hosts/servers/ovh-cloud/home.nix`

## Flake Inputs

**AI Agent Context**: External dependencies used in the flake.

- `nixpkgs` (nixos-unstable)
- `home-manager` (master branch)
- `nixos-hardware` (hardware configurations)
- `disko` (declarative disk partitioning)
- `nixos-anywhere` (remote NixOS installation)
- `nix-ai-tools` (AI development tools)
- `opnix` (1Password NixOS integration)

## System State Version

- **Version:** 25.05 (NixOS unstable)
- **Home Manager:** 24.11

## Deployment Notes

**AI Agent Context**: Server is designed as a headless cloud host for development and automation.

- No GUI or desktop environment
- Declarative disk partitioning with Btrfs subvolumes
- SSH-only access with key authentication
- User environment managed via Home Manager
- Fish shell with modern CLI tools

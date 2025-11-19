# Hetzner Cloud NixOS Multi-Host Configuration

This repository contains a comprehensive, flake-based NixOS configuration designed for multi-host deployments, with specific support for Hetzner Cloud VPS servers.

## Overview

This project provides:
- **Multi-host NixOS configuration** using modern flake-based approach
- **Hetzner Cloud optimized** settings and deployment procedures
- **Production-ready security** with SSH hardening and key-only authentication
- **Cloud-optimized storage** with Btrfs and performance tuning
- **Automated deployment tools** for streamlined operations

## Key Components

### Flake Structure
- `flake.nix`: Main configuration with multiple host support
- `hosts/servers/hetzner-cloud/`: Hetzner Cloud specific configuration
- `hosts/servers/ovh-cloud/`: OVH Cloud configuration (example)
- `disko.nix`: Automated disk partitioning and filesystem setup

### Supporting Files
- `hetzner-deploy.sh`: Automated deployment script
- `HETZNER-DEPLOYMENT-GUIDE.md`: Step-by-step deployment instructions
- `HETZNER-CLOUD-SPECIFICS.md`: Hetzner-specific considerations
- `MULTI-HOST-CONFIG.md`: Multi-host configuration documentation

## Features

### Cloud Optimizations
- **UEFI Boot Support**: Optimized for modern cloud infrastructure
- **Btrfs Filesystem**: With cloud-specific optimizations (`noatime`, `compress=zstd`)
- **Console Access**: Properly configured for out-of-band management
- **Network Configuration**: DHCP-ready for cloud environments

### Security Hardening
- **SSH Key Authentication**: No password access, key-only
- **Root Login Disabled**: Enhanced security posture
- **Sudo Configuration**: Proper user privilege management
- **Multiple Device Keys**: Support for various access devices

### Deployment Tools
- **NixOS Anywhere Support**: For initial bare-metal deployments
- **Automated Scripts**: Streamlined deployment process
- **Multi-Host Management**: Single flake manages multiple cloud providers
- **Configuration Testing**: Built-in validation capabilities

## Quick Start

### Prerequisites
1. Hetzner Cloud account with API access
2. SSH keys configured (already included in configuration)
3. Nix package manager installed

### Deployment Steps
1. **Create Hetzner Cloud server** with temporary OS
2. **Run deployment script**:
   ```bash
   ./hetzner-deploy.sh deploy --target-ip YOUR_SERVER_IP
   ```
3. **Verify deployment** by SSH'ing to your server

### Alternative Manual Deployment
```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#hetzner-cloud root@YOUR_SERVER_IP
```

## Architecture

```
/workspace/
├── flake.nix                    # Main flake with multi-host support
├── hetzner-deploy.sh           # Automated deployment script
├── hosts/
│   └── servers/
│       ├── hetzner-cloud/      # Hetzner-specific configuration
│       │   ├── configuration.nix
│       │   ├── disko.nix
│       │   └── home.nix
│       └── ovh-cloud/          # OVH-specific configuration
│           ├── configuration.nix
│           ├── disko.nix
│           └── home.nix
├── HETZNER-DEPLOYMENT-GUIDE.md # Detailed deployment guide
├── HETZNER-CLOUD-SPECIFICS.md  # Hetzner-specific considerations
└── MULTI-HOST-CONFIG.md        # Multi-host configuration guide
```

## Documentation

- **[HETZNER-DEPLOYMENT-GUIDE.md](./HETZNER-DEPLOYMENT-GUIDE.md)**: Complete deployment instructions
- **[HETZNER-CLOUD-SPECIFICS.md](./HETZNER-CLOUD-SPECIFICS.md)**: Hetzner Cloud specific details
- **[MULTI-HOST-CONFIG.md](./MULTI-HOST-CONFIG.md)**: Multi-host management documentation

## Support

This configuration is designed to be production-ready with:
- Automated deployment capabilities
- Security best practices
- Cloud-optimized settings
- Multi-provider flexibility
- Comprehensive documentation

## Next Steps

1. Review the configuration files for your specific needs
2. Customize SSH keys and user settings if needed
3. Follow the deployment guide to set up your Hetzner Cloud VPS
4. Consider implementing additional services based on your requirements
5. Set up monitoring and backup solutions for production use
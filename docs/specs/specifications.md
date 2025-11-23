# PantherOS Specifications

This document outlines the technical specifications and requirements for PantherOS.

## System Requirements

### Minimum Requirements
- 64-bit x86 processor (AMD/Intel)
- 8GB RAM (16GB recommended for development)
- 64GB storage (128GB+ recommended for Btrfs impermanence)
- UEFI firmware (BIOS support available but not recommended)

### Recommended Hardware
- Modern CPU with AES-NI support
- ECC memory for servers
- NVMe storage for optimal Btrfs performance
- TPM 2.0 chip for advanced security features

## Supported Platforms

### Workstations
- **Laptops**: Lenovo Yoga series, ASUS Zephyrus series
- **Desktops**: Standard PC hardware configurations
- **Virtual Machines**: QEMU/KVM, VirtualBox, VMware

### Servers
- **VPS**: Hetzner, OVH, DigitalOcean, AWS, GCP, Azure
- **Bare Metal**: Standard server hardware
- **Container Platforms**: Kubernetes, Podman, Docker

## Software Architecture

### Operating System Foundation
- **Base**: NixOS 25.05 or later
- **Package Manager**: Nix (latest stable)
- **Init System**: systemd
- **Shell**: Bash, Zsh

### Storage
- **Primary**: Btrfs with subvolume management
- **Encryption**: LUKS for full disk encryption
- **Impermanence**: Btrfs snapshots for root reset
- **Backup**: Automated snapshot management

### Security
- **Hardening**: Kernel, SSH, systemd, and application hardening
- **Firewall**: NixOS firewall with custom rules
- **Auditing**: AIDE, Lynis, and systemd-audit integration
- **Access Control**: SSH key-based authentication (password disabled)

### Networking
- **Primary**: Tailscale for mesh networking
- **Protocols**: IPv4/IPv6 dual stack
- **Management**: NetworkManager
- **Security**: Firewall rules restricting external access

## Module System Specifications

### Core Modules
- **Purpose**: Fundamental system configuration
- **Scope**: Boot, users, basic system settings
- **Dependencies**: Minimal external dependencies

### Service Modules
- **Purpose**: Network services and daemons
- **Scope**: Tailscale, SSH, Podman, monitoring
- **Dependencies**: Core modules

### Security Modules
- **Purpose**: Security hardening and access controls
- **Scope**: Firewall, SSH hardening, kernel parameters
- **Dependencies**: Core and service modules

### Filesystem Modules
- **Purpose**: Storage and impermanence management
- **Scope**: Btrfs, snapshots, encryption
- **Dependencies**: Core modules

### Hardware Modules
- **Purpose**: Hardware-specific optimizations
- **Scope**: Workstation, server, and specific device settings
- **Dependencies**: Core and other modules as needed

## Impermanence Specifications

### Design Principles
- **State Reset**: Root filesystem resets on each boot
- **Persistence**: Designated directories preserved across reboots
- **Snapshots**: Automated Btrfs snapshots before changes
- **Rollback**: Ability to revert to previous system states

### Persistent Directories
- `/persist` - User configuration and system persistence
- `/nix` - Nix store (remains for reproducibility)
- `/var/log` - System logs
- `/var/lib/services` - Service data
- `/var/lib/caddy` - SSL certificates for web services
- `/var/backup` - Backup storage

### Ephemeral Directories
- `/root` - Root user home directory
- `/var/cache` - Application caches
- `/var/tmp` - Temporary files
- `/tmp` - System temporary files

## Security Specifications

### Default Security Settings
- SSH password authentication disabled
- SSH key-based authentication required
- Root login disabled
- Firewall blocking most incoming connections
- Kernel hardening parameters enabled
- ASLR fully enabled

### Network Security
- Tailscale VPN as primary access method
- External port access minimized
- Regular security scanning
- Intrusion detection capabilities

### File System Security
- Encrypted storage using LUKS
- Integrity checking with AIDE
- No execute permissions in data directories
- Restricted file access patterns

## Performance Specifications

### Boot Performance
- Sub-30 second boot time on modern hardware with SSD
- Optimized systemd service loading
- Minimal unnecessary services at startup

### Runtime Performance
- Optimized I/O scheduler settings
- Proper CPU governor configuration
- Memory management tuned for system type
- Btrfs optimizations for storage performance

### Resource Usage
- Minimal background services
- Efficient package management with Nix
- Optimized container runtime with Podman

## Development Specifications

### Code Standards
- Nixpkgs coding guidelines
- Consistent module patterns
- Proper option typing
- Comprehensive descriptions for all options

### Documentation
- Inline documentation for all modules
- Separate guide documentation
- API reference materials
- Troubleshooting guides

### Testing
- Configuration validation
- Module dependency verification
- System integration testing
- Performance benchmarking

## Compatibility Specifications

### NixOS Compatibility
- Compatible with NixOS 25.05 and later
- Uses standard NixOS module system
- Integrates with NixOS tooling and workflows

### Hardware Compatibility
- Supports standard PC hardware
- Specific optimizations for supported platforms
- Modular approach for adding new hardware support

### Software Compatibility
- Compatible with standard Nix packages
- Supports container workloads
- Integrates with common development tools

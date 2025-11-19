# Multi-Host NixOS Configuration

This document describes the multi-host NixOS configuration system using flakes, which currently supports multiple cloud providers including Hetzner Cloud and OVH Cloud.

## Architecture Overview

The configuration uses a flake-based approach with the following structure:

```
/workspace/
├── flake.nix                 # Main flake file with multiple hosts
├── hosts/
│   └── servers/
│       ├── hetzner-cloud/    # Hetzner Cloud specific config
│       │   ├── configuration.nix
│       │   ├── disko.nix
│       │   └── home.nix
│       └── ovh-cloud/        # OVH Cloud specific config
│           ├── configuration.nix
│           ├── disko.nix
│           └── home.nix
├── hetzner-deploy.sh         # Deployment script for Hetzner
└── HETZNER-DEPLOYMENT-GUIDE.md # Deployment documentation
```

## Host Configurations

### Hetzner Cloud (`hetzner-cloud`)

Located at: `hosts/servers/hetzner-cloud/`

**Key Features:**
- UEFI boot support with GRUB
- Btrfs filesystem with cloud optimizations
- SSH hardening with key-only authentication
- Optimized for Hetzner Cloud environment

**Configuration Files:**
- `configuration.nix`: Main system configuration
- `disko.nix`: Disk partitioning and filesystem setup
- `home.nix`: User environment configuration (currently commented out)

### OVH Cloud (`ovh-cloud`)

Located at: `hosts/servers/ovh-cloud/`

**Key Features:**
- Traditional BIOS boot with GRUB
- Optimized for OVH Cloud environment
- Same security and user configurations as Hetzner

## Adding New Hosts

To add a new host configuration:

1. Create a new directory under `hosts/servers/`:
   ```bash
   mkdir -p hosts/servers/new-host
   ```

2. Create the basic configuration files:
   ```bash
   touch hosts/servers/new-host/{configuration.nix,disko.nix,home.nix}
   ```

3. Add the host to `flake.nix`:
   ```nix
   nixosConfigurations.new-host = nixpkgs.lib.nixosSystem {
     inherit system;
     modules = [
       ./hosts/servers/new-host/configuration.nix
       disko.nixosModules.default
     ];
   };
   ```

4. Create appropriate configuration files based on existing examples

## Common Configuration Elements

### Shared Features
Both cloud configurations include:

1. **Security Hardening**
   - SSH with key-only authentication
   - Root login disabled
   - Password authentication disabled

2. **User Management**
   - `hbohlen` user with sudo access
   - Multiple SSH keys for different devices

3. **System Optimization**
   - UTC timezone
   - English locale
   - Minimal package installation for smaller closure size

### Cloud-Specific Optimizations

#### Hetzner Cloud
- UEFI boot support (`efiSupport = true`)
- Cloud-optimized Btrfs settings
- Console access via `ttyS0`

#### OVH Cloud
- Traditional BIOS boot
- Standard disk configuration

## Building and Deploying

### Build Commands

```bash
# Build specific host configuration
nix build .#nixosConfigurations.hetzner-cloud.config.system.build.toplevel
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel

# Build all configurations
nix build .#nixosConfigurations.hetzner-cloud.config.system.build.toplevel .#nixosConfigurations.ovh-cloud.config.system.build.toplevel

# Test configuration without building
nix flake check
```

### Deploy Commands

```bash
# Deploy to Hetzner Cloud (using nixos-anywhere)
./hetzner-deploy.sh deploy --target-ip <YOUR_IP>

# Deploy to existing system
nixos-rebuild switch --flake .#hetzner-cloud --target-host hbohlen@<YOUR_IP>

# Deploy to OVH Cloud
nixos-rebuild switch --flake .#ovh-cloud --target-host hbohlen@<YOUR_IP>
```

## Development Environment

The flake includes multiple development shells:

- `nix`: Nix-specific development tools
- `rust`: Rust development environment
- `node`: Node.js development environment
- `python`: Python development environment
- `go`: Go development environment
- `mcp`: AI/MCP development environment
- `ai`: AI infrastructure development

Access with:
```bash
nix develop .#<shell-name>
```

## Best Practices

### Configuration Management
1. **Modularity**: Keep host-specific configurations separate
2. **Reusability**: Extract common configuration elements to shared modules
3. **Version Control**: Track configuration changes in Git
4. **Testing**: Test configurations locally before deploying

### Security Considerations
1. **SSH Keys**: Regularly rotate SSH keys
2. **Access Control**: Limit sudo access to necessary users only
3. **Updates**: Keep NixOS channels updated
4. **Monitoring**: Implement monitoring and alerting

### Performance Optimization
1. **Closure Size**: Minimize installed packages to reduce closure size
2. **Build Caching**: Use binary caches to speed up builds
3. **Remote Builds**: Use `--build-on-remote` for resource-intensive builds
4. **Incremental Updates**: Deploy changes incrementally

## Troubleshooting

### Common Issues

1. **Build Failures**
   - Check available disk space and memory
   - Verify network connectivity for fetching inputs
   - Ensure flake inputs are up to date

2. **Deployment Failures**
   - Verify SSH connectivity to target hosts
   - Check that target system meets requirements
   - Review firewall and security group settings

3. **Configuration Errors**
   - Use `nix flake check` to validate configurations
   - Review syntax in Nix expressions
   - Check for circular dependencies

### Recovery Procedures

1. **Rescue System**: Use cloud provider's rescue system
2. **Console Access**: Use web console for emergency access
3. **Rollback**: Keep previous configurations for rollback capability
4. **Backup**: Maintain configuration backups

## Future Enhancements

1. **Additional Cloud Providers**: AWS, GCP, Azure configurations
2. **Container Management**: Podman/Docker configurations
3. **Monitoring Stack**: Prometheus, Grafana integration
4. **Backup Solutions**: Automated backup configurations
5. **CI/CD Integration**: Automated deployment pipelines
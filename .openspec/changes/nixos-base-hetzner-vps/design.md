# Design Document: NixOS Base Configuration for Hetzner VPS

## Architecture Decisions

### NixOS Configuration Strategy

#### Flake-Based Approach
**Decision**: Use NixOS flakes as the primary configuration mechanism.

**Rationale**:
- Provides reproducible builds with locked dependencies
- Enables incremental updates without breaking existing functionality
- Aligns with project conventions established in the codebase
- Supports both system and user-level configurations

**Trade-offs**:
- Requires Nix 2.4+ (now stable in most distributions)
- Learning curve for team members unfamiliar with flakes
- Experimental features may have stability implications

#### Modular Configuration
**Decision**: Split configuration into discrete modules by concern.

**Structure**:
```
hosts/hetzner-vps/
├── configuration.nix    # Main config, imports modules
├── disko.nix           # Disk layout (future enhancement)
├── caddy.nix           # Reverse proxy (future enhancement)
└── opencode-memory.nix # OpenCode integration (future enhancement)
```

**Benefits**:
- Single concern per file (easier maintenance)
- Reusable components across hosts
- Clear dependencies and import relationships
- Simplified testing and validation

**Trade-offs**:
- Additional complexity in file management
- Potential for circular dependencies
- Requires discipline to maintain separation of concerns

### Boot Configuration Design

#### GRUB with EFI
**Decision**: Use GRUB bootloader with EFI removable mode.

**Configuration**:
```nix
boot.loader.grub = {
  enable = true;
  efiInstallAsRemovable = true;  # Hetzner Cloud requirement
  canTouchEfiVariables = false;  # Hetzner limitation
};
```

**Rationale**:
- Hetzner Cloud requires EFI removable mode for compatibility
- Disable EFI variable touching due to virtualization constraints
- Serial console access essential for remote management

**Alternative Considered**:
- systemd-boot: Simpler but less flexible for Hetzner environment
- Direct kernel boot: Too complex for maintenance

#### Kernel Parameters
**Decision**: Include both graphical and serial console access.

**Parameters**: `console=tty0, console=ttyS0,115200`

**Rationale**:
- `tty0`: Graphical console for local access
- `ttyS0`: Serial console for Hetzner web console
- 115200 baud rate: Standard for remote console access

### Networking Architecture

#### Dual Stack Networking
**Decision**: Enable both IPv4 and IPv6 with DHCP.

**Configuration**:
```nix
networking.useDHCP = true;
networking.enableIPv6 = true;
```

**Rationale**:
- Hetzner provides native IPv6 support
- DHCP simplifies initial configuration
- Future services may require IPv6 connectivity

#### Tailscale Integration
**Decision**: Use Tailscale as primary network interface for management.

**Configuration**:
```nix
services.tailscale = {
  enable = true;
  useRoutingFeatures = "server";
};
```

**Rationale**:
- Provides secure, encrypted communication
- No additional firewall rules needed for management
- Works behind NAT/firewalls automatically
- Centralized access control through Tailscale ACLs

**Security Considerations**:
- All management traffic goes through VPN
- MagicDNS provides hostname resolution
- Audit logging available in Tailscale dashboard

### SSH Security Model

#### Key-Only Authentication
**Decision**: Completely disable password authentication.

**Configuration**:
```nix
services.openssh = {
  enable = true;
  settings = {
    PermitRootLogin = "prohibit-password";
    PasswordAuthentication = false;
    PubkeyAuthentication = true;
  };
};
```

**Rationale**:
- Eliminates brute force attack vectors
- Aligns with security best practices
- Supports ED25519 keys for modern security

**Implementation Details**:
- Root login allowed but only via SSH keys
- No password authentication anywhere in the system
- ED25519 key format enforced (more secure than RSA)

#### User Management Strategy
**Decision**: Minimal system users with specific purposes.

**Users**:
- `root`: Administrative access, SSH key authentication
- `opencode`: Service account for OpenCode, group memberships

**Groups**:
- `opencode`: For OpenCode service isolation
- `onepassword-secrets`: Integration with OpNix secret management

### Firewall Design

#### Default-Deny Policy
**Decision**: Implement default-deny firewall with explicit allows.

**Policy Structure**:
1. Default: Drop all incoming traffic
2. Allow: Established connections (stateful)
3. Allow: Tailscale interface (100.64.0.0/10)
4. Allow: Specific public ports (80, 443)
5. Allow: Tailscale-only service ports

#### Port Classification

**Public Ports** (Internet accessible):
- 80, 443: HTTP/HTTPS for Caddy reverse proxy

**Tailscale-Only Ports** (VPN only):
- 4096, 6379, 6380: Service ports for OpenCode stack
- 3000: Application ports
- 8126: Monitoring/observability

**Rationale**:
- Public services only through reverse proxy
- Internal services protected by VPN
- Minimal attack surface
- Clear network segmentation

### System Package Selection

#### Essential Utilities
**Core Packages**:
- `vim`: Text editing (universal availability)
- `git`: Version control (development workflows)
- `tmux`: Terminal multiplexing (remote work)
- `htop`: Process monitoring (debugging)
- `ncdu`: Disk usage analysis (storage management)

**Rationale**:
- Proven, stable tools with long-term support
- Minimal resource usage
- Essential for system administration
- Available in NixOS stable channel

#### Filesystem Tools
**Specialized Packages**:
- `btrfs-progs`: Btrfs filesystem utilities
- `compsize`: Compression analysis for Btrfs

**Rationale**:
- Future disk layout will use Btrfs
- Compression monitoring important for SSD longevity
- Sub-volume management capabilities

### Security Posture

#### Defense in Depth
**Layers**:
1. **Network**: Tailscale VPN + firewall
2. **Service**: SSH key-only authentication
3. **System**: Minimal package installation
4. **Access**: Serial console fallback

#### Attack Surface Minimization
**Measures**:
- No unnecessary services running
- Public exposure only through reverse proxy
- All management access via encrypted VPN
- Default-deny firewall policy
- No password-based authentication

#### Incident Response
**Recovery Mechanisms**:
- Serial console access via Hetzner web console
- Previous generation rollback via GRUB
- Tailscale access from multiple devices
- Declarative configuration for quick rebuild

## Integration Points

### With Existing Project
- **Flake Configuration**: Integrates with existing `flake.nix`
- **Module Structure**: Follows established `modules/` organization
- **Security Standards**: Aligns with project security requirements
- **Documentation**: Maintains consistent documentation style

### With External Services
- **Hetzner Cloud**: Optimized for their virtualization platform
- **Tailscale**: Primary network security layer
- **1Password**: Future integration through OpNix
- **Domain**: Ready for hbohlen.systems subdomain

## Future Enhancements

### Immediate Extensions
1. **Disko Integration**: Add declarative disk partitioning
2. **Caddy Reverse Proxy**: Public-facing web services
3. **OpenCode Services**: Core application deployment
4. **Backup System**: Btrfs snapshots and remote backup

### Long-term Considerations
1. **Impermanence**: Ephemeral root filesystem
2. **Container Orchestration**: Podman-based services
3. **Monitoring**: Observability integration
4. **Scaling**: Multi-host deployment strategy

## Cost Considerations

### Infrastructure Costs
- **Hetzner CPX52**: ~$50/month (included in project budget)
- **Tailscale**: Free for personal use (up to 100 devices)
- **Domain**: Already owned (hbohlen.systems)

### Operational Costs
- **Backup Storage**: Future Backblaze B2 integration
- **Monitoring**: Future Datadog integration
- **Secret Management**: 1Password service account

## Maintainability

### Update Strategy
- **NixOS Channel**: Track nixos-25.05 stable
- **Security Updates**: Automatic with system updates
- **Configuration**: Version controlled in Git
- **Rollback**: Previous generations available

### Monitoring and Alerting
- **System Health**: Built-in systemd monitoring
- **Network Status**: Tailscale connectivity checks
- **SSH Access**: Authentication logging
- **Disk Usage**: Btrfs quota and usage monitoring

---

**Document Version**: 1.0  
**Last Updated**: 2025-11-19  
**Author**: hbohlen  
**Review Status**: Draft
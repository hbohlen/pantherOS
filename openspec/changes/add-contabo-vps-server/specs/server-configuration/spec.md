# Server Configuration Specification - Contabo VPS

## ADDED Requirements

### Requirement: Contabo VPS Base Configuration
The system SHALL provide a NixOS configuration for Contabo Cloud VPS 40 with hostname `contabo-vps`, optimized for development workloads including programming, containers, and AI tools.

#### Scenario: Server boots with correct hostname
- **WHEN** Contabo VPS is deployed with NixOS
- **THEN** the system hostname is set to `contabo-vps`

#### Scenario: Network connectivity is established
- **WHEN** system boots
- **THEN** network interface is configured via DHCP for IPv4 and IPv6

### Requirement: Contabo Hardware-Specific Configuration
The system SHALL configure kernel modules and parameters specific to Contabo Cloud KVM virtualization platform.

#### Scenario: Correct kernel modules are loaded
- **WHEN** system boots
- **THEN** virtio-scsi, virtio-pci, and other KVM-specific modules are available
- **AND** hardware detection correctly identifies QEMU/KVM virtualization

#### Scenario: Serial console is available
- **WHEN** system boots
- **THEN** serial console is accessible via Contabo Cloud console at 115200 baud

### Requirement: Contabo Development Server Optimization
The system SHALL provide performance tuning optimized for the Contabo hardware (12 vCPU, 48GB RAM, 250GB NVMe).

#### Scenario: Memory management is optimized
- **WHEN** system is running under high load
- **THEN** kernel parameters prioritize RAM usage and container performance
- **AND** 10GB swap is available for spikes

#### Scenario: Container runtime performs efficiently
- **WHEN** containers are running
- **THEN** Podman is configured with optimized storage settings
- **AND** network performance matches Hetzner setup or better

### Requirement: Secrets Management Integration
The system SHALL integrate with 1Password OpNix for secret management.

#### Scenario: 1Password secrets are populated
- **WHEN** OpNix token is provided and deployed
- **THEN** SSH keys, Tailscale auth, and 1Password integration work
- **AND** secrets are fetched from 1Password vault automatically

### Requirement: VPN and SSH Access
The system SHALL provide secure remote access via Tailscale VPN and hardened SSH.

#### Scenario: Tailscale is configured
- **WHEN** system boots with OpNix token
- **THEN** Tailscale automatically connects to the network
- **AND** server is accessible via Tailscale IP address

#### Scenario: SSH is hardened
- **WHEN** SSH connection is attempted
- **THEN** only key-based authentication is allowed
- **AND** root password login is prohibited

### Requirement: Home Manager User Environment
The system SHALL configure the `hbohlen` user with Home Manager.

#### Scenario: User environment is initialized
- **WHEN** system is deployed
- **THEN** user `hbohlen` has home directory with correct permissions
- **AND** XDG directories are configured

#### Scenario: User has access to development tools
- **WHEN** user logs in
- **THEN** OpenCode.AI is available and configured
- **AND** development subvolumes are mounted and accessible

### Requirement: Firewall and Networking
The system SHALL provide firewall protection while allowing Tailscale and development traffic.

#### Scenario: Firewall allows SSH
- **WHEN** firewall is enabled
- **THEN** SSH port (22) is open to all interfaces

#### Scenario: Tailscale interface is trusted
- **WHEN** Tailscale tunnel is active
- **THEN** traffic from Tailscale interface bypasses restrictions

### Requirement: System Maintenance and Cleanup
The system SHALL automatically maintain storage and logs.

#### Scenario: Old caches are cleaned
- **WHEN** weekly maintenance runs
- **THEN** caches older than 30 days are deleted
- **AND** journald logs are trimmed

#### Scenario: Nix store is optimized
- **WHEN** system is running
- **THEN** unused derivations are collected weekly
- **AND** duplicate files are deduplicated automatically

### Requirement: Boot Configuration for Contabo Platform
The system SHALL configure bootloader appropriate for Contabo Cloud (likely BIOS-based, pending hardware detection).

#### Scenario: System boots successfully
- **WHEN** server power cycles
- **THEN** GRUB bootloader initializes
- **AND** NixOS kernel loads with correct parameters

#### Scenario: Boot console is accessible
- **WHEN** system is booting
- **THEN** serial console is available for debugging

### Requirement: Locale and Timezone
The system SHALL be configured with standard locale and timezone settings.

#### Scenario: System time is UTC
- **WHEN** system is running
- **THEN** timezone is set to UTC
- **AND** system clock is correct

#### Scenario: Locale is US English
- **WHEN** locale is queried
- **THEN** default locale is en_US.UTF-8

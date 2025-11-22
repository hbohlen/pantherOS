## ADDED Requirements
### Requirement: Basic NixOS Server Configuration
The system SHALL provide a working NixOS configuration for Hetzner VPS deployment.

#### Scenario: Configuration builds successfully
- **WHEN** running `nixos-rebuild build .#hetzner-vps`
- **THEN** configuration compiles without errors
- **THEN** all required modules are imported successfully
- **THEN** no undefined references or missing dependencies

#### Scenario: Essential services are available
- **WHEN** system is deployed and booted
- **THEN** SSH service is running and accessible
- **THEN** Tailscale service is configured and connected
- **THEN** Podman is available for container management
- **THEN** basic networking is functional

### Requirement: Disk Layout with Disko
The system SHALL provide a functional disko configuration for Btrfs disk setup.

#### Scenario: Disk configuration validates
- **WHEN** running disko validation tools
- **THEN** partition layout is syntactically correct
- **THEN** Btrfs subvolumes are properly defined
- **THEN** mount points and options are valid
- **THEN** swap configuration is appropriate for system specs

#### Scenario: Server-optimized subvolume layout
- **WHEN** disk is configured with disko
- **THEN** root subvolume uses compression for efficiency
- **THEN** dedicated subvolume for container storage exists
- **THEN** persistent data subvolumes are defined
- **THEN** swap space is configured (32GB for 96GB RAM)

### Requirement: Hardware-Specific Configuration
The system SHALL provide hardware configuration optimized for Hetzner VPS specifications.

#### Scenario: Server hardware optimization
- **WHEN** hardware configuration is applied
- **THEN** CPU governor is set to performance mode
- **THEN** virtualization support (KVM) is enabled
- **THEN** appropriate kernel modules for virtualization are loaded
- **THEN** network interfaces are properly configured

#### Scenario: Resource management
- **WHEN** system is running under load
- **THEN** memory management is optimized for server workloads
- **THEN** I/O scheduling is configured for SSD performance
- **THEN** system parameters are tuned for 24/7 operation

### Requirement: Security Hardening
The system SHALL provide basic security configuration appropriate for internet-facing servers.

#### Scenario: SSH security
- **WHEN** SSH service is configured
- **THEN** password authentication is disabled
- **THEN** root login is prohibited
- **THEN** only key-based authentication is allowed
- **THEN** SSH access is restricted to specific users

#### Scenario: Network security
- **WHEN** firewall is configured
- **THEN** only essential ports are open (SSH, Tailscale)
- **THEN** unnecessary network services are disabled
- **THEN** basic DDoS protection measures are in place

### Requirement: Flake Integration
The system SHALL be properly integrated into the flake.nix for deployment.

#### Scenario: Flake outputs include Hetzner VPS
- **WHEN** examining flake.nix outputs
- **THEN** hetzner-vps is listed in nixosConfigurations
- **THEN** all required inputs and dependencies are declared
- **THEN** configuration can be built via flake

#### Scenario: Deployment workflow compatibility
- **WHEN** following standard deployment workflow
- **THEN** `nixos-rebuild switch --flake .#hetzner-vps` works
- **THEN** configuration can be applied from ISO installation
- **THEN** system can be bootstrapped via git clone and disko
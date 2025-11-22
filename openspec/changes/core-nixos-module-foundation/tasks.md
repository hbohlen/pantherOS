## 1. Foundation Setup
- [ ] 1.1 Create `modules/nixos/` directory structure
- [ ] 1.2 Create core/ subdirectory with base system modules
- [ ] 1.3 Create services/ subdirectory for network services
- [ ] 1.4 Create security/ subdirectory for security modules
- [ ] 1.5 Create filesystems/ subdirectory for storage modules
- [ ] 1.6 Create hardware/ subdirectory for hardware-specific modules
- [ ] 1.7 Create `modules/nixos/default.nix` for module aggregation

## 2. Core System Modules
- [ ] 2.1 Create `modules/nixos/core/base.nix` - fundamental system configuration
- [ ] 2.2 Create `modules/nixos/core/boot.nix` - bootloader and kernel configuration
- [ ] 2.3 Create `modules/nixos/core/systemd.nix` - systemd optimization and management
- [ ] 2.4 Create `modules/nixos/core/networking.nix` - basic network configuration
- [ ] 2.5 Create `modules/nixos/core/users.nix` - user management configuration

## 3. Security Module Structure
- [ ] 3.1 Create `modules/nixos/security/firewall.nix` - firewall configuration module
- [ ] 3.2 Create `modules/nixos/security/ssh.nix` - SSH hardening module
- [ ] 3.3 Create `modules/nixos/security/systemd-hardening.nix` - service hardening module
- [ ] 3.4 Create `modules/nixos/security/kernel.nix` - kernel security parameters
- [ ] 3.5 Create `modules/nixos/security/audit.nix` - security auditing tools module

## 4. Service Module Structure
- [ ] 4.1 Create `modules/nixos/services/tailscale.nix` - Tailscale VPN module
- [ ] 4.2 Create `modules/nixos/services/ssh.nix` - SSH service module
- [ ] 4.3 Create `modules/nixos/services/podman.nix` - container service module
- [ ] 4.4 Create `modules/nixos/services/networking.nix` - network services module
- [ ] 4.5 Create `modules/nixos/services/monitoring.nix` - system monitoring module

## 5. Filesystem Module Structure
- [ ] 5.1 Create `modules/nixos/filesystems/btrfs.nix` - Btrfs filesystem module
- [ ] 5.2 Create `modules/nixos/filesystems/impermanence.nix` - impermanence module
- [ ] 5.3 Create `modules/nixos/filesystems/snapshots.nix` - snapshot management module
- [ ] 5.4 Create `modules/nixos/filesystems/encryption.nix` - encryption module
- [ ] 5.5 Create `modules/nixos/filesystems/optimization.nix` - filesystem optimization module

## 6. Hardware-Specific Module Structure
- [ ] 6.1 Create `modules/nixos/hardware/workstations.nix` - workstation hardware module
- [ ] 6.2 Create `modules/nixos/hardware/servers.nix` - server hardware module
- [ ] 6.3 Create `modules/nixos/hardware/yoga.nix` - Yoga-specific hardware module
- [ ] 6.4 Create `modules/nixos/hardware/zephyrus.nix` - Zephyrus-specific hardware module
- [ ] 6.5 Create `modules/nixos/hardware/vps.nix` - VPS hardware module

## 7. Module Pattern Implementation
- [ ] 7.1 Implement `mkEnableOption` pattern for all module enable/disable
- [ ] 7.2 Implement `mkOption` pattern for module configuration
- [ ] 7.3 Create proper dependency management with `mkIf` conditions
- [ ] 7.4 Establish consistent import patterns and relative paths
- [ ] 7.5 Create module option validation and type checking

## 8. Documentation Framework
- [ ] 8.1 Create `docs/modules/nixos/` documentation structure
- [ ] 8.2 Write documentation for each module category
- [ ] 8.3 Create module usage examples and patterns
- [ ] 8.4 Document option interfaces and configuration examples
- [ ] 8.5 Create integration guides for module combinations

## 9. Testing Framework
- [ ] 9.1 Create module testing structure and validation scripts
- [ ] 9.2 Implement module compilation tests
- [ ] 9.3 Create integration tests for module combinations
- [ ] 9.4 Add option validation and type checking tests
- [ ] 9.5 Create automated testing pipeline for modules

## 10. Host Configuration Migration
- [ ] 10.1 Update `hosts/yoga/default.nix` to use new module structure
- [ ] 10.2 Update `hosts/zephyrus/default.nix` to use new module structure
- [ ] 10.3 Update `hosts/servers/hetzner-vps/default.nix` to use new module structure
- [ ] 10.4 Update `hosts/servers/ovh-vps/default.nix` to use new module structure
- [ ] 10.5 Validate all host configurations build successfully

## 11. Integration with Existing Proposals
- [ ] 11.1 Ensure foundation enables security-hardening-improvements proposal
- [ ] 11.2 Ensure foundation enables btrfs-impermanence-snapshots proposal
- [ ] 11.3 Ensure foundation enables ai-tools-integration proposal
- [ ] 11.4 Update existing proposals to reference new module structure
- [ ] 11.5 Validate integration points and dependencies

## 12. Final Validation
- [ ] 12.1 Run `openspec validate core-nixos-module-foundation --strict`
- [ ] 12.2 Test all module combinations and configurations
- [ ] 12.3 Validate documentation completeness and accuracy
- [ ] 12.4 Perform end-to-end testing of all host configurations
- [ ] 12.5 Create migration guide and rollback procedures
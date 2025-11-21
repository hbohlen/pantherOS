## 1. Setup and Infrastructure
- [ ] 1.1 Create basic directory structure validation
- [ ] 1.2 Review existing hardware documentation for specifications
- [ ] 1.3 Check reference configurations from similar hosts

## 2. Disk Configuration Implementation
- [ ] 2.1 Create disko.nix with Btrfs layout for Hetzner VPS
- [ ] 2.2 Configure subvolumes for server use case (containers, services, persistence)
- [ ] 2.3 Add swap configuration appropriate for 96GB RAM
- [ ] 2.4 Validate disko configuration syntax

## 3. Hardware Configuration
- [ ] 3.1 Create hardware.nix with server-specific kernel modules
- [ ] 3.2 Add CPU governor settings for performance mode
- [ ] 3.3 Configure virtualization support (KVM, containers)
- [ ] 3.4 Add network interface configuration

## 4. Base System Configuration
- [ ] 4.1 Create default.nix with essential system packages
- [ ] 4.2 Configure bootloader (systemd-boot) for server
- [ ] 4.3 Set up basic networking configuration
- [ ] 4.4 Configure locale and timezone settings

## 5. Security Configuration
- [ ] 5.1 Implement SSH hardening (key-only, no root)
- [ ] 5.2 Configure basic firewall rules
- [ ] 5.3 Add user account configuration for hbohlen
- [ ] 5.4 Set up sudo configuration

## 6. Service Configuration
- [ ] 6.1 Enable and configure Tailscale for secure networking
- [ ] 6.2 Configure Podman for container support
- [ ] 6.3 Add basic monitoring capabilities
- [ ] 6.4 Configure automatic updates

## 7. Flake Integration
- [ ] 7.1 Add Hetzner VPS to flake.nix outputs
- [ ] 7.2 Ensure proper module imports
- [ ] 7.3 Test build configuration
- [ ] 7.4 Validate deployment syntax

## 8. Testing and Validation
- [ ] 8.1 Test configuration build with `nixos-rebuild build`
- [ ] 8.2 Validate disko configuration with disko tools
- [ ] 8.3 Check for syntax errors and missing dependencies
- [ ] 8.4 Verify deployment workflow compatibility

## 9. Documentation
- [ ] 9.1 Update host configuration guide with Hetzner VPS specifics
- [ ] 9.2 Document deployment workflow steps
- [ ] 9.3 Add troubleshooting notes for common issues
- [ ] 9.4 Update README with server status
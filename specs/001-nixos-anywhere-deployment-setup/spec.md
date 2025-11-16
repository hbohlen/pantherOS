# Feature Specification: NixOS Anywhere Deployment Setup

**Feature Branch**: `001-nixos-anywhere-deployment-setup`  
**Created**: 2025-11-16  
**Status**: Draft  
**Input**: User description: "i am tryung to setup the confifg so i can get it deployed to ovj cloud vps using nixos-anywhere"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Fix Configuration Issues (Priority: P1)

User needs to resolve critical configuration issues that prevent nixos-anywhere deployment to OVH VPS from working.

**Why this priority**: Without these fixes, deployment will fail and block all progress on VPS setup.

**Independent Test**: Can be fully tested by running `nix build .#ovh-cloud --no-link` and verifying successful configuration validation.

**Acceptance Scenarios**:

1. **Given** disk config path mismatch in deploy.sh, **When** user runs deployment, **Then** deployment fails with file not found error
2. **Given** missing OpNix integration, **When** configuration is built, **Then** build fails due to undefined secrets references
3. **Given** TODO comment for SSH keys, **When** system boots, **Then** SSH access fails due to missing authorized keys
4. **Given** missing Tailscale service, **When** user tries to connect via VPN, **Then** connection fails

---

### User Story 2 - Deploy to OVH VPS (Priority: P1)

User needs to successfully deploy NixOS configuration to OVH cloud VPS using nixos-anywhere tool.

**Why this priority**: This is the primary goal - getting a working NixOS system running on the VPS.

**Independent Test**: Can be fully tested by running nixos-anywhere command and verifying successful VPS deployment with SSH access.

**Acceptance Scenarios**:

1. **Given** fixed configuration and VPS in rescue mode, **When** user runs deployment command, **Then** NixOS installs successfully
2. **Given** successful installation, **When** VPS reboots, **Then** system is accessible via SSH
3. **Given** working SSH access, **When** user connects, **Then** all configured services are running
4. **Given** deployed system, **When** user runs nixos-rebuild, **Then** configuration updates apply successfully

---

### User Story 3 - Verify Post-Deployment Setup (Priority: P2)

User needs to verify that all services and configurations work correctly after deployment.

**Why this priority**: Ensures the deployed system is fully functional and ready for development work.

**Independent Test**: Can be fully tested by checking service status and verifying access methods work as expected.

**Acceptance Scenarios**:

1. **Given** deployed system, **When** user checks services, **Then** SSH, Tailscale, and firewall are running
2. **Given** configured user account, **When** user attempts sudo, **Then** passwordless sudo works
3. **Given** Tailscale service, **When** user connects to VPN, **Then** system is accessible via Tailscale network
4. **Given** development tools, **When** user runs git, neovim, or other tools, **Then** they execute without errors

---

### Edge Cases

- What happens when OVH VPS has different disk layout than expected?
- How does system handle network configuration failures during deployment?
- What happens when 1Password service account token is invalid or expired?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST fix disk configuration path mismatch between deploy.sh and actual file location
- **FR-002**: System MUST integrate OpNix for 1Password secrets management in NixOS configuration
- **FR-003**: System MUST configure SSH authorized keys from 1Password via OpNix integration
- **FR-004**: System MUST enable Tailscale service for secure VPN access
- **FR-005**: System MUST support automated deployment using nixos-anywhere tool
- **FR-006**: System MUST validate configuration builds successfully before deployment
- **FR-007**: System MUST provide clear error messages for deployment failures

### Constitutional Requirements

- **CR-001**: Implementation MUST use declarative Nix expressions (Principle I)
- **CR-002**: Feature MUST be delivered as independent NixOS module (Principle II)
- **CR-003**: Secrets MUST use OpNix with 1Password integration (Principle III)
- **CR-004**: Deployment MUST be automated and reproducible (Principle IV)
- **CR-005**: MUST include structured logging and monitoring (Principle V)

### Key Entities *(include if feature involves data)*

- **Configuration Files**: NixOS configuration files that define system setup
- **Deployment Scripts**: Scripts that automate the nixos-anywhere deployment process
- **Secret References**: 1Password vault entries accessed via OpNix for SSH keys and tokens
- **Service Definitions**: Systemd service configurations for SSH, Tailscale, and firewall

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Configuration builds successfully without errors in under 2 minutes
- **SC-002**: nixos-anywhere deployment completes successfully in under 15 minutes
- **SC-003**: Deployed VPS is accessible via SSH within 3 minutes of reboot completion
- **SC-004**: All configured services (SSH, Tailscale, firewall) start successfully on first boot
- **SC-005**: User can perform configuration updates using nixos-rebuild without manual intervention

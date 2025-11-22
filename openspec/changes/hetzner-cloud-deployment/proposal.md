# Deploy pantherOS to Hetzner Cloud VPS

## Why
The pantherOS repository now has a complete flake structure and hetzner-vps configuration, but we need to document and formalize the deployment process to Hetzner Cloud. This will enable reliable, reproducible deployments of the pantherOS configuration to Hetzner's virtual private servers.

## What Changes
- Create documentation for Hetzner Cloud deployment process
- Establish deployment workflow using hcloud CLI
- Formalize the ISO-based installation procedure
- Document server specifications and configuration requirements
- Create troubleshooting and verification steps

## Impact
- Enables reliable deployment of pantherOS to Hetzner Cloud
- Provides clear documentation for future deployments
- Ensures consistent deployment process across team members
- Reduces deployment errors and issues

## Requirements

### Requirement: Documentation of Deployment Process
The system SHALL provide comprehensive documentation covering the entire deployment process from server creation to post-installation verification.

#### Scenario: Deployment documentation is available
- **WHEN** a user needs to deploy pantherOS to Hetzner Cloud
- **THEN** they have access to a step-by-step guide
- **AND** the guide covers prerequisites, server creation, installation, and verification
- **AND** the documentation includes troubleshooting information

### Requirement: Server Configuration Compliance
The deployed system SHALL match the hetzner-vps configuration specified in the flake.

#### Scenario: System configuration matches specification
- **WHEN** the installation process is complete
- **THEN** the server runs the hetzner-vps NixOS configuration
- **AND** all services specified in the configuration are running
- **AND** the disk layout matches the disko specification

### Requirement: Deployment Tool Integration
The deployment process SHALL integrate with Hetzner Cloud CLI tools.

#### Scenario: Deployment uses hcloud CLI
- **WHEN** following the deployment guide
- **THEN** hcloud CLI commands are used for server management
- **AND** SSH key management is handled via hcloud
- **AND** ISO mounting and detaching is done through hcloud

### Requirement: Security Configuration
The deployed server SHALL maintain security standards as defined in the hetzner-vps configuration.

#### Scenario: Security measures are in place
- **WHEN** the server is deployed and running
- **THEN** firewall rules are properly configured
- **AND** SSH access is restricted to authorized keys only
- **AND** encrypted swap is enabled as per disko configuration
- **AND** Tailscale integration is properly set up

## Tasks
- [x] Create comprehensive deployment guide with all steps
- [x] Document hcloud CLI usage for pantherOS deployment
- [x] Include troubleshooting steps for common deployment issues
- [x] Verify the deployment process works as documented
- [x] Create post-deployment verification checklist
- [x] Document rollback procedures if deployment fails

## Success Criteria
- [x] Deployment guide enables successful installation of pantherOS on Hetzner Cloud
- [x] Server matches hetzner-vps configuration after deployment
- [x] All services are running as expected
- [x] Security measures are properly implemented
- [x] Documentation is clear and comprehensive
- [x] Rollback procedures are available if needed
## ADDED Requirements

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
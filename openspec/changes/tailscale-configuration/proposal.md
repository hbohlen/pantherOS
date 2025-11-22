# Change: Tailscale Configuration with 1Password Integration

## Why

pantherOS currently lacks a complete Tailscale configuration proposal that includes secure secret management via 1Password. While Tailscale is mentioned in the architecture documentation, there's no formal proposal detailing the implementation with proper secret handling. This change will establish a secure, properly configured Tailscale setup with secrets managed through 1Password.

## What Changes

- Implement complete Tailscale configuration with 1Password integration for auth keys
- Define module for Tailscale service with proper host tagging and ACL configuration
- Establish secure patterns for Tailscale auth key management using 1Password
- Configure exit nodes and relay functionality as per security model

## Impact

- Affected specs: `tailscale` (new capability)
- Affected code: New module in `modules/nixos/services/tailscale.nix`
- Enables: Secure mesh networking with proper secret management
- Establishes: Standard patterns for Tailscale configuration across all hosts

---

# ADDED Requirements

## Requirement: Tailscale Service Integration

The system SHALL integrate with Tailscale to provide secure mesh networking with proper authentication.

#### Scenario: Tailscale service activation
- **WHEN** Tailscale integration is enabled
- **THEN** service SHALL start and connect to the Tailnet using proper authentication

#### Scenario: Tailscale authentication
- **WHEN** Tailscale service starts
- **THEN** system SHALL retrieve auth key from `op://pantherOS/Tailscale/authKey` via 1Password integration

## Requirement: Host Classification and Tagging

The system SHALL properly classify and tag hosts for Tailscale ACL management.

#### Scenario: Workstation tagging
- **WHEN** Tailscale is configured on workstations (yoga, zephyrus)
- **THEN** hosts SHALL be tagged as `workstation` for ACL purposes

#### Scenario: Server tagging
- **WHEN** Tailscale is configured on servers (hetzner-vps, ovh-vps)
- **THEN** hosts SHALL be tagged as `server` for ACL purposes

## Requirement: Exit Node Configuration

The system SHALL support Tailscale exit node functionality on designated servers.

#### Scenario: Server exit node
- **WHEN** server hosts are configured with exit node capability
- **THEN** Tailscale SHALL be configured to advertise as exit node for other hosts

#### Scenario: Workstation exit node usage
- **WHEN** workstation hosts connect to the Tailnet
- **THEN** they SHALL route traffic through designated server exit nodes
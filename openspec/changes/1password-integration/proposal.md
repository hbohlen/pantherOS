# Change: 1Password Integration for Secret Management

## Why

pantherOS currently lacks a complete and documented 1Password integration for managing secrets across all hosts. While the architecture documentation mentions using 1Password service account with OpNix integration, there's no formal proposal detailing how secrets will be organized, accessed, and managed. This change will establish a comprehensive secret management system using 1Password as the single source of truth.

## What Changes

- Implement complete 1Password integration using OpNix for secure secret retrieval
- Define the complete mapping of 1Password paths to NixOS configuration options
- Create module for 1Password service account configuration
- Establish patterns for accessing secrets in both system and user configurations
- Document security best practices for secret management

## Impact

- Affected specs: `1password-integration` (new capability)
- Affected code: New module in `modules/nixos/security/1password.nix`
- Enables: Secure management of all sensitive credentials without committing to repository
- Establishes: Standard patterns for secret access across all hosts

---

# ADDED Requirements

## Requirement: 1Password Service Account Integration

The system SHALL integrate with 1Password service account to securely manage secrets without storing them in the repository.

#### Scenario: Service account authentication
- **WHEN** system boots with 1Password integration enabled
- **THEN** OpNix SHALL authenticate using the service account token from a secure location

#### Scenario: Secure token management
- **WHEN** 1Password integration is configured
- **THEN** service account token SHALL be stored securely and never committed to the repository

## Requirement: Secret Path Mapping

The system SHALL map 1Password vault paths to NixOS configuration options following a consistent naming pattern.

#### Scenario: Backblaze B2 configuration
- **WHEN** Backblaze B2 service is configured
- **THEN** system SHALL retrieve credentials from `op://pantherOS/backblaze-b2/` paths as specified

#### Scenario: GitHub PAT configuration
- **WHEN** GitHub integration is configured
- **THEN** system SHALL retrieve token from `op://pantherOS/github-pat/token`

#### Scenario: Tailscale configuration
- **WHEN** Tailscale service is configured
- **THEN** system SHALL retrieve auth key from `op://pantherOS/Tailscale/authKey`

#### Scenario: 1Password service account token
- **WHEN** 1Password integration is initialized
- **THEN** system SHALL retrieve token from `op://pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token`

#### Scenario: Datadog configuration
- **WHEN** Datadog monitoring is configured
- **THEN** system SHALL retrieve credentials from `op://pantherOS/datadog/` paths as specified

## Requirement: Secure Secret Access

The system SHALL provide secure access to secrets for both system-level and user-level configurations.

#### Scenario: System-level secret access
- **WHEN** system services require secrets
- **THEN** secrets SHALL be provided via secure file paths or environment variables

#### Scenario: User-level secret access
- **WHEN** user configurations require secrets
- **THEN** secrets SHALL be accessible through Home Manager integration with 1Password

## Requirement: Host-Specific Secret Management

The system SHALL support host-specific secret access patterns appropriate for different host types.

#### Scenario: Workstation vs server secrets
- **WHEN** secrets are accessed on different host types
- **THEN** appropriate secrets SHALL be available based on host classification (workstation vs server)

#### Scenario: Environment-specific access
- **WHEN** configurations are applied to different hosts
- **THEN** secrets SHALL be accessible based on the specific host environment
## ADDED Requirements

### Requirement: 1Password Service Account Integration

The system SHALL integrate with 1Password service account to securely manage secrets without storing them in the repository.

#### Scenario: Service account authentication
- **WHEN** system boots with 1Password integration enabled
- **THEN** OpNix SHALL authenticate using the service account token from a secure location

#### Scenario: Secure token management
- **WHEN** 1Password integration is configured
- **THEN** service account token SHALL be stored securely and never committed to the repository

### Requirement: Secret Path Mapping

The system SHALL map 1Password vault paths to NixOS configuration options following a consistent naming pattern.

#### Scenario: Backblaze B2 configuration
- **WHEN** Backblaze B2 service is configured
- **THEN** system SHALL retrieve credentials from these specific paths:
  - `op://pantherOS/backblaze-b2/default/endpoint`
  - `op://pantherOS/backblaze-b2/default/region`
  - `op://pantherOS/backblaze-b2/master/keyID`
  - `op://pantherOS/backblaze-b2/master/keyName`
  - `op://pantherOS/backblaze-b2/master/applicationKey`
  - `op://pantherOS/backblaze-b2/pantherOS-nix-cache/keyID`
  - `op://pantherOS/backblaze-b2/pantherOS-nix-cache/keyName`
  - `op://pantherOS/backblaze-b2/pantherOS-nix-cache/applicationKey`

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
- **THEN** system SHALL retrieve credentials from these specific paths:
  - `op://pantherOS/datadog/default/DD_HOST`
  - `op://pantherOS/datadog/pantherOS/APPLICATION_KEY`
  - `op://pantherOS/datadog/pantherOS/KEY_ID`
  - `op://pantherOS/datadog/hetzner-vps/API_KEY`
  - `op://pantherOS/datadog/hetzner-vps/KEY_ID`

### Requirement: Secure Secret Access

The system SHALL provide secure access to secrets for both system-level and user-level configurations.

#### Scenario: System-level secret access
- **WHEN** system services require secrets
- **THEN** secrets SHALL be provided via secure file paths or environment variables

#### Scenario: User-level secret access
- **WHEN** user configurations require secrets
- **THEN** secrets SHALL be accessible through Home Manager integration with 1Password

### Requirement: Host-Specific Secret Management

The system SHALL support host-specific secret access patterns appropriate for different host types.

#### Scenario: Workstation vs server secrets
- **WHEN** secrets are accessed on different host types
- **THEN** appropriate secrets SHALL be available based on host classification (workstation vs server)

#### Scenario: Environment-specific access
- **WHEN** configurations are applied to different hosts
- **THEN** secrets SHALL be accessible based on the specific host environment
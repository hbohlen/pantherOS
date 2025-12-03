# Secrets Management Specification

## MODIFIED Requirements

### Requirement: Secret Storage and Encryption
The system SHALL store secrets encrypted in version control using OpNix's secret management, with per-host access control.

#### Scenario: Secret is encrypted for storage
- **WHEN** a new secret is added
- **THEN** the secret is encrypted using OpNix
- **AND** encrypted file is stored in `secrets/` directory
- **AND** only authorized hosts can decrypt the secret via OpNix

#### Scenario: Secret is deployed during system build
- **WHEN** nixos-rebuild is executed
- **THEN** secrets are decrypted by OpNix
- **AND** secrets are placed in `/run/secrets/` with correct permissions
- **AND** services can access their designated secrets

### Requirement: Declarative Secret Management
The system SHALL provide NixOS module options for declaring secrets and their consumers in configuration.

#### Scenario: Declare a secret in configuration
- **WHEN** a secret is defined in `secrets.nix`
- **THEN** the secret path, owner, group, and permissions are specified
- **AND** the secret is available to specified services
- **AND** secret changes trigger service restarts when needed

#### Scenario: Per-host secrets are isolated
- **WHEN** secrets are defined with host-specific keys
- **THEN** each host can only decrypt its own secrets
- **AND** shared secrets can be accessed by multiple hosts
- **AND** secret access is auditable through configuration

### Requirement: Secret Integration with 1Password via OpNix
The system SHALL integrate with 1Password CLI through OpNix to source secrets from vaults and sync to encrypted storage.

#### Scenario: Import secret from 1Password
- **WHEN** using the OpNix 1Password import helper
- **THEN** secret is retrieved from specified vault and item via 1Password CLI
- **AND** secret is encrypted using OpNix for target hosts
- **AND** secret file is created in secrets directory

#### Scenario: Sync secrets from 1Password
- **WHEN** running secret sync command
- **THEN** all configured 1Password items are fetched
- **AND** local encrypted secrets are updated if changed
- **AND** sync operation is logged for audit

### Requirement: Secret Lifecycle Management
The system SHALL provide tools for creating, editing, rotating, and retiring secrets.

#### Scenario: Edit an existing secret
- **WHEN** using the secret edit helper
- **THEN** secret is decrypted to temporary file
- **AND** editor opens for modification
- **AND** modified secret is re-encrypted automatically
- **AND** temporary files are securely wiped

#### Scenario: Rotate a secret
- **WHEN** rotating a secret
- **THEN** new value is generated or provided
- **AND** old value is archived with timestamp
- **AND** services using the secret are notified to restart
- **AND** rotation is recorded in audit log

#### Scenario: Retire a secret
- **WHEN** a secret is no longer needed
- **THEN** secret file is moved to archived directory
- **AND** configuration references are removed or flagged
- **AND** retirement is documented in changelog

### Requirement: Security and Access Control
The system SHALL enforce strict permissions and ownership for secret files and provide secure key management.

#### Scenario: Deployed secrets have restrictive permissions
- **WHEN** secrets are deployed to `/run/secrets/`
- **THEN** files are owned by specified user and group
- **AND** permissions are set to 0400 or 0440
- **AND** parent directory is not world-readable

#### Scenario: OpNix keys are protected
- **WHEN** OpNix keys are stored
- **THEN** keys are stored securely with 0400 permissions
- **AND** keys are accessible only by root
- **AND** keys are excluded from system backups by default

### Requirement: Secret Validation
The system SHALL validate secret configuration and encryption before activation.

#### Scenario: Validate secret encryption
- **WHEN** building system configuration
- **THEN** all referenced secrets can be decrypted
- **AND** secret files have correct format
- **AND** build fails if secrets are missing or malformed

#### Scenario: Validate secret permissions
- **WHEN** deploying secrets
- **THEN** requested permissions are valid (not too permissive)
- **AND** owners and groups exist on the system
- **AND** warnings are issued for overly permissive settings

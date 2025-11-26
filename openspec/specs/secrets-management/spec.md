## ADDED Requirements
### Requirement: 1Password OpNix Secrets Management
The system SHALL securely manage secrets using 1Password OpNix integration.

#### Scenario: OpNix service configured
- **WHEN** system starts
- **THEN** 1Password secrets service is active
- **AND** token file is properly configured

#### Scenario: Tailscale auth key managed
- **WHEN** Tailscale service starts
- **THEN** auth key is retrieved from 1Password vault
- **AND** key file has correct permissions (0600)

#### Scenario: SSH keys distributed
- **WHEN** users log in
- **THEN** SSH authorized_keys are populated from 1Password
- **AND** both root and user SSH keys are configured

#### Scenario: Secret permissions secure
- **WHEN** secrets are deployed
- **THEN** files have appropriate ownership and permissions
- **AND** secrets are not world-readable</content>
<parameter name="filePath">openspec/implemented/secrets-management/spec.md
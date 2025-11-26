## ADDED Requirements
### Requirement: SSH Security Hardening
The system SHALL implement hardened SSH configuration for secure remote access.

#### Scenario: Root login restricted
- **WHEN** SSH connections attempt root login
- **THEN** password authentication is rejected
- **AND** only key-based authentication is allowed

#### Scenario: Password authentication disabled
- **WHEN** SSH daemon starts
- **THEN** PasswordAuthentication is set to false
- **AND** KbdInteractiveAuthentication is disabled

#### Scenario: Key-based authentication works
- **WHEN** authorized SSH keys are configured
- **THEN** users can authenticate with SSH keys
- **AND** root can authenticate with keys only</content>
<parameter name="filePath">openspec/implemented/ssh-hardening/spec.md
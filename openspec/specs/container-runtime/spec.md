## ADDED Requirements
### Requirement: Podman Container Runtime
The system SHALL provide container capabilities using Podman with Docker compatibility.

#### Scenario: Podman service enabled
- **WHEN** system boots
- **THEN** Podman daemon is running
- **AND** Docker CLI compatibility is enabled

#### Scenario: Container networking configured
- **WHEN** containers start
- **THEN** DNS is enabled in default network
- **AND** containers can resolve hostnames

#### Scenario: Container storage optimized
- **WHEN** containers store data
- **THEN** /var/lib/containers uses Btrfs subvolume
- **AND** nodatacow is set for performance

#### Scenario: Docker compatibility works
- **WHEN** docker commands are used
- **THEN** they work transparently with Podman
- **AND** existing Docker workflows function</content>
<parameter name="filePath">openspec/implemented/container-runtime/spec.md
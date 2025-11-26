## ADDED Requirements
### Requirement: Personal Device Host Support with Facter
The system SHALL support configuration of personal devices (zephyrus and yoga) with dedicated host directories containing default.nix, hardware.nix, disko.nix, and meta.nix files generated using facter.

#### Scenario: Host directories with meta.nix exist
- **WHEN** personal device hosts are configured
- **THEN** /hosts/zephyrus/ and /hosts/yoga/ directories exist with default.nix, hardware.nix, disko.nix, and meta.nix files

#### Scenario: Facter-based hardware scanning prerequisite
- **WHEN** implementing hardware.nix and disko.nix
- **THEN** facter must be used to scan hardware and generate meta.nix files first

#### Scenario: Meta.nix structured data
- **WHEN** facter collects hardware specs
- **THEN** meta.nix contains structured Nix attribute sets for CPU, RAM, storage, network, and GPU information

#### Scenario: Configuration isolation
- **WHEN** personal device configurations are built
- **THEN** they remain isolated from server configurations

#### Scenario: Build validation
- **WHEN** host configurations are created
- **THEN** they build successfully without errors</content>
<parameter name="filePath">openspec/changes/add-personal-device-hosts/specs/configuration/spec.md
## ADDED Requirements
### Requirement: Zed IDE Available on Personal Devices
The system SHALL provide Zed IDE on personal devices (zephyrus and yoga) for high-performance code editing.

#### Scenario: Zed flake input configured
- **WHEN** flake.nix is evaluated
- **THEN** zed-industries/zed input is available for building Zed

#### Scenario: Zed installed via Home Manager
- **WHEN** personal device configuration is built
- **THEN** Zed package is installed in user environment

#### Scenario: Zed launches successfully
- **WHEN** user runs zed command on personal device
- **THEN** Zed editor opens and is functional

#### Scenario: Zed available only on personal devices
- **WHEN** server configurations are built
- **THEN** Zed is not installed on server hosts</content>
<parameter name="filePath">openspec/changes/add-zed-ide/specs/development-tools/spec.md
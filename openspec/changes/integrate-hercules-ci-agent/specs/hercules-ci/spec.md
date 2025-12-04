# Spec: Hercules CI Agent Integration

## Purpose
This specification defines the requirements for integrating Hercules CI Agent into pantherOS for continuous integration and deployment of NixOS configurations.

## ADDED Requirements

### Requirement: Hercules CI Agent Configuration
The system SHALL provide a dedicated configuration module for Hercules CI Agent on the hetzner-vps host.

#### Scenario: Configuration file creation
**Given** the hetzner-vps host configuration
**When** hercules-ci.nix is created in the host directory
**Then** the file contains Hercules CI service configuration
**And** the file uses the existing services.ci module
**And** the configuration is imported in the host's default.nix

#### Scenario: Service enablement
**Given** the hercules-ci.nix configuration file
**When** the configuration is applied
**Then** services.ci.enable is set to true
**And** services.ci.herculesCI.enable is set to true
**And** the Hercules CI agent service is enabled via the CI module

---

### Requirement: Secret Management Integration
The system SHALL manage Hercules CI credentials securely using OpNix and 1Password.

#### Scenario: Cluster join token management
**Given** the OpNix secret management is configured
**When** the Hercules CI configuration is enabled
**Then** a cluster join token secret reference is defined in OpNix
**And** the token is stored in 1Password pantherOS vault
**And** the token file path is configured in services.ci.herculesCI.clusterJoinTokenPath
**And** the token file has appropriate permissions (0600)
**And** the token file is owned by hercules-ci-agent user

#### Scenario: Binary cache credentials management
**Given** the OpNix secret management is configured
**When** Hercules CI requires binary cache access
**Then** binary cache credentials are stored in 1Password
**And** the credentials file path is configured in services.ci.herculesCI.binaryCachesPath
**And** the credentials file contains JSON-formatted cache configuration
**And** the credentials file has appropriate permissions (0600)

---

### Requirement: Service Dependencies
The system SHALL ensure Hercules CI service starts only after its dependencies are available.

#### Scenario: OpNix dependency
**Given** the Hercules CI configuration uses OpNix secrets
**When** the system boots or the service starts
**Then** Hercules CI agent waits for onepassword-secrets.service
**And** the agent only starts after secret files are populated
**And** service failures are logged if secrets are missing

#### Scenario: Network dependency
**Given** the Hercules CI agent needs network connectivity
**When** the service starts
**Then** the agent waits for network-online.target
**And** the agent can connect to Hercules CI infrastructure
**And** connection failures are properly logged

---

### Requirement: Documentation
The system SHALL provide comprehensive documentation for Hercules CI setup and operation.

#### Scenario: Setup instructions
**Given** a new system administrator
**When** they need to configure Hercules CI
**Then** documentation explains how to obtain cluster join token
**And** documentation describes 1Password vault setup
**And** documentation shows how to configure binary caches
**And** documentation includes service management commands

#### Scenario: Troubleshooting guidance
**Given** Hercules CI service encounters issues
**When** an administrator needs to diagnose problems
**Then** documentation provides troubleshooting steps
**And** documentation explains how to check service status
**And** documentation shows how to view logs
**And** documentation lists common issues and solutions

---

### Requirement: Configuration Validation
The system SHALL validate that the configuration builds correctly before deployment.

#### Scenario: Build validation
**Given** the Hercules CI configuration is complete
**When** the NixOS configuration is built
**Then** nix build succeeds without errors
**And** the hercules-ci-agent package is included
**And** all secret paths are validated
**And** service dependencies are correctly defined

#### Scenario: Secret path validation
**Given** the Hercules CI configuration references secret paths
**When** the configuration is evaluated
**Then** all secret paths are properly defined in OpNix
**And** secret paths match the CI module's expected locations
**And** the build fails if required secrets are not configured

# Spec: CI Container

## Overview

This spec defines the requirements for a GitLab CI container image that can build and test NixOS configurations in a CI/CD pipeline.

---

## ADDED Requirements

### Requirement: Container Image Build

The system SHALL provide a NixOS-based container image suitable for GitLab CI runners.

#### Scenario: Build container image

**Given** the flake configuration includes a container image output  
**When** `nix build .#gitlab-ci-container` is executed  
**Then** a Docker/OCI-compatible container image is produced  
**And** the image is tagged with version and `latest`

#### Scenario: Container includes required tools

**Given** the container image has been built  
**When** the container is inspected  
**Then** it includes `nix`, `git`, `openssh`, `attic-client`, and `nixos-rebuild` packages  
**And** Nix is configured with flakes and nix-command experimental features enabled

---

### Requirement: Nix Configuration

The container SHALL be pre-configured to use both upstream and private binary caches.

#### Scenario: Cache substituters configured

**Given** the container is running  
**When** Nix configuration is queried  
**Then** substituters include `https://cache.nixos.org` and the Attic cache URL  
**And** trusted public keys are configured for both caches

#### Scenario: Attic client pre-configured

**Given** the container includes attic-client  
**When** the CI pipeline provides authentication token  
**Then** the container can authenticate to the Attic server  
**And** can push and pull store paths without additional configuration

---

### Requirement: Container Optimization

The container image SHALL be optimized for size and layer caching.

#### Scenario: Image size constraint

**Given** the container image is built  
**When** the compressed image size is measured  
**Then** it is less than 2GB compressed

#### Scenario: Layer structure for caching

**Given** the container uses layered image structure  
**When** dependencies are updated  
**Then** only changed layers need to be re-downloaded  
**And** base layers remain cached in GitLab CI

---

### Requirement: CI Pipeline Integration

The container SHALL integrate seamlessly with GitLab CI pipelines.

#### Scenario: Container runs in GitLab CI

**Given** a `.gitlab-ci.yml` references the container image  
**When** a CI pipeline is triggered  
**Then** the container starts successfully  
**And** can execute Nix commands

#### Scenario: Build NixOS configuration

**Given** the container is running in CI  
**When** `nix build .#nixosConfigurations.hetzner-vps` is executed  
**Then** the build completes successfully  
**And** build artifacts are available for subsequent stages

---

### Requirement: Security

The container SHALL follow security best practices for CI environments.

#### Scenario: Minimal privilege execution

**Given** the container is running  
**When** processes are inspected  
**Then** no processes run as root unless required  
**And** sensitive operations use appropriate privilege escalation

#### Scenario: No embedded secrets

**Given** the container image  
**When** the image layers are inspected  
**Then** no secrets, tokens, or credentials are embedded  
**And** all secrets are provided via CI variables at runtime

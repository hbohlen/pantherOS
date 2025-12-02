# Spec: Automated Deployment

## Overview
This spec defines the requirements for automated deployment of NixOS configurations to target hosts upon successful CI builds.

---

## ADDED Requirements

### Requirement: GitLab CI Pipeline
The system SHALL provide a GitLab CI pipeline that builds, tests, caches, and deploys NixOS configurations.

#### Scenario: Pipeline stages
**Given** a `.gitlab-ci.yml` file exists  
**When** a commit is pushed to the repository  
**Then** the pipeline executes stages in order: build, test, cache, deploy  
**And** each stage depends on the success of the previous stage

#### Scenario: Build stage
**Given** the build stage is running  
**When** `nix build .#nixosConfigurations.hetzner-vps` is executed  
**Then** the NixOS configuration builds successfully  
**And** build artifacts are saved for subsequent stages

#### Scenario: Test stage
**Given** the build stage succeeded  
**When** the test stage runs  
**Then** `nix flake check` is executed  
**And** integration tests are run  
**And** the stage fails if any test fails

#### Scenario: Cache stage
**Given** the test stage succeeded  
**When** the cache stage runs  
**Then** build artifacts are pushed to Attic cache  
**And** the push completes successfully

---

### Requirement: Deployment Automation
The system SHALL automatically deploy to the Hetzner VPS on successful builds.

#### Scenario: Deployment trigger
**Given** all previous pipeline stages succeeded  
**And** the commit is on the main branch  
**When** the deploy stage runs  
**Then** deployment to Hetzner VPS is initiated

#### Scenario: Pre-deployment checks
**Given** the deploy stage is running  
**When** pre-deployment checks execute  
**Then** SSH connectivity to the target host is verified  
**And** Attic cache accessibility is verified  
**And** disk space on the target is checked

#### Scenario: NixOS rebuild
**Given** pre-deployment checks passed  
**When** `nixos-rebuild switch --flake .#hetzner-vps --target-host` is executed  
**Then** the new configuration is built on the target host  
**And** the system switches to the new generation  
**And** services are restarted as needed

#### Scenario: Post-deployment verification
**Given** the deployment completed  
**When** post-deployment checks run  
**Then** system services are verified to be running  
**And** smoke tests are executed  
**And** deployment status is reported to GitLab

---

### Requirement: Deployment Security
The system SHALL securely handle credentials and access during deployment.

#### Scenario: SSH key management
**Given** deployment requires SSH access  
**When** the deploy stage runs  
**Then** the SSH private key is loaded from GitLab CI variables  
**And** the key is used only for the deployment  
**And** the key is not persisted after the job completes

#### Scenario: Secrets in CI variables
**Given** GitLab CI variables are configured  
**When** the pipeline accesses secrets  
**Then** variables are marked as protected and masked  
**And** secrets are only available to protected branches  
**And** secrets are not exposed in logs

---

### Requirement: Deployment Flexibility
The system SHALL support both automatic and manual deployment triggers.

#### Scenario: Automatic deployment on main
**Given** a commit is pushed to the main branch  
**When** all pipeline stages succeed  
**Then** deployment runs automatically  
**And** no manual intervention is required

#### Scenario: Manual deployment trigger
**Given** a commit is on a feature branch  
**When** a developer triggers manual deployment  
**Then** the deploy stage runs  
**And** deploys to the specified target host

#### Scenario: Deployment to specific host
**Given** multiple NixOS configurations exist  
**When** deployment is triggered with a host parameter  
**Then** only the specified host configuration is deployed  
**And** other hosts are not affected

---

### Requirement: Cache-Optimized Deployment
The system SHALL use the Attic cache to speed up deployments.

#### Scenario: Cache pull during deployment
**Given** the target host is configured to use Attic cache  
**When** `nixos-rebuild` runs on the target  
**Then** store paths are pulled from Attic cache  
**And** only missing paths are built locally

#### Scenario: Deployment time improvement
**Given** the Attic cache contains recent builds  
**When** deployment runs with warm cache  
**Then** deployment completes in less than 2 minutes  
**And** is significantly faster than cold builds

---

### Requirement: Deployment Logging and Reporting
The system SHALL provide comprehensive logs and status reporting for deployments.

#### Scenario: Deployment logs
**Given** a deployment is running  
**When** the deployment script executes  
**Then** all output is captured and logged  
**And** logs are available as GitLab CI artifacts

#### Scenario: Deployment status reporting
**Given** a deployment completes  
**When** the final status is determined  
**Then** success or failure is reported to GitLab  
**And** the commit status is updated  
**And** notifications are sent if configured

#### Scenario: Deployment history
**Given** multiple deployments have occurred  
**When** deployment history is queried  
**Then** all deployments are listed with timestamps  
**And** status (success/failure) is shown  
**And** logs are accessible for each deployment

---

### Requirement: Rollback Support
The system SHALL support rollback to previous system generations.

#### Scenario: Manual rollback
**Given** a deployment caused issues  
**When** an administrator runs rollback on the target host  
**Then** the system switches to the previous generation  
**And** services are restarted with the old configuration

#### Scenario: Rollback via CI
**Given** a rollback is needed  
**When** a manual CI job is triggered with rollback parameter  
**Then** the target host is instructed to rollback  
**And** the previous generation is activated

---

### Requirement: Deployment Safety
The system SHALL include safety mechanisms to prevent destructive deployments.

#### Scenario: Dry-run mode
**Given** a deployment script supports dry-run  
**When** `--dry-run` flag is used  
**Then** the deployment is simulated  
**And** no actual changes are made to the target host  
**And** the expected changes are reported

#### Scenario: Deployment confirmation
**Given** a critical deployment is triggered  
**When** manual approval is required  
**Then** the pipeline pauses before deployment  
**And** waits for administrator approval  
**And** proceeds only after confirmation

---

### Requirement: Multi-Host Deployment
The system SHALL support deployment to multiple hosts in the future.

#### Scenario: Host selection
**Given** multiple NixOS configurations exist (hetzner-vps, ovh-vps, yoga, zephyrus)  
**When** deployment is configured for a specific host  
**Then** only that host's configuration is deployed  
**And** the deployment script is reusable for other hosts

#### Scenario: Parallel deployment preparation
**Given** the infrastructure supports multiple hosts  
**When** the pipeline is extended for multi-host deployment  
**Then** builds for all hosts can run in parallel  
**And** deployments can be orchestrated sequentially or in parallel

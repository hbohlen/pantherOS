# Spec Delta: Automated Deployment

## Purpose
This specification defines the requirements for an automated deployment system using GitHub Actions to build, test, and deploy NixOS configurations to production VPS servers.

## ADDED Requirements

### Requirement: GitHub Actions Two-Stage CI/CD Pipeline
The system SHALL provide a GitHub Actions-based CI/CD pipeline with separate build/test and deploy stages.

#### Scenario: Build & Test stage (automatic)
**Given** a commit is pushed to the main branch
**When** the GitHub Actions workflow is triggered
**Then** flake check, linting, and parallel builds execute for all VPS configurations
**And** build artifacts are cached for deployment stage
**And** status checks are required for PR merges

#### Scenario: Manual Deploy stage
**Given** the build & test stage completed successfully
**When** an authorized user triggers the deploy workflow via GitHub UI
**Then** a deployment job runs for each selected host
**And** deployment uses either nixos-anywhere or nixos-rebuild based on configuration
**And** sequential deployment ensures one host completes before the next starts

---

### Requirement: Multi-Host Deployment Support
The system SHALL support deployment to multiple VPS hosts (hetzner-vps, ovh-vps, contabo-vps) with individual control.

#### Scenario: Host selection in deploy workflow
**Given** the deploy workflow is triggered manually
**When** the user selects specific target hosts via workflow inputs
**Then** deployment jobs run only for the selected hosts
**And** unselected hosts are not affected by the deployment

#### Scenario: Individual host deployment
**Given** the deploy workflow is configured for hetzner-vps
**When** deployment is triggered
**Then** only the hetzner-vps configuration is deployed
**And** ovh-vps and contabo-vps configurations are not affected
**And** similar behavior applies for each individual host

#### Scenario: Parallel build, sequential deploy
**Given** multiple NixOS configurations exist
**When** the build & test stage runs
**Then** all host configurations build in parallel for efficiency
**But** deployments execute sequentially by default to reduce risk
**And** each deployment completes before the next begins

---

### Requirement: Dual Deployment Methods
The system SHALL support both fresh server installation (nixos-anywhere) and configuration updates (nixos-rebuild switch).

#### Scenario: Fresh installation via nixos-anywhere
**Given** the deployment method is set to 'fresh-install'
**When** the deployment job executes
**Then** `nix run github:nix-community/nixos-anywhere` is executed
**And** the target server is provisioned from scratch
**And** no reboot is required if --no-reboot flag is used
**And** OpNix integration is configured after installation completes

#### Scenario: Configuration update via nixos-rebuild
**Given** the deployment method is set to 'update-existing'
**When** the deployment job executes
**Then** `nixos-rebuild switch --flake .#<host>` is executed on the target
**And** the existing NixOS system is updated in-place
**And** services restart as needed without full system reboot
**And** deployment completes faster than fresh installation

#### Scenario: Deployment method selection
**Given** a manual deployment is triggered
**When** the user selects deployment method via workflow inputs
**Then** the selected method is used for all target hosts
**And** the workflow fails gracefully if the method is incompatible with the target

---

### Requirement: Manual Approval Gate
The system SHALL require manual approval for all production deployments.

#### Scenario: GitHub Environments with approval
**Given** GitHub Environments are configured for deployments
**When** a deploy workflow is triggered
**Then** the workflow pauses at the environment protection rule
**And** waits for an authorized reviewer to approve
**And** deployment only proceeds after approval is granted

#### Scenario: Production vs Staging environments
**Given** 'production' and 'staging' environments are configured
**When** deploying to hetzner-vps (production)
**Then** approval is always required from specified reviewers
**When** deploying to ovh-vps or contabo-vps (staging)
**Then** approval is required but with less stringent review
**And** both environments maintain security controls

#### Scenario: Approval rejection
**Given** a deployment is pending approval
**When** an authorized reviewer rejects the deployment
**Then** the workflow is cancelled
**And** no deployment occurs to any target hosts
**And** the reason for rejection is recorded in the workflow logs

---

### Requirement: GitHub Repository Secret Management
The system SHALL securely manage all deployment secrets via GitHub repository secrets.

#### Scenario: Server IP secrets
**Given** repository secrets contain VPS IP addresses (HETZNER_VPS_IP, OVH_VPS_IP, CONTABO_VPS_IP)
**When** a deployment job accesses these secrets
**Then** the IPs are loaded securely from GitHub's secret store
**And** the IPs are not exposed in workflow logs
**And** the secrets are only available to authorized workflows

#### Scenario: OpNix token management
**Given** the OPNIX_TOKEN secret is configured
**When** a deployment job needs OpNix access
**Then** the token is retrieved from GitHub secrets
**And** the token is transferred securely to the target host
**And** the token is never persisted in workflow logs or artifacts

#### Scenario: SSH key management
**Given** the DEPLOY_SSH_KEY secret contains the private key
**When** a deployment job requires SSH access
**Then** the key is loaded from GitHub secrets
**And** the key is configured in SSH agent for the job duration
**And** the key is automatically cleaned up after the job completes

---

### Requirement: Post-Deployment Verification
The system SHALL verify deployment success through automated health checks.

#### Scenario: SSH connectivity verification
**Given** deployment to a target host has completed
**When** post-deployment checks run
**Then** SSH connectivity to the host is verified
**And** the connection uses key-based authentication
**And** connection timeout is less than 10 seconds

#### Scenario: Service health verification
**Given** the target host is accessible
**When** service health checks execute
**Then** critical services (OpNix, Tailscale, SSH) are verified as running
**And** systemctl is-active returns success for each service
**And** failed services cause the deployment to be marked as failed

#### Scenario: NixOS configuration verification
**Given** post-deployment checks are running
**When** the NixOS configuration is checked
**Then** `nixos-version` confirms the expected version
**And** `nixos-rebuild dry-run` passes if executed
**And** the active generation corresponds to the deployed configuration

---

### Requirement: Deployment Script CI/CD Mode
The system SHALL support CI/CD execution mode for all deployment scripts.

#### Scenario: Non-interactive execution
**Given** a deployment script runs in CI/CD mode
**When** the CI environment variable is set
**Then** all prompts and confirmations are bypassed
**And** the script proceeds with default safe options
**And** detailed progress is logged to stdout/stderr for CI logs

#### Scenario: Environment variable configuration
**Given** deployment scripts support CI/CD mode
**When** configuration is provided via environment variables
**Then** script flags are derived from environment variables
**And** validation ensures all required variables are present
**And** errors are reported with clear messages for CI debugging

#### Scenario: GitHub Actions output formatting
**Given** deployment scripts run in GitHub Actions
**When** output is generated
**Then** status messages use GitHub Actions command syntax
**And** step summaries are written for important milestones
**And** errors use appropriate exit codes (0 for success, non-zero for failure)

---

### Requirement: Failure Handling and Recovery
The system SHALL handle deployment failures gracefully with clear error reporting and recovery options.

#### Scenario: Deployment failure detection
**Given** a deployment job is executing
**When** any step fails (build, transfer, configuration, verification)
**Then** the job is marked as failed immediately
**And** all subsequent steps for that host are skipped
**And** other host deployments continue unless explicitly stopped

#### Scenario: Partial deployment handling
**Given** multiple hosts are selected for deployment
**When** one host deployment fails
**Then** the failed host is marked as failed
**And** subsequent hosts continue deployment
**And** the final workflow status reflects both successes and failures

#### Scenario: Deployment failure logging
**Given** a deployment fails at any stage
**When** the failure is detected
**Then** detailed error logs are captured as workflow artifacts
**And** the failure reason is clearly reported in the workflow summary
**And** recommendations for resolution are included in the error message

#### Scenario: Manual rollback after failed deployment
**Given** a deployment has failed or caused issues
**When** an administrator accesses the target host
**Then** the previous NixOS generation can be activated manually
**And** `nixos-rebuild switch --rollback` restores the previous configuration
**And** services are restarted with the old configuration

---

### Requirement: Workflow Configuration and Customization
The system SHALL provide flexible workflow configuration through GitHub workflow inputs and environment variables.

#### Scenario: Skip reboot option
**Given** a nixos-anywhere deployment is configured
**When** the skip-reboot input is set to true
**Then** the --no-reboot flag is passed to nixos-anywhere
**And** the server does not reboot after installation
**And** manual verification is required before system is used

#### Scenario: Verbose logging mode
**Given** verbose mode is enabled in workflow inputs
**When** deployment scripts execute
**Then** additional debug information is logged
**And** all intermediate commands are logged
**And** the increased verbosity helps with troubleshooting

#### Scenario: Workflow retry capability
**Given** a deployment workflow has failed
**When** an authorized user re-runs the workflow
**Then** the same inputs can be reused
**And** the deployment restarts from the beginning
**And** previous failure artifacts are preserved for analysis

### Requirement: Deployment Security
The system SHALL securely handle credentials and access during deployment using GitHub Actions environments.

#### Scenario: GitHub Actions secrets security
**Given** GitHub Actions workflows are configured
**When** deployment jobs access repository secrets
**Then** secrets are loaded from GitHub's encrypted secret store
**And** secrets are masked in all log output
**And** secrets are only available to authorized workflows and branches
**And** secrets are automatically cleaned up after deployment

#### Scenario: Environment protection
**Given** GitHub Environments are configured for production and staging
**When** deployments are triggered
**Then** protected environments require approval from designated reviewers
**And** deployments to production require stricter review than staging
**And** all deployments are logged with reviewer information for audit trail

#### Scenario: SSH key management
**Given** SSH deployment keys are required for remote host access
**When** a deployment job begins
**Then** SSH keys are loaded from GitHub secrets
**And** keys are configured with appropriate permissions
**And** keys are removed from the runner after deployment completes


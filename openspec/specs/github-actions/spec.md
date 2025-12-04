# Spec Delta: GitHub Actions CI/CD Infrastructure

## Purpose
This specification defines the requirements for GitHub Actions-based CI/CD infrastructure for NixOS configuration management and deployment.

## ADDED Requirements

### Requirement: GitHub Actions Workflow Files
The system SHALL provide GitHub Actions workflow files in `.github/workflows/` directory.

#### Scenario: CI workflow file creation
**Given** the repository is configured for GitHub Actions
**When** the ci.yml workflow is created in `.github/workflows/`
**Then** the workflow is automatically available in the GitHub UI
**And** the workflow triggers on push to main branch
**And** all workflow runs are logged and visible in the Actions tab

#### Scenario: Deploy workflow file creation
**Given** the repository is configured for GitHub Actions
**When** the deploy.yml workflow is created in `.github/workflows/`
**Then** the workflow is available for manual triggering
**And** the workflow supports workflow_dispatch with inputs
**And** authorized users can trigger deployment via GitHub UI

---

### Requirement: Build & Test Workflow
The system SHALL provide an automatic build and test workflow that validates all NixOS configurations.

#### Scenario: Workflow trigger
**Given** the ci.yml workflow exists
**When** a commit is pushed to the main branch
**Then** the workflow starts automatically
**And** no manual intervention is required
**And** the workflow status appears as a commit status check

#### Scenario: Flake check and linting
**Given** the build & test workflow is running
**When** the lint job executes
**Then** `nix flake check` runs to validate flake structure
**And** `statix` lints all Nix files for best practices
**And** `deadnix` checks for unused code
**And** any failures cause the entire workflow to fail

#### Scenario: Parallel configuration builds
**Given** the build job executes
**When** building NixOS configurations
**Then** hetzner-vps, ovh-vps, and contabo-vps build in parallel
**And** each build runs `nix build .#nixosConfigurations.<host>`
**And** all builds must succeed for the job to pass
**And** individual build failures are clearly reported

#### Scenario: Build artifact caching
**Given** builds complete successfully
**When** the cache job runs
**Then** build artifacts are uploaded to GitHub
**And** artifacts are available for the deploy workflow
**And** artifacts are retained for 30 days
**And** cache hits speed up subsequent deployments

#### Scenario: Required status checks
**Given** branch protection is configured
**When** a pull request is created or updated
**Then** the ci workflow must pass before merging
**And** all build jobs must complete successfully
**And** failing checks block the merge button
**And** reviewers can see workflow status in the PR

---

### Requirement: Manual Deploy Workflow
The system SHALL provide a manually-triggered deploy workflow with flexible host selection.

#### Scenario: Workflow dispatch with inputs
**Given** the deploy.yml workflow exists
**When** an authorized user accesses the workflow in GitHub UI
**Then** a "Run workflow" button is available
**And** the user can select target hosts via checkboxes
**And** the user can choose deployment method (fresh-install or update-existing)
**And** the user can set additional options like skip-reboot

#### Scenario: Target host selection
**Given** the deploy workflow is dispatched
**When** the user selects specific hosts (e.g., only hetzner-vps)
**Then** deployment jobs run only for selected hosts
**And** unselected hosts are completely unaffected
**And** the workflow matrix dynamically adjusts based on selection
**And** the UI shows which hosts will be deployed

#### Scenario: Deployment method selection
**Given** the deploy workflow is dispatched
**When** the user chooses between 'fresh-install' and 'update-existing'
**Then** all selected hosts use the same deployment method
**And** the method is passed to the deployment scripts
**And** incompatible combinations fail gracefully with clear errors

#### Scenario: Sequential host deployment
**Given** multiple hosts are selected for deployment
**When** the workflow executes
**Then** deployments run one host at a time sequentially
**And** each deployment must complete before the next begins
**And** failures stop the sequence and are clearly reported
**And** successful deployments can continue to the next host

---

### Requirement: GitHub Environments Configuration
The system SHALL use GitHub Environments for controlled deployments with approval gates.

#### Scenario: Production environment
**Given** GitHub Environments are configured
**When** deploying to hetzner-vps (production environment)
**Then** the workflow pauses for required reviewer approval
**And** only specified reviewers can approve the deployment
**And** the deployment proceeds only after approval
**And** all approvals are logged in the deployment record

#### Scenario: Staging environment
**Given** staging environment is configured for ovh-vps and contabo-vps
**When** deploying to these hosts
**Then** approval is still required but with less stringent review
**And** different reviewers can be specified for staging vs production
**And** the approval process is recorded in the deployment history

#### Scenario: Environment-specific protection rules
**Given** environment protection rules are defined
**When** a workflow reaches the deployment step
**Then** GitHub checks all protection rules before proceeding
**And** rules can specify required reviewers, wait timers, or custom checks
**And** violations prevent deployment and report clear errors

---

### Requirement: Repository Secrets Management
The system SHALL securely manage deployment secrets through GitHub repository settings.

#### Scenario: Secret storage
**Given** repository administrators access GitHub settings
**When** deployment secrets are configured
**Then** secrets are stored in the repository's encrypted secret store
**And** secrets are encrypted with GitHub's encryption
**And** secrets are never visible in the UI after initial creation
**And** only authorized workflows can access the secrets

#### Scenario: Secret access in workflows
**Given** repository secrets are configured
**When** a workflow accesses a secret via ${{ secrets.SECRET_NAME }}
**Then** the secret value is injected at runtime
**And** the secret is masked in all log output
**And** secrets are automatically redacted from workflow logs
**And** access attempts are audited in GitHub's audit log

#### Scenario: Required secrets validation
**Given** a deployment workflow requires specific secrets
**When** the workflow starts without all required secrets
**Then** the workflow fails immediately with a clear error
**And** the error message indicates which secret is missing
**And** the workflow does not proceed without proper configuration

---

### Requirement: Deployment Script Integration
The system SHALL integrate existing deployment scripts with GitHub Actions workflows.

#### Scenario: CI mode execution
**Given** deployment scripts support CI/CD mode
**When** executed by GitHub Actions
**Then** scripts run in non-interactive mode
**And** all user prompts are automatically answered
**And** environment variables configure script behavior
**And** scripts use appropriate exit codes for success/failure

#### Scenario: GitHub Actions command output
**Given** deployment scripts run in GitHub Actions
**When** output is generated
**Then** status messages use `::` command syntax for proper formatting
**And** important milestones are marked with step summaries
**And** errors are formatted for easy identification
**And** logs are captured as workflow artifacts

#### Scenario: Script error handling
**Given** deployment scripts execute in CI/CD
**When** an error occurs at any stage
**Then** the script exits with a non-zero exit code
**And** detailed error context is logged
**And** the GitHub Actions job is marked as failed
**And** subsequent steps are skipped appropriately

---

### Requirement: Health Checks and Verification
The system SHALL verify deployment success through automated post-deployment checks.

#### Scenario: SSH connectivity check
**Given** deployment to a target host has completed
**When** post-deployment verification runs
**Then** SSH connectivity is tested from the CI runner
**And** the connection uses configured SSH keys
**And** connection timeout is reasonable (under 10 seconds)
**And** connection failures are reported clearly

#### Scenario: Service verification
**Given** the target host is accessible via SSH
**When** service health checks execute
**Then** critical services are verified with systemctl
**And** OpNix service status is checked
**And** Tailscale service status is checked
**And** SSH service status is checked
**And** any failed services cause verification to fail

#### Scenario: NixOS configuration verification
**Given** post-deployment checks are running
**When** the NixOS configuration is validated
**Then** `nixos-version` confirms the expected version
**And** `/etc/nixos/configuration.nix` exists and is readable
**And** the current generation matches expected configuration
**And** verification results are reported in workflow summaries

---

### Requirement: Workflow Artifacts and Logging
The system SHALL provide comprehensive logging and artifact retention for deployments.

#### Scenario: Deployment log capture
**Given** a deployment workflow is executing
**When** deployment scripts run
**Then** all stdout and stderr is captured in workflow logs
**And** logs are available in the GitHub UI immediately
**And** logs persist after the workflow completes
**And** logs can be downloaded as artifacts

#### Scenario: Workflow artifact upload
**Given** deployment logs are captured
**When** the job completes
**Then** logs are uploaded as workflow artifacts
**And** artifacts are retained for 30 days
**And** artifacts can be downloaded from the workflow run page
**And** artifacts include timestamps and host identifiers

#### Scenario: Workflow run history
**Given** multiple deployments have occurred
**When** an administrator reviews deployment history
**Then** all workflow runs are listed in the Actions tab
**And** each run shows success/failure status
**And** run details include which hosts were deployed
**And** logs and artifacts are accessible for each run

---

### Requirement: Security Best Practices
The system SHALL follow GitHub Actions security best practices for CI/CD workflows.

#### Scenario: Minimal workflow permissions
**Given** GitHub Actions workflows are configured
**When** they execute
**Then** they use minimal required permissions
**And** workflows cannot access unauthorized repositories
**And** workflows cannot expose secrets to unauthorized parties
**And** permissions are explicitly declared in workflow files

#### Scenario: Environment variable sanitization
**Given** workflows use environment variables
**When** values are logged or displayed
**Then** sensitive values are automatically masked
**And** secret values never appear in plain text logs
**And** workflow authors must explicitly opt-in to exposing variables
**And** debugging features don't inadvertently leak secrets

#### Scenario: Workflow forked repository security
**Given** the repository accepts contributions from forks
**When** pull requests from forks are created
**Then** workflows run with restricted permissions
**And** secrets are not available to fork workflows
**And** malicious code in forks cannot access production secrets
**And** only approved contributors can trigger production deployments

---

### Requirement: Branch Protection and Required Checks
The system SHALL enforce code quality through branch protection rules.

#### Scenario: Main branch protection
**Given** branch protection is enabled on main
**When** a pull request targets main
**Then** all required status checks must pass
**And** up-to-date checks ensure the branch hasn't diverged
**And** at least one reviewer must approve the PR
**And** enforcement prevents direct pushes to main

#### Scenario: Status check requirements
**Given** required status checks are configured
**When** the ci workflow runs
**Then** its results appear as commit status checks
**And** failing checks block PR merging
**And** checks must pass on the latest commit
**And** administrators cannot bypass protection rules

#### Scenario: Pull request integration
**Given** branch protection requires CI checks
**When** a developer creates a pull request
**Then** the ci workflow automatically runs
**And** results appear in the PR checks section
**And** the merge button remains disabled until checks pass
**And** reviewers can see detailed workflow results

---

### Requirement: Workflow Reusability and Maintenance
The system SHALL provide maintainable and reusable workflow configurations.

#### Scenario: Workflow modularity
**Given** deployment workflows need to support multiple hosts
**When** workflows are structured for reusability
**Then** common steps are encapsulated in reusable workflows
**And** host-specific configuration is parameterized
**And** similar workflows can share common jobs
**And** maintenance updates apply consistently

#### Scenario: Workflow version compatibility
**Given** GitHub Actions versions and Nix versions evolve
**When** workflows are updated
**Then** version pins ensure reproducible builds
**And** updates are tested before deployment
**And** breaking changes are documented
**And** rollback procedures exist for failed updates

#### Scenario: Documentation and examples
**Given** workflows are complex and configurable
**When** maintainers need to understand them
**Then** inline comments explain non-obvious logic
**And** workflow inputs are documented in the workflow file
**And** README files provide usage examples
**And** troubleshooting guides exist for common issues
## Requirements
### Requirement: GitHub Actions Workflow Files
The system SHALL provide GitHub Actions workflow files in `.github/workflows/` directory.

#### Scenario: CI workflow file creation
**Given** the repository is configured for GitHub Actions
**When** the ci.yml workflow is created in `.github/workflows/`
**Then** the workflow is automatically available in the GitHub UI
**And** the workflow triggers on push to main branch
**And** all workflow runs are logged and visible in the Actions tab

#### Scenario: Deploy workflow file creation
**Given** the repository is configured for GitHub Actions
**When** the deploy.yml workflow is created in `.github/workflows/`
**Then** the workflow is available for manual triggering
**And** the workflow supports workflow_dispatch with inputs
**And** authorized users can trigger deployment via GitHub UI

---

### Requirement: Build & Test Workflow
The system SHALL provide an automatic build and test workflow that validates all NixOS configurations.

#### Scenario: Workflow trigger
**Given** the ci.yml workflow exists
**When** a commit is pushed to the main branch
**Then** the workflow starts automatically
**And** no manual intervention is required
**And** the workflow status appears as a commit status check

#### Scenario: Flake check and linting
**Given** the build & test workflow is running
**When** the lint job executes
**Then** `nix flake check` runs to validate flake structure
**And** `statix` lints all Nix files for best practices
**And** `deadnix` checks for unused code
**And** any failures cause the entire workflow to fail

#### Scenario: Parallel configuration builds
**Given** the build job executes
**When** building NixOS configurations
**Then** hetzner-vps, ovh-vps, and contabo-vps build in parallel
**And** each build runs `nix build .#nixosConfigurations.<host>`
**And** all builds must succeed for the job to pass
**And** individual build failures are clearly reported

#### Scenario: Build artifact caching
**Given** builds complete successfully
**When** the cache job runs
**Then** build artifacts are uploaded to GitHub
**And** artifacts are available for the deploy workflow
**And** artifacts are retained for 30 days
**And** cache hits speed up subsequent deployments

#### Scenario: Required status checks
**Given** branch protection is configured
**When** a pull request is created or updated
**Then** the ci workflow must pass before merging
**And** all build jobs must complete successfully
**And** failing checks block the merge button
**And** reviewers can see workflow status in the PR

---

### Requirement: Manual Deploy Workflow
The system SHALL provide a manually-triggered deploy workflow with flexible host selection.

#### Scenario: Workflow dispatch with inputs
**Given** the deploy.yml workflow exists
**When** an authorized user accesses the workflow in GitHub UI
**Then** a "Run workflow" button is available
**And** the user can select target hosts via checkboxes
**And** the user can choose deployment method (fresh-install or update-existing)
**And** the user can set additional options like skip-reboot

#### Scenario: Target host selection
**Given** the deploy workflow is dispatched
**When** the user selects specific hosts (e.g., only hetzner-vps)
**Then** deployment jobs run only for selected hosts
**And** unselected hosts are completely unaffected
**And** the workflow matrix dynamically adjusts based on selection
**And** the UI shows which hosts will be deployed

#### Scenario: Deployment method selection
**Given** the deploy workflow is dispatched
**When** the user chooses between 'fresh-install' and 'update-existing'
**Then** all selected hosts use the same deployment method
**And** the method is passed to the deployment scripts
**And** incompatible combinations fail gracefully with clear errors

#### Scenario: Sequential host deployment
**Given** multiple hosts are selected for deployment
**When** the workflow executes
**Then** deployments run one host at a time sequentially
**And** each deployment must complete before the next begins
**And** failures stop the sequence and are clearly reported
**And** successful deployments can continue to the next host

---

### Requirement: GitHub Environments Configuration
The system SHALL use GitHub Environments for controlled deployments with approval gates.

#### Scenario: Production environment
**Given** GitHub Environments are configured
**When** deploying to hetzner-vps (production environment)
**Then** the workflow pauses for required reviewer approval
**And** only specified reviewers can approve the deployment
**And** the deployment proceeds only after approval
**And** all approvals are logged in the deployment record

#### Scenario: Staging environment
**Given** staging environment is configured for ovh-vps and contabo-vps
**When** deploying to these hosts
**Then** approval is still required but with less stringent review
**And** different reviewers can be specified for staging vs production
**And** the approval process is recorded in the deployment history

#### Scenario: Environment-specific protection rules
**Given** environment protection rules are defined
**When** a workflow reaches the deployment step
**Then** GitHub checks all protection rules before proceeding
**And** rules can specify required reviewers, wait timers, or custom checks
**And** violations prevent deployment and report clear errors

---

### Requirement: Repository Secrets Management
The system SHALL securely manage deployment secrets through GitHub repository settings.

#### Scenario: Secret storage
**Given** repository administrators access GitHub settings
**When** deployment secrets are configured
**Then** secrets are stored in the repository's encrypted secret store
**And** secrets are encrypted with GitHub's encryption
**And** secrets are never visible in the UI after initial creation
**And** only authorized workflows can access the secrets

#### Scenario: Secret access in workflows
**Given** repository secrets are configured
**When** a workflow accesses a secret via ${{ secrets.SECRET_NAME }}
**Then** the secret value is injected at runtime
**And** the secret is masked in all log output
**And** secrets are automatically redacted from workflow logs
**And** access attempts are audited in GitHub's audit log

#### Scenario: Required secrets validation
**Given** a deployment workflow requires specific secrets
**When** the workflow starts without all required secrets
**Then** the workflow fails immediately with a clear error
**And** the error message indicates which secret is missing
**And** the workflow does not proceed without proper configuration

---

### Requirement: Deployment Script Integration
The system SHALL integrate existing deployment scripts with GitHub Actions workflows.

#### Scenario: CI mode execution
**Given** deployment scripts support CI/CD mode
**When** executed by GitHub Actions
**Then** scripts run in non-interactive mode
**And** all user prompts are automatically answered
**And** environment variables configure script behavior
**And** scripts use appropriate exit codes for success/failure

#### Scenario: GitHub Actions command output
**Given** deployment scripts run in GitHub Actions
**When** output is generated
**Then** status messages use `::` command syntax for proper formatting
**And** important milestones are marked with step summaries
**And** errors are formatted for easy identification
**And** logs are captured as workflow artifacts

#### Scenario: Script error handling
**Given** deployment scripts execute in CI/CD
**When** an error occurs at any stage
**Then** the script exits with a non-zero exit code
**And** detailed error context is logged
**And** the GitHub Actions job is marked as failed
**And** subsequent steps are skipped appropriately

---

### Requirement: Health Checks and Verification
The system SHALL verify deployment success through automated post-deployment checks.

#### Scenario: SSH connectivity check
**Given** deployment to a target host has completed
**When** post-deployment verification runs
**Then** SSH connectivity is tested from the CI runner
**And** the connection uses configured SSH keys
**And** connection timeout is reasonable (under 10 seconds)
**And** connection failures are reported clearly

#### Scenario: Service verification
**Given** the target host is accessible via SSH
**When** service health checks execute
**Then** critical services are verified with systemctl
**And** OpNix service status is checked
**And** Tailscale service status is checked
**And** SSH service status is checked
**And** any failed services cause verification to fail

#### Scenario: NixOS configuration verification
**Given** post-deployment checks are running
**When** the NixOS configuration is validated
**Then** `nixos-version` confirms the expected version
**And** `/etc/nixos/configuration.nix` exists and is readable
**And** the current generation matches expected configuration
**And** verification results are reported in workflow summaries

---

### Requirement: Workflow Artifacts and Logging
The system SHALL provide comprehensive logging and artifact retention for deployments.

#### Scenario: Deployment log capture
**Given** a deployment workflow is executing
**When** deployment scripts run
**Then** all stdout and stderr is captured in workflow logs
**And** logs are available in the GitHub UI immediately
**And** logs persist after the workflow completes
**And** logs can be downloaded as artifacts

#### Scenario: Workflow artifact upload
**Given** deployment logs are captured
**When** the job completes
**Then** logs are uploaded as workflow artifacts
**And** artifacts are retained for 30 days
**And** artifacts can be downloaded from the workflow run page
**And** artifacts include timestamps and host identifiers

#### Scenario: Workflow run history
**Given** multiple deployments have occurred
**When** an administrator reviews deployment history
**Then** all workflow runs are listed in the Actions tab
**And** each run shows success/failure status
**And** run details include which hosts were deployed
**And** logs and artifacts are accessible for each run

---

### Requirement: Security Best Practices
The system SHALL follow GitHub Actions security best practices for CI/CD workflows.

#### Scenario: Minimal workflow permissions
**Given** GitHub Actions workflows are configured
**When** they execute
**Then** they use minimal required permissions
**And** workflows cannot access unauthorized repositories
**And** workflows cannot expose secrets to unauthorized parties
**And** permissions are explicitly declared in workflow files

#### Scenario: Environment variable sanitization
**Given** workflows use environment variables
**When** values are logged or displayed
**Then** sensitive values are automatically masked
**And** secret values never appear in plain text logs
**And** workflow authors must explicitly opt-in to exposing variables
**And** debugging features don't inadvertently leak secrets

#### Scenario: Workflow forked repository security
**Given** the repository accepts contributions from forks
**When** pull requests from forks are created
**Then** workflows run with restricted permissions
**And** secrets are not available to fork workflows
**And** malicious code in forks cannot access production secrets
**And** only approved contributors can trigger production deployments

---

### Requirement: Branch Protection and Required Checks
The system SHALL enforce code quality through branch protection rules.

#### Scenario: Main branch protection
**Given** branch protection is enabled on main
**When** a pull request targets main
**Then** all required status checks must pass
**And** up-to-date checks ensure the branch hasn't diverged
**And** at least one reviewer must approve the PR
**And** enforcement prevents direct pushes to main

#### Scenario: Status check requirements
**Given** required status checks are configured
**When** the ci workflow runs
**Then** its results appear as commit status checks
**And** failing checks block PR merging
**And** checks must pass on the latest commit
**And** administrators cannot bypass protection rules

#### Scenario: Pull request integration
**Given** branch protection requires CI checks
**When** a developer creates a pull request
**Then** the ci workflow automatically runs
**And** results appear in the PR checks section
**And** the merge button remains disabled until checks pass
**And** reviewers can see detailed workflow results

---

### Requirement: Workflow Reusability and Maintenance
The system SHALL provide maintainable and reusable workflow configurations.

#### Scenario: Workflow modularity
**Given** deployment workflows need to support multiple hosts
**When** workflows are structured for reusability
**Then** common steps are encapsulated in reusable workflows
**And** host-specific configuration is parameterized
**And** similar workflows can share common jobs
**And** maintenance updates apply consistently

#### Scenario: Workflow version compatibility
**Given** GitHub Actions versions and Nix versions evolve
**When** workflows are updated
**Then** version pins ensure reproducible builds
**And** updates are tested before deployment
**And** breaking changes are documented
**And** rollback procedures exist for failed updates

#### Scenario: Documentation and examples
**Given** workflows are complex and configurable
**When** maintainers need to understand them
**Then** inline comments explain non-obvious logic
**And** workflow inputs are documented in the workflow file
**And** README files provide usage examples
**And** troubleshooting guides exist for common issues


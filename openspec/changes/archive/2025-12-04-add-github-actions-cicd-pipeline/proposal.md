# Proposal: Add GitHub Actions CI/CD Pipeline for NixOS Deployment

## Overview

This change adds a comprehensive GitHub Actions-based CI/CD infrastructure for automated testing and deployment of NixOS configurations. The implementation provides a two-stage pipeline:

1. **Build & Test Stage**: Automatically validates all configuration changes on every push to main branch
2. **Deploy Stage**: Provides manual, controlled deployment to target VPS servers (hetzner-vps, ovh-vps, contabo-vps)

The pipeline supports both:
- Fresh server installation using `nixos-anywhere`
- Configuration updates for existing NixOS systems using `nixos-rebuild switch`

## What Changes

This change implements a comprehensive GitHub Actions CI/CD pipeline with the following modifications:

**Files Created (5):**
1. `.github/workflows/ci.yml` (155 lines) - Build & test workflow for automatic validation
2. `.github/workflows/deploy.yml` (360 lines) - Manual deployment workflow with approval gates
3. `.github/README.md` (550 lines) - Comprehensive documentation for the CI/CD system
4. `scripts/deploy-ovh.sh` (785 lines) - Deployment script for OVH VPS
5. `scripts/deploy-contabo.sh` (785 lines) - Deployment script for Contabo VPS

**Files Modified (1):**
1. `scripts/deploy-hetzner.sh` - Added CI/CD mode support with environment variable configuration

**Total Implementation:** ~2,635 lines of code, 2 workflow files, 3 deployment scripts, 1 documentation file

## Why

Currently, configuration changes require:
- Manual testing of builds before deployment
- Manual deployment to each server using existing scripts
- No automated validation to catch configuration errors
- Risk of deploying broken configurations to production servers

This creates operational risk and slows down iteration cycles when making infrastructure changes.

## Goals

1. **Automated Build Validation**: Automatically test all NixOS configurations on every commit
2. **Controlled Deployment**: Manual approval gates for production deployments
3. **Two-Stage Safety**: Separate build/test (automatic) from deployment (manual)
4. **Multi-Host Support**: Deploy to all three VPS servers with individual control
5. **Flexible Deployment Methods**: Support both fresh installs and configuration updates

## Non-Goals

- Automated deployment to desktop systems (yoga, zephyrus) - manual deployment only
- Real-time monitoring or alerting integration
- Blue-green deployment strategies
- Rollback automation (manual rollback process documented)

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│ Stage 1: Build & Test (Automatic)                       │
├─────────────────────────────────────────────────────────┤
│ Git Push → GitHub Actions                               │
│   ↓                                                      │
│   ├── Flake Check & Lint                                │
│   ├── Build: hetzner-vps                                │
│   ├── Build: ovh-vps                                    │
│   └── Build: contabo-vps                                │
│   ↓                                                      │
│   └── Status Checks (Required for PR merge)             │
│                                                          │
└─────────────────────────────────────────────────────────┘
                          ↓ (Manual Approval)
┌─────────────────────────────────────────────────────────┐
│ Stage 2: Deploy (Manual Trigger)                        │
├─────────────────────────────────────────────────────────┤
│ Workflow Dispatch (GitHub UI)                           │
│   ↓                                                      │
│   ├── Select Target Hosts (checkboxes)                  │
│   ├── Select Deployment Method (fresh/install vs update)│
│   └── Execute Deployment Script                         │
│   ↓                                                      │
│   ├── Deploy hetzner-vps (if selected)                  │
│   ├── Deploy ovh-vps (if selected)                      │
│   └── Deploy contabo-vps (if selected)                  │
│   ↓                                                      │
│   └── Verification & Health Checks                      │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Key Components

### 1. Build & Test Workflow (`.github/workflows/ci.yml`)

**Triggered on**: Push to `main` branch

**Jobs**:
- **lint**: Run `nix flake check` and format validation
- **build-hetzner-vps**: Build `hetzner-vps` configuration
- **build-ovh-vps**: Build `ovh-vps` configuration
- **build-contabo-vps**: Build `contabo-vps` configuration
- **cache**: Store build artifacts for deployment stage

**Outputs**: Build artifacts + GitHub status checks (required for PR merges)

### 2. Deploy Workflow (`.github/workflows/deploy.yml`)

**Triggered on**: Manual workflow_dispatch (button click)

**Inputs**:
- **target-hosts**: Multi-select (hetzner-vps, ovh-vps, contabo-vps)
- **deployment-method**: Choice (fresh-install, update-existing)
- **skip-reboot**: Boolean (for nixos-anywhere deployments)

**Jobs**:
- **verify-artifacts**: Ensure build artifacts from Stage 1 exist
- **deploy-hetzner-vps**: Conditionally run if selected
- **deploy-ovh-vps**: Conditionally run if selected
- **deploy-contabo-vps**: Conditionally run if selected
- **verify-deployment**: Post-deployment health checks

**Security**:
- Uses GitHub Environments with required reviewers
- Secrets managed via GitHub repository secrets
- Integrates with existing 1Password/OpNix token management

### 3. Deployment Integration

Extends existing deployment scripts:
- `scripts/deploy-hetzner.sh` - modified for CI/CD mode
- `scripts/deploy-ovh.sh` - new script for OVH VPS
- `scripts/deploy-contabo.sh` - new script for Contabo VPS

**CI Mode Changes**:
- Non-interactive execution
- Environment variable-based configuration
- Enhanced error handling and logging
- GitHub Actions output formatting

## Required GitHub Repository Configuration

### Repository Secrets
```
HETZNER_VPS_IP - IP address of Hetzner VPS
OVH_VPS_IP - IP address of OVH VPS
CONTABO_VPS_IP - IP address of Contabo VPS
OPNIX_TOKEN - OpNix service account token
DEPLOY_SSH_KEY - SSH private key for deployment
```

### Branch Protection Rules
- Require status checks to pass before merging
- Require branches to be up to date
- Require review for deployments (optional)

### GitHub Environments
- **production**: For deployments to hetzner-vps (requires approval)
- **staging**: For deployments to ovh-vps and contabo-vps (requires approval)

## Security Considerations

1. **Manual Approval Gates**: All deployments require manual trigger
2. **Secrets Management**: Sensitive data stored in GitHub repository secrets
3. **SSH Key Management**: Deployment keys secured and rotated as needed
4. **1Password Integration**: Leverages existing OpNix token management
5. **Audit Trail**: All deployments logged in GitHub Actions history

## Integration with Existing Infrastructure

### OpNix / 1Password
- Reuses existing `onepassword-secrets.service` configuration
- Integrates with existing deployment token management
- Maintains compatibility with current secrets workflow

### Attic Cache (Future Enhancement)
- Can integrate with existing GitLab CI Attic setup
- Reduces build times in CI/CD pipeline
- Shares binary cache across deployment systems

### Existing Scripts
- Modifies `deploy-hetzner.sh` to support CI mode
- Creates parallel scripts for OVH and Contabo
- Maintains backward compatibility for manual deployments

## Deployment Methods

### Method 1: nixos-rebuild switch (Existing Systems)
```bash
nixos-rebuild switch --flake .#hetzner-vps \
  --target-host ubuntu@$HETZNER_VPS_IP \
  --use-remote-secret
```
- **Use Case**: Updates to existing NixOS systems
- **Benefits**: Faster, safer, no reboot required
- **Duration**: ~2-5 minutes per host

### Method 2: nixos-anywhere (Fresh Install)
```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake .#hetzner-vps \
  --no-reboot \
  root@$HETZNER_VPS_IP
```
- **Use Case**: New servers or complete reinstalls
- **Benefits**: Can provision bare metal/VPS from scratch
- **Duration**: ~10-20 minutes per host

## Dependencies

- GitHub Actions (included with GitHub)
- Existing VPS infrastructure (hetzner-vps, ovh-vps, contabo-vps)
- OpNix and 1Password integration (already configured)
- Existing deployment scripts
- GitHub repository with admin access for secrets configuration

## Timeline Estimate

- **Planning**: Complete (this proposal)
- **Implementation**: 3-4 days
- **Testing & Validation**: 2 days
- **Documentation**: 1 day
- **Total**: 6-7 days

## Success Criteria

1. ✅ All 3 VPS configurations build successfully in CI
2. ✅ Build artifacts cached and available for deployment
3. ✅ Manual deployment workflow functional via GitHub UI
4. ✅ At least one successful deployment to production VPS
5. ✅ Deployment verification and health checks passing
6. ✅ GitHub Actions workflows documented
7. ✅ Rollback procedures documented and tested

## Risk Assessment

### Low Risk
- Build validation (purely read-only)
- Testing deployments to non-production hosts first

### Medium Risk
- Production deployments (mitigated by manual approval)
- Concurrent deployments to multiple hosts (mitigated by sequential execution)

### Mitigation Strategies
1. Always test on non-production first (ovh-vps, contabo-vps)
2. Sequential deployment (one host at a time)
3. Health checks after each deployment
4. Manual rollback procedures documented
5. No auto-merge of deployments to main (separate approval process)

## Future Enhancements

1. **Attic Cache Integration**: Reduce CI build times with binary cache
2. **Desktop Deployment**: Extend to yoga and zephyrus (optional)
3. **Rollback Automation**: Automatic rollback on health check failure
4. **Multi-Region**: Deploy to multiple regions simultaneously
5. **Notification Integration**: Slack/Discord notifications on deployment status
6. **Metrics & Monitoring**: Build/deploy time tracking and optimization

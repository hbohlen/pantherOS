# Tasks: Add GitHub Actions CI/CD Pipeline

## 1. Create GitHub Actions Workflow Files

### 1.1 Create Build & Test Workflow
- [x] 1.1.1 Create `.github/workflows/ci.yml`
- [x] 1.1.2 Configure flake check and lint stage
- [x] 1.1.3 Configure parallel build jobs for all 3 VPS hosts
- [x] 1.1.4 Configure build artifact caching
- [x] 1.1.5 Add status check outputs for PR merge requirements

### 1.2 Create Deploy Workflow
- [x] 1.2.1 Create `.github/workflows/deploy.yml`
- [x] 1.2.2 Configure workflow_dispatch with inputs (hosts, method, options)
- [x] 1.2.3 Configure artifact verification job
- [x] 1.2.4 Create conditional deployment jobs per host
- [x] 1.2.5 Configure GitHub Environments with required reviewers
- [x] 1.2.6 Add post-deployment verification and health checks

### 1.3 Create Workflow Documentation
- [x] 1.3.1 Document workflow usage in `.github/README.md`
- [x] 1.3.2 Document manual trigger procedures
- [x] 1.3.3 Document required GitHub repository configuration

## 2. Modify Existing Deployment Scripts for CI/CD Mode

### 2.1 Enhance deploy-hetzner.sh
- [x] 2.1.1 Add CI mode support (non-interactive execution)
- [x] 2.1.2 Configure environment variable support
- [x] 2.1.3 Add GitHub Actions output formatting
- [x] 2.1.4 Enhance error handling and exit codes
- [ ] 2.1.5 Test in CI/CD environment

### 2.2 Create deploy-ovh.sh
- [x] 2.2.1 Copy and adapt deploy-hetzner.sh for OVH VPS
- [x] 2.2.2 Update host-specific configurations (IP, SSH user, etc.)
- [x] 2.2.3 Add OpNix integration for OVH VPS
- [x] 2.2.4 Add Tailscale configuration for OVH VPS
- [ ] 2.2.5 Test deployment to OVH VPS

### 2.3 Create deploy-contabo.sh
- [x] 2.3.1 Copy and adapt deploy-hetzner.sh for Contabo VPS
- [x] 2.3.2 Update host-specific configurations (IP, SSH user, etc.)
- [x] 2.3.3 Add OpNix integration for Contabo VPS
- [x] 2.3.4 Add Tailscale configuration for Contabo VPS
- [ ] 2.3.5 Test deployment to Contabo VPS

## 3. Configure GitHub Repository Secrets

### 3.1 Add Server IP Secrets
- [ ] 3.1.1 Add HETZNER_VPS_IP to repository secrets
- [ ] 3.1.2 Add OVH_VPS_IP to repository secrets
- [ ] 3.1.3 Add CONTABO_VPS_IP to repository secrets

### 3.2 Add Authentication Secrets
- [ ] 3.2.1 Add OPNIX_TOKEN to repository secrets
- [ ] 3.2.2 Add DEPLOY_SSH_KEY to repository secrets
- [ ] 3.2.3 Add TAILSCALE_AUTH_KEY to repository secrets (if using)

### 3.3 Configure GitHub Environments
- [ ] 3.3.1 Create 'production' environment for hetzner-vps
- [ ] 3.3.2 Create 'staging' environment for ovh-vps and contabo-vps
- [ ] 3.3.3 Configure required reviewers for production deployments
- [ ] 3.3.4 Configure branch protection rules for main branch

## 4. Update Existing Configuration Files

### 4.1 Update flake.nix
- [ ] 4.1.1 Add nixos-anywhere input (if not already present)
- [ ] 4.1.2 Verify all three VPS configurations are exportable
- [ ] 4.1.3 Add deployment configuration examples

### 4.2 Update Host Configurations
- [ ] 4.2.1 Verify hetzner-vps configuration exports correctly
- [ ] 4.2.2 Verify ovh-vps configuration exports correctly
- [ ] 4.2.3 Verify contabo-vps configuration exports correctly
- [ ] 4.2.4 Add deployment metadata if needed

## 5. Create Documentation

### 5.1 Create CI/CD Guide
- [ ] 5.1.1 Document workflow architecture
- [ ] 5.1.2 Document two-stage pipeline (build vs deploy)
- [ ] 5.1.3 Document manual deployment procedures
- [ ] 5.1.4 Document rollback procedures
- [ ] 5.1.5 Document troubleshooting guide

### 5.2 Create Security Documentation
- [ ] 5.2.1 Document secrets management
- [ ] 5.2.2 Document GitHub Environments and approval process
- [ ] 5.2.3 Document SSH key management
- [ ] 5.2.4 Document OpNix integration security

### 5.3 Update Main README
- [ ] 5.3.1 Add CI/CD badge to main README
- [ ] 5.3.2 Link to detailed CI/CD documentation
- [ ] 5.3.3 Document deployment status badges

## 6. Testing & Validation

### 6.1 Build Testing
- [ ] 6.1.1 Test flake check on feature branch
- [ ] 6.1.2 Test parallel builds for all 3 hosts
- [ ] 6.1.3 Verify status checks appear on PR
- [ ] 6.1.4 Test build artifact caching

### 6.2 Deployment Testing
- [ ] 6.2.1 Test deployment to contabo-vps (non-production first)
- [ ] 6.2.2 Test deployment to ovh-vps (staging)
- [ ] 6.2.3 Test deployment to hetzner-vps (production)
- [ ] 6.2.4 Verify both deployment methods (fresh-install and update)
- [ ] 6.2.5 Test rollback procedures

### 6.3 Integration Testing
- [ ] 6.3.1 Verify OpNix integration works in CI/CD
- [ ] 6.3.2 Verify 1Password integration works in CI/CD
- [ ] 6.3.3 Verify Tailscale configuration via CI/CD
- [ ] 6.3.4 Verify SSH access after deployment
- [ ] 6.3.5 Verify all services start correctly

## 7. Final Validation & Cleanup

### 7.1 Code Review
- [ ] 7.1.1 Self-review all changes
- [ ] 7.1.2 Verify all workflows follow best practices
- [ ] 7.1.3 Verify security best practices followed
- [ ] 7.1.4 Verify error handling is comprehensive

### 7.2 Documentation Review
- [ ] 7.2.1 Review all documentation for accuracy
- [ ] 7.2.2 Verify examples are current and working
- [ ] 7.2.3 Verify troubleshooting guide is complete
- [ ] 7.2.4 Verify security documentation is clear

### 7.3 Archive Preparation
- [ ] 7.3.1 Update project.md if needed
- [ ] 7.3.2 Run openspec validate on the change
- [ ] 7.3.3 Prepare final summary of changes
- [ ] 7.3.4 Document lessons learned and future enhancements

## 8. Deployment to Production

### 8.1 Feature Branch Merge
- [ ] 8.1.1 Create pull request for change
- [ ] 8.1.2 Address review feedback
- [ ] 8.1.3 Merge to main branch
- [ ] 8.1.4 Verify workflows are triggered

### 8.2 Initial Production Deployment
- [ ] 8.2.1 Run first production deployment to hetzner-vps
- [ ] 8.2.2 Verify deployment completes successfully
- [ ] 8.2.3 Verify all services are operational
- [ ] 8.2.4 Document any issues or adjustments needed

### 8.3 Post-Deployment
- [ ] 8.3.1 Monitor deployments for 24-48 hours
- [ ] 8.3.2 Verify no unexpected issues
- [ ] 8.3.3 Update documentation based on real-world usage
- [ ] 8.3.4 Archive the change using openspec archive command

## Estimated Timeline

- **Week 1**: Tasks 1-3 (Core Implementation)
- **Week 1-2**: Tasks 4-5 (Configuration & Documentation)
- **Week 2**: Tasks 6-7 (Testing & Validation)
- **Week 2-3**: Task 8 (Production Deployment)

Total Estimated Duration: 10-15 days

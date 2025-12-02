# Implementation Tasks: GitLab CI Infrastructure

## Overview

This document outlines the implementation tasks for adding GitLab CI infrastructure with Attic binary cache and automated deployment capabilities.

## Prerequisites

- [x] Confirm GitLab instance: GitLab.com
- [ ] Create Backblaze B2 bucket `pantheros-nix-cache`
- [ ] Store B2 credentials in 1Password service account
- [x] Domain name: `cache.hbohlen.systems` (Cloudflare)
- [x] Deployment trigger: Automatic on main branch
- [x] Testing requirements: `nix flake check` + `nixos-rebuild build` minimum

## Phase 1: Attic Server Setup (Hetzner VPS)

### 1.1 PostgreSQL Database

- [ ] Add PostgreSQL service to `hosts/servers/hetzner-vps/default.nix`
- [ ] Configure database user and permissions for Attic
- [ ] Set up automated backups with `services.postgresqlBackup`
- [ ] Test database connectivity

### 1.2 Backblaze B2 Configuration

- [ ] Create S3 bucket `pantheros-nix-cache` in Backblaze B2
- [ ] Generate application key with read/write permissions
- [ ] Store credentials in 1Password vault `pantherOS`
- [ ] Add OpNix secret references for B2 credentials
- [ ] Configure bucket lifecycle rules (30-day retention)

### 1.3 Attic Server Installation

- [ ] Add `attic-server` package to system packages
- [ ] Create Attic NixOS module configuration
- [ ] Configure S3 storage backend with B2 credentials
- [ ] Set up chunking and compression settings
- [ ] Configure database connection
- [ ] Start Attic service and verify operation

### 1.4 Caddy Reverse Proxy

- [ ] Add Caddy service to Hetzner VPS configuration
- [ ] Configure virtual host for `cache.hbohlen.systems`
- [ ] Set up automatic HTTPS with Let's Encrypt
- [ ] Configure reverse proxy to Attic server (port 8080)
- [ ] Add Tailscale network access control (optional)
- [ ] Configure Cloudflare DNS for `cache.hbohlen.systems`
- [ ] Configure firewall rules for HTTPS (port 443)

### 1.5 Cache and Token Management

- [ ] Create `public-cache` for common dependencies
- [ ] Create `ci-cache` for CI/CD builds
- [ ] Generate root admin token and store in 1Password
- [ ] Generate CI token with push/pull permissions for `ci-cache`
- [ ] Generate public read-only token for `public-cache`
- [ ] Configure cache retention policies

### 1.6 Garbage Collection

- [ ] Create systemd service for Attic GC
- [ ] Create systemd timer for daily GC runs
- [ ] Test garbage collection manually
- [ ] Verify retention policy enforcement

---

## Phase 2: GitLab CI Container

### 2.1 Container Image Definition

- [ ] Create `containers/gitlab-ci/default.nix` in repository
- [ ] Define base NixOS minimal image
- [ ] Add required packages (nix, git, openssh, attic-client)
- [ ] Configure Nix settings (flakes, substituters)
- [ ] Add Attic cache as substituter
- [ ] Optimize layer structure for caching

### 2.2 Container Build and Registry

- [ ] Build container image with `nix build .#gitlab-ci-container`
- [ ] Test container locally with Docker/Podman
- [ ] Push to GitLab Container Registry
- [ ] Tag with version and `latest`
- [ ] Document container usage

### 2.3 Attic Client Configuration

- [ ] Pre-configure Attic client in container
- [ ] Add login script for CI authentication
- [ ] Test push/pull operations from container
- [ ] Verify cache hit rates

---

## Phase 3: GitLab CI Pipeline

### 3.1 Pipeline Configuration

- [ ] Create `.gitlab-ci.yml` in repository root
- [ ] Define pipeline stages (build, test, cache, deploy)
- [ ] Configure container image reference
- [ ] Set up GitLab CI variables for secrets

### 3.2 Build Stage

- [ ] Add build job for `hetzner-vps` configuration
- [ ] Add build jobs for other hosts (yoga, zephyrus, ovh-vps)
- [ ] Configure artifact retention
- [ ] Add build status reporting
- [ ] Ensure `nixos-rebuild build` passes for all configurations

### 3.3 Test Stage

- [ ] Add `nix flake check` job (required)
- [ ] Add `nixos-rebuild build` validation (required)
- [ ] Design and add integration tests
- [ ] Configure test result reporting
- [ ] Set up test failure notifications

### 3.4 Cache Stage

- [ ] Add Attic push job after successful builds
- [ ] Configure cache naming strategy
- [ ] Add cache statistics reporting
- [ ] Verify deduplication is working

### 3.5 Deploy Stage

- [ ] Create deployment script `scripts/deploy.sh`
- [ ] Add SSH key configuration for deployment
- [ ] Implement pre-deployment checks (connectivity, disk space)
- [ ] Add `nixos-rebuild switch` with remote target
- [ ] Implement post-deployment verification
- [ ] Configure deployment to run only on main branch
- [ ] Add manual deployment trigger option

---

## Phase 4: Secrets Management

### 4.1 1Password Integration

- [ ] Create `Attic/ci-token` entry in 1Password
- [ ] Create `SSH/deploy-key` entry in 1Password
- [ ] Create `Backblaze-B2/application-key-id` entry
- [ ] Create `Backblaze-B2/application-key` entry

### 4.2 GitLab CI Variables

- [ ] Add `CI_ATTIC_TOKEN` variable (protected, masked)
- [ ] Add `DEPLOY_SSH_KEY` variable (protected, masked)
- [ ] Add `ATTIC_SERVER_URL` variable
- [ ] Configure variable scopes (protected branches only)

---

## Phase 5: Documentation

### 5.1 User Documentation

- [ ] Create `docs/ci-cd-pipeline.md` with pipeline overview
- [ ] Document how to trigger manual deployments
- [ ] Document cache usage and best practices
- [ ] Add troubleshooting guide

### 5.2 Operational Documentation

- [ ] Document Attic server maintenance procedures
- [ ] Create runbook for cache issues
- [ ] Document backup and restore procedures
- [ ] Add monitoring and alerting recommendations

### 5.3 Developer Documentation

- [ ] Document how to add new hosts to CI pipeline
- [ ] Explain cache configuration and tuning
- [ ] Document container image updates
- [ ] Add examples for common workflows

---

## Phase 6: Testing and Validation

### 6.1 Unit Testing

- [ ] Test Attic server locally
- [ ] Test container image builds
- [ ] Test deployment script in isolation
- [ ] Verify all NixOS configurations build

### 6.2 Integration Testing

- [ ] Test full CI pipeline end-to-end
- [ ] Verify cache push/pull operations
- [ ] Test deployment to Hetzner VPS
- [ ] Verify cache hit rates and performance

### 6.3 Security Testing

- [ ] Verify secret handling in CI
- [ ] Test token permissions and scoping
- [ ] Verify SSH key security
- [ ] Test HTTPS/TLS configuration

### 6.4 Performance Testing

- [ ] Measure build times with cold cache
- [ ] Measure build times with warm cache
- [ ] Verify deduplication ratios
- [ ] Test concurrent build handling

---

## Phase 7: Deployment and Rollout

### 7.1 Initial Deployment

- [ ] Deploy Attic server to Hetzner VPS
- [ ] Verify server is accessible and functional
- [ ] Warm cache with initial builds
- [ ] Configure monitoring

### 7.2 CI Pipeline Activation

- [ ] Enable GitLab CI on repository
- [ ] Run initial pipeline manually
- [ ] Verify all stages complete successfully
- [ ] Monitor first automated deployment

### 7.3 Validation

- [ ] Confirm cache is being used effectively
- [ ] Verify deployments are successful
- [ ] Check logs for errors or warnings
- [ ] Validate performance improvements

---

## Acceptance Criteria

### Functional Requirements

- ✅ GitLab CI successfully builds all NixOS configurations
- ✅ Attic cache reduces build times by >50% on cache hits
- ✅ Successful builds automatically deploy to Hetzner VPS
- ✅ All secrets are properly managed and secured
- ✅ Cache garbage collection runs automatically

### Non-Functional Requirements

- ✅ Container image size < 2GB compressed
- ✅ Build times < 5 minutes with warm cache
- ✅ Deployment completes in < 2 minutes
- ✅ Cache hit rate > 80% for repeated builds
- ✅ Zero secrets exposed in logs or artifacts

### Documentation Requirements

- ✅ All components documented
- ✅ Runbooks created for operations
- ✅ Developer guides available
- ✅ Troubleshooting guides complete

---

## Dependencies and Blockers

### External Dependencies

- Backblaze B2 account setup
- GitLab CI runner availability
- Domain name for Attic cache
- SSL certificate provisioning

### Internal Dependencies

- Existing Hetzner VPS infrastructure
- 1Password OpNix integration (already configured)
- NixOS configuration builds successfully

### Potential Blockers

- GitLab CI runner resource constraints
- Network connectivity issues
- S3 API rate limits
- Disk space on Hetzner VPS

---

## Rollback Plan

If issues arise during deployment:

1. **Attic Server Issues:**
   - Disable Attic substituter in CI
   - Fall back to cache.nixos.org only
   - Debug and fix Attic configuration

2. **CI Pipeline Issues:**
   - Disable automated deployment
   - Use manual deployment process
   - Fix pipeline configuration

3. **Deployment Issues:**
   - Rollback to previous system generation on VPS
   - Investigate deployment script errors
   - Test fixes in staging environment

---

## Post-Implementation

### Monitoring

- [ ] Set up Attic server metrics collection
- [ ] Monitor cache hit rates
- [ ] Track build and deployment times
- [ ] Set up alerts for failures

### Optimization

- [ ] Tune cache retention policies based on usage
- [ ] Optimize container image size
- [ ] Improve build parallelization
- [ ] Consider CDN for cache distribution

### Future Enhancements

- [ ] Add support for additional deployment targets
- [ ] Implement rollback mechanisms
- [ ] Add cache analytics dashboard
- [ ] Explore multi-region cache replication

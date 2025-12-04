# GitHub Actions CI/CD Documentation

This repository uses GitHub Actions for automated building and deployment of NixOS configurations.

## Overview

The CI/CD pipeline consists of two workflows:

1. **Build & Test** (ci.yml) - Automatic validation on every push
2. **Deploy** (deploy.yml) - Manual deployment with approval gates

## Workflow 1: Build & Test

**Trigger:** Push to `main` branch or pull request

**Purpose:** Validate all NixOS configurations build correctly

**Jobs:**
- **Lint**: Runs `nix flake check`, `statix`, and `deadnix`
- **Build**: Builds all three VPS configurations in parallel:
  - hetzner-vps
  - ovh-vps
  - contabo-vps
- **Build Summary**: Verifies all builds succeeded

**Outputs:**
- Build artifacts (stored for 30 days)
- GitHub status checks (required for PR merging)
- Cache for faster subsequent builds

**Requirements:**
- All checks must pass before merging to main
- Build artifacts available for deployment workflow

## Workflow 2: Deploy

**Trigger:** Manual workflow dispatch (button click in GitHub UI)

**Purpose:** Deploy validated configurations to target VPS servers

**Manual Inputs:**
- **Target Hosts**: Select which hosts to deploy (single or multiple)
- **Deployment Method**:
  - `update-existing`: Use `nixos-rebuild switch` for existing systems
  - `fresh-install`: Use `nixos-anywhere` for new servers
- **Skip Reboot**: For nixos-anywhere deployments (default: true)
- **Verbose Logging**: Enable detailed logs (default: false)

**Execution Flow:**
1. Verify build artifacts from Build & Test workflow
2. Determine target hosts based on selection
3. Deploy each selected host sequentially (one at a time)
4. Run post-deployment verification for each host
5. Generate deployment summary

**Environments:**
- **production**: For hetzner-vps (requires approval)
- **staging**: For ovh-vps and contabo-vps (requires approval)

**Jobs:**
- Deploy to hetzner-vps (if selected)
- Deploy to ovh-vps (if selected)
- Deploy to contabo-vps (if selected)
- Each job includes automatic verification

## Required GitHub Repository Configuration

### 1. Repository Secrets

Configure the following secrets in GitHub repository settings:

```
HETZNER_VPS_IP - IP address of Hetzner VPS
OVH_VPS_IP - IP address of OVH VPS
CONTABO_VPS_IP - IP address of Contabo VPS
OPNIX_TOKEN - OpNix service account token
DEPLOY_SSH_KEY - SSH private key for deployment
```

**To add secrets:**
1. Go to repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add each secret listed above

### 2. GitHub Environments

Create the following environments:

**production environment:**
- For: hetzner-vps deployments
- Protection rules:
  - Required reviewers: [list reviewers]
  - Wait timer: 0 minutes
  - Deployment branches: main

**staging environment:**
- For: ovh-vps and contabo-vps deployments
- Protection rules:
  - Required reviewers: [list reviewers]
  - Wait timer: 0 minutes
  - Deployment branches: main

### 3. Branch Protection Rules

Enable branch protection for `main` branch:
- ✅ Require status checks to pass before merging
- ✅ Require branches to be up to date
- ✅ Require pull request reviews before merging (optional)
- ✅ Restrict pushes to administrators (optional)

### 4. Cachix (Optional)

For faster CI builds, configure Cachix:
1. Create account at https://cachix.org/
2. Create a cache named `pantheros`
3. Generate auth token
4. Add to repository secrets: `CACHIX_AUTH_TOKEN`

## Manual Deployment Procedure

### Prerequisites

1. Build artifacts from Build & Test workflow must exist
2. Repository secrets must be configured
3. GitHub Environments must be set up
4. You must have approval permissions

### Deployment Steps

1. **Navigate to Actions Tab**
   - Go to GitHub repository
   - Click "Actions" tab

2. **Run Deploy Workflow**
   - Click "Deploy" workflow in left sidebar
   - Click "Run workflow" button
   - Select inputs:
     - Target hosts
     - Deployment method
     - Additional options

3. **Review & Approve**
   - Click "Run workflow"
   - Workflow will pause at environment approval
   - Review the changes
   - Click "Approve and deploy"

4. **Monitor Deployment**
   - Watch job progress in real-time
   - Check logs for each deployment step
   - Verify health checks pass

5. **Post-Deployment**
   - Review deployment summary
   - SSH to target hosts to verify services
   - Document any issues or adjustments needed

## Deployment Methods

### Method 1: update-existing (Recommended)

**Command:**
```bash
nixos-rebuild switch --flake .#<host> \
  --target-host root@<server-ip> \
  --use-remote-secret
```

**Use Case:**
- Updating existing NixOS systems
- Configuration changes
- Service updates

**Benefits:**
- Fast (~2-5 minutes)
- Safe (no full reboot)
- Services restart smoothly

**Example:**
- Updating packages
- Changing system configuration
- Adding new services

### Method 2: fresh-install

**Command:**
```bash
nix run github:nix-community/nixos-anywhere -- \
  --no-reboot \
  --flake .#<host> \
  root@<server-ip>
```

**Use Case:**
- New servers
- Complete system reinstalls
- Bare metal provisioning

**Benefits:**
- Can provision from scratch
- Complete system reinstall
- Works with cloud VPS providers

**Example:**
- Setting up new VPS
- Recovering from corrupted system
- Testing clean installation

## Rollback Procedure

If a deployment causes issues:

### Manual Rollback

1. **SSH to the affected server:**
   ```bash
   ssh root@<server-ip>
   ```

2. **List available generations:**
   ```bash
   nixos-rebuild list-generations
   ```

3. **Rollback to previous generation:**
   ```bash
   nixos-rebuild switch --rollback
   ```

4. **Reboot if necessary:**
   ```bash
   reboot
   ```

5. **Verify services:**
   ```bash
   systemctl status
   ```

### Rollback via NixOS

The previous generation is automatically preserved. You can also:
- Boot into previous generation from GRUB menu
- Use `nixos-rebuild switch --rollback` as shown above
- Restore from backup if needed

## Troubleshooting

### Build Failures

**Problem:** Build & Test workflow fails
**Solution:**
1. Check workflow logs for specific errors
2. Run `nix flake check` locally
3. Ensure all Nix files are valid
4. Check for syntax errors in configuration

### Deployment Failures

**Problem:** Deployment job fails
**Solution:**
1. Check deployment logs for specific errors
2. Verify server IP addresses in secrets
3. Ensure SSH connectivity to target server
4. Check OpNix token is valid
5. Verify server is running NixOS (for update-existing method)

### Environment Approval Not Available

**Problem:** Cannot approve deployment
**Solution:**
1. Ensure you are listed as a required reviewer in environment settings
2. Check your permissions on the repository
3. Contact repository administrator to add you as reviewer

### SSH Key Issues

**Problem:** SSH authentication fails
**Solution:**
1. Verify `DEPLOY_SSH_KEY` secret contains correct private key
2. Check corresponding public key is in server's `authorized_keys`
3. Ensure SSH key format is correct (should include `-----BEGIN` and `-----END`)
4. Test SSH connection manually: `ssh -i <key> root@<server-ip>`

### OpNix Token Issues

**Problem:** OpNix service fails to authenticate
**Solution:**
1. Verify `OPNIX_TOKEN` secret is correct
2. Check token hasn't expired
3. Verify OpNix service is running on target: `systemctl status onepassword-secrets.service`
4. Check OpNix logs: `journalctl -u onepassword-secrets.service`

### Service Verification Failures

**Problem:** Post-deployment health checks fail
**Solution:**
1. SSH to server and check service status manually
2. Check system logs for errors
3. Verify configuration is correct
4. Check if service needs to be started: `systemctl start <service-name>`
5. If service fails to start, review service configuration

## Best Practices

### Before Deployment
- ✅ Always test on staging environment first (ovh-vps, contabo-vps)
- ✅ Review configuration changes carefully
- ✅ Ensure backup of critical data
- ✅ Notify team of scheduled maintenance window
- ✅ Verify build artifacts are available from Build & Test workflow

### During Deployment
- ⚠️ Deploy one host at a time
- ⚠️ Monitor logs for errors
- ⚠️ Don't cancel deployment in progress
- ⚠️ Verify each deployment before proceeding to next

### After Deployment
- ✅ Verify all services are running
- ✅ Test critical functionality
- ✅ Update documentation if needed
- ✅ Monitor for 24-48 hours for issues
- ✅ Archive deployment workflow run

### Security
- 🔒 Never commit secrets to repository
- 🔒 Rotate deployment SSH keys regularly
- 🔒 Use strong OpNix tokens
- 🔒 Review approval permissions periodically
- 🔒 Enable audit logging on GitHub repository

## Monitoring and Observability

### GitHub Actions Monitoring

1. **Actions Tab**: Monitor all workflow runs
2. **Deployment History**: Track all deployments
3. **Status Badges**: Add to README.md for quick status

### Server Monitoring

1. **SSH Monitoring**: Regularly check server status
2. **Service Monitoring**: Verify services are running
3. **Log Monitoring**: Check system logs for errors
4. **Performance Monitoring**: Monitor resource usage

## Integration with Existing Tools

### OpNix and 1Password

The deployment process automatically integrates with existing OpNix and 1Password setup:
- OpNix tokens are transferred securely during deployment
- 1Password secrets are automatically populated
- SSH keys are managed via OpNix
- Tailscale authentication is configured

### Attic Cache (Future)

Can integrate with existing Attic cache setup for faster deployments:
- Build artifacts pushed to cache
- Deployments pull from cache
- Reduced build times
- Bandwidth savings

## Support and Contact

For issues or questions:
- Check troubleshooting guide above
- Review GitHub Actions logs
- Contact repository maintainers
- Open an issue in the repository

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
- [OpNix Documentation](https://github.com/brizzbuzz/opnix)

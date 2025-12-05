# Deployment Strategies

Patterns and best practices for deploying and updating NixOS configurations.

## Build Before Switch

```bash
# Always test configuration before switching
nixos-rebuild build --flake .#hostname

# Review the build
nix log .#nixosConfigurations.hostname.config.system.build.toplevel

# If build succeeds, then switch
nixos-rebuild switch --flake .#hostname
```

- **Always build first**: Never `switch` without testing with `build`
- **Review build logs**: Check for warnings or errors in logs
- **Keep build artifacts**: Build artifacts can be inspected
- **Test in staging first**: If possible, test on staging environment

## Rolling Updates

```nix
# Enable automatic updates (optional)
system.autoUpgrade = {
  enable = true;
  dates = "02:15";
  randomizedDelaySec = "45min";
  allowReboot = false;
};
```

- **Consider automatic updates**: For non-critical systems
- **Use randomized delays**: Prevent all hosts updating simultaneously
- **Document update schedule**: When do updates occur?
- **Monitor update logs**: Check system logs after automatic updates

## Deployment Process

### 1. Prepare Changes

```bash
# Update flake dependencies
nix flake update

# Check for issues
nix flake check

# Build all configurations
nix build .#nixosConfigurations.hostname1.config.system.build.toplevel
nix build .#nixosConfigurations.hostname2.config.system.build.toplevel
```

### 2. Deploy to Host

```bash
# SSH to target host
ssh hostname

# Build and switch
nixos-rebuild switch --flake /path/to/flake#hostname

# Verify system is working
systemctl status
```

- **Use SSH for remote deployment**: Deploy from local machine
- **Specify flake path**: Include full path to flake
- **Verify after switch**: Check system state after deployment
- **Have rollback plan**: Be ready to revert if needed

## Configuration Versioning

```bash
# Tag important configuration versions
git tag -a "v2025.12" -m "NixOS 25.05 configuration"
git push origin v2025.12

# Rollback to previous generation
nixos-rebuild switch --rollback
```

- **Tag releases**: Mark stable configuration versions
- **Use generations**: NixOS creates automatic rollback points
- **Document rollbacks**: How to rollback if deployment fails
- **Keep old generations**: Don't immediately garbage collect

## Multi-Host Deployment

```bash
# Deploy to multiple hosts
for host in host1 host2 host3; do
  echo "Deploying to $host"
  nixos-rebuild switch --flake .#$host --target-host $host
done
```

- **Script deployments**: Use scripts for multiple hosts
- **Check each host**: Verify each host after deployment
- **Handle failures gracefully**: Continue if one host fails
- **Track deployment status**: Log which hosts were updated

## Flake Updates

```bash
# Update flake.lock
nix flake update

# Review changes
git diff flake.lock

# Test updated configuration
nixos-rebuild build --flake .#hostname

# Commit if tests pass
git add flake.lock
git commit -m "Update flake dependencies"
```

- **Review lock file changes**: Check what versions changed
- **Test after update**: Always test after updating dependencies
- **Commit lock file**: Keep flake.lock synchronized
- **Document major updates**: Note significant version bumps

## Backup Strategies

### Configuration Backup

```bash
# Backup configuration to remote
rsync -avz /etc/nixos/ user@backup-host:/backups/nixos/

# Or use nix-copy-closure
nix-copy-closure user@backup-host /run/current-system
```

- **Backup configuration**: Keep copies of NixOS configurations
- **Use remote backup**: Backup to separate system
- **Include system closure**: Backup full system for rollback
- **Test restore process**: Ensure backups can be restored

### Btrfs Snapshots

```nix
# Enable automatic snapshots
services.btrbk = {
  enable = true;
  instances.daily = {
    onCalendar = "daily";
    settings = {
      snapshot_preserve = "14d";
      volume."/" = {
        subvolume = {
          "@" = {
            snapshot_dir = ".snapshots";
          };
        };
      };
    };
  };
};
```

- **Enable snapshots**: Use btrbk for automatic snapshots
- **Document snapshot retention**: How long are snapshots kept?
- **Test recovery**: Periodically test restoring from snapshots
- **Separate from backups**: Snapshots are local, backups are remote

## Rollback Procedures

### Automatic Rollback

```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# List available generations
sudo nixos generations list

# Switch to specific generation
sudo nixos-rebuild switch --generation 123
```

- **Use --rollback flag**: Quick rollback to previous generation
- **List generations**: See available rollback points
- **Test after rollback**: Verify system works after rollback
- **Keep multiple generations**: Don't garbage collect too soon

### Manual Rollback

```bash
# Boot previous generation
# At GRUB menu, select "Advanced options" > "Previous Linux version"

# Or set default boot entry
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

- **Use GRUB menu**: Boot previous generation from menu
- **Make GRUB remember selection**: Configurable in GRUB settings
- **Document GRUB access**: How to access GRUB menu
- **Test rollback process**: Practice rollback before it's needed

## Production Deployment Checklist

```markdown
# Pre-Deployment Checklist
- [ ] Configuration builds without errors
- [ ] Tests pass (if applicable)
- [ ] flake.lock is updated and committed
- [ ] Backup of current system created
- [ ] Rollback plan documented
- [ ] Maintenance window scheduled (if needed)
- [ ] Monitoring ready for post-deployment checks

# Post-Deployment Checklist
- [ ] System boots successfully
- [ ] All services running
- [ ] No error logs in journal
- [ ] Monitoring shows green status
- [ ] User access verified
- [ ] Documentation updated
- [ ] Team notified
```

- **Use checklists**: Ensure consistent deployment process
- **Check before and after**: Verify state before and after deployment
- **Document all steps**: What to check and when
- **Include rollbacks**: Have rollback plan ready

## Zero-Downtime Deployments

```bash
# For critical services, consider:
# 1. Deploy to staging first
# 2. Test thoroughly
# 3. Deploy to production during maintenance window
# 4. Monitor closely after deployment
# 5. Have quick rollback ready
```

- **Use maintenance windows**: For critical deployments
- **Staging environments**: Test in staging before production
- **Monitor closely**: Watch logs and metrics after deployment
- **Quick rollback**: Be ready to rollback if issues arise

## Remote Deployment

```bash
# Deploy to remote host without SSH
nixos-rebuild switch --flake .#hostname --target-host user@hostname

# Or use deploy script
./deploy.sh hostname
```

- **Use target-host option**: Deploy to remote hosts
- **Consider deployment scripts**: Automate multi-host deployments
- **Handle authentication**: Ensure SSH keys are configured
- **Log deployments**: Track what was deployed when

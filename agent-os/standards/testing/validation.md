# Configuration Validation

Strategies for validating NixOS configurations before deployment.

## Static Validation

```bash
# Validate flake
nix flake check

# Validate syntax
nix-instantiate --parse ./flake.nix

# Check for unused bindings
deadnix --recursive .

# Check for style violations
statix check .
```

- **Run flake check**: Validate entire flake structure
- **Parse syntax**: Catch syntax errors early
- **Find dead code**: Use deadnix to remove unused code
- **Check style**: Use statix for Nix linting
- **Automated formatting**: Use alejandra, nixfmt, or nixpkgs-fmt

## Build Validation

```bash
# Dry build
nixos-rebuild dry-build --flake .#hostname

# Full build
nix build .#nixosConfigurations.hostname.config.system.build.toplevel

# Validate build output
nix-store --verify /run/current-system
```

- **Always dry-build**: Test builds without switching
- **Verify build output**: Check built system integrity
- **Test all hosts**: Build all configurations, not just one
- **Review warnings**: Pay attention to build warnings

## Option Validation

```bash
# Check option value
nixos-option networking.hostName

# Test enable option
nixos-option services.openssh.enable

# Validate all options
nixos-rebuild check --flake .#hostname
```

- **Verify option values**: Check that options are set correctly
- **Test boolean options**: Ensure enable options work
- **Use nixos-rebuild check**: Built-in validation of configuration
- **Review option errors**: Fix any option validation errors

## Dependency Validation

```bash
# Show flake dependencies
nix flake show

# Check for circular dependencies
nix-instantiate --eval ./flake.nix

# Validate input locks
nix show-lock
```

- **Review dependencies**: Understand what the flake depends on
- **Check for circular deps**: Ensure no circular dependencies
- **Validate lock file**: Ensure all inputs are properly locked
- **Document external deps**: Comment on important external dependencies

## Service Validation

```bash
# Check service configuration
systemctl status servicename

# Validate service file
systemd-analyze verify /etc/systemd/system/servicename.service

# Check service dependencies
systemd-analyze blame
```

- **Test service start**: Verify services can start
- **Validate service files**: Check service configuration for errors
- **Review dependencies**: Ensure service dependencies are correct
- **Check service logs**: Review logs for errors and warnings

## Configuration Integrity

```bash
# Verify system closure
nix-store --verify --repair /run/current-system

# Check for broken symlinks
find /run/current-system -xtype l

# Validate file permissions
find /etc -type f -perm /o+w
```

- **Verify closures**: Ensure system closure is intact
- **Check symlinks**: Find and fix broken symlinks
- **Review permissions**: Ensure file permissions are correct
- **Use nix-store commands**: Leverage Nix's integrity checking

## Security Validation

```bash
# Check file permissions on sensitive files
ls -la /etc/ssh/
ls -la /etc/secrets/

# Validate firewall rules
iptables -L -n
nft list ruleset

# Check SSH configuration
sshd -T
```

- **Review file permissions**: Ensure sensitive files are protected
- **Validate firewall**: Check firewall rules are correct
- **Test SSH config**: Validate SSH server configuration
- **Check certificates**: Ensure certificates are valid

## Network Validation

```bash
# Test network connectivity
ping -c 3 8.8.8.8

# Check network configuration
ip addr show
ip route show

# Validate DNS resolution
nslookup example.com
```

- **Test connectivity**: Verify network connectivity works
- **Check configuration**: Review network interface configuration
- **Validate DNS**: Ensure DNS resolution works correctly
- **Test firewall rules**: Verify firewall allows necessary traffic

## User Environment Validation

```bash
# Check Home Manager configuration
home-manager generations

# Validate user packages
nix-env -q

# Test shell configuration
echo $SHELL
echo $EDITOR
```

- **Check Home Manager**: Verify user environment configuration
- **Review installed packages**: Ensure user packages are installed
- **Validate environment variables**: Check shell and editor settings
- **Test XDG directories**: Verify XDG base directory support

## Log Analysis

```bash
# Check system logs
journalctl --since "1 hour ago"

# Check for errors
journalctl -p err --since "1 hour ago"

# Check specific service
journalctl -u servicename --since "1 hour ago"
```

- **Review system logs**: Check for errors and warnings
- **Filter by priority**: Focus on errors and critical issues
- **Check service logs**: Review logs for configured services
- **Analyze patterns**: Look for recurring issues

## Rollback Validation

```bash
# List available generations
nixos generations list

# Compare generations
nix diff /run/current-system /nix/var/nix/profiles/system-1-link

# Test rollback
nixos-rebuild switch --rollback
```

- **List generations**: See available rollback points
- **Compare configurations**: Understand differences between generations
- **Test rollback process**: Verify rollback works correctly
- **Keep multiple generations**: Don't garbage collect too soon

## Pre-Deployment Checklist

```markdown
# Pre-Deployment Validation Checklist

## Syntax & Structure
- [ ] `nix flake check` passes
- [ ] All modules import successfully
- [ ] No syntax errors detected
- [ ] No unused code found

## Build Validation
- [ ] Configuration builds successfully
- [ ] No build warnings
- [ ] All services would start
- [ ] Dependencies are properly resolved

## Configuration Review
- [ ] All required options are set
- [ ] No conflicting options
- [ ] Hostname is correct
- [ ] Time zone is set

## Security Review
- [ ] Secret management is configured
- [ ] File permissions are correct
- [ ] Firewall rules are appropriate
- [ ] SSH configuration is secure

## Network Configuration
- [ ] Network interfaces are configured
- [ ] DNS resolution is set up
- [ ] Firewall rules allow necessary traffic
- [ ] VPN configuration is correct

## Service Configuration
- [ ] All services are enabled
- [ ] Service dependencies are correct
- [ ] Service configuration files are valid
- [ ] Logs are configured appropriately

## Testing
- [ ] Dry build succeeds
- [ ] Check command passes
- [ ] Integration tests pass (if applicable)
- [ ] Hardware tests pass (if applicable)

## Backup & Rollback
- [ ] Current generation is backed up
- [ ] Rollback plan is documented
- [ ] Recovery procedures are tested
- [ ] Backup verification is complete

## Documentation
- [ ] Changelog is updated
- [ ] Deployment notes are prepared
- [ ] Team is notified
- [ ] Documentation is current
```

- **Use comprehensive checklist**: Ensure nothing is missed
- **Validate before deployment**: All checks must pass
- **Document validation steps**: Make process clear
- **Track validation status**: Record what was validated

## Continuous Validation

```bash
# Set up automated validation in CI
# Validate on every commit
# Block deployment if validation fails
# Generate validation reports
```

- **Automate validation**: Run validation automatically
- **Fail fast**: Stop deployment if validation fails
- **Generate reports**: Produce validation reports
- **Track validation trends**: Monitor validation over time

## Error Handling

```bash
# Common validation errors and solutions

# Syntax error
# Solution: Fix syntax, re-validate

# Option doesn't exist
# Solution: Check option name, update to correct option

# Service fails to start
# Solution: Check service configuration, dependencies, and logs

# Build failure
# Solution: Review build logs, fix dependencies
```

- **Document common errors**: Keep list of common validation errors
- **Provide solutions**: Include fix for each error type
- **Track error patterns**: Identify recurring validation issues
- **Improve validation**: Use errors to improve validation process

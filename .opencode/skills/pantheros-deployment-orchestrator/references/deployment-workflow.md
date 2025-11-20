# Deployment Workflow

## Overview

The deployment orchestrator automates the complete Phase 3 deployment process for pantherOS, managing builds, testing, and rollbacks with comprehensive logging and safety checks.

## The Deployment Process

### Standard Deployment Workflow

1. **Build Phase**
   - Compile system configuration
   - Resolve all dependencies
   - Create system closure
   - Validate Nix expressions

2. **Dry-Run Phase**
   - Test configuration without applying
   - Simulate system activation
   - Check for conflicts or issues
   - Verify service configurations

3. **Deployment Phase**
   - Switch to new configuration
   - Activate system changes
   - Start/stop services
   - Update boot loader

4. **Validation Phase**
   - Verify system is running
   - Check critical services
   - Monitor system health
   - Save deployment logs

## Deployment Scripts

### deploy.sh

Main deployment orchestrator script.

**Usage:**
```bash
./scripts/deploy.sh <hostname> [--build-only|--dry-run]
```

**Modes:**
- Default: Full deployment (build → dry-activate → switch)
- `--build-only`: Only build, don't activate
- `--dry-run`: Build and test, don't switch

**Example:**
```bash
# Full deployment
./scripts/deploy.sh yoga

# Test only
./scripts/deploy.sh zephyrus --dry-run

# Build verification
./scripts/deploy.sh hetzner-vps --build-only
```

**Safety Features:**
- Validates host exists before building
- Logs all output to log files
- Checks for warnings in configuration
- Prompts for confirmation before switching
- Automatic rollback on failure

**Workflow:**
```bash
Step 1/3: Build system configuration
  ↓ (on success)
Step 2/3: Test configuration (dry-activate)
  ↓ (on success)
Step 3/3: Deploy system (switch)
  ↓ (on success)
Post-deployment checks
  ↓
Complete
```

**Error Handling:**
- Build failure → Abort, no changes
- Dry-run failure → Abort, review logs
- Switch failure → Automatic rollback
- Rollback failure → Manual intervention required

### build-all.sh

Parallel builder for testing all hosts simultaneously.

**Usage:**
```bash
./scripts/build-all.sh [--jobs N]
```

**Examples:**
```bash
# Auto-detect parallel jobs
./scripts/build-all.sh

# Limit to 2 parallel jobs
./scripts/build-all.sh --jobs 2
```

**Features:**
- Builds all hosts in parallel
- Individual logs per host
- Summary report (passed/failed)
- Faster CI/CD pipelines

**Example Output:**
```
=== PantherOS Parallel Build Tool ===

ℹ Building with 8 parallel jobs...
ℹ Hosts: yoga zephyrus hetzner-vps ovh-vps

✓ yoga
✓ zephyrus
✓ hetzner-vps
✓ ovh-vps

=== Build Summary ===

ℹ Passed: 4
ℹ Failed: 0
ℹ Total: 4

✓ All hosts built successfully!
```

### rollback.sh

Generation management and rollback utility.

**Usage:**
```bash
./scripts/rollback.sh [hostname] [--list|--rollback [N]]
```

**Examples:**
```bash
# List generations for current host
./scripts/rollback.sh --list

# List generations for specific host
./scripts/rollback.sh yoga --list

# Rollback to previous generation
./scripts/rollback.sh zephyrus --rollback

# Rollback to specific generation
./scripts/rollback.sh hetzner-vps --rollback 123
```

## Pre-Deployment Checklist

### Before Running deploy.sh

1. **Verify Configuration**
   ```bash
   # Check syntax
   nix-instantiate --eval flake.nix

   # Verify imports
   grep -r "imports" hosts/*/configuration.nix
   ```

2. **Check Dependencies**
   ```bash
   # Update flake inputs
   nix flake update

   # Check for updates
   nix flake info
   ```

3. **Review Changes**
   ```bash
   # Show diff (if using git)
   git diff HEAD

   # Check for secrets in config
   grep -r "op:" hosts/ | head -20
   ```

4. **Backup Important Data**
   ```bash
   # Backup home directory
   rsync -av --delete ~/.config ~/backup-config-$(date +%Y%m%d)

   # Backup system config
   nixos-rebuild list-generations --flake .#yoga > ~/generations.txt
   ```

### For Remote Hosts (Servers)

1. **Ensure Access**
   ```bash
   # Test SSH connection
   ssh root@hetzner-vps "echo connected"

   # Check Tailscale connectivity
   ping 100.x.x.x  # server IP
   ```

2. **Have Console Access**
   ```bash
   # Hetzner: Console access in control panel
   # OVH: IPMI/KVM access
   # AWS/GCP: Serial console
   ```

3. **Prepare Rollback**
   ```bash
   # List current generation
   ssh root@hetzner-vps "nixos-rebuild list-generations --flake .#hetzner-vps"

   # Note current generation number
   ```

## Deployment Scenarios

### Scenario 1: Development Workstation (Yoga/Zephyrus)

**Safe deployment with instant rollback:**

```bash
# 1. Test first
./scripts/deploy.sh yoga --dry-run

# 2. Review output
cat logs/deploy/dry-run-yoga-*.log | less

# 3. Build only
./scripts/deploy.sh yoga --build-only

# 4. If build succeeds, deploy
./scripts/deploy.sh yoga

# 5. Verify system
systemctl status
journalctl -xb -n 100
```

**Risk Level:** Low - Easy physical access, local rollback

### Scenario 2: Remote Server (Hetzner/OVH)

**Caution required - remote deployment:**

```bash
# 1. Build locally first
./scripts/deploy.sh hetzner-vps --build-only

# 2. Test configuration
./scripts/deploy.sh hetzner-vps --dry-run

# 3. Verify Tailscale connection
ping $(tailscale ip -4 hetzner-vps)

# 4. Deploy with confirmation
./scripts/deploy.sh hetzner-vps

# 5. If connection drops, use console
# Console → SSH back → Check status
```

**Risk Level:** Medium - Must have console access ready

### Scenario 3: Critical Production Server

**Maximum safety procedures:**

```bash
# 1. Build and test thoroughly
./scripts/deploy.sh hetzner-vps --build-only
if [ $? -ne 0 ]; then exit 1; fi

./scripts/deploy.sh hetzner-vps --dry-run
if [ $? -ne 0 ]; then exit 1; fi

# 2. Test in staging (if available)
# Not applicable for single-server setup

# 3. Schedule deployment window
# Notify users of potential downtime

# 4. Deploy during low-traffic period
./scripts/deploy.sh hetzner-vps

# 5. Verify immediately
ssh root@hetzner-vps "systemctl is-system-running"

# 6. Monitor services
ssh root@hetzner-vps "systemctl status nginx postgresql"
```

**Risk Level:** High - Requires careful planning and monitoring

## Deployment Monitoring

### During Deployment

Watch the deployment in real-time:

```bash
# Terminal 1: Run deployment
./scripts/deploy.sh yoga

# Terminal 2: Monitor system (on target host)
ssh yoga "watch -n 1 'systemctl list-units --type=service --state=failed'"
```

### After Deployment

Check system health:

```bash
# Check system is running
systemctl is-system-running

# Check critical services
systemctl status \
  systemd-hostnamed \
  NetworkManager \
  systemd-logind

# Check recent logs
journalctl -xb -n 100 --no-pager

# Check Nix configuration
nixos-option services.my-service.enable
```

### Service-Specific Checks

```bash
# Web services
curl -I http://localhost:8080
curl -I http://localhost

# Databases
sudo -u postgres psql -c "SELECT 1"
systemctl status postgresql

# Network services
ss -tuln | grep :80
ss -tuln | grep :443
```

## Rollback Procedures

### Automatic Rollback

The deploy script automatically rolls back on deployment failure:

```bash
./scripts/deploy.sh yoga

# If deployment fails:
# 1. Automatic rollback is attempted
# 2. Rollback status is reported
# 3. System is restored to previous generation
```

### Manual Rollback

Rollback to previous generation:

```bash
./scripts/rollback.sh yoga --rollback
```

Rollback to specific generation:

```bash
# List generations first
./scripts/rollback.sh yoga --list

# Rollback to generation 123
./scripts/rollback.sh yoga --rollback 123
```

### Bootloader Rollback

If system won't boot:

1. Reboot into bootloader (GRUB)
2. Select "Advanced options for NixOS"
3. Select previous generation
4. Boot and verify
5. Run manual rollback:

```bash
nixos-rebuild switch --rollback
```

### Last Resort Recovery

If system is completely broken:

```bash
# From NixOS installation USB:
mount /dev/disk/by-label/nixos /mnt
nixos-install --root /mnt --flake .#yoga
reboot
```

## Troubleshooting

### Build Fails

**Error: "error: package does not exist"**

```bash
# Solution: Add missing package
nix flake update
nix search nixpkgs <package-name>

# Add to configuration.nix
environment.systemPackages = [ pkgs.<package-name> ];
```

**Error: "error: infinite recursion encountered"**

```bash
# Solution: Fix circular import
grep -r "import.*$(basename" modules/
# Remove circular import
```

### Dry-Run Fails

**Error: "error: attribute 'xyz' missing"**

```bash
# Solution: Add required option
services.my-service.xyz = "value";
```

**Error: "error: assertion failed"**

```bash
# Solution: Fix assertion
# Check the assertion in module
# Provide required configuration
```

### Switch Fails

**Error: "connection refused" (remote host)**

```bash
# Solution: Console access
# 1. Access server console (Hetzner/OVH)
# 2. Check network configuration
# 3. Verify Tailscale is running
systemctl status tailscaled
ip addr show tailscale0
```

**Error: "service failed to start"**

```bash
# Solution: Check service logs
journalctl -u <service-name> -n 50

# Debug configuration
systemctl cat <service-name>

# Test manually
<service-binary> --help
```

### System Won't Boot

```bash
# Solution: Boot previous generation
# 1. Reboot
# 2. Select previous generation in GRUB
# 3. Run rollback
nixos-rebuild switch --rollback
```

## Best Practices

### Development Workflow

1. Always test locally first (`--dry-run`)
2. Build before deploy (`--build-only`)
3. Deploy to non-production first
4. Review logs after each step

### Production Deployment

1. Schedule deployment windows
2. Notify stakeholders
3. Have rollback plan ready
4. Test on non-production first
5. Monitor after deployment
6. Document changes

### Remote Deployment

1. Verify network connectivity
2. Have console access ready
3. Test configuration first
4. Monitor during deployment
5. Keep session alive (tmux)
6. Have out-of-band access

### Safety First

- Never deploy without testing
- Always have a rollback path
- Keep console/SSH access available
- Monitor deployment logs
- Test immediately after deployment

## CI/CD Integration

### GitHub Actions Example

```yaml
# .github/workflows/deploy.yml
name: Deploy to Servers

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v20

      - name: Build all hosts
        run: ./scripts/build-all.sh --jobs 2

      - name: Upload logs
        uses: actions/upload-artifact@v3
        if: failure()
        with:
          name: build-logs
          path: logs/build/
```

### Manual Verification

```bash
# After CI build succeeds
./scripts/deploy.sh hetzner-vps --dry-run
./scripts/deploy.sh hetzner-vps
```

## Advanced Topics

### Rolling Updates

For zero-downtime deployments:

```bash
# Use systemd's sd-replace or similar
# Plan: Not implemented in current scripts
# Future enhancement: Blue-green deployment
```

### Configuration Diff

```bash
# Show configuration differences
nixos-rebuild build .#yoga --show-diff

# Or use git
git diff HEAD~1 HEAD
```

### Health Checks

```bash
# Create health check script
cat > /tmp/health-check.sh << 'EOF'
#!/usr/bin/env bash
systemctl is-system-running || exit 1
systemctl is-active nginx || exit 1
systemctl is-active postgresql || exit 1
EOF

chmod +x /tmp/health-check.sh
ssh yoga "/tmp/health-check.sh"
```

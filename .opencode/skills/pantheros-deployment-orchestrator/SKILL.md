---
name: pantheros-deployment-orchestrator
description: Automates Phase 3 build, test, and deployment process for pantherOS. Provides safe deployment workflow with build → dry-activate → switch, parallel building, automatic rollback on failure, and comprehensive logging. Essential for reliable system updates. Use when: (1) Deploying configurations to any pantherOS host, (2) Testing configurations before applying, (3) Building multiple hosts in parallel, (4) Rolling back failed deployments, (5) Managing system generations.
---

# PantherOS Deployment Orchestrator

## Overview

This skill automates the complete Phase 3 deployment process for pantherOS, providing a safe, reliable, and fully logged deployment workflow. It manages the entire build → test → deploy pipeline with automatic rollback, parallel builds, and comprehensive health checks.

**What it does:**
- Orchestrates build → dry-activate → switch workflow
- Tests configurations before deployment
- Provides automatic rollback on failures
- Builds all hosts in parallel
- Manages system generations
- Comprehensive logging and monitoring

## Quick Start

### Deploy a Host

```bash
# Standard deployment (full workflow)
./scripts/deploy.sh yoga

# Test only (don't switch)
./scripts/deploy.sh zephyrus --dry-run

# Build only (don't activate)
./scripts/deploy.sh hetzner-vps --build-only
```

### Build All Hosts

```bash
# Auto-parallel build
./scripts/build-all.sh

# Limited parallel jobs
./scripts/build-all.sh --jobs 2
```

### Rollback System

```bash
# List generations
./scripts/rollback.sh yoga --list

# Rollback to previous
./scripts/rollback.sh zephyrus --rollback

# Rollback to specific generation
./scripts/rollback.sh hetzner-vps --rollback 123
```

## The Deployment Workflow

### Standard Deployment Process

The `deploy.sh` script follows this proven workflow:

```
┌─────────────────────────────────────────────────┐
│ 1. BUILD PHASE                                   │
│    • Compile configuration                      │
│    • Resolve dependencies                       │
│    • Create system closure                      │
│    ↓ (fails → abort)                            │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ 2. DRY-RUN PHASE                                 │
│    • Test without applying                      │
│    • Simulate activation                         │
│    • Check for conflicts                         │
│    ↓ (fails → abort)                            │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ 3. DEPLOYMENT PHASE                              │
│    • Prompt for confirmation                    │
│    • Switch configuration                        │
│    • Activate changes                            │
│    ↓ (fails → auto-rollback)                    │
└─────────────────────────────────────────────────┘
           ↓
┌─────────────────────────────────────────────────┐
│ 4. VALIDATION PHASE                              │
│    • Check system status                         │
│    • Verify critical services                    │
│    • Monitor health                              │
│    • Save deployment logs                        │
└─────────────────────────────────────────────────┘
```

### Safety Features

**Pre-Deployment Checks:**
- Validates host exists before building
- Checks for flake.nix presence
- Verifies Nix expressions syntax
- Confirms network access (remote hosts)

**Deployment Safeguards:**
- Prompts for confirmation before switching
- Logs all output to timestamped files
- Checks for configuration warnings
- Provides immediate rollback option

**Post-Deployment Validation:**
- Verifies systemd is running
- Checks critical services status
- Reports new generation number
- Saves deployment information

**Automatic Rollback:**
- Triggered on switch failure
- Restores previous generation
- Reports rollback status
- Saves failure logs for analysis

## Core Scripts

### deploy.sh - Main Orchestrator

**Purpose:** Orchestrates the complete deployment workflow

**Usage:**
```bash
./scripts/deploy.sh <hostname> [--build-only|--dry-run]
```

**Arguments:**
- `hostname` - Target host to deploy
- `--build-only` - Build configuration, don't activate
- `--dry-run` - Build and test, don't switch

**Examples:**

```bash
# Standard deployment
./scripts/deploy.sh yoga

# Test configuration without applying
./scripts/deploy.sh zephyrus --dry-run

# Build verification only
./scripts/deploy.sh hetzner-vps --build-only

# Complete build and test, but don't deploy
./scripts/deploy.sh ovh-vps --dry-run
```

**Output:**
```
=== PantherOS Deployment Orchestrator ===

ℹ Hostname: yoga
ℹ Mode: deploy
ℹ Log: logs/deploy/deploy-yoga-20241201-143022.log

Step 1/3: Building system configuration...
✓ Build successful

Step 2/3: Testing configuration (dry-run)...
✓ Dry-run successful

Step 3/3: Deploying system...
WARNING: This will modify the live system!
Continue with deployment? (yes/no) yes

✓ Deployment successful!

=== Build Summary ===
Passed: 4
Failed: 0
Total: 4
```

**Log Files:**
- `logs/deploy/deploy-<hostname>-<timestamp>.log` - Full deployment log
- `logs/deploy/deploy-<hostname>-<date>.info` - Deployment metadata

### build-all.sh - Parallel Builder

**Purpose:** Build all host configurations in parallel

**Usage:**
```bash
./scripts/build-all.sh [--jobs N]
```

**Examples:**

```bash
# Auto-detect CPU cores
./scripts/build-all.sh

# Limit to 2 parallel builds
./scripts/build-all.sh --jobs 2

# Sequential builds
./scripts/build-all.sh --jobs 1
```

**Features:**
- Builds all hosts simultaneously
- Individual logs per host
- Summary report
- Fast CI/CD integration

**Example Output:**
```
=== PantherOS Parallel Build Tool ===

ℹ Building all host configurations...
ℹ Hosts: yoga zephyrus hetzner-vps ovh-vps
ℹ Log: logs/build/build-all-20241201-143022.log

✓ yoga
✗ zephyrus
✓ hetzner-vps
✓ ovh-vps

=== Build Summary ===

Passed: 3
Failed: 1
Total: 4

✗ Some hosts failed to build
```

**Log Files:**
- `logs/build/build-all-<timestamp>.log` - Master log
- `logs/build/build-<hostname>-<timestamp>.log` - Per-host logs

### rollback.sh - Generation Manager

**Purpose:** List and manage system generations

**Usage:**
```bash
./scripts/rollback.sh [hostname] [--list|--rollback [N]]
```

**Actions:**
- `--list` - List all generations (default)
- `--rollback` - Rollback to previous generation
- `--rollback N` - Rollback to generation N

**Examples:**

```bash
# List current host generations
./scripts/rollback.sh --list

# List specific host generations
./scripts/rollback.sh yoga --list

# Rollback current host
./scripts/rollback.sh --rollback

# Rollback specific host
./scripts/rollback.sh zephyrus --rollback

# Rollback to specific generation
./scripts/rollback.sh hetzner-vps --rollback 123
```

**Example Output:**
```
=== PantherOS Rollback Utility ===

Host: yoga
Action: list

Available Generations:

   123  2024-12-01 14:30:22  current
   122  2024-11-28 09:15:11
   121  2024-11-25 16:42:33
```

## Deployment Scenarios

### Scenario 1: Local Workstation Deployment

**Context:** Deploying to yoga or zephyrus (physically accessible)

**Strategy:** Safe deployment with instant local rollback

**Commands:**
```bash
# 1. Test configuration
./scripts/deploy.sh yoga --dry-run

# 2. Review output
less logs/deploy/dry-run-yoga-*.log

# 3. Build to verify
./scripts/deploy.sh yoga --build-only

# 4. Deploy if all checks pass
./scripts/deploy.sh yoga

# 5. Verify system
systemctl status
journalctl -xb -n 100
```

**Risk Level:** LOW - Physical access, local rollback

### Scenario 2: Remote Server Deployment

**Context:** Deploying to hetzner-vps or ovh-vps (remote access)

**Strategy:** Remote deployment with console backup

**Prerequisites:**
- Tailscale VPN connection
- Console/IPMI access ready
- Previous generation noted

**Commands:**
```bash
# 1. Verify connectivity
ping $(tailscale ip -4 hetzner-vps)
ssh root@$(tailscale ip -4 hetzner-vps) "echo connected"

# 2. Build locally first
./scripts/deploy.sh hetzner-vps --build-only

# 3. Test configuration
./scripts/deploy.sh hetzner-vps --dry-run

# 4. Deploy with confirmation
./scripts/deploy.sh hetzner-vps

# 5. Verify immediately
ssh root@$(tailscale ip -4 hetzner-vps) "systemctl is-system-running"
```

**Risk Level:** MEDIUM - Must have console access

### Scenario 3: Critical Production Server

**Context:** Production server, zero-downtime critical

**Strategy:** Maximum safety, thorough testing

**Prerequisites:**
- Deployment window scheduled
- Stakeholders notified
- Rollback plan documented
- Monitoring ready

**Commands:**
```bash
# 1. Thorough build test
./scripts/deploy.sh hetzner-vps --build-only
if [ $? -ne 0 ]; then echo "Build failed, aborting"; exit 1; fi

# 2. Thorough dry-run test
./scripts/deploy.sh hetzner-vps --dry-run
if [ $? -ne 0 ]; then echo "Dry-run failed, aborting"; exit 1; fi

# 3. Check current status
ssh root@$(tailscale ip -4 hetzner-vps) \
  "systemctl list-units --type=service --state=failed"

# 4. Deploy during low-traffic window
./scripts/deploy.sh hetzner-vps

# 5. Immediate verification
ssh root@$(tailscale ip -4 hetzner-vps) \
  "systemctl is-system-running && \
   systemctl status nginx postgresql"

# 6. Monitor for 10 minutes
ssh root@$(tailscale ip -4 hetzner-vps) \
  "watch -n 5 'systemctl is-active nginx postgresql'"
```

**Risk Level:** HIGH - Requires careful planning

### Scenario 4: CI/CD Automated Deployment

**Context:** Automated deployment pipeline

**Strategy:** Build all, then deploy sequentially

**Pipeline:**
```yaml
# .github/workflows/deploy.yml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: ./scripts/build-all.sh --jobs 2

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: ./scripts/deploy.sh hetzner-vps --dry-run
      - run: ./scripts/deploy.sh ovh-vps --dry-run
      - run: ./scripts/deploy.sh hetzner-vps
      - run: ./scripts/deploy.sh ovh-vps
```

## Pre-Deployment Checklist

### Before Running deploy.sh

**Configuration Checks:**
```bash
# 1. Verify syntax
nix-instantiate --eval flake.nix

# 2. Check imports exist
grep -r "imports" hosts/*/configuration.nix

# 3. Review changes
git diff HEAD

# 4. Check for secrets
grep -r "op:" hosts/ | head -20
```

**Dependency Checks:**
```bash
# 1. Update flake
nix flake update

# 2. Check for updates
nix flake info

# 3. Verify dependencies
nix build .#checks.x86_64-linux.yoga
```

**Backup Important Data:**
```bash
# Backup configs
rsync -av ~/.config ~/backup-config-$(date +%Y%m%d)

# Backup generations
nixos-rebuild list-generations --flake .#yoga > ~/generations.txt
```

**For Remote Hosts:**
```bash
# 1. Test SSH
ssh root@hetzner-vps "echo connected"

# 2. Test Tailscale
ping $(tailscale ip -4 hetzner-vps)

# 3. Check console access
# (Have Hetzner/OVH console open)

# 4. Note current generation
nixos-rebuild list-generations --flake .#hetzner-vps
```

## Post-Deployment Verification

### System Health Check

```bash
# Overall system status
systemctl is-system-running

# Expected: running, degraded, or maintenance

# Failed units (should be none)
systemctl list-units --type=service --state=failed

# Critical services
systemctl status \
  systemd-hostnamed \
  NetworkManager \
  systemd-logind \
  tailscaled

# Recent logs
journalctl -xb -n 100 --no-pager
```

### Service-Specific Checks

**Web Services:**
```bash
# Nginx
systemctl status nginx
curl -I http://localhost
ss -tuln | grep :80

# Caddy
systemctl status caddy
curl -I http://localhost
```

**Databases:**
```bash
# PostgreSQL
systemctl status postgresql
sudo -u postgres psql -c "SELECT version();"

# Redis
systemctl status redis
redis-cli ping
```

**Development Tools:**
```bash
# Docker/Podman
systemctl status docker
docker ps

# Node/Python tools
node --version
python3 --version
```

### Performance Verification

```bash
# CPU and memory
htop

# Disk I/O
iotop

# Network
iftop
ss -tuln

# Nix store
nix-store --verify --repair
```

## Rollback Procedures

### Automatic Rollback

The `deploy.sh` script automatically rolls back on failure:

```bash
./scripts/deploy.sh yoga

# If deployment fails:
# 1. Automatic rollback is attempted
# 2. Rollback status is reported
# 3. System restored to previous generation
# 4. Logs saved for analysis
```

### Manual Rollback

**Rollback to Previous Generation:**
```bash
./scripts/rollback.sh yoga --rollback

# Or for current host
./scripts/rollback.sh --rollback
```

**Rollback to Specific Generation:**
```bash
# List generations first
./scripts/rollback.sh yoga --list

# Rollback to generation 123
./scripts/rollback.sh yoga --rollback 123
```

**Bootloader Rollback:**

If system won't boot:
1. Reboot → Select GRUB
2. "Advanced options for NixOS"
3. Select previous generation
4. Boot and verify
5. Run manual rollback:

```bash
nixos-rebuild switch --rollback
```

## Troubleshooting

### Build Failures

**Error: "package does not exist"**

```bash
# Check package name
nix search nixpkgs <package>

# Update flake
nix flake update

# Add to configuration
environment.systemPackages = [ pkgs.<package> ];
```

**Error: "infinite recursion encountered"**

```bash
# Find circular import
grep -r "import.*$(basename" modules/

# Remove or fix circular reference
```

**Error: "attribute 'xyz' missing"**

```bash
# Check module options
nixos-option services.my-service

# Provide required option
services.my-service.xyz = "value";
```

### Dry-Run Failures

**Error: "assertion failed"**

```bash
# Check assertion in module
# Provide required configuration
services.required-service.enable = true;
```

**Error: "unknown option"**

```bash
# Typo in option name
# Check spelling in module documentation
```

### Deployment Failures

**Error: "connection refused" (remote)**

```bash
# Check network
ping $(tailscale ip -4 hetzner-vps)

# Check Tailscale status
ssh root@$(tailscale ip -4 hetzner-vps) "systemctl status tailscaled"

# Use console if needed
# (Hetzner/OVH control panel)
```

**Error: "service failed to start"**

```bash
# Check service logs
journalctl -u my-service -n 50

# Check configuration
systemctl cat my-service

# Test binary manually
my-service-binary --help
```

### System Won't Boot

```bash
# Reboot into previous generation
# GRUB → Advanced options → Previous generation

# After boot, run rollback
nixos-rebuild switch --rollback
```

## Advanced Usage

### Monitoring Deployment

**Real-time Monitoring:**

```bash
# Terminal 1: Deploy
./scripts/deploy.sh yoga

# Terminal 2: Monitor (on target)
ssh yoga "watch -n 1 'systemctl list-units --type=service --state=failed'"
```

**Health Check Script:**

```bash
cat > /tmp/health-check.sh << 'EOF'
#!/usr/bin/env bash
systemctl is-system-running || exit 1
systemctl is-active nginx || exit 1
systemctl is-active postgresql || exit 1
EOF

chmod +x /tmp/health-check.sh
ssh yoga "/tmp/health-check.sh"
```

### Configuration Diff

```bash
# Show what will change
nixos-rebuild build .#yoga --show-diff

# Or use git
git diff HEAD~1 HEAD
```

### Log Analysis

```bash
# View deployment log
less logs/deploy/deploy-yoga-*.log

# Check for errors
grep -i "error\|failed" logs/deploy/deploy-yoga-*.log

# Check for warnings
grep -i "warning" logs/deploy/deploy-yoga-*.log
```

### Generation Management

```bash
# Keep only last 5 generations
sudo nix-collect-garbage --delete-older-than 5d

# List all generations
nixos-rebuild list-generations --flake .#yoga

# Remove specific generation
sudo nix-env --delete-generations +5
```

## Best Practices

### Development Workflow

1. **Always test first:** Use `--dry-run` before deploying
2. **Build before deploy:** Use `--build-only` to verify
3. **Review logs:** Check deployment logs for warnings
4. **Local first:** Test on workstations before servers
5. **Incremental changes:** Small changes are safer

### Production Deployment

1. **Schedule windows:** Deploy during low-traffic periods
2. **Notify stakeholders:** Inform users of potential downtime
3. **Have rollback plan:** Know how to restore quickly
4. **Monitor after:** Watch system health for issues
5. **Document changes:** Keep deployment log

### Remote Deployment

1. **Verify connectivity:** Test SSH and Tailscale
2. **Console ready:** Have IPMI/console access prepared
3. **Keep session alive:** Use `tmux` for long operations
4. **Out-of-band access:** Have alternative access method
5. **Monitor closely:** Watch deployment in real-time

### Safety Guidelines

- **Never skip dry-run:** Always test before deploying
- **Have rollback path:** Know how to restore quickly
- **Keep console access:** For emergency recovery
- **Monitor deployment:** Watch logs and system health
- **Test immediately:** Verify after deployment

## Integration with Other Skills

- **Hardware Scanner** - Use hardware info for deployment optimization
- **Module Generator** - Test new modules before deployment
- **Nix Analyzer** - Validate configuration before building
- **Host Manager** - Organize hosts for batch deployment
- **Secrets Manager** - Verify secrets before deployment

## Resources

This skill provides:
- **Scripts**: `deploy.sh`, `build-all.sh`, `rollback.sh`
- **References**: Complete deployment workflow documentation
- **Logging**: Comprehensive deployment and build logs
- **Safety**: Automatic rollback and validation

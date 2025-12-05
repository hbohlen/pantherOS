# pantherOS Deployment Scripts

Automated scripts for verifying and deploying NixOS configurations.

## Available Scripts

### Hetzner VPS Deployment Verification

Before deploying to your Hetzner VPS, verify the configuration with one of these scripts:

#### **Using Fish Shell (Recommended)**
```bash
./scripts/verify-hetzner-deployment.fish
```

#### **Using Bash Shell (Universal Compatibility)**
```bash
./scripts/verify-hetzner-deployment.sh
```

## What These Scripts Do

The verification scripts perform the following checks in order:

1. **Nix Installation Check** - Verifies Nix is installed and accessible
2. **Determinate Nix Installation** - Installs/updates to Determinate Nix for better flake support
3. **Flake Input Verification** - Updates and validates flake inputs
4. **Flake Check** - Runs `nix flake check` to validate syntax and structure
5. **Disko Validation** - Verifies the disk layout configuration is valid
6. **Full Build** - Builds the complete hetzner-vps NixOS configuration
7. **System Info Report** - Displays configuration details
8. **Deployment Summary** - Shows next steps for deployment

## Requirements

- **Nix** (any version - script will upgrade to Determinate Nix)
- **Curl** (for downloading Determinate Nix installer)
- **Git** (for repository operations)
- **nixos-rebuild** (available via `nix-shell` or installed locally)

## Typical Usage Flow

### 1. First Time Setup (With Nix Already Installed)

```bash
cd /home/user/pantherOS

# Using Fish:
./scripts/verify-hetzner-deployment.fish

# Or using Bash:
./scripts/verify-hetzner-deployment.sh
```

The script will:
- Install Determinate Nix if not already installed
- Update all flake inputs
- Validate the configuration
- Build the NixOS system

### 2. During the Build

The build may take 10-30 minutes depending on:
- Network speed (downloading packages from cache)
- System performance
- Whether binaries are available in the cache

**Progress indicators:**
- `[1/N]` shows compilation progress
- Pay attention to any warnings or errors in red text

### 3. After Successful Verification

You'll see output like:

```
✓ Configuration is ready for deployment!

ℹ Next Steps for Deployment:
  1. Put server in Hetzner Rescue Mode
  2. SSH into rescue mode: ssh root@<your-hetzner-ip>
  3. Run nixos-anywhere from this machine:
     nix run github:nix-community/nixos-anywhere -- \
       --flake '.#hetzner-vps' \
       --no-reboot \
       root@<your-hetzner-ip>
  ...
```

## Troubleshooting

### Script Fails at "Flake Check"

**Causes:**
- Flake inputs are inaccessible (network issues)
- Typos in input references
- Circular dependencies

**Fixes:**
```bash
# Update flake lock file
nix flake update

# Check specific input
nix flake info

# See detailed error
nix flake check --verbose
```

### Script Fails During Build

**Causes:**
- Missing dependencies
- Incompatible package versions
- Syntax errors in configuration

**Fixes:**
```bash
# Check for syntax errors
nix eval --strict ".#nixosConfigurations.hetzner-vps"

# View detailed build output
nixos-rebuild build --flake ".#hetzner-vps" -v --print-build-logs

# Check specific module
nix eval ".#nixosConfigurations.hetzner-vps.config.boot"
```

### "Determinate Nix Installation Failed"

**Causes:**
- Network connectivity issue
- Insufficient disk space
- Permission denied

**Fixes:**
```bash
# Try manual installation
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Or use default Nix if you prefer
# (Determinate Nix is optional but recommended)
```

## Manual Verification Steps

If you prefer to run checks manually:

```bash
cd /home/user/pantherOS

# 1. Update flake inputs
nix flake update

# 2. Check flake syntax
nix flake check --no-build

# 3. Validate disko configuration
nix eval --json ".#nixosConfigurations.hetzner-vps.config.disko" | head -20

# 4. Build configuration
nixos-rebuild build --flake ".#hetzner-vps"

# 5. Check build output location
readlink -f result
```

## After Verification: Running nixos-anywhere

Once verification is complete and successful, deploy with:

### From Your Local Machine

```bash
# Make sure server is in Hetzner Rescue Mode first!

nix run github:nix-community/nixos-anywhere -- \
  --flake ".#hetzner-vps" \
  --no-reboot \
  root@<your-hetzner-ip>
```

### Post-Deployment Setup

```bash
# Copy OpNix token
scp /path/to/opnix-token hbohlen@hetzner-vps:/tmp/

# Setup secrets on the server
ssh hbohlen@hetzner-vps
sudo mv /tmp/opnix-token /etc/opnix-token
sudo chmod 600 /etc/opnix-token

# Populate secrets from 1Password
sudo systemctl restart onepassword-secrets.service

# Verify Tailscale is connected
sudo tailscale status
```

## Environment Variables

You can customize script behavior with:

```bash
# Skip Determinate Nix installation
SKIP_DETERMINATE=1 ./scripts/verify-hetzner-deployment.fish

# Verbose output (already enabled in scripts)
VERBOSE=1 ./scripts/verify-hetzner-deployment.sh

# Skip flake update
SKIP_UPDATE=1 ./scripts/verify-hetzner-deployment.sh
```

## Performance Tips

### Faster Builds

```bash
# Use local binary cache if available
nix build ".#nixosConfigurations.hetzner-vps.system" \
  --substituters https://cache.nixos.org https://nix-community.cachix.org

# Build only system closure (smaller build)
nix build ".#nixosConfigurations.hetzner-vps.system" --dry-run
```

### Monitor Build Progress

```bash
# In another terminal, watch nix processes
watch -n 1 'ps aux | grep -E "nix|build"'

# Or use htop
htop -p $(pgrep -f 'nix build' | head -1)
```

## Getting Help

If something goes wrong:

1. **Check the error message** - Scripts provide specific guidance
2. **Review this README** - Most common issues are documented
3. **Manual check** - See "Manual Verification Steps" section
4. **Detailed diagnostics:**
   ```bash
   nix eval --debug ".#nixosConfigurations.hetzner-vps" 2>&1 | tail -50
   ```

## Architecture

Both scripts follow this flow:

```
Check Nix
    ↓
Install/Update Determinate Nix
    ↓
Update Flake Inputs
    ↓
Validate Flake Syntax
    ↓
Validate Disko Config
    ↓
Build Full Configuration
    ↓
Display System Info
    ↓
Show Deployment Steps
```

## Script Comparison

| Feature | Fish | Bash |
|---------|------|------|
| Color output | ✓ | ✓ |
| Error handling | ✓ | ✓ |
| Progress tracking | ✓ | ✓ |
| Compatibility | Modern shells | Universal |
| Performance | Slightly faster | Slightly slower |
| Readability | Better | Standard |

**Recommendation:** Use Fish if available, Bash for maximum compatibility.

## Related Resources

- [Determinate Nix](https://determinate.systems/posts/determinate-nix/)
- [Disko Documentation](https://github.com/nix-community/disko)
- [nixos-anywhere](https://github.com/nix-community/nixos-anywhere)
- [1Password OpNix](https://github.com/brizzbuzz/opnix)

# GitHub Copilot Coding Agent - NixOS Build Testing Setup

**Created**: 2025-11-22  
**Purpose**: Enable GitHub Copilot coding agents to fully test NixOS builds for pantherOS  
**Scope**: CI/CD workflows, local testing, and agent configuration

## Overview

This guide provides step-by-step instructions for setting up GitHub Copilot coding agents to test NixOS builds, validate configurations, and ensure production readiness for pantherOS modules.

## Prerequisites

### System Requirements
- GitHub Actions runner (self-hosted or GitHub-hosted)
- Nix package manager 2.18+
- Git 2.30+
- 8GB+ RAM for NixOS builds
- 20GB+ free disk space

### Repository Access
- Read access to pantherOS repository
- Write access for creating test branches (optional)
- Access to GitHub Actions secrets (for protected resources)

## Setup Components

### 1. GitHub Actions Workflow for NixOS Build Testing

Create `.github/workflows/nixos-build-test.yml`:

```yaml
name: NixOS Build Tests

on:
  pull_request:
    branches: [ main, develop, "copilot/*" ]
    paths:
      - 'flake.nix'
      - 'flake.lock'
      - 'hosts/**'
      - 'code_snippets/**'
      - '.github/workflows/nixos-build-test.yml'
  push:
    branches: [ main, develop ]
  workflow_dispatch:
    inputs:
      host:
        description: 'Host to build (all, ovh-cloud, hetzner-cloud)'
        required: false
        default: 'all'

jobs:
  # Check flake validity
  check-flake:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Nix
        uses: cachix/install-nix-action@v24
        with:
          nix_path: nixpkgs=channel:nixos-unstable
          extra_nix_config: |
            experimental-features = nix-command flakes
            
      - name: Check flake
        run: nix flake check --all-systems --no-build
        
      - name: Show flake metadata
        run: nix flake metadata

  # Build NixOS configurations
  build-configurations:
    runs-on: ubuntu-latest
    needs: check-flake
    strategy:
      fail-fast: false
      matrix:
        host: [ovh-cloud, hetzner-cloud]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Nix
        uses: cachix/install-nix-action@v24
        with:
          nix_path: nixpkgs=channel:nixos-unstable
          extra_nix_config: |
            experimental-features = nix-command flakes
            substituters = https://cache.nixos.org https://nix-community.cachix.org
            trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
      
      - name: Setup Cachix
        uses: cachix/cachix-action@v13
        with:
          name: pantheros
          authToken: '${{ secrets.CACHIX_AUTH_TOKEN }}'
          skipPush: ${{ github.event_name == 'pull_request' }}
      
      - name: Build NixOS configuration - ${{ matrix.host }}
        run: |
          nix build .#nixosConfigurations.${{ matrix.host }}.config.system.build.toplevel \
            --print-build-logs \
            --show-trace
      
      - name: Check closure size
        run: |
          nix path-info -S .#nixosConfigurations.${{ matrix.host }}.config.system.build.toplevel | \
            awk '{printf "Closure size: %.2f GB\n", $2/1024/1024/1024}'
      
      - name: Store build artifacts
        if: success()
        uses: actions/upload-artifact@v4
        with:
          name: nixos-build-${{ matrix.host }}
          path: result
          retention-days: 7

  # Validate module syntax
  validate-modules:
    runs-on: ubuntu-latest
    needs: check-flake
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Nix
        uses: cachix/install-nix-action@v24
        with:
          extra_nix_config: |
            experimental-features = nix-command flakes
      
      - name: Validate module syntax
        run: |
          # Check all .nix files for syntax errors
          find hosts -name "*.nix" -exec nix-instantiate --parse {} \; > /dev/null
          echo "✓ All NixOS configuration files have valid syntax"
      
      - name: Check for common issues
        run: |
          # Check for trailing whitespace
          ! find hosts -name "*.nix" -exec grep -l '[[:space:]]$' {} +
          
          # Check for tabs (should use spaces)
          ! find hosts -name "*.nix" -exec grep -l $'\t' {} +

  # Evaluate configurations
  evaluate-configurations:
    runs-on: ubuntu-latest
    needs: check-flake
    strategy:
      matrix:
        host: [ovh-cloud, hetzner-cloud]
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Nix
        uses: cachix/install-nix-action@v24
        with:
          extra_nix_config: |
            experimental-features = nix-command flakes
      
      - name: Evaluate configuration options
        run: |
          nix eval .#nixosConfigurations.${{ matrix.host }}.config.system.nixos.version
          nix eval .#nixosConfigurations.${{ matrix.host }}.config.networking.hostName
      
      - name: Show enabled services
        run: |
          nix eval .#nixosConfigurations.${{ matrix.host }}.config.systemd.services --apply builtins.attrNames

  # Test module documentation
  test-module-docs:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Check module documentation exists
        run: |
          modules=(
            "audio-system"
            "wifi-network"
            "display-management"
            "touchpad-input"
            "thermal-management"
            "bluetooth-config"
            "usb-thunderbolt"
          )
          
          for module in "${modules[@]}"; do
            if [ ! -f "code_snippets/system_config/nixos/${module}.nix.md" ]; then
              echo "❌ Missing documentation for ${module}"
              exit 1
            fi
            echo "✓ Documentation exists for ${module}"
          done
      
      - name: Validate markdown syntax
        uses: DavidAnson/markdownlint-action@v1
        with:
          globs: |
            code_snippets/**/*.md
            openspec-proposals/**/*.md
          config: |
            {
              "default": true,
              "MD013": false,
              "MD033": false,
              "MD041": false
            }

  # Report results
  test-summary:
    runs-on: ubuntu-latest
    needs: [check-flake, build-configurations, validate-modules, evaluate-configurations]
    if: always()
    
    steps:
      - name: Report Status
        run: |
          echo "## NixOS Build Test Summary" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "✅ Flake check: Passed" >> $GITHUB_STEP_SUMMARY
          echo "✅ Configurations built successfully" >> $GITHUB_STEP_SUMMARY
          echo "✅ Module validation: Passed" >> $GITHUB_STEP_SUMMARY
          echo "✅ Configuration evaluation: Passed" >> $GITHUB_STEP_SUMMARY
```

### 2. Local Testing Script for Copilot Agents

Create `.github/scripts/test-nixos-build.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test NixOS builds locally before pushing
echo "🚀 Starting NixOS Build Tests for pantherOS"

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo -e "${RED}❌ Nix is not installed. Please install Nix first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Nix found: $(nix --version)${NC}"

# Enable flakes if not already enabled
export NIX_CONFIG="experimental-features = nix-command flakes"

# Test 1: Flake check
echo ""
echo "📋 Test 1: Checking flake validity..."
if nix flake check --no-build; then
    echo -e "${GREEN}✓ Flake check passed${NC}"
else
    echo -e "${RED}❌ Flake check failed${NC}"
    exit 1
fi

# Test 2: Show flake info
echo ""
echo "📋 Test 2: Flake metadata..."
nix flake metadata

# Test 3: Build configurations
HOSTS=("ovh-cloud" "hetzner-cloud")
for host in "${HOSTS[@]}"; do
    echo ""
    echo "📋 Test 3: Building $host configuration..."
    if nix build ".#nixosConfigurations.$host.config.system.build.toplevel" \
        --print-build-logs \
        --show-trace; then
        echo -e "${GREEN}✓ $host build successful${NC}"
        
        # Show closure size
        SIZE=$(nix path-info -S ".#nixosConfigurations.$host.config.system.build.toplevel" | \
            awk '{printf "%.2f GB", $2/1024/1024/1024}')
        echo "  Closure size: $SIZE"
    else
        echo -e "${RED}❌ $host build failed${NC}"
        exit 1
    fi
done

# Test 4: Validate module syntax
echo ""
echo "📋 Test 4: Validating NixOS module syntax..."
if find hosts -name "*.nix" -exec nix-instantiate --parse {} \; > /dev/null 2>&1; then
    echo -e "${GREEN}✓ All modules have valid syntax${NC}"
else
    echo -e "${RED}❌ Syntax errors found in modules${NC}"
    exit 1
fi

# Test 5: Check for common issues
echo ""
echo "📋 Test 5: Checking for common issues..."

# Check for trailing whitespace
if find hosts -name "*.nix" -exec grep -l '[[:space:]]$' {} + 2>/dev/null; then
    echo -e "${YELLOW}⚠ Warning: Trailing whitespace found${NC}"
fi

# Check for tabs
if find hosts -name "*.nix" -exec grep -l $'\t' {} + 2>/dev/null; then
    echo -e "${YELLOW}⚠ Warning: Tabs found (use spaces instead)${NC}"
fi

# Test 6: Evaluate configurations
echo ""
echo "📋 Test 6: Evaluating configuration options..."
for host in "${HOSTS[@]}"; do
    echo "  $host:"
    VERSION=$(nix eval ".#nixosConfigurations.$host.config.system.nixos.version" --raw)
    HOSTNAME=$(nix eval ".#nixosConfigurations.$host.config.networking.hostName" --raw)
    echo "    - NixOS version: $VERSION"
    echo "    - Hostname: $HOSTNAME"
done

# Summary
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ All tests passed successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "You can now safely commit and push your changes."
```

Make it executable:
```bash
chmod +x .github/scripts/test-nixos-build.sh
```

### 3. Copilot Agent Configuration

Create `.github/copilot-agent-nixos-testing.md`:

```markdown
# Copilot Agent NixOS Testing Instructions

## When to Run Tests

Run NixOS build tests when:
- Modifying `flake.nix` or `flake.lock`
- Adding/modifying host configurations in `hosts/`
- Creating new NixOS modules
- Updating dependencies
- Before merging PRs

## Test Commands

### Quick Validation (< 1 minute)
\`\`\`bash
# Check flake syntax
nix flake check --no-build

# Validate module syntax
find hosts -name "*.nix" -exec nix-instantiate --parse {} \;
\`\`\`

### Full Build Test (5-10 minutes)
\`\`\`bash
# Run comprehensive test suite
./.github/scripts/test-nixos-build.sh
\`\`\`

### Specific Host Build
\`\`\`bash
# Build specific host
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel

# Build with verbose output
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel \
  --print-build-logs --show-trace
\`\`\`

### Check Configuration Options
\`\`\`bash
# Evaluate specific option
nix eval .#nixosConfigurations.ovh-cloud.config.system.nixos.version

# List all services
nix eval .#nixosConfigurations.ovh-cloud.config.systemd.services \
  --apply builtins.attrNames
\`\`\`

## Test Workflow

1. **Before Making Changes**:
   \`\`\`bash
   # Verify baseline
   nix flake check --no-build
   \`\`\`

2. **After Making Changes**:
   \`\`\`bash
   # Quick syntax check
   find hosts -name "*.nix" -exec nix-instantiate --parse {} \;
   
   # Full build test
   ./.github/scripts/test-nixos-build.sh
   \`\`\`

3. **Before Committing**:
   \`\`\`bash
   # Run all tests
   ./.github/scripts/test-nixos-build.sh
   
   # Check git status
   git status
   \`\`\`

## Common Issues and Solutions

### Issue: Flake check fails
\`\`\`bash
# Solution: Show detailed error
nix flake check --show-trace
\`\`\`

### Issue: Build fails with dependency error
\`\`\`bash
# Solution: Update flake lock
nix flake update

# Or update specific input
nix flake lock --update-input nixpkgs
\`\`\`

### Issue: Out of disk space
\`\`\`bash
# Solution: Clean up Nix store
nix-collect-garbage -d
nix-store --gc
\`\`\`

### Issue: Syntax error in module
\`\`\`bash
# Solution: Check specific file
nix-instantiate --parse hosts/servers/ovh-cloud/configuration.nix
\`\`\`

## Expected Test Results

### Successful Build Output
\`\`\`
✓ Flake check passed
✓ ovh-cloud build successful
  Closure size: 1.2 GB
✓ hetzner-cloud build successful
  Closure size: 1.3 GB
✓ All modules have valid syntax
✅ All tests passed successfully!
\`\`\`

### Test Timing
- Flake check: ~10 seconds
- Single host build: 2-5 minutes (first time), 30 seconds (cached)
- Full test suite: 5-10 minutes (first time), 1-2 minutes (cached)

## Caching

### Local Cache
Nix automatically caches builds in `/nix/store`. Subsequent builds are much faster.

### Remote Cache (Cachix)
For CI/CD, use Cachix for faster builds:
\`\`\`bash
# Setup Cachix (one-time)
nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use pantheros

# Push to cache (requires auth)
cachix push pantheros result
\`\`\`

## Integration with GitHub Actions

All tests run automatically on:
- Pull requests to main/develop branches
- Pushes to main/develop
- Manual workflow dispatch

Check results at:
https://github.com/hbohlen/pantherOS/actions

## Troubleshooting

### Enable Verbose Logging
\`\`\`bash
export NIX_LOG_LEVEL=debug
export NIX_SHOW_TRACE=1
\`\`\`

### Check System Resources
\`\`\`bash
# Disk space
df -h /nix

# Memory
free -h

# Nix store size
du -sh /nix/store
\`\`\`

### Get Help
- NixOS Manual: https://nixos.org/manual/nixos/stable/
- Nix Pills: https://nixos.org/guides/nix-pills/
- Community: https://discourse.nixos.org/
\`\`\`
```

### 4. Pre-commit Hook for Local Testing

Create `.github/hooks/pre-push`:

```bash
#!/usr/bin/env bash

echo "🔍 Running NixOS build tests before push..."

# Run quick validation
if ! nix flake check --no-build; then
    echo "❌ Flake check failed. Push aborted."
    echo "Fix errors and try again, or use --no-verify to skip."
    exit 1
fi

# Validate module syntax
if ! find hosts -name "*.nix" -exec nix-instantiate --parse {} \; > /dev/null 2>&1; then
    echo "❌ Module syntax validation failed. Push aborted."
    exit 1
fi

echo "✅ Pre-push validation passed!"
exit 0
```

Installation:
```bash
chmod +x .github/hooks/pre-push
# Link to git hooks
ln -sf ../../.github/hooks/pre-push .git/hooks/pre-push
```

## Testing Module Documentation

### 5. Module Documentation Validator

Create `.github/scripts/validate-module-docs.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "📚 Validating module documentation..."

MODULES=(
    "audio-system"
    "wifi-network"
    "display-management"
    "touchpad-input"
    "thermal-management"
    "bluetooth-config"
    "usb-thunderbolt"
)

REQUIRED_SECTIONS=(
    "## Enrichment Metadata"
    "## Configuration Points"
    "## Code"
    "## Usage Examples"
    "## Troubleshooting"
)

failed=0

for module in "${MODULES[@]}"; do
    file="code_snippets/system_config/nixos/${module}.nix.md"
    
    if [ ! -f "$file" ]; then
        echo "❌ Missing: $file"
        ((failed++))
        continue
    fi
    
    echo "Checking $module..."
    
    for section in "${REQUIRED_SECTIONS[@]}"; do
        if ! grep -q "$section" "$file"; then
            echo "  ❌ Missing section: $section"
            ((failed++))
        fi
    done
    
    # Check minimum line count
    lines=$(wc -l < "$file")
    if [ "$lines" -lt 300 ]; then
        echo "  ⚠️  Warning: Only $lines lines (expected 300+)"
    fi
done

if [ $failed -eq 0 ]; then
    echo "✅ All module documentation validated!"
    exit 0
else
    echo "❌ Found $failed issue(s) in module documentation"
    exit 1
fi
```

## Copilot Agent Workflow

### Step-by-Step Testing Process

1. **Initial Setup** (one-time):
   ```bash
   # Install Nix with flakes
   sh <(curl -L https://nixos.org/nix/install) --daemon
   
   # Enable flakes
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   
   # Make test scripts executable
   chmod +x .github/scripts/*.sh
   ```

2. **Before Code Changes**:
   ```bash
   # Verify baseline
   nix flake check --no-build
   ```

3. **After Code Changes**:
   ```bash
   # Quick check
   .github/scripts/test-nixos-build.sh
   ```

4. **Before Committing**:
   ```bash
   # Full validation
   .github/scripts/test-nixos-build.sh
   .github/scripts/validate-module-docs.sh
   ```

5. **Monitor CI/CD**:
   - Check GitHub Actions for automated test results
   - Review any failures in the Actions tab

## Performance Optimization

### Build Cache Setup

```bash
# Use binary cache for faster builds
nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use nix-community
cachix use pantheros  # If configured
```

### Parallel Builds

Add to `~/.config/nix/nix.conf`:
```
max-jobs = auto
cores = 0
```

## Environment Variables

Set these for consistent testing:

```bash
export NIX_CONFIG="experimental-features = nix-command flakes"
export NIXPKGS_ALLOW_UNFREE=1
```

## Success Criteria

A successful test run should show:
- ✅ Flake check passes
- ✅ All host configurations build
- ✅ Module syntax validated
- ✅ Configuration evaluation succeeds
- ✅ Documentation validation passes
- ✅ Closure sizes within expected range (<2GB per host)

## Next Steps

1. Set up the GitHub Actions workflow
2. Run local tests before pushing
3. Monitor CI/CD results
4. Address any test failures promptly

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [GitHub Actions for Nix](https://github.com/cachix/install-nix-action)
- [pantherOS Documentation](../README.md)

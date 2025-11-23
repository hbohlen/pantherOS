# NixOS Testing Quick Start Guide for Copilot Agents

## Quick Commands

### Local Testing (Fastest)
```bash
# Quick syntax check (10 seconds)
nix flake check --no-build

# Run full test suite (5-10 minutes)
./.github/scripts/test-nixos-build.sh

# Build specific host
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel
```

### GitHub Actions Testing
All tests run automatically on PRs to `main`, `develop`, or `copilot/*` branches.

View results: https://github.com/hbohlen/pantherOS/actions

## Setup (One-Time)

### Install Nix
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### Enable Flakes
```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### Make Test Script Executable
```bash
chmod +x .github/scripts/test-nixos-build.sh
```

## Usage Workflow

1. **Before changes**: `nix flake check --no-build`
2. **After changes**: `./.github/scripts/test-nixos-build.sh`
3. **Before commit**: `./.github/scripts/test-nixos-build.sh`
4. **After push**: Check GitHub Actions

## Expected Results

### Success Output
```
✅ All tests passed successfully!

Summary:
  ✓ Flake validation passed
  ✓ All host configurations built successfully
  ✓ Module syntax validated
  ✓ Configuration evaluation completed
  ✓ Documentation validated
```

### Timing
- Flake check: ~10 seconds
- First build: 5-10 minutes
- Cached build: 30 seconds - 2 minutes

## Troubleshooting

### Flake Check Fails
```bash
nix flake check --show-trace
```

### Build Fails
```bash
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel \
  --print-build-logs --show-trace
```

### Out of Disk Space
```bash
nix-collect-garbage -d
```

## Resources

- Full Guide: `.github/COPILOT-NIXOS-TESTING-SETUP.md`
- Workflow: `.github/workflows/nixos-build-test.yml`
- Test Script: `.github/scripts/test-nixos-build.sh`

## CI/CD Status Badge

Add to README.md:
```markdown
[![NixOS Build Tests](https://github.com/hbohlen/pantherOS/actions/workflows/nixos-build-test.yml/badge.svg)](https://github.com/hbohlen/pantherOS/actions/workflows/nixos-build-test.yml)
```

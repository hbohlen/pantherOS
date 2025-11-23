#!/usr/bin/env bash

# Test script to verify nixos-anywhere integration in deployment scripts
# This script checks that the necessary changes have been made correctly

set -euo pipefail

echo "Testing nixos-anywhere integration in PantherOS deployment scripts..."
echo

# Check that deploy-hetzner.sh has been updated correctly
echo "1. Checking deploy-hetzner.sh for nixos-anywhere integration..."

if grep -q "USE_NIXOS_ANYWHERE" deploy-hetzner.sh; then
    echo "   ✓ USE_NIXOS_ANYWHERE variable added"
else
    echo "   ✗ USE_NIXOS_ANYWHERE variable not found"
    exit 1
fi

if grep -q "deploy_pantheros_anywhere" deploy-hetzner.sh; then
    echo "   ✓ deploy_pantheros_anywhere function added"
else
    echo "   ✗ deploy_pantheros_anywhere function not found"
    exit 1
fi

if grep -q "\-\-nixos-anywhere" deploy-hetzner.sh; then
    echo "   ✓ --nixos-anywhere option added to CLI parser"
else
    echo "   ✗ --nixos-anywhere option not found in CLI parser"
    exit 1
fi

if grep -q "nixos-anywhere.*--flake" deploy-hetzner.sh; then
    echo "   ✓ nixos-anywhere command with flake option added"
else
    echo "   ✗ nixos-anywhere command not found"
    exit 1
fi

if grep -q "nix run github:numtide/nixos-anywhere" deploy-hetzner.sh; then
    echo "   ✓ Correct nixos-anywhere invocation found"
else
    echo "   ✗ Correct nixos-anywhere invocation not found"
    exit 1
fi

echo "   ✓ All nixos-anywhere integration elements found in deploy-hetzner.sh"
echo

# Check that deploy-hetzner-rescue.sh has been updated to mention nixos-anywhere
echo "2. Checking deploy-hetzner-rescue.sh for nixos-anywhere reference..."

if grep -q "nixos-anywhere" deploy-hetzner-rescue.sh; then
    echo "   ✓ nixos-anywhere reference added to deploy-hetzner-rescue.sh"
else
    echo "   ✗ nixos-anywhere reference not found in deploy-hetzner-rescue.sh"
    exit 1
fi

echo

# Check that README.md has been updated with usage information
echo "3. Checking README.md for nixos-anywhere documentation..."

if grep -q "nixos-anywhere.*recommended" README.md; then
    echo "   ✓ README.md updated with nixos-anywhere usage instructions"
else
    echo "   ✗ nixos-anywhere usage instructions not found in README.md"
    exit 1
fi

echo

# Verify that the flake contains the hetzner-vps configuration
echo "4. Checking flake.nix for hetzner-vps configuration..."

if grep -q "hetzner-vps" flake.nix; then
    echo "   ✓ hetzner-vps configuration found in flake.nix"
else
    echo "   ✗ hetzner-vps configuration not found in flake.nix"
    exit 1
fi

echo

echo "All tests passed! nixos-anywhere integration is properly implemented."
echo
echo "To test the deployment:"
echo "1. Ensure you have hcloud CLI installed and authenticated"
echo "2. Run: ./deploy-hetzner.sh --nixos-anywhere"
echo
echo "The deployment will:"
echo "- Create a Hetzner Cloud server"
echo "- Enable rescue mode"
echo "- Use nixos-anywhere to deploy PantherOS automatically"
echo "- Disable rescue mode after successful deployment"
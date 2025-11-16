# OpNix / 1Password Setup Guide

**AI Agent Context**: ⚠️ NOT IMPLEMENTED - This describes planned features not yet configured.

## Current Status

OpNix is **imported in flake.nix** but **NOT configured** in the actual system.

The configuration file includes:
```nix
opnix.nixosModules.default
```

But there is NO OpNix configuration in `configuration.nix` or `home.nix`.

## What This Would Do (If Implemented)

OpNix integration would:
- Read secrets from 1Password vault
- Inject them as environment variables
- Manage SSH keys automatically
- Provide Tailscale auth keys
- Handle API tokens for services

## Current Secret Management

**Actually implemented**: None

Users must manually:
1. Add SSH public keys to `configuration.nix`
2. Set environment variables manually
3. Manage secrets outside NixOS configuration

## To Implement OpNix

If you want to implement OpNix:

1. Get a 1Password service account token
2. Add OpNix configuration to `configuration.nix`:
   ```nix
   services.opnix = {
     enable = true;
     vaultName = "pantherOS";
   };
   ```
3. Create 1Password items with proper paths
4. Reference secrets in configuration

See: https://github.com/brizzbuzz/opnix

---

**Note**: This file describes features NOT currently implemented. OpNix is imported but not configured.

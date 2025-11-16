# OpNix / 1Password Setup Guide

This guide explains how to configure 1Password items to be sourced as environment variables using OpNix.

## Overview

OpNix integrates 1Password with NixOS by reading secrets from 1Password and making them available as environment variables throughout your system.

## Required 1Password Items

Create the following items in your 1Password vault:

### 1. **pantherOS/secrets** (API Keys & Tokens)

Create a **Login** item named `pantherOS/secrets` with these fields:

```
# Standard Fields (will be auto-sourced)
API Key: ANTHROPIC_API_KEY
ANTHROPIC_API_KEY: <your-api-key>
OPENAI_API_KEY: <your-openai-key>
GITHUB_TOKEN: <your-github-token>
GITLAB_TOKEN: <your-gitlab-token>
NPM_TOKEN: <your-npm-token>

# Custom Fields (also auto-sourced)
ANTHROPIC_API_KEY: <your-api-key>
OPENAI_API_KEY: <your-openai-key>
GITHUB_TOKEN: <your-github-token>
```

**Note:** Add any field name to the 1Password item, and it will be automatically sourced as an environment variable with that exact name.

### 2. **pantherOS/tailscale/authKey** (Tailscale)

Create a **Custom** item named `pantherOS/tailscale/authKey` with:
- Field name: `authKey`
- Value: `<your-tailscale-auth-key>`

### 3. SSH Keys (Already configured in your setup)

These are already configured in your current setup:
- `pantherOS/yogaSSH/public key`
- `pantherOS/zephyrusSSH/public key`
- `pantherOS/phoneSSH/public key`
- `pantherOS/desktopSSH/public key`

## How It Works

### In NixOS Configuration

OpNix reads from 1Password and makes secrets available via `config.opnix.secrets`:

```nix
# Example usage in configuration.nix
services.tailscale = {
  authKeyFile = config.opnix.secrets.opnix-1password."op://pantherOS/tailscale/authKey".path;
};
```

### In Home-Manager

Environment variables are automatically sourced and made available to all user processes:

```nix
# In home.nix
home.sessionVariables = {
  ANTHROPIC_API_KEY = config.opnix.secrets.opnix-1password."op://pantherOS/secrets:ANTHROPIC_API_KEY";
  OPENAI_API_KEY = config.opnix.secrets.opnix-1password."op://pantherOS/secrets:OPENAI_API_KEY";
};
```

## Environment Variable Usage

Once configured, environment variables are available in:

### Claude Code Settings

```json
{
  "anthropic": {
    "apiKey": "{env:ANTHROPIC_API_KEY}"
  }
}
```

### Shell

```bash
echo $ANTHROPIC_API_KEY
```

### Applications

Any application launched from your user session will have these environment variables available.

## Setting Up 1Password CLI

1. **Install 1Password CLI** (already installed via `_1password` package)

2. **Sign in to 1Password CLI**:
   ```bash
   op signin <subdomain>.1password.com <email> <secret-key>
   ```

3. **Verify access**:
   ```bash
   op list items --vault="Personal" --format=json
   ```

## OpNix Configuration in Your Flake

Your `flake.nix` already includes OpNix:

```nix
inputs = {
  opnix.url = "github:brizzbuzz/opnix";
  # ... other inputs
};
```

Your `configuration.nix` already imports the OpNix module and configures SSH keys.

## Important Paths

- 1Password item path format: `op://vault/item:field`
- In OpNix config: `config.opnix.secrets.opnix-1password."op://pantherOS/secrets:FIELD_NAME"`

## Security Notes

- All secrets are stored only in 1Password
- No hardcoded values in Nix files
- Environment variables are scoped to your user session
- SSH keys are automatically sourced by the system
- Rebuild with `sudo nixos-rebuild switch` after adding new secrets

# How To: Manage Secrets

> **Category:** How-To Guide  
> **Audience:** Developers, System Administrators  
> **Last Updated:** 2025-11-17

This guide explains how to manage secrets and environment variables in pantherOS using 1Password CLI.

## Table of Contents

- [Quick Start](#quick-start)
- [Setting Up 1Password CLI](#setting-up-1password-cli)
- [Managing Secrets](#managing-secrets)
- [Using Secrets in Development](#using-secrets-in-development)
- [Common Workflows](#common-workflows)

## Quick Start

### Essential Secrets (Required for Core Functionality)

```bash
# GitHub API Access
export GITHUB_TOKEN="ghp_xxxxxxxxxxxxxxxxxxxxx"

# 1Password Service Account (for OpNix - future)
export OP_SERVICE_ACCOUNT_TOKEN="ops_xxxxxxxxxxxxxxxxxxxxx"
```

### Recommended Secrets (AI Development)

```bash
# Claude AI
export ANTHROPIC_API_KEY="sk-ant-xxxxxxxxxxxxxxxxxxxxx"

# OpenAI
export OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxxx"

# PostgreSQL (AgentDB)
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"
```

### Optional Secrets (Extended Features)

```bash
# Web Search
export BRAVE_API_KEY="BSAxxxxxxxxxxxxxxxxxxx"

# Monitoring
export DATADOG_API_KEY="xxxxxxxxxxxxxxxxxxxxx"

# VPN
export TAILSCALE_AUTH_KEY="tskey-auth-xxxxxxxxxxxxxxxxxxxxx"
```

## Setting Up 1Password CLI

### 1. Install 1Password CLI

The 1Password CLI (`op`) is included in the development environment:

```bash
# Enter development shell
nix develop

# Verify installation
op --version
```

Alternatively, install manually:
```bash
nix-shell -p _1password
```

### 2. Sign In to 1Password

```bash
# Sign in (interactive)
op signin

# Or sign in to specific account
op signin my.1password.com user@example.com
```

### 3. Verify Access

```bash
# Check current user
op whoami

# List vaults
op vault list

# List items in a vault
op item list --vault Personal
```

## Managing Secrets

### Storing Secrets in 1Password

**Using the 1Password GUI:**
1. Create a new item or edit existing item
2. Add fields for your secrets (e.g., `GITHUB_TOKEN`, `ANTHROPIC_API_KEY`)
3. Use the reference path format: `op://Vault/Item/Field`

**Using the CLI:**

```bash
# Create a new item
op item create \
  --category=password \
  --title="pantherOS-secrets" \
  --vault=Personal

# Add a field to existing item
op item edit "pantherOS-secrets" \
  GITHUB_TOKEN="ghp_your_token_here" \
  --vault=Personal
```

### Reading Secrets

```bash
# Read a specific secret
op read "op://Personal/pantherOS-secrets/GITHUB_TOKEN"

# Read and export
export GITHUB_TOKEN=$(op read "op://Personal/pantherOS-secrets/GITHUB_TOKEN")

# Read multiple secrets at once
export ANTHROPIC_API_KEY=$(op read "op://Personal/pantherOS-secrets/ANTHROPIC_API_KEY")
export OPENAI_API_KEY=$(op read "op://Personal/pantherOS-secrets/OPENAI_API_KEY")
```

## Using Secrets in Development

### Option 1: Using direnv (Recommended)

Create a `.envrc` file to automatically load secrets:

```bash
# Create .envrc
cat > .envrc <<'EOF'
# Core secrets
export GITHUB_TOKEN=$(op read "op://Personal/pantherOS-secrets/GITHUB_TOKEN")

# AI Development secrets
export ANTHROPIC_API_KEY=$(op read "op://Personal/pantherOS-secrets/ANTHROPIC_API_KEY")
export OPENAI_API_KEY=$(op read "op://Personal/pantherOS-secrets/OPENAI_API_KEY")

# Database
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"

# MCP Configuration
export MCP_CONFIG_PATH=".github/mcp-servers.json"
EOF

# Allow direnv to load the file
direnv allow

# Secrets are now automatically loaded when entering the directory
```

**Benefits:**
- Automatic loading when entering directory
- Works with any shell
- Integrated with Nix development shells

### Option 2: Manual Export

For one-time use or testing:

```bash
# Load all required secrets
export GITHUB_TOKEN=$(op read "op://Personal/pantherOS-secrets/GITHUB_TOKEN")
export ANTHROPIC_API_KEY=$(op read "op://Personal/pantherOS-secrets/ANTHROPIC_API_KEY")
export OPENAI_API_KEY=$(op read "op://Personal/pantherOS-secrets/OPENAI_API_KEY")
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"
export MCP_CONFIG_PATH=".github/mcp-servers.json"
```

### Option 3: Shell Script

Create a reusable script:

```bash
# Create load-secrets.sh
cat > load-secrets.sh <<'EOF'
#!/usr/bin/env bash
set -e

echo "Loading secrets from 1Password..."

export GITHUB_TOKEN=$(op read "op://Personal/pantherOS-secrets/GITHUB_TOKEN")
export ANTHROPIC_API_KEY=$(op read "op://Personal/pantherOS-secrets/ANTHROPIC_API_KEY")
export OPENAI_API_KEY=$(op read "op://Personal/pantherOS-secrets/OPENAI_API_KEY")
export POSTGRES_CONNECTION_STRING="postgresql://localhost:5432/agentdb"
export MCP_CONFIG_PATH=".github/mcp-servers.json"

echo "✓ Secrets loaded successfully"
EOF

chmod +x load-secrets.sh

# Use it
source ./load-secrets.sh
```

## Common Workflows

### Verify Secrets Are Loaded

```bash
# Check if secrets are set (shows first 10 characters only)
echo "GitHub Token: ${GITHUB_TOKEN:0:10}..."
echo "Anthropic Key: ${ANTHROPIC_API_KEY:0:10}..."
echo "OpenAI Key: ${OPENAI_API_KEY:0:10}..."

# Or check if set (without exposing value)
[[ -n "$GITHUB_TOKEN" ]] && echo "✓ GITHUB_TOKEN is set" || echo "✗ GITHUB_TOKEN is not set"
```

### Update a Secret

```bash
# Update existing secret in 1Password
op item edit "pantherOS-secrets" \
  GITHUB_TOKEN="ghp_new_token_here" \
  --vault=Personal

# Reload in current shell
export GITHUB_TOKEN=$(op read "op://Personal/pantherOS-secrets/GITHUB_TOKEN")
```

### Generate a New Secret

```bash
# Generate secure random password
op item create \
  --category=password \
  --title="new-service-key" \
  --vault=Personal \
  --generate-password='letters,digits,symbols,32'

# Or use openssl
openssl rand -hex 32
```

### List All Secrets

```bash
# Show all fields in an item
op item get "pantherOS-secrets" --vault=Personal

# Show just field names
op item get "pantherOS-secrets" --vault=Personal --fields label
```

### Share Secrets with Team

```bash
# Move item to shared vault
op item move "pantherOS-secrets" --from=Personal --to=Shared

# Or create a copy
op item get "pantherOS-secrets" --vault=Personal | \
  op item create --vault=Shared
```

## Best Practices

### Security

1. **Never commit secrets** to version control
   - Add `.envrc` to `.gitignore`
   - Use 1Password references instead of hardcoded values
   - Review git history before pushing

2. **Use service accounts** for automation
   - Create separate 1Password service accounts for CI/CD
   - Limit permissions to what's needed
   - Rotate service account tokens regularly

3. **Rotate secrets periodically**
   - Set reminders to update API keys
   - Use temporary tokens when possible
   - Revoke unused credentials

### Organization

1. **Use consistent naming**
   - Format: `SERVICE_NAME_TYPE` (e.g., `GITHUB_TOKEN`, `DATADOG_API_KEY`)
   - Use UPPER_CASE for environment variables
   - Document what each secret is for

2. **Group related secrets**
   - Keep project secrets in dedicated 1Password items
   - Use vault structure: `vault/project/secret`
   - Tag items for easy filtering

3. **Document requirements**
   - List required vs optional secrets
   - Provide links to get API keys
   - Include setup instructions

## Troubleshooting

### 1Password CLI Not Working

```bash
# Check if signed in
op whoami

# Sign in if needed
op signin

# Verify vault access
op vault list
```

### Secrets Not Loading

```bash
# Check secret exists
op read "op://Personal/pantherOS-secrets/GITHUB_TOKEN"

# Check vault and item names
op item list --vault=Personal

# Verify field name
op item get "pantherOS-secrets" --vault=Personal --fields label
```

### direnv Not Loading Secrets

```bash
# Check direnv is installed
direnv version

# Allow the .envrc file
direnv allow

# Check for errors
direnv status
```

### Permission Denied

```bash
# Verify vault access
op vault get Personal

# Check item permissions
op item get "pantherOS-secrets" --vault=Personal

# Re-authenticate
op signin --force
```

## See Also

- **[Secrets Quick Reference](../reference/secrets-quick-reference.md)** - Quick lookup and commands
- **[Secrets Inventory](../reference/secrets-inventory.md)** - Complete list of all secrets
- **[Secrets & Environment Variables](../reference/secrets-environment-vars.md)** - Detailed documentation
- **[1Password CLI Documentation](https://developer.1password.com/docs/cli/)** - Official docs
- **[OpNix Setup](../../archive/future-features/OPNIX-SETUP.md)** - Future OpNix integration (archived)

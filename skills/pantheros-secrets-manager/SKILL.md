---
name: pantheros-secrets-manager
description: Manages 1Password secrets integration for pantherOS. Scans Nix files for op: references, validates secrets against 1Password, inventories all secrets, and assists with refactoring. Eliminates "secret not found" errors and reduces refactoring time. Use when: (1) Auditing secrets usage across the project, (2) Validating secrets before deployment, (3) Finding where a secret is used, (4) Refactoring secret references (renaming/moving), (5) Setting up CI/CD with 1Password.
---

# PantherOS Secrets Manager

## Overview

This skill manages the integration between pantherOS and 1Password for secure secrets handling. It provides inventory, validation, refactoring, and usage tracking for all `op:` secret references in your Nix configurations, ensuring secrets are properly managed throughout the development lifecycle.

**What it does:**
- Scans all Nix files for `op:` secret references
- Generates comprehensive secrets inventory
- Validates secrets against 1Password
- Tracks usage locations of secrets
- Assists with secret refactoring
- Exports inventory for audits

## Quick Start

### Inventory All Secrets

```bash
# Generate complete inventory
./scripts/inventory-secrets.py inventory

# Export to JSON for analysis
cat secrets-inventory.json | jq '.references | keys'
```

### Validate Secrets

```bash
# Check all secrets exist in 1Password
./scripts/inventory-secrets.py validate

# Should output:
# ✓ op:pantherOS/database/password
# ✗ op:pantherOS/missing/secret (not found)
```

### Find Secret Usage

```bash
# Find where a secret is referenced
./scripts/inventory-secrets.py find "database"

# Output:
# === Usage of database ===
#
# op:pantherOS/database/password:
#   hosts/yoga/configuration.nix
#   hosts/zephyrus/configuration.nix
#   modules/nixos/services/postgres/default.nix
```

### Refactor Secrets

```bash
# Rename/move a secret reference
./scripts/inventory-secrets.py refactor \
  "op:pantherOS/old/name" \
  "op:pantherOS/new/name"
```

## The op: Reference Format

### Understanding op: References

Secrets in pantherOS are referenced using the `op:` protocol:

```nix
op:<vault>/<item>/<field>
```

**Components:**
- **vault** - 1Password vault name (e.g., `pantherOS`)
- **item** - Item name in the vault
- **field** - Field name (password, username, note, etc.)

### Usage Examples

```nix
# Database password
postgresqlPassword = "op:pantherOS/database/password";

# API token
apiKey = "op:pantherOS/cloudflare/api-token";

# SSL private key
sslKey = "op:pantherOS/ssl/example.com/private-key";

# SSH private key
sshKey = "op:pantherOS/ssh/keys/private";
```

## Core Scripts

### inventory-secrets.py

The main script for secrets management.

**Subcommands:**

#### 1. inventory

Generate complete secrets inventory:

```bash
./scripts/inventory-secrets.py inventory
```

**Output includes:**
- Summary statistics (total refs, unique secrets)
- Breakdown by vault
- List of secrets per vault
- Detailed reference locations
- JSON export to `secrets-inventory.json`

**Example Output:**
```
=== PantherOS Secrets Inventory ===

Scanning: /home/hbohlen/dev/pantherOS

=== Summary ===
Total references found: 42
Unique secrets: 15
Files scanned: 127
Errors: 0

=== By Vault ===

pantherOS (15 secrets):
  • database-password  (referenced in 3 files)
  • api-token  (referenced in 5 files)
  • ssl-private-key  (referenced in 2 files)

=== Detailed References ===

pantherOS/database/password:
  → hosts/yoga/configuration.nix
  → hosts/zephyrus/configuration.nix
  → modules/nixos/services/postgres/default.nix
```

**JSON Export:**
```json
{
  "generated": "2024-12-01T14:30:00Z",
  "scan_path": "/home/hbohlen/dev/pantherOS",
  "stats": {
    "total_refs": 42,
    "unique_secrets": 15,
    "files": 127,
    "errors": 0
  },
  "references": {
    "op:pantherOS/database/password": [
      {
        "file": "hosts/yoga/configuration.nix",
        "context": "... postgresqlPassword = \"op:pantherOS/database/password\" ..."
      }
    ]
  }
}
```

#### 2. validate

Verify all secrets exist in 1Password:

```bash
./scripts/inventory-secrets.py validate
```

**Requirements:**
- 1Password CLI (`op`) installed and signed in
- Service account token or authenticated session
- Access to all referenced vaults

**Example Output:**
```
=== PantherOS Secrets Validation ===

Found 15 unique secrets

=== Validation Results ===

✓ pantherOS/database/password
✓ pantherOS/cloudflare/api-token
✗ pantherOS/ssl/missing-key (not found)
⚠ pantherOS/service/timeout (timeout)

=== Summary ===
Validated: 13
Missing: 1
Errors: 1
Total: 15

⚠ Some secrets are missing or invalid
```

**Use cases:**
- Pre-deployment checks
- CI/CD pipeline validation
- Auditing vault consistency
- Finding stale references

#### 3. find

Find all usages of a specific secret:

```bash
./scripts/inventory-secrets.py find "database"
```

**Example Output:**
```
=== Usage of database ===

op:pantherOS/database/password:
  hosts/yoga/configuration.nix
  hosts/zephyrus/configuration.nix
  modules/nixos/services/postgres/default.nix

op:pantherOS/database/connection-string:
  modules/nixos/services/web/default.nix
  hosts/hetzner-vps/configuration.nix
```

**Use cases:**
- Before deleting a secret
- Tracking secret dependencies
- Refactoring preparation
- Security audits

#### 4. refactor

Refactor secret references (rename/move):

```bash
./scripts/inventory-secrets.py refactor \
  "op:pantherOS/old/name" \
  "op:pantherOS/new/name"
```

**Process:**
1. Scans all Nix files for old reference
2. Lists files to modify
3. Prompts for confirmation
4. Updates all references in place

**Example:**
```bash
./scripts/inventory-secrets.py refactor \
  "op:pantherOS/api/api-key" \
  "op:pantherOS/cloudflare/api-token"

# Output:
# === Refactoring Secrets ===
#
# Old prefix: op:pantherOS/api/api-key
# New prefix: op:pantherOS/cloudflare/api-token
#
# Files to modify: 3
#   • hosts/yoga/configuration.nix
#   • hosts/zephyrus/configuration.nix
#   • modules/nixos/services/web/default.nix
#
# Confirm? (yes/no) yes
#
# ✓ Modified: hosts/yoga/configuration.nix
# ✓ Modified: hosts/zephyrus/configuration.nix
# ✓ Modified: modules/nixos/services/web/default.nix
#
# Refactoring complete
```

**Use cases:**
- Reorganizing vault structure
- Renaming secrets for clarity
- Moving secrets between vaults
- Migrating to new naming convention

## Integration Patterns

### With NixOS Services

```nix
{ config, ... }:

let
  dbPassword = "op:pantherOS/database/password";
in
{
  services.postgresql = {
    enable = true;

    initialScript = pkgs.writeText "init.sql" ''
      ALTER USER postgres WITH PASSWORD '${dbPassword}';
      CREATE DATABASE app;
    '';
  };
}
```

### With Environment Variables

```nix
{ config, ... }:

{
  systemd.services.my-app = {
    environment = {
      API_KEY = "op:pantherOS/api-keys/my-app/key";
      DATABASE_URL = "op:pantherOS/database/connection-string";
    };

    serviceConfig = {
      ExecStart = "${cfg.package}/bin/my-app";
    };
  };
}
```

### With Configuration Files

```nix
{ config, ... }:

{
  environment.etc."my-app/config.yaml".source =
    pkgs.writeText "config.yaml" ''
      apiKey: ${"op:pantherOS/api-keys/my-app/key"}
      databaseUrl: ${"op:pantherOS/database/connection-string"}
    '';
}
```

### With Home-Manager

```nix
{ config, ... }:

{
  programs.bash.initExtra = ''
    export API_KEY="$(
      echo 'op:pantherOS/api-keys/my-app/key' | op read
    )"
  '';
}
```

## 1Password Setup

### Install 1Password CLI

```bash
# Via Nix
nix-env -iA nixos.op

# Or add to system configuration
environment.systemPackages = [ pkgs.op ];
```

### Authentication Methods

**Interactive Sign-in:**
```bash
op signin my.1password.com user@example.com
```

**Service Account (Recommended):**
```bash
# Set environment variable
export OP_SERVICE_ACCOUNT_TOKEN="your-token-here"

# Sign in with service account
echo "$OP_SERVICE_ACCOUNT_TOKEN" | op signin --account my.1password.com
```

**CI/CD:**
```bash
# GitHub Actions
env:
  OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}

# GitLab CI
variables:
  OP_SERVICE_ACCOUNT_TOKEN: $OP_SERVICE_ACCOUNT_TOKEN
```

### Vault Structure

**Recommended organization:**

```
pantherOS/
├── ssl/                    # SSL certificates
│   ├── example.com/
│   │   ├── private-key
│   │   └── fullchain
│   └── another.com/
├── database/              # Database credentials
│   ├── password
│   ├── username
│   └── connection-string
├── api-keys/              # API tokens
│   ├── cloudflare
│   ├── github
│   └── docker-hub
├── ssh-keys/              # SSH keys
│   ├── keys/
│   │   ├── private
│   │   └── public
│   └── known-hosts
├── service-accounts/      # Service credentials
│   ├── username
│   ├── password
│   └── api-token
└── misc/                  # Other secrets
    ├── encryption-key
    └── jwt-secret
```

## Common Use Cases

### Pre-Deployment Validation

Ensure all secrets exist before deploying:

```bash
# In CI/CD pipeline
- name: Validate secrets
  run: ./scripts/inventory-secrets.py validate

- name: Build system
  run: ./scripts/deploy.sh yoga
```

If any secrets are missing, the build will fail with detailed information about what needs to be added to 1Password.

### Security Audit

Find all secrets referenced in the codebase:

```bash
# Generate inventory
./scripts/inventory-secrets.py inventory

# Review secrets
cat secrets-inventory.json | jq '.references | keys'

# Find secrets used in specific files
grep -r "op:" hosts/yoga/configuration.nix
```

### Before Deleting a Secret

Check where a secret is used before removing it:

```bash
# Find usage
./scripts/inventory-secrets.py find "old-secret-name"

# If no usage found, it's safe to delete
# If usage found, update configurations first
```

### Reorganizing Vault Structure

When restructuring secrets:

```bash
# 1. Create new vault structure in 1Password
# 2. Move secrets to new locations
# 3. Update references

./scripts/inventory-secrets.py refactor \
  "op:pantherOS/old/api-key" \
  "op:pantherOS/cloudflare/api-token"

# 4. Test deployment
./scripts/inventory-secrets.py validate
./scripts/deploy.sh yoga
```

### Finding Missing Secrets

When deployment fails with "secret not found":

```bash
# Validate all secrets
./scripts/inventory-secrets.py validate

# Find specific secret
./scripts/inventory-secrets.py find "postgresql"

# Check 1Password directly
op item list --vault pantherOS | grep postgresql

# Add missing secret to 1Password
op item create --vault pantherOS \
  --title "postgresql/password" \
  --field password
```

### CI/CD Pipeline Integration

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: nix-env -iA nixos.op
      - name: Setup 1Password
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
        run: echo "$OP_SERVICE_ACCOUNT_TOKEN" | op signin
      - name: Validate secrets
        run: ./scripts/inventory-secrets.py validate

  build:
    needs: validate
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: ./scripts/build-all.sh --jobs 2

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - run: ./scripts/deploy.sh yoga
```

## Best Practices

### Secret Naming

**Good naming:**
```nix
# Clear and specific
"op:pantherOS/database/postgres-password"
"op:pantherOS/cloudflare/api-token"
"op:pantherOS/ssl/example.com-private-key"
```

**Avoid:**
```nix
# Too generic
"op:pantherOS/password"
"op:pantherOS/api-key"
"op:pantherOS/cert"
```

### Field Selection

**Standard field names:**
- `password` - For passwords
- `username` - For usernames
- `api-token` - For API tokens
- `private` - For private keys
- `public` - For public keys
- `note` - For multi-line secrets

**Access field:**
```bash
# Get specific field
op item get pantherOS/database/password --fields password

# Get all fields
op item get pantherOS/database/password --fields
```

### Security Guidelines

1. **Never commit actual secrets** - Only `op:` references
2. **Use service accounts** - For CI/CD, not personal accounts
3. **Limit permissions** - Service accounts should have read-only access
4. **Rotate regularly** - Update secrets periodically
5. **Validate before deploy** - Always run validation
6. **Audit periodically** - Review secret usage

### Performance Tips

1. **Cache op responses** - Use opnix for caching
2. **Batch operations** - Validate all secrets at once
3. **Use specific paths** - Narrow scans with path argument
4. **Parallel builds** - Use build-all.sh for multiple hosts

## Troubleshooting

### Secret Not Found

**Error:** `op: item not found`

```bash
# Check if secret exists in 1Password
op item get pantherOS/database/password

# List all items in vault
op item list --vault pantherOS

# Verify exact naming
op item list --vault pantherOS | grep database
```

**Solution:**
- Add missing secret to 1Password
- Verify secret name matches exactly
- Check for typos in reference

### Authentication Failed

**Error:** `Authentication failed`

```bash
# Check authentication status
op whoami

# Re-authenticate
op signin my.1password.com

# Check service account token
echo $OP_SERVICE_ACCOUNT_TOKEN
```

**Solution:**
- Re-authenticate with `op signin`
- Verify service account token is valid
- Ensure token has vault access

### Permission Denied

**Error:** `Insufficient permissions`

```bash
# Check vault access
op vault list

# List items in vault
op item list --vault pantherOS
```

**Solution:**
- Request access from 1Password admin
- Verify service account has vault permissions
- Use correct vault name

### Invalid Reference Format

**Error:** Parsing failed or secret not found

```bash
# Check reference format
echo "op:pantherOS/database/password"
```

**Common issues:**
- Extra spaces: `"op: pantherOS / database / password"`
- Wrong field: `"op:pantherOS/database/wrong-field"`
- Typo in name: `"op:pantherOS/databse/password"`

**Solution:**
- Verify reference format matches: `op:vault/item/field`
- Remove extra spaces
- Check exact secret name in 1Password

### Timeout

**Error:** `Timeout waiting for response`

```bash
# Try with timeout
op item get pantherOS/database/password --fields password
```

**Solution:**
- Check network connectivity
- Try again (temporary issue)
- Verify 1Password service status

### Empty Inventory

**Error:** "No op: references found"

**Possible causes:**
- No secrets in project (unexpected)
- Wrong directory scanned
- Hidden Nix files not scanned

**Solution:**
```bash
# Check current directory
pwd

# Verify Nix files exist
find . -name "*.nix" | head -10

# Scan explicitly
./scripts/inventory-secrets.py inventory .
```

## Advanced Usage

### Custom Scan Path

```bash
# Scan specific directory
./scripts/inventory-secrets.py inventory hosts/

# Scan specific host
./scripts/inventory-secrets.py inventory hosts/yoga/
```

### JSON Processing

```bash
# List all unique secrets
cat secrets-inventory.json | jq -r '.references | keys[]'

# Count references per secret
cat secrets-inventory.json | jq '.references | to_entries | map({secret: .key, refs: (.value | length)})'

# Find secrets with most references
cat secrets-inventory.json | jq '.references | to_entries | sort_by((.value | length)) | reverse | .[0:5]'
```

### Bulk Validation

```bash
# Validate, then build all
./scripts/inventory-secrets.py validate && ./scripts/build-all.sh
```

### Integration with Scripts

```bash
#!/bin/bash
# Pre-deployment check
set -e

echo "=== Pre-Deployment Check ==="
echo "1. Validating secrets..."
./scripts/inventory-secrets.py validate

echo "2. Building all hosts..."
./scripts/build-all.sh

echo "3. Ready to deploy!"
echo "Run: ./scripts/deploy.sh <hostname>"
```

## Integration with Other Skills

- **Hardware Scanner** - May use secrets for hardware-related services
- **Module Generator** - Templates may include secrets placeholders
- **Deployment Orchestrator** - Validates secrets before deployment
- **Host Manager** - Compares secrets usage across hosts
- **Nix Analyzer** - Checks secrets in configuration analysis

## Resources

This skill provides:
- **Scripts**: `inventory-secrets.py` - Main secrets management tool
- **References**: Complete 1Password integration guide
- **Inventory**: JSON export of all secret references
- **Validation**: Automated secret verification
- **Refactoring**: Secret reference updates

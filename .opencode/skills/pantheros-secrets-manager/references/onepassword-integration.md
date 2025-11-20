# 1Password Integration with PantherOS

## Overview

pantherOS uses 1Password for secure secrets management through the `op` CLI and `opnix` integration. This allows secrets to be stored securely in 1Password and referenced in Nix configurations without exposing them in the repository.

## The op: Reference Format

### Basic Format

Secrets are referenced in Nix files using the `op:` protocol:

```nix
op:<vault>/<item>/<field>
```

**Components:**
- `vault` - 1Password vault name (e.g., `pantherOS`)
- `item` - Item name in the vault
- `field` - Field name in the item (password, username, note, etc.)

### Examples

```nix
# Database password
postgresqlPassword = "op:pantherOS/database/password";

# API key
apiKey = "op:pantherOS/cloudflare/api-token";

# SSH private key
sshKey = "op:pantherOS/ssh/keys/private";

# Username
user = "op:pantherOS/service-account/username";
```

## 1Password Setup

### Install 1Password CLI

```bash
# Install op CLI
nix-env -iA nixos.op

# Or add to system configuration
environment.systemPackages = [ pkgs.op ];
```

### Authenticate

```bash
# Sign in to 1Password
op signin my.1password.com user@example.com

# For service account (recommended for CI/CD)
export OP_SERVICE_ACCOUNT_TOKEN="<token>"
```

### Service Account Setup (Recommended)

1. **Create Service Account**:
   - Go to 1Password → My Account → Service Accounts
   - Create new service account
   - Grant access to required vaults

2. **Get Token**:
   ```bash
   # Copy service account token
   # Add to environment
   export OP_SERVICE_ACCOUNT_TOKEN="your-token-here"
   ```

3. **Use in CI/CD**:
   ```bash
   # GitHub Actions
   env:
     OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
   ```

## Integration Patterns

### With NixOS Modules

```nix
{ config, lib, ... }:

let
  secrets = config.secrets;
in
{
  options.secrets = mkOption {
    type = types.attrs;
    default = { };
    description = "Secrets loaded from 1Password";
  };

  config = mkIf cfg.enable {
    # Load secrets from op
    environment.sessionVariables = secrets;

    # Use in systemd service
    systemd.services.my-service = {
      environment = secrets;
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/my-service";
      };
    };

    # Use in configuration files
    environment.etc."my-service/config".source =
      pkgs.writeText "my-service-config.json" (builtins.toJSON secrets);
  };
}
```

### With Home-Manager

```nix
{ config, pkgs, ... }:

let
  secrets = config.home.sessionVariables;
in
{
  home.sessionVariables = {
    # Secrets will be loaded here
    API_KEY = null;
    DATABASE_URL = null;
  };

  programs.bash.initExtra = ''
    # Export secrets for shell
    export API_KEY="$API_KEY"
    export DATABASE_URL="$DATABASE_URL"
  '';

  # Use in program configuration
  programs.my-program.settings = {
    apiKey = secrets.API_KEY;
    databaseUrl = secrets.DATABASE_URL;
  };
}
```

### Direct Usage in Configuration

```nix
{ config, ... }:

{
  # Use directly in configuration
  services.nginx.virtualHosts."example.com" = {
    sslCertificate = "/etc/ssl/certs/fullchain.pem";
    sslCertificateKey = "op:pantherOS/ssl/example.com/private-key";
  };

  services.postgresql = {
    authentication = ''
      host all all 0.0.0.0/0 scram-sha-256
    '';
    initialScript = pkgs.writeText "init.sql" ''
      CREATE USER app WITH PASSWORD 'op:pantherOS/postgres/app-password';
      CREATE DATABASE app;
    '';
  };
}
```

## Security Best Practices

### Vault Organization

**Recommended vault structure:**

```
pantherOS/
├── ssl/              # SSL certificates and keys
│   ├── example.com/
│   └── another.com/
├── database/         # Database credentials
│   ├── password
│   ├── username
│   └── connection-string
├── api-keys/         # API tokens
│   ├── cloudflare
│   ├── github
│   └── docker-hub
├── ssh-keys/         # SSH keys
│   ├── keys/
│   │   ├── private
│   │   └── public
│   └── known-hosts
├── service-accounts/ # Service account credentials
│   ├── username
│   ├── password
│   └── api-token
└── misc/             # Other secrets
    ├── encryption-key
    └── jwt-secret
```

### Field Naming Conventions

**Use descriptive field names:**

```nix
# Good
op:pantherOS/database/postgres-password
op:pantherOS/api-keys/cloudflare-token
op:pantherOS/ssl/example.com-private-key

# Bad
op:pantherOS/database/password  # Which database?
op:pantherOS/api-keys/key       # Which API?
op:pantherOS/ssl/cert           # Which domain?
```

### Access Control

**Limit service account permissions:**

```bash
# Service account should only have:
# - Read access to specific vaults
# - No write access (except where needed)
# - No admin access
```

**Rotate secrets regularly:**

```bash
# Review and rotate:
# - API keys: Every 90 days
# - Database passwords: Every 180 days
# - SSH keys: Every 365 days
# - SSL certificates: Before expiration
```

### Secret Validation

**Validate secrets before deployment:**

```bash
# Check all secrets exist
./scripts/inventory-secrets.py validate

# Verify specific secret
./scripts/inventory-secrets.py find "database"

# Test build with secrets
nixos-rebuild build .#yoga
```

## Common Use Cases

### Database Credentials

```nix
services.postgresql = {
  enable = true;

  authentication = ''
    local all all peer
    host all all 127.0.0.1/32 scram-sha-256
    host all all ::1/128 scram-sha-256
    host all all 0.0.0.0/0 scram-sha-256
  '';

  initialScript = pkgs.writeText "init.sql" ''
    -- Use secret reference
    ALTER USER postgres WITH PASSWORD 'op:pantherOS/database/postgres-password';
  '';
};
```

### API Keys

```nix
{ config, ... }:

{
  services.cloudflared = {
    enable = true;

    config = builtins.toJSON {
      # Use API token from 1Password
      token = "op:pantherOS/cloudflare/api-token";
      tunnelToken = "op:pantherOS/cloudflare/tunnel-token";
    };
  };
}
```

### SSL Certificates

```nix
{ config, ... }:

{
  # Store private key in 1Password
  security.acme.certs."example.com" = {
    email = "admin@example.com";
    webroot = "/var/www/certbot";

    # Private key reference
    key = "op:pantherOS/ssl/example.com/private-key";
  };
}
```

### SSH Keys

```nix
{ config, pkgs, ... }:

{
  users.users.deploy = {
    openssh.authorizedKeys.keys = [
      "op:pantherOS/ssh/keys/public"
    ];
  };

  # Or use in git configuration
  programs.git.extraConfig = {
    core = {
      sshCommand = "ssh -i $(echo 'op:pantherOS/ssh/keys/private' | op read)";
    };
  };
}
```

### Environment Variables

```nix
{ config, ... }:

{
  # For services
  systemd.services.my-app = {
    environment = {
      API_KEY = "op:pantherOS/api-keys/my-app/key";
      DATABASE_URL = "op:pantherOS/database/connection-string";
    };
  };

  # For user session
  environment.sessionVariables = {
    EDITOR = "vim";
    API_KEY = "op:pantherOS/api-keys/my-app/key";
  };
}
```

## Troubleshooting

### Secret Not Found

**Error:** `op: item not found`

**Solutions:**

```bash
# Check secret exists
op item get pantherOS/database/password --fields password

# Verify vault name
op vault list

# Check item name
op item list --vault pantherOS

# Verify field name
op item get pantherOS/database/password --fields
```

### Authentication Failed

**Error:** `Authentication failed`

**Solutions:**

```bash
# Sign in interactively
op signin my.1password.com

# Check service account token
echo $OP_SERVICE_ACCOUNT_TOKEN

# Verify token is valid
op whoami
```

### Secret Reference Format

**Error:** Invalid `op:` reference

**Common issues:**
```nix
# Wrong: Missing field
"op:pantherOS/database/password"

# Correct
"op:pantherOS/database/password"

# Wrong: Extra spaces
"op: pantherOS / database / password"

# Correct
"op:pantherOS/database/password"
```

### Permission Denied

**Error:** `Insufficient permissions`

**Solutions:**
```bash
# Check service account permissions
op vault list --account my.1password.com

# Verify vault access
op item list --vault pantherOS

# Request access from 1Password admin
```

## Maintenance

### Regular Tasks

**Weekly:**
- Run secrets inventory validation
- Check for missing secrets
- Review access logs

**Monthly:**
- Audit vault permissions
- Review unused secrets
- Update documentation

**Quarterly:**
- Rotate API keys
- Audit service accounts
- Review security policies

### Secret Inventory

```bash
# Generate full inventory
./scripts/inventory-secrets.py inventory

# Export to JSON
cat secrets-inventory.json | jq '.references | keys'

# Find usage of specific secret
./scripts/inventory-secrets.py find "database"

# Validate all secrets exist
./scripts/inventory-secrets.py validate
```

### Refactoring Secrets

When moving or renaming secrets:

```bash
# Refactor all references
./scripts/inventory-secrets.py refactor \
  "op:pantherOS/old/name" \
  "op:pantherOS/new/name"
```

This will:
1. Scan all Nix files
2. Find references to old path
3. Prompt for confirmation
4. Update all references

## CI/CD Integration

### GitHub Actions

```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install op
        run: nix-env -iA nixos.op

      - name: Setup 1Password
        env:
          OP_SERVICE_ACCOUNT_TOKEN: ${{ secrets.OP_SERVICE_ACCOUNT_TOKEN }}
        run: echo "$OP_SERVICE_ACCOUNT_TOKEN" | op signin --account my.1password.com

      - name: Validate secrets
        run: ./scripts/inventory-secrets.py validate

      - name: Build and deploy
        run: ./scripts/deploy.sh yoga
```

### GitLab CI

```yaml
deploy:
  script:
    - nix-env -iA nixos.op
    - echo "$OP_SERVICE_ACCOUNT_TOKEN" | op signin --account my.1password.com
    - ./scripts/inventory-secrets.py validate
    - ./scripts/deploy.sh yoga
  variables:
    OP_SERVICE_ACCOUNT_TOKEN: $OP_SERVICE_ACCOUNT_TOKEN
```

## Performance Tips

### Cache op Responses

```bash
# Use opnix for caching
# Add to configuration.nix:
nix.opnix.enable = true;
nix.opnix.cacheDir = "/var/cache/opnix";
```

### Parallel Secret Loading

```nix
# Load secrets in parallel
let
  secrets = pkgs.runCommand "load-secrets" { } ''
    ${pkgs.op}/bin/op read op:pantherOS/database/password > $out/password
    ${pkgs.op}/bin/op read op:pantherOS/api-keys/key > $out/key
    mv $out/password $out
  '';
in
{
  # Use secrets
  environment.sessionVariables = {
    PASSWORD = secrets;
  };
}
```

## Advanced Patterns

### Secret Templates

```nix
let
  makeSecret = name: "op:pantherOS/${name}";
in
{
  # Use template
  services.my-app = {
    password = makeSecret "my-app/password";
    apiKey = makeSecret "my-app/api-key";
  };
}
```

### Conditional Secrets

```nix
config = mkIf cfg.enable {
  environment.sessionVariables = mkIf cfg.useSecrets {
    API_KEY = "op:pantherOS/my-app/api-key";
  };
};
```

### Secret Rotation

```nix
{ config, ... }:

{
  # Automatically rotate on update
  systemd.services.my-app = {
    preStart = ''
      # Rotate secret on each deployment
      op read op:pantherOS/my-app/api-key > /tmp/api-key
    '';
  };
}
```

## References

- [1Password CLI Documentation](https://developer.1password.com/docs/cli/)
- [opnix Integration](https://github.com/viperML/opnix)
- [Nix Security Best Practices](https://nixos.org/manual/nixpkgs/stable/#sec-security)

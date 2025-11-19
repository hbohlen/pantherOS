# Secrets AGENTS.md

## Purpose

The `secrets/` directory defines the secret management strategy for pantherOS. All secrets must be managed through OpNix and accessed via 1Password CLI to ensure security, consistency, and proper audit trails.

## Core Principle

**All secrets should be managed with [OpNix](https://github.com/brizzbuzz/opnix) and accessed through the 1Password CLI service account via the `op://` path.**

## Directory Structure

```
secrets/
├── AGENTS.md                   # This file - secret management guidance
├── README.md                   # Secret inventory (encrypted)
├── templates/                  # Secret templates
│   ├── service-account.md      # Service account template
│   ├── api-key.md              # API key template
│   └── certificate.md          # Certificate template
└── opnix/                      # OpNix configuration
    └── vault-config.yml        # Vault configuration
```

## Secret Management Standards

See root [AGENTS.md](../AGENTS.md) for general project guidelines.

### Golden Rules

1. **NEVER commit secrets** - No secrets in git, ever
2. **Always use OpNix** - All secrets via OpNix/1Password
3. **Use op:// paths** - Access secrets via `op://` URI scheme
4. **Service accounts only** - Use service accounts, not personal accounts
5. **Audit trail** - All secret access should be logged

### What Are Secrets?

**Secrets include:**
- API keys and tokens
- Database passwords
- SSH private keys
- TLS certificates and keys
- Cloud provider credentials
- Service account credentials
- Third-party service passwords

**Not secrets:**
- Public keys
- Configuration files (without secrets)
- Documentation
- Non-sensitive metadata

## OpNix Integration

### What is OpNix?

OpNix is a tool that integrates 1Password with NixOS, allowing:
- Secrets as Nix values
- Type-safe secret references
- Automatic secret injection
- Build-time secret resolution

### OpNix Setup

1. **Install OpNix**
   ```bash
   nix profile install github:brizzbuzz/opnix
   ```

2. **Configure service account**
   ```bash
   # Set up 1Password service account
   export OP_SERVICE_ACCOUNT_TOKEN="<service-account-token>"
   ```

3. **Verify setup**
   ```bash
   op --version
   op item list --format json | jq
   ```

## Accessing Secrets

### Via OpNix in NixOS Configuration

```nix
{ opnix, ... }:

{
  # Access secret via op:// path
  services.my-service.password = opnix "op://vault/item/secret-field";

  # Or using OpNix attribute
  services.my-service.password = opnix.secrets.my-service-password;
}
```

### Via 1Password CLI

```bash
# Get secret value
op run --env-file=<(echo "PASSWORD=$(op://vault/item/secret-field)") -- command

# Or export to environment
export PASSWORD=$(op://vault/item/secret-field)
```

### Via OpNix Nix Expression

```nix
{ opnix }:

let
  db-password = opnix "op://vault/database/password";
in
{
  services.postgresql.password = db-password;
}
```

## Secret Types

### 1. Service Account Credentials
**Format:** Service account tokens, API keys, OAuth tokens

**Storage in 1Password:**
- Item type: "Secure Note"
- Fields: `token`, `client-id`, `client-secret`
- Tags: `service-account`, `api`, `system-name`

**Usage:**
```nix
{ opnix }:

{
  services.my-service = {
    client-id = opnix "op://vault/service-accounts/my-service/client-id";
    client-secret = opnix "op://vault/service-accounts/my-service/client-secret";
  };
}
```

### 2. Database Credentials
**Format:** Username and password for databases

**Storage in 1Password:**
- Item type: "Password"
- Fields: `username`, `password`
- Tags: `database`, `credentials`

**Usage:**
```nix
{ opnix }:

{
  services.postgresql.authentication = {
    username = opnix "op://vault/databases/main/username";
    password = opnix "op://vault/databases/main/password";
  };
}
```

### 3. Certificates
**Format:** TLS certificates and private keys

**Storage in 1Password:**
- Item type: "Secure Note"
- Fields: `certificate`, `private-key`, `ca-certificate`
- Tags: `certificate`, `tls`, `ssl`

**Usage:**
```nix
{ opnix }:

{
  services.caddy.global.acme_email = "admin@example.com";
  security.pki.certificates = [
    (opnix.certificate "op://vault/certificates/web/tls-cert")
  ];
}
```

### 4. SSH Keys
**Format:** Private SSH keys

**Storage in 1Password:**
- Item type: "Secure Note"
- Fields: `private-key`, `public-key`
- Tags: `ssh`, `key`

**Usage:**
```nix
{ opnix, pkgs, ... }:

{
  services.openssh.knownHosts = {
    github = {
      hostNames = [ "github.com" ];
      publicKey = opnix "op://vault/ssh-keys/github/public-key";
    };
  };
}
```

## Working in secrets/

### Adding a New Secret

1. **Create secret in 1Password**
   ```bash
   # Create new item
   op item create --category "Secure Note" --title "service-name-api-key"
   ```

2. **Add fields**
   ```bash
   # Add fields to the item
   op item edit "service-name-api-key" "api-token[password]"="<token-value>"
   ```

3. **Reference in configuration**
   ```nix
   { opnix }:

   {
     services.my-service.api-token = opnix "op://vault/service-name-api-key/api-token";
   }
   ```

4. **Test access**
   ```bash
   # Verify secret access
   op run -- echo "Secret accessible: $(op://vault/service-name-api-key/api-token)"
   ```

### Updating a Secret

1. **Update in 1Password**
   ```bash
   # Update the secret value
   op item edit "service-name-api-key" "api-token[password]"="<new-token-value>"
   ```

2. **Rebuild configuration**
   ```bash
   # Rebuild with new secret
   nixos-rebuild switch --flake .#<hostname>
   ```

### Rotating Secrets

1. **Generate new secret**
   - In 1Password or source system

2. **Update 1Password item**
   ```bash
   op item edit "service-name-api-key" "api-token[password]"="<new-token-value>"
   ```

3. **Update dependent systems**
   - Update configuration that uses the secret
   - Rebuild affected hosts
   - Verify functionality

4. **Revoke old secret**
   - Delete or disable old credential
   - Update 1Password item notes

## Secret Inventory

### Maintaining README.md

**Important:** README.md should be encrypted via OpNix, not stored in plain text.

```nix
{ opnix }:

{
  # README.md can reference op:// paths for documentation
  environment.etc."secrets-inventory.md".text = ''
    # Secret Inventory
    ## Database Secrets
    - Main Database: \`op://vault/databases/main/*\`
    ## API Keys
    - Service A: \`op://vault/service-accounts/service-a/*\`
  '';
}
```

### Secret Naming Conventions

**1Password Item Naming:**
```
<service-type>/<service-name>
examples:
- database/main
- service-accounts/tailscale
- certificates/web/tls
- ssh-keys/deployment
- api-keys/stripe
```

**Field Naming:**
- `password` - Generic password
- `api-token` - API authentication token
- `client-id` - OAuth client ID
- `client-secret` - OAuth client secret
- `private-key` - Private key material
- `public-key` - Public key material
- `certificate` - Certificate (PEM)
- `username` - Username
- `url` - Service URL

## Security Best Practices

### Do's ✓
- Use service accounts, not personal accounts
- Rotate secrets regularly
- Use least-privilege principle
- Audit secret access regularly
- Use different secrets for dev/staging/prod
- Tag secrets with purpose and owner
- Document secret dependencies

### Don'ts ✗
- Never commit secrets to git
- Don't hardcode secrets in configs
- Don't share service account tokens
- Don't use same secret across environments
- Don't store secrets in plain text
- Don't use personal 1Password accounts
- Don't forget to rotate when staff changes

### Audit and Compliance

**Regular Tasks:**
- [ ] Audit secret access logs
- [ ] Review service account permissions
- [ ] Rotate expired secrets
- [ ] Update README.md (encrypted)
- [ ] Verify all secrets are referenced properly

## Troubleshooting

### Secret Not Found
**Symptom:** `Error: Item not found`
**Solution:**
1. Verify secret path in 1Password
2. Check service account has access
3. Verify op:// path syntax
4. Run `op item list` to confirm

### Permission Denied
**Symptom:** `Error: Insufficient permissions`
**Solution:**
1. Verify service account token
2. Check service account has item access
3. Verify vault sharing settings
4. Re-authenticate if needed

### Build Failure
**Symptom:** `Error: Secret resolution failed`
**Solution:**
1. Check OpNix is properly configured
2. Verify op:// paths are valid
3. Check Nix configuration syntax
4. Review build logs for details

## Integration Examples

### Module Integration
```nix
# modules/nixos/services/my-service.nix
{ config, lib, opnix, ... }:

{
  options.services.my-service = {
    enable = lib.mkEnableOption "my-service";
    password = lib.mkOption {
      type = lib.types.str;
      description = "Service password";
    };
  };

  config = lib.mkIf config.services.my-service.enable {
    # Reference secret via opnix
    services.my-service.password = opnix "op://vault/services/my-service/password";
  };
}
```

### Home Manager Integration
```nix
# modules/home-manager/applications/my-app.nix
{ opnix, ... }:

{
  programs.my-app = {
    enable = true;
    settings = {
      api-key = opnix "op://vault/applications/my-app/api-key";
    };
  };
}
```

## Cross-References

**See also:**
- [AGENTS.md](../AGENTS.md) - Project overview
- [OpNix Repository](https://github.com/brizzbuzz/opnix) - OpNix documentation
- [1Password CLI Docs](https://developer.1password.com/docs/cli/) - 1Password CLI reference
- [modules/AGENTS.md](../modules/AGENTS.md) - Module development
- [hosts/AGENTS.md](../hosts/AGENTS.md) - Host configuration

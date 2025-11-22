# Secrets Management in pantherOS

This guide explains how to manage secrets (passwords, API keys, tokens, certificates) securely in your NixOS configuration.

## ⚠️ Critical Rules

1. **NEVER commit secrets to git** - Even in private repositories
2. **NEVER hardcode secrets in Nix files** - Use external secret management
3. **Use `.gitignore`** - Prevent accidental commits of secret files
4. **Rotate secrets regularly** - Especially after any potential exposure
5. **Use encryption at rest** - For any secrets stored on disk

## 🎯 Recommended Approach

pantherOS currently references **1Password** as the primary secrets management solution. This guide covers:

1. 1Password integration (current)
2. sops-nix (recommended alternative)
3. agenix (simpler alternative)
4. Environment variables (for local development)

## 📦 Option 1: 1Password (Current)

### Overview

1Password is mentioned in the README as the secrets management solution via `opnix`.
The configuration references secrets using the format:

```
op:<vault>/<item>/<section>/<field>
```

### Setup

1. **Install 1Password CLI:**
   ```bash
   nix-shell -p _1password-cli
   ```

2. **Sign in to 1Password:**
   ```bash
   op signin
   ```

3. **Create a service account** (for automated access):
   - Go to 1Password web interface
   - Create a service account with read access
   - Save the service account token securely

4. **Configure opnix:**
   ```bash
   # Set up service account
   export OP_SERVICE_ACCOUNT_TOKEN="your-token-here"
   
   # Verify access
   op vault list
   ```

### Usage in NixOS

Reference secrets in your Nix configuration:

```nix
{ config, lib, pkgs, ... }:

{
  # Example: Tailscale auth key
  services.tailscale.authKeyFile = pkgs.writeText "tailscale-key" ''
    ${builtins.readFile (pkgs.runCommand "get-tailscale-key" {} ''
      ${pkgs._1password-cli}/bin/op read "op://pantherOS/tailscale/auth-key" > $out
    '')}
  '';
  
  # Example: SSH private key
  users.users.hbohlen.openssh.authorizedKeys.keys = [
    (builtins.readFile (pkgs.runCommand "get-ssh-key" {} ''
      ${pkgs._1password-cli}/bin/op read "op://pantherOS/ssh/public-key" > $out
    ''))
  ];
}
```

### Vault Structure

Organize secrets in 1Password vaults:

```
pantherOS/           # Main vault
├── tailscale/       # Tailscale secrets
│   ├── auth-key
│   └── api-token
├── ssh/             # SSH keys
│   ├── hbohlen-private
│   ├── hbohlen-public
│   └── deploy-key
├── services/        # Service credentials
│   ├── smtp-password
│   ├── db-password
│   └── api-keys
└── certificates/    # TLS certificates
    ├── domain-cert
    └── domain-key
```

### Limitations

- Requires 1Password subscription
- Needs network access during build
- Build is not purely reproducible (secrets fetched at build time)
- Secrets visible in Nix store (world-readable)

## 📦 Option 2: sops-nix (Recommended)

### Overview

sops-nix provides encrypted secrets that are decrypted only at activation time. Secrets are committed to git encrypted and never enter the Nix store in plain text.

### Setup

1. **Add sops-nix to flake inputs:**

```nix
# flake.nix
{
  inputs = {
    # ... existing inputs
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      modules = [
        sops-nix.nixosModules.sops
        # ... other modules
      ];
    };
  };
}
```

2. **Generate age key:**

```bash
# Install age
nix-shell -p age

# Generate key pair
age-keygen -o ~/.config/sops/age/keys.txt

# Get public key for .sops.yaml
age-keygen -y ~/.config/sops/age/keys.txt
```

3. **Create .sops.yaml:**

```yaml
# .sops.yaml
keys:
  - &admin_hbohlen age1qx5r6w7y8z9a0b1c2d3e4f5g6h7j8k9l0m1n2p3q4r5s6t7u8v9w0x
  - &host_yoga age1abc...xyz
  - &host_zephyrus age1def...uvw
  - &host_hetzner age1ghi...rst

creation_rules:
  # Global secrets (all hosts)
  - path_regex: secrets/global\.yaml$
    key_groups:
      - age:
          - *admin_hbohlen
          - *host_yoga
          - *host_zephyrus
          - *host_hetzner
  
  # Host-specific secrets
  - path_regex: secrets/hosts/yoga\.yaml$
    key_groups:
      - age:
          - *admin_hbohlen
          - *host_yoga
  
  - path_regex: secrets/hosts/hetzner\.yaml$
    key_groups:
      - age:
          - *admin_hbohlen
          - *host_hetzner
```

4. **Create secrets file:**

```bash
# Create secrets directory
mkdir -p secrets/hosts

# Create and edit global secrets
sops secrets/global.yaml

# Create host-specific secrets
sops secrets/hosts/yoga.yaml
sops secrets/hosts/hetzner.yaml
```

### Usage in NixOS

```nix
{ config, lib, pkgs, ... }:

{
  # Configure sops-nix
  sops = {
    defaultSopsFile = ./secrets/global.yaml;
    age.keyFile = "/var/lib/sops-nix/key.txt";
    
    secrets = {
      # Tailscale auth key
      "tailscale/auth-key" = {
        mode = "0400";
        owner = "root";
        group = "root";
      };
      
      # SSH private key
      "ssh/hbohlen-key" = {
        mode = "0400";
        owner = "hbohlen";
        group = "users";
      };
      
      # SMTP password
      "services/smtp-password" = {
        mode = "0400";
        owner = "root";
        group = "root";
      };
    };
  };
  
  # Use secrets in configuration
  services.tailscale.authKeyFile = config.sops.secrets."tailscale/auth-key".path;
  
  # Use in systemd services
  systemd.services.example = {
    serviceConfig = {
      EnvironmentFile = config.sops.secrets."services/smtp-password".path;
    };
  };
}
```

### Secrets File Format

```yaml
# secrets/global.yaml (after sops encryption)
tailscale:
  auth-key: tskey-auth-xxxxx
ssh:
  hbohlen-key: |
    -----BEGIN OPENSSH PRIVATE KEY-----
    ...
    -----END OPENSSH PRIVATE KEY-----
services:
  smtp-password: your-smtp-password-here
  api-key: your-api-key-here
```

### Advantages

- ✅ Secrets encrypted in git
- ✅ Decrypted only at activation time
- ✅ Never in Nix store
- ✅ Per-host access control
- ✅ Works offline after initial setup
- ✅ Open source and auditable

### Rotating Secrets

```bash
# Edit secrets
sops secrets/global.yaml

# Update specific field
sops --set '["services"]["api-key"] "new-value"' secrets/global.yaml

# Rotate keys
sops updatekeys secrets/global.yaml
```

## 📦 Option 3: agenix

### Overview

agenix is similar to sops-nix but simpler. Uses age encryption with a different approach.

### Setup

1. **Add agenix to flake:**

```nix
{
  inputs = {
    agenix.url = "github:ryantm/agenix";
  };

  outputs = { self, nixpkgs, agenix, ... }: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      modules = [
        agenix.nixosModules.default
        # ...
      ];
    };
  };
}
```

2. **Create secrets:**

```bash
# Install agenix
nix-shell -p agenix

# Generate age key on each host
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key

# Add public keys to secrets.nix
```

3. **Configure secrets.nix:**

```nix
# secrets/secrets.nix
let
  hbohlen = "age1...";
  yoga = "age1...";
  hetzner = "age1...";
in
{
  "tailscale-key.age".publicKeys = [ hbohlen yoga hetzner ];
  "smtp-password.age".publicKeys = [ hbohlen hetzner ];
}
```

### Usage

```nix
{
  age.secrets.tailscale-key.file = ./secrets/tailscale-key.age;
  
  services.tailscale.authKeyFile = config.age.secrets.tailscale-key.path;
}
```

### Creating Secrets

```bash
# Encrypt a secret
agenix -e secrets/tailscale-key.age
```

## 📦 Option 4: Environment Variables (Development)

For local development only, not for production:

```nix
{
  # Load from environment file
  systemd.services.example = {
    serviceConfig = {
      EnvironmentFile = "/etc/nixos/secrets.env";
    };
  };
}
```

**Never commit .env files to git!**

Add to `.gitignore`:
```
*.env
secrets.env
.env.*
```

## 🔐 Best Practices

### General

1. **Use a secrets manager** - Don't manage secrets manually
2. **Principle of least privilege** - Give minimal access needed
3. **Separate concerns** - Different secrets for different services
4. **Rotate regularly** - Especially for long-lived credentials
5. **Audit access** - Log and monitor secret access

### For NixOS

1. **Use systemd-creds** - For systemd service credentials
2. **Set proper permissions** - Mode 0400 or 0600 for secret files
3. **Use LoadCredential** - For systemd services
4. **Avoid Nix store** - Never put secrets in Nix store
5. **Test secret rotation** - Ensure services handle secret updates

### File Permissions

```nix
sops.secrets."example" = {
  mode = "0400";          # Read-only for owner
  owner = "service-user";  # Service user
  group = "service-group"; # Service group
  path = "/run/secrets/example"; # Custom path if needed
};
```

## 🚨 Secret Leakage Prevention

### Pre-commit Hook

Install pre-commit hook to check for secrets:

```bash
# .git/hooks/pre-commit
#!/usr/bin/env bash
set -euo pipefail

# Check for common secret patterns
if git diff --cached | grep -iE '(password|secret|key|token|api_key).*=.*["\047][^"\047]{8,}'; then
  echo "ERROR: Potential secret in commit. Aborting."
  exit 1
fi

# Check with gitleaks
if command -v gitleaks &> /dev/null; then
  gitleaks protect --staged
fi
```

Make it executable:
```bash
chmod +x .git/hooks/pre-commit
```

### GitHub Actions

```yaml
# .github/workflows/security.yml
name: Security Scan
on: [push, pull_request]
jobs:
  gitleaks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: gitleaks/gitleaks-action@v2
```

## 🔄 Migration Guide

### From Hardcoded to 1Password

1. Identify all hardcoded secrets:
   ```bash
   grep -r "password\|secret\|key" --include="*.nix" .
   ```

2. Move secrets to 1Password vault

3. Replace in Nix files:
   ```nix
   # Before
   password = "hardcoded-password";
   
   # After
   passwordFile = pkgs.writeText "password" ''
     ${builtins.readFile (pkgs.runCommand "get-password" {} ''
       ${pkgs._1password-cli}/bin/op read "op://vault/item/field" > $out
     '')}
   '';
   ```

### From 1Password to sops-nix

1. Export secrets from 1Password:
   ```bash
   op read "op://vault/item/field" > temp-secret.txt
   ```

2. Import to sops:
   ```bash
   sops --set '["path"]["to"]["secret"]' "$(cat temp-secret.txt)" secrets/global.yaml
   ```

3. Update Nix configuration:
   ```nix
   # Before (1Password)
   authKeyFile = pkgs.writeText "key" ''${builtins.readFile ...}'';
   
   # After (sops-nix)
   authKeyFile = config.sops.secrets."tailscale/auth-key".path;
   ```

4. Remove temporary files:
   ```bash
   shred -u temp-secret.txt
   ```

## 📚 Examples

### Complete sops-nix Setup

See [examples/secrets-sops-nix.md](../examples/secrets-sops-nix.md) for a complete working example.

### Complete 1Password Setup

See [examples/secrets-1password.md](../examples/secrets-1password.md) for a complete working example.

## 🆘 Troubleshooting

### Secret Not Accessible

```bash
# Check secret file exists
ls -la /run/secrets/

# Check permissions
ls -la /run/secrets/example

# Check sops-nix logs
journalctl -u sops-nix
```

### Build Fails with Secret Error

```bash
# Verify age key exists
ls -la /var/lib/sops-nix/key.txt

# Check .sops.yaml configuration
sops --config .sops.yaml secrets/global.yaml

# Try decrypting manually
sops -d secrets/global.yaml
```

### Secret Rotation Issues

```bash
# Update keys in .sops.yaml first
vim .sops.yaml

# Then rotate secrets
sops updatekeys secrets/global.yaml

# Verify encryption
sops -d secrets/global.yaml
```

## 📖 Resources

- [sops-nix Documentation](https://github.com/Mic92/sops-nix)
- [agenix Documentation](https://github.com/ryantm/agenix)
- [age Encryption](https://github.com/FiloSottile/age)
- [1Password CLI](https://developer.1password.com/docs/cli/)
- [NixOS Secrets Management](https://nixos.wiki/wiki/Comparison_of_secret_managing_schemes)

---

**Remember:** The best secret is one that never exists. Prefer authentication tokens over passwords, use short-lived credentials, and rotate frequently.

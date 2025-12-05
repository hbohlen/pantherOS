# Secret Management

Secure handling of sensitive information in NixOS configurations.

## Never Store Secrets in Config

- **No hardcoded secrets**: Never commit API keys, passwords, or tokens to configuration
- **Use external secret management**: Integrate with 1Password, Vault, or similar
- **Avoid environment variables**: Don't pass secrets via environment variables in config
- **Use secret file paths**: Store secrets in files with restricted permissions

## 1Password + OpNix Integration

```nix
services.onepassword-secrets = {
  enable = true;
  tokenFile = "/etc/opnix-token";

  secrets = {
    serviceName = {
      reference = "op://vault/item";  # 1Password reference
      path = "/path/to/secret/file";
      owner = "username";
      group = "groupname";
      mode = "0600";
      services = ["servicename"];  # Only these services can access
    };
  };
};
```

- **Use unique references**: Each secret should have a clear, unique 1Password reference
- **Set ownership correctly**: Set proper owner/group for secret files
- **Use restrictive permissions**: Always use mode "0600" for secrets
- **Scope access**: Only grant access to services that need the secret

## Secret File Management

- **Create directories first**: Use activation scripts to create secret directories
- **Set permissions immediately**: Use `chmod 600` on secret files
- **Separate secrets by service**: Keep service secrets in dedicated directories

```nix
system.activationScripts.create-secret-dirs = {
  text = ''
    mkdir -p /etc/secrets/service
    chmod 700 /etc/secrets/service
  '';
  deps = [];
};
```

## SSH Key Management

- **Never hardcode keys**: All SSH keys must be external references
- **Use different keys per service**: Separate keys for different purposes
- **Document key sources**: Comment where each key comes from
- **Use authorized_keys format**: For SSH public keys, use standard authorized_keys format

```nix
userSshKeys = {
  reference = "op://pantherOS/SSH/public key";
  path = "/home/user/.ssh/authorized_keys";
  owner = "user";
  group = "users";
  mode = "0600";
};
```

## Certificate Management

- **Use automated renewal**: Integrate with Let's Encrypt or similar for automatic certificate renewal
- **Store certificates securely**: Use secret management for private keys
- **Document renewal process**: Comment on how certificates are renewed
- **Separate test and production**: Use different certificates for different environments

## Secret Rotation

- **Document rotation process**: Comment on how to rotate secrets
- **Use version control for configuration**: Track configuration changes, not secret values
- **Test secret updates**: Verify secrets work after rotation
- **Plan for emergency rotation**: Have a plan for compromised secrets

## Service-Specific Patterns

### Database Passwords
```nix
database.secret = {
  reference = "op://pantherOS/database/password";
  path = "/var/lib/service/db-password";
  owner = "postgres";
  mode = "0600";
};
```

### API Keys
```nix
apiKeys = {
  reference = "op://pantherOS/service/api-key";
  path = "/etc/service/api-key";
  owner = "service-user";
  mode = "0600";
};
```

### Tailscale Auth
```nix
tailscaleAuthKey = {
  reference = "op://pantherOS/tailscale/authKey";
  path = "/etc/tailscale/auth-key";
  owner = "root";
  group = "root";
  mode = "0600";
  services = ["tailscaled"];
};
```

## Security Considerations

- **Minimize blast radius**: Each secret should only be accessible to services that need it
- **Log access**: Enable logging for secret file access where possible
- **Audit regularly**: Review which services have access to which secrets
- **Use separate vaults**: Consider separate secret vaults for different security domains

# Spec: Secrets Integration

## ADDED Requirements

### Requirement: OpNix Integration for Cloudflare Token
**Type**: ADDED  
**Priority**: Critical  
**Component**: flake.nix / NixOS configuration

#### Scenario: Retrieve Cloudflare API Token from 1Password
```nix
{ inputs, outputs, ... }:
{
  # OpNix integration in flake
  opnix = {
    url = "github:brizzbuzz/opnix";
    inputs.nixpkgs.follows = "nixpkgs";
    serviceAccount = "pantherOS";
  };
  
  # Or in system configuration
  environment.etc."secrets/cloudflare-token" = {
    text = "@opnix-cloudflare-token";
    mode = "0400";
  };
}
```

**Rationale**: Cloudflare API token must never be committed to repository. Use OpNix to retrieve from 1Password.

**Validation**:
- OpNix configured in flake
- Service account access verified
- Token retrieved successfully

### Requirement: systemd LoadCredential Setup
**Type**: ADDED  
**Priority**: Critical  
**Component**: Caddy systemd service

#### Scenario: Inject Cloudflare Token via LoadCredential
```nix
systemd.services.caddy.serviceConfig.LoadCredential = [
  "cloudflare-token:/run/secrets/cloudflare-token"
];

# Environment reference in Caddyfile
config.services.caddy.configFile = pkgs.writeText "Caddyfile" ''
  {
    acme email admin@hbohlen.systems
    acme dns cloudflare {
      env.CLOUDFLARE_API_TOKEN
    }
  }
  # ... rest of config
'';
```

**Rationale**: LoadCredential provides secure, read-only access to secrets without exposing in environment variables.

**Validation**:
- Credential file created at /run/secrets/cloudflare-token
- File owned by caddy user with 0600 permissions
- Caddy can read token from credential file

### Requirement: Cloudflare API Token Format
**Type**: ADDED  
**Priority**: High  
**Component**: 1Password / OpNix

#### Scenario: Cloudflare Token in 1Password
```
Item: "Cloudflare DNS API Token"
Vault: "pantherOS"

Required Permissions:
- Zone:Zone:Edit
- Zone:DNS:Edit
```

**Rationale**: Cloudflare API token needs specific permissions for DNS-01 challenges.

**Validation**:
- Token exists in 1Password vault
- Token has correct permissions
- Token is active and not expired

### Requirement: Secret File Permissions
**Type**: ADDED  
**Priority**: High  
**Component**: NixOS configuration

#### Scenario: Secure Secret File Handling
```nix
# Create secret file with correct permissions
environment.etc."secrets/cloudflare-token" = {
  text = "@opnix-cloudflare-token";
  mode = "0400";  # Read-only for root
};

# systemd credential (alternative approach)
systemd.tmpfiles.rules = [
  "L /run/secrets/cloudflare-token - - root caddy 0400 /etc/secrets/cloudflare-token"
];
```

**Rationale**: Prevent unauthorized access to Cloudflare token.

**Validation**:
- File mode is 0400 (read-only)
- Owner is root:caddy
- No write access for other users
- File not world-readable

### Requirement: Environment Variable Injection
**Type**: ADDED  
**Priority**: Medium  
**Component**: Caddyfile

#### Scenario: Pass Token to Caddy via Environment
```caddyfile
{
  acme email admin@hbohlen.systems
  acme dns cloudflare {
    env.CLOUDFLARE_API_TOKEN  # Reads from systemd credential
  }
}
```

**Rationale**: Caddy reads Cloudflare token from CLOUDFLARE_API_TOKEN environment variable.

**Validation**:
- Variable is set from credential file
- Caddy can access variable
- Variable not visible in process list

### Requirement: Secret Rotation Support
**Type**: ADDED  
**Priority**: Medium  
**Component**: OpNix / 1Password

#### Scenario: Rotate Cloudflare Token Without Service Restart
```nix
# Reload Caddy when secret changes
systemd.services.caddy.serviceConfig.OnChange = "opnix-sync";
```

**Rationale**: Allow secret rotation without downtime.

**Validation**:
- OpNix can update secrets
- Caddy can reload configuration
- No service interruption on rotation

## MODIFIED Requirements

### Requirement: Caddyfile Dynamic Secret Loading
**Type**: MODIFIED  
**Priority**: High  
**Component**: hosts/hetzner-vps/caddy.nix

#### Scenario: Generate Caddyfile with Secrets
```nix
let
  cloudflareToken = "@opnix-cloudflare-token";  # OpNix reference
in
{
  services.caddy.configFile = pkgs.writeText "Caddyfile" ''
    {
      acme email admin@hbohlen.systems
      acme dns cloudflare {
        env.CLOUDFLARE_API_TOKEN
      }
      
      ${baseConfig}
    }
  '';
}
```

**Rationale**: Secrets must be injected at configuration generation time, not hardcoded.

**Validation**:
- Caddyfile generated with secrets
- Secrets not visible in generated file
- File regenerated on config change

## Security Requirements

### Requirement: No Hardcoded Secrets
**Type**: ADDED  
**Priority**: Critical  
**Component**: All configuration files

#### Scenario: Search for Hardcoded Secrets
```bash
# Verify no secrets in repository
rg -i "api[_-]?key|secret|password|token" \
  --type Nix \
  /home/hbohlen/dev/pantherOS/hosts/hetzner-vps/
```

**Rationale**: Zero tolerance for hardcoded secrets in configuration.

**Validation**:
- Grep finds no secrets in Nix files
- All secrets reference OpNix or environment
- Documentation warns about secret handling

### Requirement: Secret Isolation
**Type**: ADDED  
**Priority**: High  
**Component**: System configuration

#### Scenario: Secrets Only Accessible to Caddy
```nix
# Secret files in protected location
environment.etc."secrets/cloudflare-token" = {
  text = "@opnix-cloudflare-token";
  mode = "0400";
};

# Caddy service can read
systemd.services.caddy.serviceConfig.ReadWritePaths = [
  "/var/lib/caddy"
];

# No other services need access
```

**Rationale**: Least privilege principle for secret access.

**Validation**:
- Only Caddy service can read secret
- Secret not in Nix store
- Secret not in world-readable locations

### Requirement: Audit Trail for Secret Access
**Type**: ADDED  
**Priority**: Medium  
**Component**: Logging

#### Scenario: Log Secret Usage
```nix
# Audit logging in Caddy service
systemd.services.caddy.serviceConfig.SystemCallAudit = "yes";
```

**Rationale**: Track access to sensitive credentials.

**Validation**:
- Secret access logged in audit log
- Access attempts recorded
- Logs preserved for security review

## Integration Points

### With OpNix
- Service account: `pantherOS`
- Vault: `pantherOS` or `Infrastructure Secrets`
- Secret path: `DNS/cloudflare-token` or similar

### With systemd
- LoadCredential mechanism
- Credential file: `/run/secrets/cloudflare-token`
- Permissions: 0400, owner: caddy

### With 1Password
- Service account for read-only access
- Cloudflare API token item
- Version history for rotation

### With NixOS
- Environment file integration
- Systemd service configuration
- Nix store isolation

## Testing Requirements

### Secret Retrieval Tests
```bash
# Test OpNix access
op nix list-items pantherOS | grep cloudflare

# Test credential file
cat /run/secrets/cloudflare-token
# Should show token

# Test file permissions
ls -la /run/secrets/cloudflare-token
# Should show 0400 permissions
```

### Caddy Configuration Tests
```bash
# Test Caddy starts with secret
systemctl restart caddy
systemctl status caddy

# Check logs for errors
journalctl -u caddy -n 50

# Test ACME challenge
curl -I https://dashboard.hbohlen.systems
```

### Security Tests
```bash
# Verify no secrets in Nix store
nix-store --query --roots $(which caddy)

# Check process environment (should not show token)
ps aux | grep caddy

# Verify secret file isolation
find /run/secrets -type f -ls
```

## Acceptance Criteria

- [ ] Cloudflare API token stored in 1Password service account
- [ ] OpNix configured and accessible
- [ ] Token injected via systemd LoadCredential
- [ ] Caddy can access token from environment
- [ ] Secret file has 0400 permissions
- [ ] Secret owned by root:caddy
- [ ] No hardcoded secrets in configuration
- [ ] Secret not visible in Nix store
- [ ] Token has correct Cloudflare permissions
- [ ] Secret rotation process documented

## Failure Scenarios

### Scenario: OpNix Service Down
- **Symptom**: Secret file not created
- **Diagnosis**: Check opnix service status
- **Resolution**: Restart opnix, verify 1Password access

### Scenario: 1Password Token Expired
- **Symptom**: ACME challenges fail
- **Diagnosis**: Check 1Password token validity
- **Resolution**: Regenerate token, update in 1Password

### Scenario: Cloudflare Token Invalid
- **Symptom**: DNS API calls fail
- **Diagnosis**: Check Cloudflare API response
- **Resolution**: Verify token permissions, rotate if needed

### Scenario: Wrong File Permissions
- **Symptom**: Caddy cannot read token
- **Diagnosis**: Check file permissions
- **Resolution**: Fix permissions, restart Caddy

## Secret Management Workflow

### Initial Setup
1. Create Cloudflare API token in Cloudflare dashboard
2. Add token to 1Password vault under "pantherOS" service account
3. Configure OpNix in flake.nix
4. Test secret retrieval

### Rotation Process
1. Generate new token in Cloudflare dashboard
2. Update token in 1Password
3. Trigger OpNix sync or restart service
4. Verify new token works

### Emergency Access
1. Use Hetzner web console if locked out
2. SSH to server via Tailscale from another device
3. Check 1Password CLI directly: `op signin`
4. Read token: `op nix get cloudflare-token`

## Compliance Requirements

### Secrets Handling
- [ ] No secrets in Git repository
- [ ] No secrets in Nix store
- [ ] No secrets in logs or error messages
- [ ] No secrets in process environment

### Access Control
- [ ] Read-only access for services
- [ ] Minimal permissions required
- [ ] Audit trail for access
- [ ] Regular access review

### Storage Security
- [ ] Encrypted at rest (1Password)
- [ ] Encrypted in transit (TLS)
- [ ] Protected file permissions
- [ ] Isolated from other secrets

## Related Specs

- [Reverse Proxy Service](reverse-proxy-service/spec.md) - Consumes secrets
- [ACME Cloudflare](acme-cloudflare/spec.md) - Uses Cloudflare token

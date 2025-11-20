# Spec: ACME Cloudflare Integration

## ADDED Requirements

### Requirement: ACME DNS-01 Challenge Configuration
**Type**: ADDED  
**Priority**: Critical  
**Component**: Caddyfile/global options

#### Scenario: Enable DNS-01 ACME with Cloudflare
```caddyfile
{
  # ACME configuration
  acme email admin@hbohlen.systems
  acme dns cloudflare {
    env.CLOUDFLARE_API_TOKEN
  }
}
```

**Rationale**: DNS-01 challenges work behind Tailscale without requiring external port 80 access.

**Validation**:
- ACME email is configured
- Cloudflare DNS provider is specified
- Token environment variable is referenced

### Requirement: Cloudflare API Token Integration
**Type**: ADDED  
**Priority**: Critical  
**Component**: systemd service

#### Scenario: Load Cloudflare Token via systemd
```nix
systemd.services.caddy.serviceConfig.LoadCredential = [
  "cloudflare-token:/run/secrets/cloudflare-token"
];
```

**Rationale**: Secure credential injection without exposing token in environment or configuration.

**Validation**:
- Credential file exists at /run/secrets/cloudflare-token
- Owned by caddy user with 0600 permissions
- Token has proper Cloudflare DNS permissions

### Requirement: Certificate Storage Configuration
**Type**: ADDED  
**Priority**: High  
**Component**: Caddyfile

#### Scenario: Persist ACME Certificates
```caddyfile
{
  # Certificates stored in data directory
  storage ${config.services.caddy.dataDir}
}
```

**Rationale**: Certificates and ACME account data must persist across reboots.

**Validation**:
- Storage directory exists
- Contains ACME account keys
- Contains issued certificates

### Requirement: Automatic Certificate Renewal
**Type**: ADDED  
**Priority**: High  
**Component**: Caddyfile

#### Scenario: Renew Certificates Before Expiry
```caddyfile
{
  # Default behavior: renew at 30 days before expiry
  # Caddy handles this automatically
}
```

**Rationale**: Prevent service disruption from expired certificates.

**Validation**:
- Certificates renew automatically
- Renewal process logs to journal
- Old certificates are replaced

## MODIFIED Requirements

### Requirement: HTTPS Port Configuration
**Type**: MODIFIED  
**Priority**: Critical  
**Component**: Caddyfile

#### Scenario: Enable HTTPS with Automatic Certs
```caddyfile
# HTTPS is automatic with ACME
https:// {
  # No explicit configuration needed
  # Certificates handled automatically
}
```

**Rationale**: Caddy automatically provisions HTTPS certificates via ACME.

**Validation**:
- Port 443 is enabled
- HTTPS works with valid certificates
- HTTP redirects to HTTPS

### Requirement: Contact Email Configuration
**Type**: MODIFIED  
**Priority**: Medium  
**Component**: Caddyfile/global options

#### Scenario: Set ACME Registration Email
```caddyfile
{
  acme email admin@hbohlen.systems
}
```

**Rationale**: Let's Encrypt requires contact email for certificate registration.

**Validation**:
- Email is valid format
- Email receives certificate notifications
- Email is registered with Let's Encrypt

## Domain-Specific Requirements

### Requirement: hbohlen.systems Certificate
**Type**: ADDED  
**Priority**: Critical  
**Component**: Virtual host configuration

#### Scenario: Certificate for Apex Domain
```caddyfile
hbohlen.systems {
  redir https://dashboard.hbohlen.systems permanent
}
```

**Rationale**: Main domain needs certificate for redirect functionality.

**Validation**:
- Certificate includes apex domain
- Redirect works with HTTPS
- No certificate warnings

### Requirement: dashboard.hbohlen.systems Certificate
**Type**: ADDED  
**Priority**: Critical  
**Component**: Virtual host configuration

#### Scenario: Certificate for Dashboard Subdomain
```caddyfile
dashboard.hbohlen.systems {
  reverse_proxy localhost:8080
}
```

**Rationale**: Dashboard requires valid certificate for HTTPS access.

**Validation**:
- Certificate includes subdomain
- Backend proxy works correctly
- HTTPS connection is secure

### Requirement: opencode.hbohlen.systems Certificate
**Type**: ADDED  
**Priority**: High  
**Component**: Virtual host configuration

#### Scenario: Certificate for OpenCode API
```caddyfile
opencode.hbohlen.systems {
  reverse_proxy localhost:4096
}
```

**Rationale**: API endpoint requires HTTPS for secure communication.

**Validation**:
- Certificate includes subdomain
- WebSocket proxy works if needed
- API calls succeed over HTTPS

### Requirement: falkordb.hbohlen.systems Certificate
**Type**: ADDED  
**Priority**: Medium  
**Component**: Virtual host configuration

#### Scenario: Certificate for FalkorDB UI
```caddyfile
falkordb.hbohlen.systems {
  reverse_proxy localhost:3000
}
```

**Rationale**: Database UI should use HTTPS.

**Validation**:
- Certificate includes subdomain
- Web interface accessible
- Connection is secure

### Requirement: observability.hbohlen.systems Certificate
**Type**: ADDED  
**Priority**: Medium  
**Component**: Virtual host configuration

#### Scenario: Certificate for Observability Endpoint
```caddyfile
observability.hbohlen.systems {
  reverse_proxy localhost:8126
}
```

**Rationale**: Monitoring endpoint needs HTTPS.

**Validation**:
- Certificate includes subdomain
- APM endpoint accessible
- Data transmission is secure

## Certificate Management

### Requirement: Let's Encrypt Production Environment
**Type**: ADDED  
**Priority**: High  
**Component**: Caddyfile

#### Scenario: Use Production ACME Server
```caddyfile
{
  # Default is Let's Encrypt production
  # No explicit configuration needed
  acmeCA https://acme-v02.api.letsencrypt.org/directory
}
```

**Rationale**: Production environment for real certificates.

**Validation**:
- Uses production ACME endpoint
- Certificates are publicly trusted
- Rate limits respected

### Requirement: Certificate Renewal Schedule
**Type**: ADDED  
**Priority**: Medium  
**Component**: Caddy configuration

#### Scenario: Renew at 30 Days Before Expiry
```caddyfile
{
  # Default renewal window: 30 days
  # Caddy checks and renews automatically
}
```

**Rationale**: Prevent expiry while allowing buffer for issues.

**Validation**:
- Renewal happens before expiry
- Process logs completion
- No manual intervention needed

## Security Requirements

### Requirement: OCSP Stapling
**Type**: ADDED  
**Priority**: Medium  
**Component**: Caddyfile

#### Scenario: Enable OCSP Stapling for Performance
```caddyfile
{
  # OCSP stapling enabled by default
  # Improves certificate validation performance
}
```

**Rationale**: OCSP stapling improves security and performance.

**Validation**:
- OCSP stapling is enabled
- Responses are cached
- Performance impact is minimal

### Requirement: HTTP Security Headers
**Type**: ADDED  
**Priority**: High  
**Component**: Virtual host configuration

#### Scenario: Add Security Headers
```caddyfile
dashboard.hbohlen.systems {
  header {
    Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    X-Content-Type-Options "nosniff"
    X-Frame-Options "DENY"
    Referrer-Policy "strict-origin-when-cross-origin"
  }
  reverse_proxy localhost:8080
}
```

**Rationale**: Security headers protect against common attacks.

**Validation**:
- Headers are present in responses
- Values match specification
- No sensitive information leaked

## Testing Requirements

### Certificate Validation Tests
```bash
# Check certificate details
echo | openssl s_client -connect dashboard.hbohlen.systems:443 2>/dev/null | openssl x509 -noout -text

# Check expiry date
echo | openssl s_client -connect hbohlen.systems:443 2>/dev/null | openssl x509 -noout -dates

# Check certificate chain
echo | openssl s_client -connect dashboard.hbohlen.systems:443 2>/dev/null | openssl s_client -showcerts
```

### ACME Challenge Tests
```bash
# Check ACME account registration
cat /var/lib/caddy/acme/acme-v02.api.letsencrypt.org/directory/*/account.json

# Check certificate storage
ls -la /var/lib/caddy/certificates/

# Check renewal logs
journalctl -u caddy | grep -i "certificate\|acme\|renew"
```

### Cloudflare DNS Tests
```bash
# Verify DNS records
dig dashboard.hbohlen.systems
dig TXT _acme-challenge.dashboard.hbohlen.systems

# Check API token permissions
curl -X GET "https://api.cloudflare.com/client/v4/zones" \
  -H "Authorization: Bearer $(cat /run/secrets/cloudflare-token)"
```

## Acceptance Criteria

- [ ] ACME DNS-01 challenge configured with Cloudflare
- [ ] Cloudflare API token loaded via systemd credential
- [ ] All 5 domains have valid certificates
- [ ] Certificates issued by Let's Encrypt
- [ ] Certificates auto-renew before expiry
- [ ] OCSP stapling enabled
- [ ] Security headers present on all responses
- [ ] No hardcoded credentials in configuration

## Failure Scenarios

### Scenario: Cloudflare API Token Invalid
- **Symptom**: Certificate provisioning fails
- **Diagnosis**: Check journalctl for ACME errors
- **Resolution**: Update token via OpNix, restart Caddy

### Scenario: DNS Propagation Delay
- **Symptom**: DNS-01 challenge fails
- **Diagnosis**: Check DNS records manually
- **Resolution**: Wait for propagation (up to 48 hours)

### Scenario: Rate Limit Exceeded
- **Symptom**: Too many certificate requests
- **Diagnosis**: Check Let's Encrypt rate limits
- **Resolution**: Wait 1 hour before retrying

### Scenario: Domain Validation Failure
- **Symptom**: Certificate request denied
- **Diagnosis**: Verify domain ownership
- **Resolution**: Check Cloudflare DNS settings

## Related Specs

- [Reverse Proxy Service](reverse-proxy-service/spec.md) - Uses ACME configuration
- [Tailscale Access Control](tailscale-access-control/spec.md) - Applies to virtual hosts
- [Secrets Integration](secrets-integration/spec.md) - Provides Cloudflare token

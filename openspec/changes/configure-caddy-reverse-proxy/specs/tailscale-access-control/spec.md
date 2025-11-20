# Spec: Tailscale Access Control

## ADDED Requirements

### Requirement: Tailscale IP Range Filtering
**Type**: ADDED  
**Priority**: Critical  
**Component**: Virtual host configuration

#### Scenario: Restrict Access to Tailscale Clients Only
```caddyfile
dashboard.hbohlen.systems {
  @tailscale {
    remote_ip 100.64.0.0/10
  }
  
  reverse_proxy @tailscale localhost:8080
  
  respond @tailscale "Access denied. Tailscale VPN required." 403 {
    close
  }
}
```

**Rationale**: All services should only be accessible from Tailscale VPN clients for security.

**Validation**:
- Tailscale clients can access service
- Non-Tailscale clients receive 403 Forbidden
- Access attempts are logged

### Requirement: Common IP Filter Directive
**Type**: ADDED  
**Priority**: High  
**Component**: Caddyfile

#### Scenario: Reusable Tailscale Filter
```caddyfile
# Define Tailscale subnet as variable
@tailscale {
  remote_ip 100.64.0.0/10
}

# Use in virtual hosts
dashboard.hbohlen.systems {
  reverse_proxy @tailscale localhost:8080
  respond !@tailscale "Tailscale VPN required" 403
}
```

**Rationale**: Centralize IP filter definition for consistency.

**Validation**:
- Filter works for all virtual hosts
- No duplication in configuration
- Easy to modify if IP range changes

## Domain-Specific Access Control

### Requirement: Dashboard Access Control
**Type**: ADDED  
**Priority**: Critical  
**Component**: dashboard.hbohlen.systems virtual host

#### Scenario: Dashboard Requires Tailscale
```caddyfile
dashboard.hbohlen.systems {
  # Tailscale access control
  @tailscale {
    remote_ip 100.64.0.0/10
  }
  
  # Security headers
  header {
    Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    X-Content-Type-Options "nosniff"
    X-Frame-Options "DENY"
    X-XSS-Protection "1; mode=block"
    Referrer-Policy "strict-origin-when-cross-origin"
    Content-Security-Policy "default-src 'self'"
  }
  
  # Proxy to backend with access control
  reverse_proxy @tailscale localhost:8080 {
    header_up Host {upstream_hostport}
    header_up X-Real-IP {remote}
    header_up X-Forwarded-For {remote}
    header_up X-Forwarded-Proto {scheme}
  }
  
  # Deny non-Tailscale access
  respond !@tailscale "Access denied. Tailscale VPN required." 403 {
    close
  }
  
  # Logging
  log {
    output file /var/log/caddy/dashboard.access.log
    format json
  }
}
```

**Rationale**: OpenCode dashboard contains sensitive data and must be VPN-only.

**Validation**:
- Tailscale access works from any VPN client
- Non-Tailscale receives clean 403 response
- Security headers present in all responses
- Backend receives correct headers

### Requirement: OpenCode API Access Control
**Type**: ADDED  
**Priority**: High  
**Component**: opencode.hbohlen.systems virtual host

#### Scenario: API Requires Tailscale with WebSocket Support
```caddyfile
opencode.hbohlen.systems {
  # Tailscale access control
  @tailscale {
    remote_ip 100.64.0.0/10
  }
  
  # Security headers (API-specific)
  header {
    Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    X-Content-Type-Options "nosniff"
    Referrer-Policy "strict-origin-when-cross-origin"
    Access-Control-Allow-Origin "https://dashboard.hbohlen.systems"
    Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Access-Control-Allow-Headers "Content-Type, Authorization"
  }
  
  # Proxy with WebSocket support
  reverse_proxy @tailscale localhost:4096 {
    header_up Host {upstream_hostport}
    header_up X-Real-IP {remote}
    header_up X-Forwarded-For {remote}
    header_up X-Forwarded-Proto {scheme}
    
    # WebSocket support
    transport http {
      keepalive 30s
    }
  }
  
  # CORS preflight for API
  @options {
    method OPTIONS
  }
  
  header @options {
    Access-Control-Allow-Origin "https://dashboard.hbohlen.systems"
    Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS"
    Access-Control-Allow-Headers "Content-Type, Authorization"
    Access-Control-Max-Age "86400"
  }
  
  respond @options 204
  
  # Deny non-Tailscale access
  respond !@tailscale "Access denied. Tailscale VPN required." 403
  
  # API logging
  log {
    output file /var/log/caddy/opencode.access.log
    format json
  }
}
```

**Rationale**: OpenCode API handles sensitive operations and needs WebSocket support for real-time features.

**Validation**:
- WebSocket connections work from Tailscale
- CORS headers correct for dashboard domain
- API calls succeed with authentication
- 403 response for unauthorized access

### Requirement: FalkorDB Access Control
**Type**: ADDED  
**Priority**: Medium  
**Component**: falkordb.hbohlen.systems virtual host

#### Scenario: Database UI Requires Tailscale
```caddyfile
falkordb.hbohlen.systems {
  # Tailscale access control
  @tailscale {
    remote_ip 100.64.0.0/10
  }
  
  # Database-specific security headers
  header {
    Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    X-Content-Type-Options "nosniff"
    X-Frame-Options "SAMEORIGIN"  # Allow embedding in dashboard
    Referrer-Policy "strict-origin-when-cross-origin"
    Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"
  }
  
  # Proxy to database
  reverse_proxy @tailscale localhost:3000 {
    header_up Host {upstream_hostport}
    header_up X-Real-IP {remote}
    header_up X-Forwarded-For {remote}
    header_up X-Forwarded-Proto {scheme}
  }
  
  # Deny non-Tailscale
  respond !@tailscale "Access denied. Tailscale VPN required." 403
  
  # Database logging
  log {
    output file /var/log/caddy/falkordb.access.log
    format json
  }
}
```

**Rationale**: Database management interface should be secure and VPN-only.

**Validation**:
- Web interface loads from Tailscale
- Database queries execute properly
- Non-Tailscale access blocked
- X-Frame-Options allows dashboard embedding

### Requirement: Observability Access Control
**Type**: ADDED  
**Priority**: Medium  
**Component**: observability.hbohlen.systems virtual host

#### Scenario: Monitoring Endpoint Requires Tailscale
```caddyfile
observability.hbohlen.systems {
  # Tailscale access control
  @tailscale {
    remote_ip 100.64.0.0/10
  }
  
  # Monitoring-specific security headers
  header {
    Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
    X-Content-Type-Options "nosniff"
    X-Frame-Options "DENY"  # No embedding for monitoring
    Referrer-Policy "strict-origin-when-cross-origin"
    Content-Security-Policy "default-src 'self'"
  }
  
  # Proxy to APM endpoint
  reverse_proxy @tailscale localhost:8126 {
    header_up Host {upstream_hostport}
    header_up X-Real-IP {remote}
    header_up X-Forwarded-For {remote}
    header_up X-Forwarded-Proto {scheme}
    
    # Timeout settings for monitoring
    timeout 60s
    retries 3
  }
  
  # Health check endpoint (could be public or restricted)
  @health {
    path /health
  }
  
  respond @health "OK" 200 {
    header Content-Type text/plain
  }
  
  # Deny non-Tailscale for non-health endpoints
  respond !@tailscale "Access denied. Tailscale VPN required." 403
  
  # Monitoring logging
  log {
    output file /var/log/caddy/observability.access.log
    format json
  }
}
```

**Rationale**: Monitoring endpoints should be accessible from VPN, with optional health check.

**Validation**:
- APM data accessible from Tailscale
- Health check works
- Non-Tailscale blocked for main endpoints
- Monitoring tools can connect

## Security Headers Configuration

### Requirement: HSTS Header
**Type**: ADDED  
**Priority**: High  
**Component**: All virtual hosts

#### Scenario: Enforce HTTPS with HSTS
```caddyfile
header {
  Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
}
```

**Rationale**: Prevents protocol downgrade attacks and cookie hijacking.

**Validation**:
- HSTS header present in responses
- max-age is 1 year or more
- includeSubDomains and preload flags set

### Requirement: X-Content-Type-Options Header
**Type**: ADDED  
**Priority**: High  
**Component**: All virtual hosts

#### Scenario: Prevent MIME Sniffing
```caddyfile
header {
  X-Content-Type-Options "nosniff"
}
```

**Rationale**: Prevents browsers from interpreting files as different content types.

**Validation**:
- Header present in all responses
- Value is "nosniff"
- Applied consistently

### Requirement: X-Frame-Options Header
**Type**: ADDED  
**Priority**: High  
**Component**: All virtual hosts

#### Scenario: Prevent Clickjacking
```caddyfile
# For most services
header {
  X-Frame-Options "DENY"
}

# For FalkorDB (can be embedded)
header {
  X-Frame-Options "SAMEORIGIN"
}
```

**Rationale**: Prevents clickjacking attacks by controlling iframe embedding.

**Validation**:
- Header present in all responses
- Correct value per service
- Prevents unauthorized embedding

### Requirement: Referrer-Policy Header
**Type**: ADDED  
**Priority**: Medium  
**Component**: All virtual hosts

#### Scenario: Control Referrer Information
```caddyfile
header {
  Referrer-Policy "strict-origin-when-cross-origin"
}
```

**Rationale**: Protects user privacy by controlling referrer information.

**Validation**:
- Header present in all responses
- Value is "strict-origin-when-cross-origin"
- Consistent across services

### Requirement: Content-Security-Policy Header
**Type**: ADDED  
**Priority**: Medium  
**Component**: All virtual hosts

#### Scenario: Prevent XSS Attacks
```caddyfile
# Basic CSP
header {
  Content-Security-Policy "default-src 'self'"
}

# For dashboard (may need more permissions)
header {
  Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'"
}
```

**Rationale**: Prevents XSS by controlling resource loading.

**Validation**:
- CSP header present in responses
- Policy is appropriate for service
- Prevents inline script execution where possible

## Access Logging

### Requirement: Access Log Configuration
**Type**: ADDED  
**Priority**: Medium  
**Component**: All virtual hosts

#### Scenario: Log All Access Attempts
```caddyfile
log {
  output file /var/log/caddy/dashboard.access.log {
    roll_size 100mb
    roll_keep 5
  }
  format json
  level DEBUG
}
```

**Rationale**: Track access patterns for security auditing.

**Validation**:
- Log files created for each service
- JSON format for structured logging
- Log rotation configured
- Access attempts logged

### Requirement: Failed Access Logging
**Type**: ADDED  
**Priority**: High  
**Component**: Access denied responses

#### Scenario: Log Denied Access Attempts
```caddyfile
respond !@tailscale "Access denied. Tailscale VPN required." 403 {
  close
  log {
    level WARN
    message "Access denied from {remote} to {request.uri.path}"
  }
}
```

**Rationale**: Security monitoring for unauthorized access attempts.

**Validation**:
- Denied attempts logged with warning level
- Source IP recorded
- Requested path logged
- Appears in journalctl

## Testing Requirements

### Tailscale Access Tests
```bash
# From Tailscale client
curl -v https://dashboard.hbohlen.systems
# Should return 200 OK

# From non-Tailscale network
curl -v https://dashboard.hbohlen.systems
# Should return 403 Forbidden
```

### Security Header Tests
```bash
curl -I https://dashboard.hbohlen.systems | grep -i \
  "strict-transport\|x-frame\|x-content\|referrer"
```

### Log Validation
```bash
# Check access logs
tail -f /var/log/caddy/dashboard.access.log

# Check denied access
journalctl -u caddy | grep "Access denied"
```

## Acceptance Criteria

- [ ] All virtual hosts restricted to Tailscale IPs (100.64.0.0/10)
- [ ] Non-Tailscale clients receive 403 Forbidden
- [ ] Tailscale clients can access all services
- [ ] HSTS header present with 1-year expiry
- [ ] X-Content-Type-Options: nosniff on all responses
- [ ] X-Frame-Options configured per service
- [ ] Referrer-Policy: strict-origin-when-cross-origin
- [ ] CSP headers appropriate for each service
- [ ] Access attempts logged
- [ ] Denied access logged with warning level

## Edge Cases

### Scenario: Tailscale Subnet Changes
- **Issue**: 100.64.0.0/10 subnet might change
- **Mitigation**: Document in config, easy to update
- **Response**: Update filter, restart Caddy

### Scenario: Device Connected to Multiple Networks
- **Issue**: Device has both public IP and Tailscale IP
- **Resolution**: Caddy checks source IP of connection
- **Behavior**: Connection from Tailscale IP allowed

### Scenario: Tailscale Disconnect During Session
- **Issue**: VPN drops mid-connection
- **Resolution**: Connection continues until next request
- **Behavior**: New requests require active Tailscale

### Scenario: DNS Resolution from Non-Tailscale
- **Issue**: Domain resolves but access denied
- **Resolution**: Normal behavior, access check happens at connection
- **Response**: User sees 403 Forbidden

## Related Specs

- [Reverse Proxy Service](reverse-proxy-service/spec.md) - Implements virtual hosts
- [ACME Cloudflare](acme-cloudflare/spec.md) - Certificates for domains

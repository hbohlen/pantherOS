# Design: Caddy Reverse Proxy Configuration

## Architecture Overview

The Caddy reverse proxy layer sits between external clients and internal services, providing:
- Automatic HTTPS via Cloudflare DNS-01 ACME
- Access control via Tailscale IP filtering
- Centralized service routing
- Security header injection

## Component Design

### Reverse Proxy Service
**Technology**: Caddy 2.x with Cloudflare DNS plugin
**Rationale**: Built-in ACME support, automatic HTTPS, simple configuration

**Key Features**:
- DNS-01 challenges work behind Tailscale (no port 80 required)
- Automatic certificate renewal
- JSON-based configuration with Caddyfile support
- Admin API for runtime management

### ACME Cloudflare Integration
**Challenge Type**: DNS-01 (via Cloudflare API)
**Rationale**: Works behind NAT/firewall, no external port exposure

**Authentication**:
- Cloudflare API token with DNS:Zone:DNS:Edit permissions
- Stored via OpNix in 1Password service account
- Injected via systemd LoadCredential

**Certificate Management**:
- Let's Encrypt production endpoint
- RSA-2048 or ECDSA-P256 certificates
- Stored in /var/lib/caddy with proper permissions
- Auto-renewal 30 days before expiry

### Access Control Layer
**Method**: IP-based filtering using Tailscale subnet range
**Range**: 100.64.0.0/10 (CGNAT reserved for Tailscale)

**Implementation**:
- Caddy IP filter directives
- Per-vhost access rules
- 403 Forbidden response for unauthorized clients
- Logging of access attempts

### Virtual Host Routing

#### Domain Structure
```
hbohlen.systems (apex)
├── dashboard.hbohlen.systems
├── opencode.hbohlen.systems
├── falkordb.hbohlen.systems
└── observability.hbohlen.systems
```

#### Backend Mapping
- `dashboard.hbohlen.systems` → localhost:8080
- `opencode.hbohlen.systems` → localhost:4096
- `falkordb.hbohlen.systems` → localhost:3000
- `observability.hbohlen.systems` → localhost:8126

### Security Headers
**Per-Vhost Headers**:
- `Strict-Transport-Security: max-age=31536000; includeSubDomains; preload`
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Content-Security-Policy` (service-specific)

### Secrets Integration
**Storage**: 1Password service account via OpNix
**Item**: Cloudflare API token
**Path**: `op:pantherOS/Infrastructure Secrets/DNS/cloudflare-token`
**Injection**: systemd EnvironmentFile or LoadCredential

## Configuration Structure

### File Organization
```
hosts/hetzner-vps/
├── default.nix       # Main config imports caddy.nix
├── caddy.nix         # Caddy module configuration
├── hardware.nix      # Hardware detection
└── disko.nix         # Disk layout (future)
```

### Module Design
**Module**: `services.caddy.enable`
**Options**:
- `enable`: Boolean to enable/disable
- `package`: Caddy with plugins
- `config`: Caddyfile content
- `dataDir`: Certificate and state directory
- `cloudflareToken`: Secret reference via OpNix

### Flake Integration
**Package**: Caddy with Cloudflare plugin via `withPlugins`
**Inputs**:
- `pkgs.caddy`
- `pkgs.caddy-cloudflare` (plugin derivation)

## Security Model

### Threat Model
**External Threats**:
- DDoS attempts → Cloudflare handles
- Certificate attacks → DNS-01 validation
- Man-in-the-middle → HSTS enforcement

**Internal Threats**:
- Unauthorized service access → Tailscale IP filtering
- Credential exposure → OpNix + systemd credentials
- Service enumeration → Minimal headers, error pages

### Mitigation Strategies
1. **Zero Public Exposure**: All services localhost-only
2. **VPN-Only Access**: Tailscale IP requirement
3. **Automatic HTTPS**: No manual certificate management
4. **Defense in Depth**: Multiple security layers

## Data Flow

### Request Flow
```
Client → Cloudflare → Caddy → Backend Service
           ↓           ↓         ↓
        Proxy CDN  TLS/Auth  localhost
```

### Certificate Flow
```
Caddy → Cloudflare API → DNS-01 Challenge → Let's Encrypt
   ↓              ↓              ↓              ↓
Renewal Check   Token Auth   TXT Record   Certificate
```

### Access Control Flow
```
Client Request → Tailscale IP Check → Allow/Deny Decision
      ↓                    ↓                  ↓
   Source IP          100.64.0.0/10    Forward/403
```

## Performance Considerations

### Resource Usage
- **Memory**: ~50-100MB for Caddy process
- **CPU**: Minimal for reverse proxy operations
- **Disk**: Certificates stored in /var/lib/caddy (~10MB)

### Optimization
- Connection keep-alive to backends
- HTTP/2 support
- Automatic compression (gzip/brotli)
- Graceful shutdown for zero downtime

## Monitoring and Observability

### Health Checks
- Caddy process status (systemd)
- Certificate expiry monitoring
- Backend service health
- DNS resolution verification

### Logging
- Access logs: `/var/log/caddy/access.log`
- Error logs: `/var/log/caddy/error.log`
- systemd journal integration
- Log rotation via newsyslog

## Backup and Recovery

### Certificate Backup
- **Directory**: `/var/lib/caddy`
- **Contents**: ACME account keys, certificates, OCSP stapling
- **Backup Strategy**: Included in system backups
- **Recovery**: Restore directory, restart Caddy

### Configuration Backup
- NixOS configuration in Git
- Caddyfile embedded in Nix module
- Secrets via 1Password (versioned)

## Deployment Strategy

### Rollout Phases
1. **Phase 1**: Install Caddy without virtual hosts
2. **Phase 2**: Configure ACME with test certificates
3. **Phase 3**: Add virtual hosts with Tailscale access
4. **Phase 4**: Add security headers and finalize

### Testing Approach
1. **Build Test**: `nixos-rebuild build .#hetzner-vps`
2. **Dry Run**: `nixos-rebuild dry-activate .#hetzner-vps`
3. **Certificate Test**: Verify with Let's Encrypt staging
4. **Access Test**: Validate Tailscale filtering
5. **Production Deploy**: Switch to live certificates

## Integration Points

### With Tailscale
- ACLs to allow Caddy ports (80, 443, 2019)
- MagicDNS for service discovery
- Exit node configuration if needed

### With Cloudflare
- DNS A records for all subdomains
- Proxy enabled for public-facing services
- SSL/TLS mode: Full (strict)
- Minimum TLS version: 1.3

### With OpNix
- Secret retrieval from 1Password
- Automatic credential injection
- Secret rotation support

### With Backend Services
- Localhost-only backends
- Health check endpoints
- Graceful degradation

## Future Enhancements

### Potential Additions
- Load balancing across multiple backends
- Custom error pages
- Rate limiting per client
- Prometheus metrics export
- Wildcard certificate support

### Scalability Considerations
- Horizontal scaling via upstream load balancers
- Session affinity for stateful services
- Cache layer integration (Redis, etc.)

## Validation Criteria

### Functional Tests
- [ ] All domains resolve to correct backends
- [ ] HTTPS works with valid certificates
- [ ] Tailscale clients can access all services
- [ ] Non-Tailscale clients receive 403
- [ ] Certificate renewal works automatically

### Security Tests
- [ ] Admin endpoint only on localhost
- [ ] Security headers present on all responses
- [ ] No sensitive data in logs
- [ ] Cloudflare token properly secured
- [ ] Failed access attempts logged

### Performance Tests
- [ ] <100ms latency overhead
- [ ] Certificate retrieval <30s
- [ ] Zero downtime during renewals
- [ ] Memory usage <200MB
- [ ] CPU usage <5% under normal load

## Related Design Decisions

### Why DNS-01 over HTTP-01?
- Works behind NAT/firewall
- No port 80 exposure required
- Better security posture
- Cloudflare provides reliable API

### Why Tailscale IP filtering?
- Zero-trust security model
- Simple to implement and maintain
- Works with existing Tailscale setup
- No additional authentication layer needed

### Why Caddy over Nginx/Traefik?
- Built-in ACME support
- Automatic HTTPS
- Simple configuration syntax
- Good NixOS integration

---

**Design Status**: Draft  
**Review Required**: Yes  
**Implementation Ready**: Pending approval

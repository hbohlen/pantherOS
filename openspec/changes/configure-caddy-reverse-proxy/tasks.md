# Tasks: Caddy Reverse Proxy Implementation

## Phase 1: Foundation Setup

### Task 1.1: Configure Flake with Caddy Package
**Estimate**: 1 hour  
**Prerequisites**: None  
**Description**: Update flake.nix to include Caddy with Cloudflare DNS plugin

**Work Items**:
- [ ] Research Caddy plugin packaging in nixpkgs
- [ ] Add caddy to nixpkgs overlays or custom package derivation
- [ ] Verify Cloudflare plugin is available
- [ ] Test package builds successfully
- [ ] Document package selection rationale

**Deliverables**:
- Updated `flake.nix` with Caddy package
- Package build verification
- Documentation of plugin integration

**Validation**:
```bash
nix build .#caddy
nix eval .#caddy.version
```

### Task 1.2: Create Caddy Module Structure
**Estimate**: 2 hours  
**Prerequisites**: Task 1.1 complete  
**Description**: Create the main Caddy NixOS module with options and basic configuration

**Work Items**:
- [ ] Create `hosts/hetzner-vps/caddy.nix`
- [ ] Define module options (enable, config, dataDir, etc.)
- [ ] Implement systemd service configuration
- [ ] Set up file permissions for data directory
- [ ] Add basic health check endpoint

**Deliverables**:
- Caddy module file at `hosts/hetzner-vps/caddy.nix`
- Module options documentation
- Systemd service configuration

**Validation**:
```bash
nixos-rebuild build .#hetzner-vps --dry-run
```

## Phase 2: ACME Configuration

### Task 2.1: Integrate OpNix for Cloudflare Token
**Estimate**: 2 hours  
**Prerequisites**: Task 1.2 complete  
**Description**: Set up OpNix integration for Cloudflare API token retrieval

**Work Items**:
- [ ] Research existing OpNix integration patterns
- [ ] Create Cloudflare token secret reference
- [ ] Configure systemd LoadCredential for token
- [ ] Test secret retrieval and injection
- [ ] Verify token permissions in Cloudflare

**Deliverables**:
- OpNix secret configuration
- Systemd credential setup
- Token retrieval test results

**Validation**:
```bash
op nix list-items pantherOS
cat /run/secrets/cloudflare-token
```

### Task 2.2: Configure ACME DNS-01 Challenge
**Estimate**: 2 hours  
**Prerequisites**: Task 2.1 complete  
**Description**: Set up Caddy ACME configuration with Cloudflare DNS provider

**Work Items**:
- [ ] Create Caddyfile for ACME configuration
- [ ] Configure Cloudflare DNS provider settings
- [ ] Set up certificate storage directory
- [ ] Configure email for Let's Encrypt notifications
- [ ] Test certificate provisioning (staging first)

**Deliverables**:
- ACME-enabled Caddyfile
- Certificate directory configuration
- Cloudflare DNS integration

**Validation**:
```bash
nixos-rebuild switch .#hetzner-vps
curl -k https://dashboard.hbohlen.systems
journalctl -u caddy -f
```

## Phase 3: Virtual Host Configuration

### Task 3.1: Implement Apex Domain Redirect
**Estimate**: 1 hour  
**Prerequisites**: Task 2.2 complete  
**Description**: Configure hbohlen.systems to redirect to dashboard subdomain

**Work Items**:
- [ ] Add apex domain virtual host
- [ ] Configure permanent redirect to dashboard.hbohlen.systems
- [ ] Test redirect functionality
- [ ] Verify proper HTTP status code (301/308)

**Deliverables**:
- Apex domain redirect configuration
- Redirect test results

**Validation**:
```bash
curl -I https://hbohlen.systems
curl -L https://hbohlen.systems
```

### Task 3.2: Configure Dashboard Virtual Host
**Estimate**: 2 hours  
**Prerequisites**: Task 3.1 complete  
**Description**: Set up dashboard.hbohlen.systems with Tailscale access control

**Work Items**:
- [ ] Create dashboard virtual host configuration
- [ ] Set backend proxy to localhost:8080
- [ ] Implement Tailscale IP filtering (100.64.0.0/10)
- [ ] Add security headers (HSTS, X-Frame-Options, etc.)
- [ ] Configure 403 error page for non-Tailscale access

**Deliverables**:
- Dashboard virtual host configuration
- Tailscale access control implementation
- Security headers configuration

**Validation**:
```bash
# From Tailscale client
curl -I https://dashboard.hbohlen.systems

# From non-Tailscale network
curl -I https://dashboard.hbohlen.systems
# Should return 403 Forbidden
```

### Task 3.3: Configure OpenCode API Virtual Host
**Estimate**: 1 hour  
**Prerequisites**: Task 3.2 complete  
**Description**: Set up opencode.hbohlen.systems with Tailscale access control

**Work Items**:
- [ ] Create OpenCode API virtual host
- [ ] Set backend proxy to localhost:4096
- [ ] Apply Tailscale IP filtering
- [ ] Configure WebSocket support if needed
- [ ] Add appropriate security headers

**Deliverables**:
- OpenCode API virtual host configuration
- WebSocket proxy setup

**Validation**:
```bash
curl -I https://opencode.hbohlen.systems/status
```

### Task 3.4: Configure FalkorDB Virtual Host
**Estimate**: 1 hour  
**Prerequisites**: Task 3.3 complete  
**Description**: Set up falkordb.hbohlen.systems with Tailscale access control

**Work Items**:
- [ ] Create FalkorDB virtual host
- [ ] Set backend proxy to localhost:3000
- [ ] Apply Tailscale IP filtering
- [ ] Configure database-specific headers
- [ ] Add CORS headers if needed

**Deliverables**:
- FalkorDB virtual host configuration
- Database-specific proxy settings

**Validation**:
```bash
curl -I https://falkordb.hbohlen.systems
```

### Task 3.5: Configure Observability Virtual Host
**Estimate**: 1 hour  
**Prerequisites**: Task 3.4 complete  
**Description**: Set up observability.hbohlen.systems with Tailscale access control

**Work Items**:
- [ ] Create observability virtual host
- [ ] Set backend proxy to localhost:8126
- [ ] Apply Tailscale IP filtering
- [ ] Configure APM-specific headers
- [ ] Add health check endpoint

**Deliverables**:
- Observability virtual host configuration
- APM proxy setup

**Validation**:
```bash
curl -I https://observability.hbohlen.systems/health
```

## Phase 4: Security and Hardening

### Task 4.1: Implement Comprehensive Security Headers
**Estimate**: 2 hours  
**Prerequisites**: Task 3.5 complete  
**Description**: Add all security headers across all virtual hosts

**Work Items**:
- [ ] Add HSTS headers (1 year, includeSubDomains, preload)
- [ ] Add X-Content-Type-Options: nosniff
- [ ] Add X-Frame-Options: DENY
- [ ] Add Referrer-Policy: strict-origin-when-cross-origin
- [ ] Add CSP headers (service-specific)
- [ ] Add Permissions-Policy headers

**Deliverables**:
- Comprehensive security header configuration
- Security headers validation

**Validation**:
```bash
curl -I https://dashboard.hbohlen.systems | grep -i "strict-transport\|x-frame\|x-content"
```

### Task 4.2: Lock Down Admin Endpoint
**Estimate**: 1 hour  
**Prerequisites**: Task 4.1 complete  
**Description**: Ensure Caddy admin API is only accessible on localhost

**Work Items**:
- [ ] Configure admin endpoint on 127.0.0.1:2019 only
- [ ] Disable admin on all network interfaces
- [ ] Test admin endpoint accessibility
- [ ] Document admin API usage

**Deliverables**:
- Admin endpoint configuration
- Security test results

**Validation**:
```bash
curl http://127.0.0.1:2019/config
# Should work from localhost

curl http://hetzner-vps:2019/config
# Should fail from network
```

### Task 4.3: Enable Debug Mode for Development
**Estimate**: 30 minutes  
**Prerequisites**: Task 4.2 complete  
**Description**: Configure Caddy debug mode for enhanced logging and diagnostics

**Work Items**:
- [ ] Enable debug mode in Caddy configuration
- [ ] Configure detailed access logging
- [ ] Set up log rotation
- [ ] Configure log levels for production

**Deliverables**:
- Debug mode configuration
- Logging configuration

**Validation**:
```bash
tail -f /var/log/caddy/error.log
journalctl -u caddy -f
```

## Phase 5: Cloudflare DNS Setup

### Task 5.1: Configure Cloudflare DNS Records
**Estimate**: 1 hour  
**Prerequisites**: Task 4.3 complete  
**Description**: Set up DNS records in Cloudflare for all subdomains

**Work Items**:
- [ ] Create A records for all subdomains pointing to Hetzner IP
- [ ] Enable Cloudflare proxy (orange cloud) for dashboard
- [ ] Disable proxy for internal services (opencode, falkordb, observability)
- [ ] Configure SSL/TLS mode: Full (strict)
- [ ] Set minimum TLS version: 1.3

**Deliverables**:
- Cloudflare DNS configuration
- SSL/TLS settings
- DNS propagation verification

**Validation**:
```bash
dig dashboard.hbohlen.systems
dig +short hbohlen.systems
nslookup opencode.hbohlen.systems
```

### Task 5.2: Test Certificate Provisioning
**Estimate**: 2 hours  
**Prerequisites**: Task 5.1 complete  
**Description**: Verify certificates are automatically provisioned for all domains

**Work Items**:
- [ ] Check certificate status for all domains
- [ ] Verify certificate chain is valid
- [ ] Test certificate renewal process
- [ ] Validate OCSP stapling
- [ ] Check certificate expiry dates

**Deliverables**:
- Certificate status report
- SSL/TLS validation results

**Validation**:
```bash
openssl s_client -connect dashboard.hbohlen.systems:443 -servername dashboard.hbohlen.systems
echo | openssl s_client -connect hbohlen.systems:443 2>/dev/null | openssl x509 -noout -dates
```

## Phase 6: Testing and Validation

### Task 6.1: Comprehensive Build Testing
**Estimate**: 1 hour  
**Prerequisites**: All previous tasks complete  
**Description**: Run full build and test suite for Caddy configuration

**Work Items**:
- [ ] Run nixos-rebuild build for hetzner-vps
- [ ] Test dry-activate to verify changes
- [ ] Check all imports resolve correctly
- [ ] Validate Caddyfile syntax
- [ ] Test service startup

**Deliverables**:
- Build test results
- Dry-run activation results

**Validation**:
```bash
nixos-rebuild build .#hetzner-vps
nixos-rebuild dry-activate .#hetzner-vps
```

### Task 6.2: Tailscale Access Control Testing
**Estimate**: 2 hours  
**Prerequisites**: Task 6.1 complete  
**Description**: Test all virtual hosts with and without Tailscale access

**Work Items**:
- [ ] Test access from Tailscale clients
- [ ] Test access from non-Tailscale networks
- [ ] Verify 403 Forbidden for unauthorized access
- [ ] Check access logs for filtering
- [ ] Test from different Tailscale devices

**Deliverables**:
- Access control test results
- Security validation report

**Validation**:
```bash
# From Tailscale device
curl -v https://dashboard.hbohlen.systems

# From non-Tailscale network (should fail)
curl -v https://dashboard.hbohlen.systems
```

### Task 6.3: Certificate Auto-Renewal Testing
**Estimate**: 3 hours (includes waiting)  
**Prerequisites**: Task 6.2 complete  
**Description**: Verify automatic certificate renewal process

**Work Items**:
- [ ] Check current certificate expiry
- [ ] Verify renewal scheduling
- [ ] Test forced renewal
- [ ] Monitor renewal logs
- [ ] Validate new certificate deployment

**Deliverables**:
- Certificate renewal test results
- Auto-renewal documentation

**Validation**:
```bash
journalctl -u caddy | grep -i "certificate\|acme\|renew"
ls -la /var/lib/caddy/certificates/
```

### Task 6.4: Integration Testing with Backend Services
**Estimate**: 2 hours  
**Prerequisites**: Task 6.3 complete  
**Description**: Test reverse proxy with actual backend services (when available)

**Work Items**:
- [ ] Test proxy to OpenCode dashboard (localhost:8080)
- [ ] Test proxy to OpenCode API (localhost:4096)
- [ ] Test proxy to FalkorDB (localhost:3000)
- [ ] Test proxy to Datadog APM (localhost:8126)
- [ ] Verify health checks for all backends

**Deliverables**:
- Backend integration test results
- Service proxy validation

**Validation**:
```bash
curl http://localhost:8080/health
curl http://localhost:4096/status
# etc.
```

## Phase 7: Documentation and Cleanup

### Task 7.1: Create Documentation
**Estimate**: 2 hours  
**Prerequisites**: All testing complete  
**Description**: Write comprehensive documentation for Caddy configuration

**Work Items**:
- [ ] Document configuration structure
- [ ] Explain Tailscale access control
- [ ] Document certificate management
- [ ] Create troubleshooting guide
- [ ] Document Cloudflare setup process
- [ ] Add maintenance procedures

**Deliverables**:
- Complete documentation
- Troubleshooting guide

**Validation**:
- Documentation review
- Peer review of configuration

### Task 7.2: Final Validation and Sign-off
**Estimate**: 1 hour  
**Prerequisites**: Task 7.1 complete  
**Description**: Final validation and approval

**Work Items**:
- [ ] Review all acceptance criteria
- [ ] Verify all success criteria met
- [ ] Run final build test
- [ ] Check documentation completeness
- [ ] Get security review approval

**Deliverables**:
- Final validation report
- Change sign-off

**Validation**:
```bash
# Final build test
nixos-rebuild build .#hetzner-vps

# Certificate check
echo | openssl s_client -connect dashboard.hbohlen.systems:443 2>/dev/null | openssl x509 -noout -text | grep -A2 "Subject:"
```

## Timeline Summary

- **Phase 1**: 3 hours (Foundation)
- **Phase 2**: 4 hours (ACME)
- **Phase 3**: 6 hours (Virtual Hosts)
- **Phase 4**: 3.5 hours (Security)
- **Phase 5**: 3 hours (DNS)
- **Phase 6**: 8 hours (Testing)
- **Phase 7**: 3 hours (Documentation)

**Total Estimated Effort**: 30.5 hours (4 days at 8 hours/day)

## Dependencies

### External Dependencies
- Cloudflare API access
- Domain hbohlen.systems ownership
- Tailscale tailnet access
- Let's Encrypt production environment

### Internal Dependencies
- Base NixOS configuration
- OpNix integration
- Firewall module
- Tailscale networking

## Critical Path Items

1. **Task 1.1** - Flake configuration (blocks all other tasks)
2. **Task 2.1** - OpNix integration (blocks ACME setup)
3. **Task 2.2** - ACME configuration (blocks certificate testing)
4. **Task 5.1** - DNS setup (blocks certificate provisioning)
5. **Task 6.2** - Access control testing (blocks production deployment)

## Risk Mitigation

### High-Risk Items
- **Certificate provisioning**: Use Let's Encrypt staging first
- **DNS propagation**: Allow 24-48 hours for full propagation
- **Tailscale access**: Verify network before firewall lockdown

### Contingency Plans
- Staging environment for testing
- Manual certificate renewal process
- Rollback procedure via NixOS generations
- Emergency access via Hetzner console

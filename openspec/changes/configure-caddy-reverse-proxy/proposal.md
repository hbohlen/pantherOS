# Change Proposal: Configure Caddy Reverse Proxy with Cloudflare DNS-01 ACME and Tailscale Access Control

## Summary

Deploy Caddy as a reverse proxy for the hbohlen.systems domain with Cloudflare DNS-01 ACME challenge support and Tailscale-based access control. This configuration will enable HTTPS certificate automation, protect internal services behind Tailscale VPN, and provide secure reverse proxy capabilities for the pantherOS infrastructure.

## Why

This change is essential for establishing a secure, production-ready reverse proxy layer for the pantherOS project. The current infrastructure lacks proper HTTPS management and centralized access control for internal services.

**Security**: DNS-01 ACME challenges work behind Tailscale without requiring external port 80 access, eliminating a common security risk.

**Automation**: Automatic HTTPS certificate provisioning and renewal without manual intervention or port exposure.

**Access Control**: All services restricted to Tailscale VPN clients (100.64.0.0/10) with granular per-service controls.

**Simplicity**: Single configuration point for all reverse proxy needs with declarative management.

## Context

### Infrastructure Details
- **Target**: hetzner-vps (Hetzner Cloud CPX52)
- **Domain**: hbohlen.systems
- **Tailscale**: Primary network layer (100.64.0.0/10)
- **Backend Services**: 
  - OpenCode dashboard (localhost:8080)
  - OpenCode API (localhost:4096)
  - FalkorDB web UI (localhost:3000)
  - Datadog APM (localhost:8126)

### Current State
- Base NixOS configuration exists for hetzner-vps
- Tailscale networking is configured
- Backend services are planned but not yet implemented
- No reverse proxy infrastructure exists

### Problem Statement
The infrastructure needs a reverse proxy that can:
- Automatically provision and renew HTTPS certificates via Cloudflare DNS
- Restrict access to internal services via Tailscale only
- Provide clean URLs for all backend services
- Maintain security while enabling remote access

## Solution Overview

### Architectural Approach
1. **Caddy with Cloudflare Plugin**: DNS-01 ACME challenges for automatic HTTPS
2. **Tailscale-Only Access**: All services restricted to VPN clients
3. **Declarative Configuration**: Full NixOS integration with flakes
4. **Minimal Attack Surface**: No public port exposure for internal services

### Key Components

#### Reverse Proxy Service
- Caddy 2.x with Cloudflare DNS plugin
- Admin API on localhost:2019 only
- Debug mode enabled for development
- File-based configuration with Caddyfile format

#### ACME Configuration
- DNS-01 challenge via Cloudflare
- Automatic certificate provisioning
- Certificate persistence in /var/lib/caddy
- Contact email: admin@hbohlen.systems

#### Virtual Hosts
- hbohlen.systems → Permanent redirect to dashboard
- dashboard.hbohlen.systems → localhost:8080 (OpenCode dashboard)
- opencode.hbohlen.systems → localhost:4096 (OpenCode API)
- falkordb.hbohlen.systems → localhost:3000 (FalkorDB UI)
- observability.hbohlen.systems → localhost:8126 (Datadog APM)

#### Access Control
- Tailscale IP filtering (100.64.0.0/10)
- Per-vhost security headers
- 403 Forbidden for non-Tailscale access

#### Secrets Management
- Cloudflare API token via OpNix
- systemd LoadCredential integration
- Secure credential injection

## Success Criteria

### Functional Requirements
- [ ] Caddy service starts and runs without errors
- [ ] HTTPS certificates automatically provisioned for all domains
- [ ] All virtual hosts redirect/serve correctly
- [ ] Tailscale IP filtering blocks non-VPN access
- [ ] Services accessible from Tailscale clients only
- [ ] Certificates auto-renew before expiry

### Technical Requirements
- [ ] Configuration builds successfully
- [ ] Caddyfile syntax is valid
- [ ] Cloudflare DNS plugin works correctly
- [ ] systemd service configuration is proper
- [ ] Persistence directory created and owned correctly

### Security Requirements
- [ ] Admin endpoint only on localhost
- [ ] No public access to internal services
- [ ] Security headers applied per service
- [ ] Cloudflare token secured via OpNix
- [ ] Firewall rules respect Tailscale-only access

## Deliverables

### Configuration Files
1. `hosts/hetzner-vps/caddy.nix` - Main Caddy configuration module
2. Updated `hosts/hetzner-vps/default.nix` - Import caddy module
3. Updated `flake.nix` - Add caddy with Cloudflare plugin

### Documentation
- Configuration documentation
- Cloudflare DNS setup guide
- Access control explanation
- Troubleshooting guide

### Validation
- Build verification
- Service testing
- Certificate validation
- Security testing

## Risks and Mitigations

### High Risk
- **Certificate Provisioning Failure**: Validate Cloudflare API token and DNS propagation
- **Lockout from Services**: Ensure Tailscale access before firewall lockdown

### Medium Risk
- **Plugin Compatibility**: Test caddy version with Cloudflare plugin
- **DNS Configuration**: Verify Cloudflare settings before deployment

### Low Risk
- **Performance Impact**: Minimal overhead from reverse proxy layer
- **Maintenance**: Automated renewal reduces manual intervention

## Timeline

This change should be implemented after the base NixOS configuration is complete and before backend services are deployed. Estimated effort: 1 day for implementation and testing.

## Dependencies

### External Services
- Cloudflare account with API token
- Domain hbohlen.systems configured in Cloudflare
- Tailscale tailnet access

### Internal Components
- Base NixOS configuration for hetzner-vps
- OpNix integration for secrets
- Firewall module configuration
- Tailscale networking setup

## Approval Requirements

- [ ] Security review of access control implementation
- [ ] Network review of Tailscale filtering
- [ ] Build test successful
- [ ] Certificate provisioning validated
- [ ] Documentation complete and reviewed
- [ ] Change ID assigned and proposal accepted

## References

- [Caddy Documentation](https://caddyserver.com/docs/)
- [Caddy Cloudflare Plugin](https://github.com/caddy-dns/cloudflare)
- [ACME DNS-01 Challenge](https://letsencrypt.org/docs/challenge-types/)
- [Cloudflare DNS API](https://developers.cloudflare.com/dns/)
- [Tailscale ACLs](https://tailscale.com/kb/1017/acls/)

---

**Change ID**: configure-caddy-reverse-proxy  
**Status**: Proposal  
**Author**: hbohlen  
**Date**: 2025-11-20

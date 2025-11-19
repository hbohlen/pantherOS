# Phase 3: Host Configuration Tasks

**Phase 3 Goal:** Configure each host with specific optimizations and requirements

## Yoga (Lenovo Yoga 7 2-in-1 14AKP10)

**Purpose:** Lightweight programming and web browsing, battery life prioritized

**Tasks:**
- [ ] Hardware configuration (CPU, GPU, RAM, disk)
- [ ] Power management optimization
- [ ] Battery life optimization
- [ ] Lightweight application profile
- [ ] Testing and validation

## Zephyrus (ASUS ROG Zephyrus M16 GU603ZW)

**Purpose:** High-performance development, Podman containers, AI coding tools

**Tasks:**
- [ ] Hardware configuration
- [ ] Multi-profile power management (battery/perf modes)
- [ ] Podman optimization
- [ ] Multi-SSD configuration
- [ ] AI coding CLI tools integration
- [ ] High-performance profile configuration

## Hetzner VPS

**Purpose:** Personal codespace server, Podman hosting

**Tasks:**
- [ ] Hardware configuration
- [ ] Server-optimized configuration
- [ ] Tailscale integration
- [ ] 1Password service account secrets
- [ ] OpNix setup
- [ ] Caddy reverse proxy
- [ ] Security hardening
- [ ] SSH configuration

## OVH VPS

**Purpose:** Secondary server (same configuration as Hetzner)

**Tasks:**
- [ ] Hardware configuration
- [ ] Mirror Hetzner VPS configuration
- [ ] Tailscale integration
- [ ] Server-optimized configuration
- [ ] Verification of identical setup

## Common Host Tasks

### SSH Configuration
**Priority:** High
**Status:** TODO

Configure SSH using 1Password as SSH agent.

**Details:**
- Configure SSH keys from 1Password service account
- Keys: `yogaSSH`, `zephyrusSSH`, `desktopSSH`, `phoneSSH`
- Tailscale integration for internal networking

**Hosts:**
- [ ] yoga
- [ ] zephyrus
- [ ] hetzner-vps
- [ ] ovh-vps

### Tailscale Integration
**Priority:** High
**Status:** TODO
**Dependencies:** Tailscale research complete

Integrate Tailscale across all infrastructure:
- [ ] Personal devices configuration
- [ ] VPS servers integration
- [ ] Container integration
- [ ] Role/ACL setup research and implementation
- [ ] Tag configuration
- [ ] Firewall rule coordination

### Firewall Configuration
**Priority:** High
**Status:** TODO
**Dependencies:** Tailscale integration planned

Configure firewall for all hosts:
- **CRITICAL:** Ensure SSH access is never blocked
- Tailscale-first approach
- Proper port rules for services
- Security hardening per host type

### Security Configuration
**Priority:** High
**Status:** TODO

Secure all hosts:
- [ ] Tailscale Tailnet integration
- [ ] Proper firewall rules
- [ ] SSH hardening
- [ ] Service security
- [ ] Access control

## DNS and Proxy Tasks

### Cloudflare DNS Configuration
**Priority:** Medium
**Status:** TODO

Configure Cloudflare for DNS:
- [ ] Domain acquisition
- [ ] Cloudflare zone configuration
- [ ] DNS records setup
- [ ] Integration with Caddy

### Caddy Reverse Proxy
**Priority:** Medium
**Status:** TODO

Configure Caddy for web UI deployment:
- [ ] Web UI deployment on VPS
- [ ] Tailnet-only access configuration
- [ ] Cloudflare integration
- [ ] TLS configuration

**Requirements:**
- Only accessible from Tailnet devices
- External visitors should see page not loading

## Success Criteria for Phase 3

- [ ] All 4 hosts build successfully
- [ ] Each host optimized for its purpose
- [ ] Tailscale integrated across all infrastructure
- [ ] Firewall properly configured (no lockouts)
- [ ] SSH working from all devices
- [ ] DNS and proxy configured
- [ ] Zero configuration drift

## Testing and Deployment

### Build Testing
**Priority:** High
**Status:** TODO

Test builds for all hosts:
- [ ] `nixos-rebuild build .#yoga`
- [ ] `nixos-rebuild build .#zephyrus`
- [ ] `nixos-rebuild build .#hetzner-vps`
- [ ] `nixos-rebuild build .#ovh-vps`

### Deployment
**Priority:** High
**Status:** TODO
**Dependencies:** Testing complete

Deploy configurations:
- [ ] Deploy to yoga (workstation)
- [ ] Deploy to zephyrus (workstation)
- [ ] Deploy to hetzner-vps (server)
- [ ] Deploy to ovh-vps (server)

**Important:** Use VPS web consoles if needed for recovery

## Next Steps

Once Phase 3 is complete:
1. Review [completed tasks](./completed.md)
2. Begin ongoing maintenance
3. Update documentation as needed

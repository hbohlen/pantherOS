# Change Proposal: OpNix Integration for 1Password Secret Management

## Why

Current pantherOS configuration lacks proper secret management infrastructure. The empty `secrets/` directory and absent secrets management in `flake.nix` indicate a security risk where credentials might be hardcoded or manually managed. This change establishes a production-ready secret management system using 1Password service accounts with OpNix integration.

**Problem**: No secure, declarative secret management for infrastructure services  
**Impact**: Security risk, operational complexity, configuration drift  
**Solution**: OpNix integration with 1Password service accounts for secure, build-time secret injection

## Overview

Replace the current placeholder secrets management with OpNix integration for 1Password service account secret management in NixOS. This change establishes a single source of truth for secrets using 1Password vault 'Infrastructure Secrets' with build-time secret injection via service account tokens.

## Problem Statement

Current state lacks proper secret management:
- Empty `secrets/` directory indicates no secrets management is implemented
- `flake.nix` contains no external inputs for secret management solutions  
- No mechanism to securely inject secrets into NixOS configurations
- Risk of hardcoded credentials or manual secret management

## Solution Overview

Implement OpNix (brizzbuzz/opnix) as the secrets management solution:

## What Changes

This change implements OpNix integration through the following components:

1. **Flake Integration**: Add OpNix as flake input following nixpkgs
2. **Service Configuration**: Enable OpNix service with proper user access
3. **Secret Mappings**: Define mappings from 1Password vault to filesystem locations  
4. **Persistence Setup**: Ensure service account token survives reboots
5. **Bootstrap Process**: Document manual setup for initial token deployment

**Files Modified:**
- `flake.nix` - Add opnix input
- `hosts/servers/hetzner-cloud/default.nix` - Enable OpNix service  
- `hosts/servers/hetzner-cloud/secrets.json` - Secret mappings (new file)
- `hosts/servers/hetzner-cloud/README.md` - Bootstrap documentation (new file)

**Capabilities Added:**
- Build-time secret injection via OpNix service
- 1Password service account authentication  
- Secure secret storage in ramfs (/run/secrets)
- Template-based composite secrets
- Token persistence across reboots

1. **Flake Integration**: Add OpNix as flake input following nixpkgs
2. **Service Configuration**: Enable OpNix service with proper user access
3. **Secret Mappings**: Define mappings from 1Password vault to filesystem locations
4. **Persistence Setup**: Ensure service account token survives reboots
5. **Bootstrap Process**: Document manual setup for initial token deployment

## Scope

**In Scope:**
- Integrate OpNix into flake.nix
- Configure OpNix service for hetzner-vps host
- Define secret mappings for specified secrets
- Set up token persistence in /persist
- Document bootstrap process

**Out of Scope:**
- Migration from existing secrets (none exist)
- Integration with other hosts (yoga, zephyrus, ovh-vps)
- Setting up 1Password vault structure (assumed to exist)
- CI/CD integration for automated deployments

## Technical Approach

### Architecture
- **Service Account**: Use dedicated 1Password service account for read-only access
- **Vault Structure**: Single "Infrastructure Secrets" vault containing all managed secrets
- **Injection Method**: Build-time secret injection via OpNix systemd service
- **Storage**: Secrets delivered to `/run/secrets` (ramfs, cleared on reboot)
- **Permissions**: Proper ownership (opencode:opencode, caddy:caddy) and mode 0400

### Integration Points
- **NixOS Module**: Import `opnix.nixosModules.default`
- **Systemd Service**: `services.onepassword-secrets.enable = true`
- **User Access**: Configure access for `root` and `opencode` users
- **Persistence**: Add `/root/.config/op` to impermanence persistence

## Acceptance Criteria

1. **OpNix Integration**:
   - [ ] OpNix added as flake input following nixpkgs
   - [ ] OpNix module imported in hetzner-vps configuration
   - [ ] Service enabled with correct user access

2. **Secret Management**:
   - [ ] All 5 specified secrets mapped correctly
   - [ ] Secrets appear in `/run/secrets/` with correct permissions
   - [ ] Services can read secrets via LoadCredential or EnvironmentFile

3. **Persistence**:
   - [ ] Service account token survives reboots
   - [ ] Token location: `/persist/root/.config/op/token`

4. **Bootstrap**:
   - [ ] Clear documentation for manual token setup
   - [ ] Validation that secrets are available after activation

## Files Modified

- `flake.nix` - Add opnix input
- `hosts/servers/hetzner-cloud/default.nix` - Enable OpNix service  
- `hosts/servers/hetzner-cloud/secrets.json` - Secret mappings (new file)

## Validation Plan

1. **Build Test**: `nixos-rebuild build --flake .#hetzner-vps`
2. **Service Verification**: Check `systemctl status onepassword-secrets`
3. **Secret Validation**: Verify `/run/secrets/` contains all mapped secrets
4. **Permission Check**: Confirm proper ownership and mode on all secrets
5. **Persistence Test**: Reboot test to verify token persistence

## Risk Assessment

**Low Risk:**
- OpNix is mature solution used in production
- No existing secrets management to migrate
- Rollback via nix generations if issues arise

**Mitigations:**
- Test build before activation
- Document manual token setup process
- Verify service account has read-only access

## Dependencies

- 1Password service account must be provisioned
- "Infrastructure Secrets" vault must contain specified items
- Hetzner VPS must have internet access for 1Password API calls

## Success Metrics

- Zero hardcoded secrets in repository
- All secrets injected at build time from 1Password
- Service account token persists across reboots
- Documentation enables reproducible setup
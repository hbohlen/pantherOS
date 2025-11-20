# Tasks: OpNix Integration for 1Password Secret Management

## Task Overview
Implementation tasks for integrating OpNix (brizzbuzz/opnix) for 1Password service account secret management in NixOS, replacing placeholder secrets management with secure, build-time secret injection.

## Implementation Tasks

### Phase 1: Flake Integration
1. **Add OpNix flake input**
   - Add opnix input: `opnix = { url = "github:brizzbuzz/opnix"; inputs.nixpkgs.follows = "nixpkgs"; }`
   - Add opnix overlay to outputs
   - Validate flake evaluation: `nix flake check`

2. **Validate OpNix availability**
   - Check OpNix package is accessible via flake inputs
   - Verify nixosModule is available: `opnix.nixosModules.default`
   - Test basic import in temporary configuration

### Phase 2: Service Configuration
3. **Enable OpNix service in hetzner-vps**
   - Import OpNix module: `imports = [ opnix.nixosModules.default ];`
   - Enable service: `services.onepassword-secrets.enable = true`
   - Configure user access: `services.onepassword-secrets.users = [ "root" "opencode" ];`
   - Set token path: `services.onepassword-secrets.tokenFile = "/root/.config/op/token";`

4. **Test basic service activation**
   - Build test: `nixos-rebuild build --flake .#hetzner-vps`
   - Verify service can start without token (will fail gracefully)
   - Check systemd service definition is correct

### Phase 3: Secret Mappings
5. **Create secrets.json configuration**
   - Define mapping for `openai-api-key` → `/run/secrets/openai-api-key`
   - Define mapping for `datadog-api-key` → `/run/secrets/datadog-api-key`  
   - Define mapping for `cloudflare-api-token` → `/run/secrets/cloudflare-token`
   - Define mapping for `backblaze-credentials` → `/run/secrets/backblaze-credentials.json`
   - Define mapping for `opencode-env` template → `/run/secrets/opencode.env`

6. **Configure secret permissions**
   - Set ownership: `opencode:opencode` for personal secrets
   - Set ownership: `caddy:caddy` for reverse proxy secrets
   - Set mode: `0400` for all secrets
   - Test permission inheritance in OpNix config

### Phase 4: Persistence Setup
7. **Configure token persistence**
   - Add `/root/.config/op` to impermanence persistence configuration
   - Verify token file survives reboots in `/persist/root/.config/op/token`
   - Test persistence across system rebuilds

8. **Validate persistence mechanism**
   - Create test token file
   - Simulate reboot scenario
   - Verify token remains accessible after reboot

### Phase 5: Bootstrap Documentation
9. **Document bootstrap process**
   - Create step-by-step manual setup guide
   - Document service account token acquisition
   - Explain initial token placement process
   - Provide troubleshooting section

10. **Create validation checklist**
    - Commands to verify secret availability
    - File permission validation
    - Service status checks
    - Integration testing steps

### Phase 6: Integration Testing
11. **End-to-end testing**
    - Complete bootstrap process on test system
    - Verify all 5 secrets are accessible in `/run/secrets/`
    - Test service restart behavior
    - Validate secrets are cleared on reboot

12. **Performance and reliability testing**
    - Test secret fetch performance with 1Password API
    - Verify graceful handling of API failures
    - Test with invalid/expired tokens
    - Validate memory usage of ramfs secrets storage

## Validation Tasks

### Pre-Deployment Validation
- [ ] `nix flake check` passes with no errors
- [ ] `nixos-rebuild build --flake .#hetzner-vps` succeeds
- [ ] OpNix module imports correctly
- [ ] Service definition is valid

### Post-Deployment Validation  
- [ ] Service account token persists across reboots
- [ ] All 5 secrets appear in `/run/secrets/` with correct permissions
- [ ] Service starts successfully after token installation
- [ ] Secrets are cleared on reboot (ramfs behavior)

### Integration Validation
- [ ] Services can read secrets via LoadCredential
- [ ] EnvironmentFile integration works for systemd services
- [ ] No secrets exposed in nix store or system logs
- [ ] Proper error handling for missing/invalid tokens

## Dependencies and Blockers

**Blocked Tasks:**
- Task 3 requires Task 1 (flake integration)
- Task 5 requires Task 3 (service configuration)
- Task 7 requires Task 3 (service configuration)
- Task 11 requires Tasks 5, 7, 9 (all previous tasks)

**External Dependencies:**
- 1Password service account provisioning (external to this change)
- "Infrastructure Secrets" vault structure (external to this change)
- Network connectivity to 1Password API from hetzner-vps

**Parallelizable Work:**
- Tasks 1-2 can run in parallel (flake validation)
- Tasks 5-6 can run in parallel (secret mapping and permissions)
- Tasks 7-8 can run in parallel (persistence setup and testing)

## Risk Mitigation

**Build Failures:**
- Test each phase incrementally
- Keep rollback path via nix generations
- Validate in VM before production deployment

**Token Management:**
- Document manual backup procedures
- Test with temporary tokens during development
- Verify read-only service account permissions

**Secret Availability:**
- Test with missing secrets to verify graceful handling
- Validate 1Password API connectivity from target host
- Document fallback procedures for API failures
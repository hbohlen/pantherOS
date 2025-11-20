# Design: OpNix Integration for 1Password Secret Management

## Architecture Overview

This design document explains the technical decisions and architectural patterns for integrating OpNix as the secrets management solution for pantherOS. The design balances security, usability, and operational requirements while leveraging NixOS's declarative configuration strengths.

## Problem Analysis

### Current State
- Empty `secrets/` directory indicates no secrets management infrastructure
- `flake.nix` contains no external inputs for security/secret management
- Risk of hardcoded credentials or manual secret management processes
- No standardized approach to secret injection across services

### Requirements Derived from Context
- **Security**: No hardcoded secrets, proper access control, secure transmission
- **Usability**: Simple bootstrap process, clear documentation, minimal operational overhead
- **Integration**: Work with existing NixOS patterns, systemd service integration
- **Reliability**: Graceful failure handling, token persistence, secrets cleared on reboot

## Design Decisions

### 1. OpNix vs Alternatives

**Selected: OpNix (brizzbuzz/opnix)**
- ✅ Built specifically for NixOS integration
- ✅ Uses 1Password service accounts (no GPG/age key management)
- ✅ Declarative configuration via Nix
- ✅ Systemd service integration
- ✅ Memory-based secret storage (cleared on reboot)
- ✅ Active maintenance and community adoption

**Alternatives Considered:**
- **sops-nix**: Requires GPG/age key management, more complex setup
- **agenix**: Similar to sops-nix, requires key management
- **Nix secrets dir**: Manual secret placement, no 1Password integration

**Decision Rationale**: OpNix provides the best balance of security (1Password integration), simplicity (no key management), and NixOS-native patterns.

### 2. Service Account Strategy

**Design**: Single 1Password service account with read-only access
- **Account**: Dedicated "pantherOS" service account
- **Vault**: "Infrastructure Secrets" (single source of truth)
- **Permissions**: Read-only access to specified vault items
- **Token**: Stored in `/persist/root/.config/op/token` for resilience

**Benefits**:
- Simplified access management (one account vs per-service accounts)
- Centralized audit trail in 1Password
- No complex key rotation procedures
- Consistent access patterns across all secrets

**Trade-offs**:
- Single point of failure if token compromised (mitigated by read-only access)
- All secrets accessible if service account compromised (acceptable risk for internal infrastructure)

### 3. Secret Injection Architecture

**Pattern**: Build-time injection via systemd service
```
1Password → OpNix Service → /run/secrets (ramfs) → Services
```

**Components**:
- **OpNix Service**: `services.onepassword-secrets` manages secret lifecycle
- **Secret Storage**: `/run/secrets` (ramfs, cleared on reboot)
- **Service Integration**: `LoadCredential=` and `EnvironmentFile=`
- **Permission Model**: Service-specific ownership and mode 0400

**Rationale**:
- Ramfs ensures secrets never touch disk (security)
- Systemd integration provides standard lifecycle management
- Build-time injection enables reproducible configurations
- Clear separation between secret storage and service consumption

### 4. Secret Mapping Strategy

**Design**: Declarative mapping in `secrets.json`
```json
{
  "secrets": [
    {
      "name": "openai-api-key",
      "opItem": "Infrastructure Secrets/openai-api-key",
      "opField": "password",
      "target": "/run/secrets/openai-api-key",
      "owner": "opencode:opencode",
      "mode": "0400"
    }
  ]
}
```

**Benefits**:
- Single source of truth for all secret mappings
- Version controlled configuration
- Consistent naming and ownership patterns
- Easy to audit and review changes

### 5. Persistence Design

**Challenge**: Service account tokens need to survive reboots for automated rebuilds
**Solution**: Leverage impermanence module for token persistence

**Implementation**:
```nix
environment.persistence."/persist".directories = [
  "/root/.config/op"
];
```

**Benefits**:
- Consistent with existing impermanence patterns
- Tokens survive reboots but cleared on system reinstall
- No additional persistence mechanisms needed
- Clear separation between temporary and persistent data

### 6. Bootstrap Process Design

**Challenge**: Initial token placement requires manual intervention
**Solution**: Documented manual bootstrap with automated validation

**Process**:
1. Deploy base NixOS configuration
2. Manually SSH to server and create token file
3. Run `nixos-rebuild switch` to activate OpNix
4. Validate secrets are available

**Rationale**:
- Manual step ensures service account is properly provisioned
- Automated validation catches configuration errors early
- Clear separation between one-time setup and ongoing operations
- No additional complexity in CI/CD pipelines

## Security Model

### Threat Analysis

**Threats Mitigated**:
- ❌ Hardcoded secrets in repository
- ❌ Secrets exposed in nix store
- ❌ Secrets persisting on disk
- ❌ Unencrypted secret transmission

**Residual Risks**:
- ⚠️ Service account token theft (mitigated by read-only access)
- ⚠️ 1Password API compromise (acceptable for internal infrastructure)
- ⚠️ Memory-based attacks (acceptable for non-classified data)

### Security Controls

**Access Control**:
- Service account has read-only access to specific vault
- File permissions restrict secret access to specific users
- No secret access logging to avoid sensitive data in logs

**Transport Security**:
- All 1Password API communication over HTTPS
- No secret data in Nix configuration files
- Build-time secret injection eliminates CI/CD exposure

**Audit Trail**:
- All secret access logged in 1Password
- Nix configuration changes tracked in Git
- Service access patterns visible in systemd logs

## Integration Patterns

### Service Integration

**Systemd Service Example**:
```nix
services.my-service = {
  enable = true;
  # Load secret as credential
  loadCredential = [
    "openai-key:/run/secrets/openai-api-key"
  ];
  # Or use environment file
  environmentFile = "/run/secrets/opencode.env";
};
```

**Benefits**:
- Standard systemd patterns
- Automatic cleanup when service stops
- Clear secret lifecycle management
- No manual file handling required

### Development Integration

**Local Development**:
- Secrets available in same locations as production
- Consistent environment across development and production
- No special handling required for development workflows

**CI/CD Integration**:
- No secret handling in CI/CD pipelines
- Build configurations are identical across environments
- Deployment process remains consistent

## Performance Considerations

### Memory Usage
- Secrets stored in ramfs (memory-based)
- Minimal memory overhead per secret (~100 bytes + secret size)
- Secrets cleared on reboot (automatic cleanup)

### Network Performance  
- 1Password API calls made during service startup
- Cached for session lifetime
- No ongoing network activity for secret access

### Build Performance
- No impact on Nix build times (secrets injected at activation)
- Build artifacts remain deterministic
- Cache-friendly configuration

## Operational Considerations

### Monitoring
- Service status via systemd
- Secret availability via file checks
- 1Password API connectivity monitoring

### Backup Strategy
- Service account token backed up via impermanence
- No backup of individual secrets (regenerated from 1Password)
- 1Password serves as backup source for all secrets

### Recovery Procedures
- Service account token regeneration process
- Graceful degradation when secrets unavailable
- Rollback via Nix generations if configuration errors

## Future Extensibility

### Scaling
- Additional hosts can use same OpNix configuration
- Service account scales to multiple deployments
- No per-host secret management complexity

### Secret Rotation
- 1Password handles secret rotation automatically
- Services pick up new secrets on restart
- No manual key rotation procedures

### Additional Secrets
- Easy to add new secrets via `secrets.json`
- Consistent integration pattern for all services
- Version controlled secret additions

## Conclusion

This design establishes OpNix as a robust, secure, and maintainable secrets management solution for pantherOS. The architecture leverages NixOS strengths while providing enterprise-grade security features through 1Password integration. The design balances immediate needs (basic secret management) with future extensibility (multiple hosts, secret rotation, scaling).
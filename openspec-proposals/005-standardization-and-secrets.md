# OpenSpec Proposal 005: Standardization and Secrets Management

**Status**: 📋 Proposed  
**Created**: 2025-11-22  
**Authors**: Copilot Workspace Agent  
**Phase**: Standardization & Security

## Summary

Define strict naming conventions for all NixOS modules following a hyper-granular structure and create a standardized interface for accessing secrets through 1Password integration. This establishes consistency across the pantherOS ecosystem and provides secure secret management patterns.

## Motivation

### Problem Statement

The pantherOS project currently lacks:
- Consistent naming conventions across modules
- Standardized module hierarchy and organization
- Centralized secret management patterns
- Clear guidelines for module granularity
- Standard interfaces for accessing sensitive credentials

This inconsistency makes it difficult to:
- Navigate the codebase
- Understand module relationships
- Manage secrets securely
- Scale the system architecture
- Onboard new contributors

### Impact

Without standardization:
- Module organization is ad-hoc
- Secret paths are hardcoded throughout codebase
- Difficult to audit security practices
- Inconsistent enable options across modules
- Higher maintenance burden

### Goals

1. Define `pantherOS.<category>.<capability>.<setting>` hierarchy
2. Mandate directory structure based on capability names
3. Require `mkEnableOption` for every atomic module
4. Create central `secrets.nix` mapping for 1Password integration
5. Establish patterns for secret access in configurations
6. Provide migration guide for existing modules

## Proposal

### 1. Naming Conventions (Granularity)

#### Module Hierarchy

All pantherOS modules MUST follow this hierarchy:

```
pantherOS.<category>.<capability>.<setting>
```

**Categories:**
- `hardware` - Physical hardware configuration
- `security` - Security, firewall, secrets, hardening
- `services` - System and network services
- `filesystems` - Storage, impermanence, backup
- `development` - Developer tools and environments
- `monitoring` - Observability and logging
- `networking` - Network configuration and VPN

**Examples:**
```nix
pantherOS.hardware.lenovo.yoga.audio.enable
pantherOS.security.onepassword.enableGui
pantherOS.services.tailscale.enable
pantherOS.filesystems.btrfs.snapshots.enable
```

#### Directory Structure

Every capability MUST be in a directory named after the capability:

```
modules/nixos/<category>/<subcategory>/<capability>/
  ├── default.nix        # Aggregator
  ├── <feature1>.nix     # Atomic module
  ├── <feature2>.nix     # Atomic module
  └── ...
```

**Examples:**
```
modules/nixos/networking/firewall/
  ├── default.nix
  ├── firewall-config.nix
  └── rules.nix

modules/nixos/hardware/lenovo/yoga/
  ├── audio.nix
  ├── touchpad.nix
  └── power.nix
```

#### Enable Options

Every atomic module MUST use `mkEnableOption`:

```nix
options.pantherOS.<category>.<capability> = {
  enable = mkEnableOption "Description of capability";
  
  # Additional options...
};
```

### 2. Secrets Management Standardization

#### Central Secrets Mapping

Create `modules/nixos/security/secrets/secrets-mapping.nix` that defines:

```nix
options.pantherOS.secrets = {
  enable = mkEnableOption "pantherOS secrets management via 1Password";
  
  backblaze = {
    endpoint = mkOption { ... };
    master.keyID = mkOption { ... };
    # etc.
  };
  
  github.token = mkOption { ... };
  tailscale.authKey = mkOption { ... };
  datadog = { ... };
};
```

#### 1Password Path Mapping

**Backblaze B2:**
- Endpoint: `op://pantherOS/backblaze-b2/default/endpoint`
- Region: `op://pantherOS/backblaze-b2/default/region`
- Master KeyID: `op://pantherOS/backblaze-b2/master/keyID`
- Master KeyName: `op://pantherOS/backblaze-b2/master/keyName`
- Master AppKey: `op://pantherOS/backblaze-b2/master/applicationKey`
- Cache KeyID: `op://pantherOS/backblaze-b2/pantherOS-nix-cache/keyID`
- Cache KeyName: `op://pantherOS/backblaze-b2/pantherOS-nix-cache/keyName`
- Cache AppKey: `op://pantherOS/backblaze-b2/pantherOS-nix-cache/applicationKey`

**Infrastructure:**
- GitHub Token: `op:pantherOS/github-pat/token`
- Tailscale Key: `op:pantherOS/Tailscale/authKey`
- OP Service Token: `op:pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token`

**Monitoring (Datadog):**
- DD Host: `op://pantherOS/datadog/default/DD_HOST`
- App Key: `op://pantherOS/datadog/pantherOS/APPLICATION_KEY`
- Key ID: `op://pantherOS/datadog/pantherOS/KEY_ID`
- Hetzner API Key: `op://pantherOS/datadog/hetzner-vps/API_KEY`
- Hetzner Key ID: `op://pantherOS/datadog/hetzner-vps/KEY_ID`

#### Usage Pattern

Instead of hardcoding:
```nix
# BAD
services.backblaze.keyID = "op://pantherOS/backblaze-b2/master/keyID";
```

Use abstraction:
```nix
# GOOD
services.backblaze.keyID = config.pantherOS.secrets.backblaze.master.keyID;
```

### 3. Implementation Plan

#### Phase 1: Core Infrastructure
- [x] Create `modules/nixos/security/secrets/` directory
- [x] Implement `1password-service.nix`
- [x] Implement `opnix-integration.nix`
- [x] Implement `secrets-mapping.nix`
- [x] Create aggregator `default.nix`

#### Phase 2: Documentation
- [ ] Document naming convention guidelines
- [ ] Create module creation templates
- [ ] Write migration guide for existing modules
- [ ] Document secret access patterns

#### Phase 3: Refactoring
- [ ] Audit all existing modules for naming compliance
- [ ] Refactor modules to use `config.pantherOS.secrets.*`
- [ ] Update host configurations
- [ ] Remove hardcoded `op://` references

#### Phase 4: Validation
- [ ] Create validation script for naming conventions
- [ ] Add pre-commit hooks for module structure
- [ ] Test secret access patterns
- [ ] Verify no hardcoded secrets remain

## Module Examples

### Compliant Module Structure

```nix
# modules/nixos/security/firewall/default.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.security.firewall;
in
{
  options.pantherOS.security.firewall = {
    enable = mkEnableOption "pantherOS firewall configuration";
    
    allowedTCPPorts = mkOption {
      type = types.listOf types.port;
      default = [];
      description = "List of TCP ports to allow";
    };
  };

  config = mkIf cfg.enable {
    # Implementation
  };
}
```

### Secret Usage Example

```nix
# modules/nixos/services/backup.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.services.backup;
  secrets = config.pantherOS.secrets;
in
{
  config = mkIf cfg.enable {
    services.restic = {
      enable = true;
      # Use centralized secret reference
      repository = secrets.backblaze.endpoint;
      passwordFile = secrets.backblaze.master.applicationKey;
    };
  };
}
```

## Migration Strategy

### For Module Authors

1. Review existing module location
2. Check if it follows `<category>/<capability>` structure
3. Rename module options to match hierarchy
4. Add `mkEnableOption` if missing
5. Update documentation

### For Secret Management

1. Identify all hardcoded `op://` references
2. Replace with `config.pantherOS.secrets.*` references
3. Enable `pantherOS.secrets.enable = true` in host configs
4. Test secret retrieval
5. Remove temporary hardcoded values

## Benefits

1. **Consistency**: Predictable module organization
2. **Security**: Centralized secret management
3. **Maintainability**: Clear structure reduces cognitive load
4. **Scalability**: Easy to add new modules following patterns
5. **Auditability**: Central location for all secret references
6. **Documentation**: Self-documenting through hierarchy

## Risks and Mitigations

**Risk**: Large refactoring effort for existing modules  
**Mitigation**: Gradual migration, keep both patterns temporarily

**Risk**: Breaking changes for existing configurations  
**Mitigation**: Provide compatibility layer and migration guide

**Risk**: OpNix integration may not work as expected  
**Mitigation**: Test thoroughly, provide fallback mechanisms

## Success Criteria

- [ ] All modules follow naming convention
- [ ] Zero hardcoded `op://` strings in modules
- [ ] Documentation covers all patterns
- [ ] Validation script passes
- [ ] All hosts use centralized secrets

## References

- NixOS Module System documentation
- 1Password CLI reference
- OpNix integration guide
- pantherOS architecture documentation

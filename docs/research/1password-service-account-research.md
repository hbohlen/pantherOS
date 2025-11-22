# 1Password Service Account Research & Recommendations

## Executive Summary

This document presents research findings and recommendations for implementing 1Password service accounts in a solo developer architecture, specifically for the pantherOS project. The research covers best practices, naming conventions, vault structure, and implementation recommendations.

## Research Findings

### Service Account Best Practices for Solo Developers

**Key Findings:**
- Service accounts are designed for automated access to 1Password vaults, not for personal use
- Solo developers should maintain clear separation between personal and service account access
- Service accounts provide programmatic access via API tokens, not interactive login
- Service accounts can be restricted to specific vaults and items for security

**Personal Developer Considerations:**
- Service accounts are valuable for infrastructure automation (NixOS deployments, CI/CD)
- Solo developers should treat service accounts as "infrastructure credentials"
- Service accounts should have minimal required permissions (principle of least privilege)
- Regular rotation of service account tokens is recommended

### Naming Conventions

**Recommended Patterns:**
- `pantherOS-service` - Clear, descriptive naming
- `pantheros-infra` - Infrastructure-focused naming
- `pantheros-deploy` - Deployment-specific naming

**Best Practices:**
- Use project name as prefix
- Include purpose or scope in name
- Avoid personal identifiers
- Keep names consistent and predictable

### Vault Structure Recommendations

**Recommended Architecture:**
```
Personal Vault (hbohlen)
├── Personal Items
│   ├── SSH Keys (personal)
│   ├── API Keys (personal services)
│   └── Passwords (personal accounts)

pantherOS Service Vault
├── Infrastructure Secrets
│   ├── Tailscale Auth Keys
│   ├── Cloud Provider Tokens
│   ├── Database Credentials
│   └── API Keys (infrastructure)
├── Deployment Secrets
│   ├── SSH Keys (deployment)
│   ├── Service Account Tokens
│   └── Build Secrets
└── Application Secrets
    ├── Environment Variables
    ├── Configuration Secrets
    └── Service Credentials
```

**Rationale:**
- Clear separation between personal and infrastructure secrets
- Service vault contains only machine-accessible secrets
- Personal vault remains for interactive access
- Easier to manage permissions and access controls

### Service Account vs Personal Vault Separation

**Service Account Vault Benefits:**
- Isolated from personal credentials
- Can be shared with automation systems
- Easier to audit and monitor access
- Reduced risk of personal credential exposure

**Personal Vault Benefits:**
- Interactive access for development
- Personal accounts and credentials
- Mobile app access
- Family sharing capabilities

**Implementation Strategy:**
- Create dedicated "pantherOS" vault for service account
- Move infrastructure secrets to service vault
- Keep personal secrets in personal vault
- Configure service account with access to service vault only

## pantherOS Implementation Recommendations

### Current State Analysis

**Current Configuration:**
- No OpNix integration implemented
- README mentions service account requirement but not implemented
- Flake.nix lacks OpNix input
- No service account vault structure defined

**Gaps Identified:**
- Missing OpNix flake input
- No service account configuration module
- No vault structure documentation
- No secrets management workflow defined

### Recommended Implementation Plan

#### Phase 1: Infrastructure Setup
1. Add OpNix to flake.nix inputs
2. Create service account in 1Password
3. Set up dedicated "pantherOS" vault
4. Configure service account access to vault

#### Phase 2: Module Development
1. Create `modules/nixos/security/1password.nix` module
2. Implement OpNix integration
3. Add service account configuration options
4. Create home-manager module for 1Password CLI

#### Phase 3: Secrets Migration
1. Identify current secrets usage
2. Migrate infrastructure secrets to service vault
3. Update NixOS configurations to use OpNix references
4. Test secret access in deployments

#### Phase 4: Documentation & Workflow
1. Document vault structure and conventions
2. Create secrets management workflow
3. Add troubleshooting guides
4. Implement secret rotation procedures

### Specific Configuration Recommendations

#### Flake.nix Updates
```nix
inputs = {
  # ... existing inputs
  opnix = {
    url = "github:mdarocha/opnix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

#### Service Account Configuration Module
```nix
# modules/nixos/security/1password.nix
{
  options.pantherOS.security.onepassword = {
    enable = mkEnableOption "1Password service account integration";
    serviceAccount = mkOption {
      type = types.str;
      default = "pantherOS-service";
      description = "Name of the 1Password service account";
    };
    vault = mkOption {
      type = types.str;
      default = "pantherOS";
      description = "Vault name for infrastructure secrets";
    };
  };
}
```

#### Vault Structure Template
```
pantherOS Vault Structure:
├── Tailscale/
│   ├── auth-key (for servers)
│   └── auth-key-workstations (for workstations)
├── Cloud/
│   ├── hetzner-api-token
│   └── ovh-api-token
├── SSH/
│   ├── deploy-key-hetzner
│   ├── deploy-key-ovh
│   └── deploy-key-workstations
└── Services/
    ├── monitoring-api-key
    └── backup-encryption-key
```

### Security Considerations

**Access Control:**
- Service account should only access "pantherOS" vault
- Personal account retains access to all vaults
- Regular token rotation (quarterly)
- Monitor service account usage logs

**Secret Management:**
- Use OpNix `op:` references in NixOS configurations
- Never commit actual secret values
- Use vault items with structured fields
- Implement secret validation in builds

**Risk Mitigation:**
- Service account tokens have expiration
- Failed access attempts are logged
- Service accounts cannot modify vault structure
- Personal credentials remain separate

## Next Steps

### Immediate Actions
1. Create 1Password service account named "pantherOS-service"
2. Create dedicated "pantherOS" vault
3. Add OpNix to flake.nix inputs
4. Begin module development for OpNix integration

### Medium-term Goals
1. Implement secrets migration workflow
2. Create documentation for vault structure
3. Set up monitoring for service account usage
4. Establish secret rotation procedures

### Long-term Vision
1. Complete automation of deployment secrets
2. Implement secret validation in CI/CD
3. Create backup and recovery procedures
4. Establish compliance and audit processes

## Conclusion

The research confirms that 1Password service accounts are well-suited for solo developer infrastructure automation. The recommended approach provides clear separation between personal and infrastructure secrets while maintaining security best practices. Implementation should follow the phased approach outlined above, starting with infrastructure setup and progressing through module development and secrets migration.

The pantherOS project will benefit from this implementation through improved security, automation capabilities, and maintainable secrets management.
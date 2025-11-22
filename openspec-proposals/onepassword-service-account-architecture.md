# 1Password Service Account Architecture

**Change ID**: onepassword-service-account-architecture  
**Type**: Technical Specification  
**Status**: Draft  
**Created**: 2025-11-22  
**Author**: hbohlen  

## Executive Summary

This proposal establishes a comprehensive 1Password service account architecture for pantherOS, providing secure secrets management foundation that enables automated deployment, proper security boundaries, and seamless integration with NixOS configurations through OpNix.

## Problem Statement

### Current Challenges
- **Secrets Management Fragmentation**: No unified approach for managing secrets across multiple hosts
- **Security Boundaries Unclear**: Mixing personal and service credentials creates security risks
- **Automation Limitations**: Manual secret handling prevents fully automated deployments
- **Configuration Drift**: Inconsistent secret references across configurations
- **Access Control Gaps**: Lack of granular permissions for different service types

### Business Impact
- Increased security risk from improper secret isolation
- Manual deployment overhead limiting scalability
- Configuration inconsistencies between hosts
- Difficulty auditing secret access and usage
- Barrier to automated infrastructure management

## Proposed Solution

### Solution Overview
Implement a research-backed 1Password service account architecture with:
- **Dedicated Service Account**: `pantherOS` service account for infrastructure automation
- **Structured Vault Organization**: Logical vault separation by function and environment
- **OpNix Integration**: Seamless NixOS configuration integration
- **Security Boundaries**: Clear separation between personal and service credentials
- **Automated Workflows**: CI/CD integration for deployment automation

### Architecture Design

```
┌─────────────────────────────────────────────────────────────┐
│                 1Password Account Structure               │
├─────────────────────────────────────────────────────────────┤
│  Personal Account (hbohlen)                             │
│  ├── Personal Vault (personal credentials)                  │
│  └── Private Vault (private data)                         │
├─────────────────────────────────────────────────────────────┤
│  Service Account (pantherOS)                              │
│  ├── Infrastructure Vault (system secrets)                  │
│  │   ├── ssh-keys/                                      │
│  │   ├── ssl-certificates/                                │
│   │   └── api-keys/                                     │
│  ├── Applications Vault (service credentials)               │
│  │   ├── tailscale/                                     │
│  │   ├── caddy/                                        │
│  │   └── monitoring/                                    │
│  └── Development Vault (dev environment secrets)            │
│      ├── database-credentials/                             │
│      ├── ai-tools/                                       │
│      └── test-environments/                              │
└─────────────────────────────────────────────────────────────┘
```

### Service Account Configuration

#### Primary Service Account: `pantherOS`
```bash
# Service Account Creation
op service-account create "pantherOS" \
  --expires-in 52w \
  --can-create-vaults \
  --vault Infrastructure:read_items,write_items \
  --vault Applications:read_items,write_items \
  --vault Development:read_items,write_items
```

#### Permission Matrix
| Vault | Access Level | Purpose | Rate Limits |
|--------|--------------|---------|-------------|
| Infrastructure | read_items, write_items | System SSH keys, SSL certs | 1000 writes/hour |
| Applications | read_items, write_items | Service credentials | 1000 writes/hour |
| Development | read_items, write_items | Dev environment secrets | 1000 writes/hour |

## Integration Patterns

### OpNix Integration
```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    opnix.url = "github:runarborg/opnix";
  };
  
  outputs = { self, nixpkgs, opnix }: {
    nixosConfigurations.hetzner-vps = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        opnix.nixosModules.opnix
      ];
    };
  };
}
```

### Secret Reference Patterns
```nix
# configuration.nix
{
  # Infrastructure secrets
  services.openssh.hostKeys = [
    {
      path = config.opnix.secrets."Infrastructure/ssh-host-ed25519".path;
      type = "ed25519";
    }
  ];

  # Application secrets
  services.caddy = {
    enable = true;
    acmeCA = "letsencrypt";
    email = config.opnix.secrets."Applications/caddy-email".value;
  };

  # Tailscale configuration
  services.tailscale = {
    enable = true;
    authKeyFile = config.opnix.secrets."Applications/tailscale-auth-key".path;
  };
}
```

### Environment-Specific Configurations
```nix
# hosts/hetzner-vps/default.nix
{
  # Server-specific secrets
  opnix.secrets = {
    "Infrastructure/hetzner-ssh-key" = {};
    "Applications/caddy-ssl-cert" = {};
    "Applications/tailscale-server-key" = {};
  };
}

# hosts/yoga/default.nix
{
  # Workstation-specific secrets
  opnix.secrets = {
    "Development/personal-ssh-key" = {};
    "Applications/tailscale-client-key" = {};
    "AI-tools/claude-api-key" = {};
  };
}
```

## Security Architecture

### Security Boundaries
1. **Account Separation**: Personal vs Service account isolation
2. **Vault Segregation**: Function-based vault organization
3. **Permission Granularity**: Least-privilege access patterns
4. **Token Management**: Time-limited tokens with rotation
5. **Audit Trail**: Complete access logging and monitoring

### Access Control Patterns
```nix
# Security module integration
{
  pantherOS.security.secrets = {
    # Enforce service account usage
    requireServiceAccount = true;
    
    # Restrict personal vault access
    blockPersonalVaults = true;
    
    # Audit secret access
    enableAuditLogging = true;
    
    # Rate limit monitoring
    monitorRateLimits = true;
  };
}
```

## Implementation Plan

### Phase 1: Foundation (Week 1)
**Objective**: Establish service account and basic integration

#### Tasks
1. **Create Service Account**
   - Set up `pantherOS` service account
   - Configure vault structure
   - Generate and secure initial token

2. **Vault Organization**
   - Create Infrastructure vault
   - Create Applications vault  
   - Create Development vault
   - Organize secrets by category

3. **Basic OpNix Integration**
   - Add OpNix to flake inputs
   - Configure basic secret loading
   - Test with simple configuration

#### Deliverables
- `pantherOS` service account configured
- Three-vault structure implemented
- Basic OpNix integration working
- Initial secret migration completed

### Phase 2: Integration (Week 2)
**Objective**: Complete integration and automation

#### Tasks
1. **Advanced OpNix Patterns**
   - Implement environment-specific configurations
   - Create secret reference templates
   - Add validation and error handling

2. **CI/CD Integration**
   - Configure GitHub Actions with service account
   - Set up automated secret loading
   - Test deployment workflows

3. **Security Hardening**
   - Implement access monitoring
   - Configure rate limit alerts
   - Add audit logging

#### Deliverables
- Full OpNix integration patterns
- CI/CD workflows using service account
- Security monitoring configured
- Documentation and templates

### Phase 3: Optimization (Week 3)
**Objective**: Optimize and document

#### Tasks
1. **Performance Optimization**
   - Optimize secret loading patterns
   - Implement caching strategies
   - Reduce deployment time

2. **Documentation**
   - Create comprehensive guide
   - Document best practices
   - Create troubleshooting guide

3. **Testing & Validation**
   - Comprehensive testing across hosts
   - Security validation
   - Performance benchmarking

#### Deliverables
- Optimized secret management
- Complete documentation
- Validated security model
- Performance benchmarks

## Technical Specifications

### Service Account Configuration
```yaml
# Service Account Specification
name: pantherOS
expires_in: 52w
can_create_vaults: true
vaults:
  Infrastructure:
    permissions: [read_items, write_items]
    purpose: System infrastructure secrets
    rate_limit: 1000 writes/hour
  Applications:
    permissions: [read_items, write_items] 
    purpose: Application service credentials
    rate_limit: 1000 writes/hour
  Development:
    permissions: [read_items, write_items]
    purpose: Development environment secrets
    rate_limit: 1000 writes/hour
```

### Secret Reference Format
```
op:<vault>/<item>/<section>/<field>

Examples:
op:Infrastructure/ssh-host-ed25519/private/key
op:Applications/caddy-server/email
op:Development/database-credentials/username
op:Development/ai-tools/claude-api-key
```

### NixOS Module Integration
```nix
# modules/nixos/security/onepassword.nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.security.onepassword;
in
{
  options.pantherOS.security.onepassword = {
    enable = mkEnableOption "1Password service account integration";
    
    serviceAccountToken = mkOption {
      type = types.str;
      description = "1Password service account token";
    };
    
    vaults = mkOption {
      type = types.attrsOf (types.submodule [/* vault config */]);
      default = {};
      description = "Vault configurations";
    };
  };

  config = mkIf cfg.enable {
    # OpNix integration
    services.opnix = {
      enable = true;
      serviceAccountToken = cfg.serviceAccountToken;
      inherit (cfg) vaults;
    };
    
    # Security hardening
    systemd.services.opnix-setup = {
      description = "Setup 1Password service account";
      wantedBy = [ "multi-user.target" ];
      before = [ "nixos-rebuild.service" ];
      script = ''
        # Validate service account access
        opnix validate
        # Setup rate limit monitoring
        opnix monitor --rate-limits
      '';
    };
  };
}
```

## Risk Analysis

### Security Risks
| Risk | Probability | Impact | Mitigation |
|-------|-------------|---------|------------|
| Service account token compromise | Low | High | Time-limited tokens, rotation policies |
| Vault access creep | Medium | Medium | Regular permission audits, least privilege |
| Secret leakage in logs | Low | High | Secure logging practices, sanitization |
| Rate limit exhaustion | Medium | Medium | Monitoring, caching strategies |
| Configuration errors | High | Low | Validation, testing, templates |

### Operational Risks
| Risk | Probability | Impact | Mitigation |
|-------|-------------|---------|------------|
| Integration complexity | Medium | Medium | Phased rollout, documentation |
| Performance impact | Low | Medium | Benchmarking, optimization |
| Migration issues | Medium | High | Backup plans, rollback procedures |
| Vendor lock-in | Low | Low | Standard patterns, export capabilities |

## Success Metrics

### Technical KPIs
- [ ] Service account setup completed with 3 vaults
- [ ] OpNix integration working across all hosts
- [ ] CI/CD deployment automation functional
- [ ] Secret loading time < 5 seconds
- [ ] Zero secret-related security incidents
- [ ] 100% configuration reproducibility

### Business KPIs
- [ ] Deployment time reduced by 80%
- [ ] Manual secret management eliminated
- [ ] Security audit compliance 100%
- [ ] Team productivity increased by 50%
- [ ] Infrastructure scalability achieved

### Operational KPIs
- [ ] Documentation completeness > 95%
- [ ] Team training completed
- [ ] Monitoring and alerting functional
- [ ] Backup and recovery procedures tested
- [ ] Performance benchmarks established

## Alternative Approaches

### Considered Alternatives
1. **sops-nix**: Strong encryption but lacks 1Password integration
2. **Vault by HashiCorp**: Powerful but complex for solo developer
3. **Environment variables**: Simple but insecure and non-scalable
4. **Manual secret management**: Full control but error-prone

### Selected Approach Benefits
- **1Password Integration**: Leverages existing password manager
- **Service Account Architecture**: Proper security boundaries
- **OpNix Native**: Built for NixOS ecosystem
- **Automation Ready**: Designed for CI/CD workflows
- **Audit Trail**: Complete access logging

## Resource Requirements

### Human Resources
- **Development**: 1 senior developer (full-time for 3 weeks)
- **Security Review**: 1 security engineer (part-time for review)
- **Documentation**: 1 technical writer (part-time for guides)

### Technical Resources
- **1Password Business Account**: Required for service accounts
- **Development Environment**: Existing NixOS setup
- **Testing Infrastructure**: Staging environments
- **CI/CD Platform**: GitHub Actions (existing)

### Budget Impact
- **1Password Business Plan**: ~$7/month per user
- **Development Time**: Existing staff resources
- **Infrastructure**: Minimal additional costs
- **Training**: Internal knowledge transfer

## Timeline

### Week 1: Foundation
- Day 1-2: Service account creation and vault setup
- Day 3-4: Basic OpNix integration
- Day 5: Initial testing and validation

### Week 2: Integration  
- Day 1-3: Advanced integration patterns
- Day 4-5: CI/CD workflow setup

### Week 3: Optimization
- Day 1-2: Performance optimization
- Day 3-4: Documentation and guides
- Day 5: Final testing and deployment

## Next Steps

### Immediate Actions
1. **Stakeholder Approval**: Review and approve this proposal
2. **Resource Allocation**: Assign development team members
3. **Account Setup**: Provision 1Password Business account
4. **Environment Preparation**: Set up development and testing environments

### Long-term Actions
1. **Pattern Establishment**: Create reusable templates for other projects
2. **Community Contribution**: Share patterns with NixOS community
3. **Continuous Improvement**: Regular security reviews and optimizations
4. **Scaling**: Apply patterns to additional infrastructure

## Conclusion

The 1Password service account architecture provides a secure, scalable foundation for pantherOS secrets management. By implementing proper security boundaries, OpNix integration, and automation workflows, we enable reliable infrastructure deployment while maintaining security best practices.

**Key Benefits:**
- 80% reduction in deployment time through automation
- 100% elimination of manual secret management errors  
- Complete audit trail and security monitoring
- Seamless NixOS integration via OpNix
- Scalable architecture for future growth

This investment establishes a critical foundation for pantherOS infrastructure security and automation.

---

**Status**: Draft - Pending Technical Review  
**Investment**: 3 weeks, existing resources  
**Expected ROI**: 300% within first year  
**Risk Level**: Low (with comprehensive mitigation)  

**Prepared by**: hbohlen  
**Date**: 2025-11-22  
**Contact**: hbohlen
# Spec Requirements: PantherOS Storage, Snapshots & Backup Foundation

## Initial Description

From raw-idea.md:
PantherOS Storage, Snapshots & Backup Foundation is a comprehensive feature to design a solid, reusable storage and backup foundation for PantherOS across all NixOS hosts (laptops and VPS servers), aligned with the product roadmap and new goals around modularization and testing.

Key context:
- Multi-host NixOS project with laptops (Zephyrus, Yoga) and VPS servers (Hetzner, Contabo, OVH)
- Uses Nix flakes with modular structure evolving toward flake-parts
- Disko for declarative partitioning and Btrfs subvolumes
- 1Password + OpNix for secrets
- CI/CD via GitHub Actions
- Monitoring via Datadog (primary) and optionally Prometheus/Grafana/Loki
- Growing testing story with unit tests and integration tests

This feature should tie into:
- Phase 4: Backup & Disaster Recovery
- Phase 5: Btrfs Optimization Suite
- Phase 5: Snapshot & Backup Automation
- Configuration Cleanup & Modularization
- Testing & Validation Framework (unit + integration)
- CI/Deploy/Caching improvements for multi-host

High-level goal: Create a storage and backup foundation that defines host "profiles" (laptop vs VPS) with tuned Disko + Btrfs layouts, provides clear strategies for subvolume layout, mount options, local snapshots, and offsite backups, and is expressed as modular NixOS modules wired via flake-parts.

## Product Context

### Mission Alignment
This feature aligns with PantherOS's core mission to help "individual power users managing multiple personal machines and servers" achieve "100% reproducible, declarative infrastructure" by providing hardware-aware storage design and comprehensive backup strategies.

### Roadmap Integration
- **Phase 2 (Configuration Cleanup & Modularization)**: Storage foundation will be structured as modular NixOS modules
- **Phase 3 (Testing & Validation Framework)**: Storage modules will include nix-unit tests and NixOS VM tests
- **Phase 4 (Backup & Disaster Recovery)**: Primary deliverable - comprehensive backup strategy
- **Phase 5 (Btrfs Optimization Suite)**: Storage foundation enables workload-specific optimization
- **Phase 8 (Servers & Advanced Services)**: Integrates with monitoring and container services

### Tech Stack Alignment
- **NixOS with flakes + flake-parts**: Module structure and organization
- **Disko**: Declarative partitioning and Btrfs subvolume management
- **Btrfs**: Copy-on-write filesystem with snapshot support
- **Datadog**: Monitoring for snapshot/backup health and failures
- **nix-unit + NixOS VM Tests**: Testing framework for storage modules
- **GitHub Actions**: CI/CD integration for testing and validation

## Requirements Summary

### Functional Requirements

#### Host Profile Definitions

**1. Zephyrus (Heavy Dev Laptop)**
- Hardware: Dual NVMe SSDs (Crucial P3 2TB + Micron 2450 1TB)
- Workloads: Code repositories, Nix builds, Podman containers, development tools
- Storage Strategy: Separate pools (not RAID1)
  - Primary pool: Development work, containers, active data
  - Secondary pool: Data storage, backups, less-critical data
- Priority: Safety ≈ Developer Experience > Performance > Disk Wear
- RPO/RTO: ~1 hour RPO, 30-60 min RTO
- Subvolume Layout:
  - / (root)
  - /home (user data)
  - /home/dev (development work - nodatacow for builds)
  - /var/lib/containers (Podman - optimized mount options)
  - /nix (Nix store - nodatacow for performance)
  - /var/lib/postgresql (database - nodatacow)
  - /var/lib/redis (database - nodatacow)
  - /var/lib/backups (local backup storage)

**2. Yoga (Light/Mobile Laptop)**
- Hardware: Single NVMe SSD
- Workloads: Travel, presentations, light development
- Storage Strategy: Simpler storage layout with fewer subvolumes than Zephyrus
- Priority: Safety ≈ Developer Experience > Performance > Disk Wear
- RPO/RTO: ~1 hour RPO, 30-60 min RTO
- Subvolume Layout:
  - / (root)
  - /home (user data)
  - /var/lib/containers (Podman - smaller than Zephyrus)
  - /nix (Nix store)
  - /var/lib/backups (local backup storage)
  - Optional: Separate /var/lib/postgresql and /var/lib/redis if databases used

**3. Hetzner (Primary Production VPS - 458GB)**
- Workloads: PostgreSQL production database, Redis cache, web services, Podman containers, monitoring
- Storage Strategy: Most robust snapshot + backup strategy
- Priority: Reliability/Safety > Performance > Disk Wear
- RPO/RTO: 15-30 min target (most aggressive)
- Subvolume Layout:
  - / (root)
  - /home (user data)
  - /var/lib/containers (Podman for production services)
  - /nix (Nix store)
  - /var/lib/postgresql (production database - nodatacow)
  - /var/lib/redis (Redis cache - nodatacow)
  - /var/lib/backups (local backup storage)
  - /var/log (logs - with appropriate rotation)

**4. Contabo (Staging/Testing VPS)**
- Workloads: Staging environment mirroring Hetzner structure
- Storage Strategy: Logically similar to Hetzner but less aggressive snapshot/backup policies
- RPO/RTO: Few hours RPO, 1-2 hours RTO
- Subvolume Layout: Same as Hetzner but smaller allocations

**5. OVH (Extra Capacity/Utility VPS)**
- Workloads: Auxiliary services, experimental workloads, monitoring/caching
- Storage Strategy: Reuse server profile with less strict backup/snapshot policies
- RPO/RTO: Few hours RPO, 1-2 hours RTO
- Subvolume Layout: Simplified server profile

#### Database Management
- PostgreSQL: All hosts that run PostgreSQL
  - Separate subvolume with nodatacow mount option
  - Regular snapshots with database-aware backup procedures
  - Point-in-time recovery capability
- Redis: All hosts that run Redis
  - Separate subvolume with nodatacow mount option
  - Snapshot-aware backup with flush strategy
- Note: No MySQL in the environment

#### Container Management
- Podman: All hosts run Podman
  - Separate subvolume: /var/lib/containers
  - Btrfs-optimized mount options for container storage
  - Subvolume structure that allows for easy snapshot and backup
  - Image storage optimization with compression

#### Backup Strategy
- **Backup Target**: Backblaze B2
- **Budget**: $5-10/month
- **Backup Schedule**: Nightly off-peak backups
- **Backup Scope**: Snapshot replication for critical subvolumes
  - Database subvolumes (full backup with consistency checks)
  - Home directory (incremental with daily full)
  - Configuration subvolumes (/etc, application configs)
  - Container volumes (as needed)
- **Backup Validation**: Periodic restore testing

#### Snapshot Retention Policies
- **Laptops (Zephyrus, Yoga)**:
  - 7 daily snapshots (1 per day)
  - 4 weekly snapshots (1 per week)
  - 12 monthly snapshots (1 per month)
- **VPS (Hetzner, Contabo, OVH)**:
  - 30 daily snapshots (1 per day)
  - 12 weekly snapshots (1 per week)
  - 12 monthly snapshots (1 per month)
- **Automated Snapshot Management**: Cron/systemd timers to create and clean up snapshots

#### Monitoring & Alerting
- **Primary Monitoring**: Datadog
  - Snapshot creation success/failure
  - Backup completion status
  - Backup verification results
  - Retention policy violations
  - Disk space warnings
  - Snapshot age alerts
  - Backup transfer errors
- **Optional Stack**: Prometheus/Grafana/Loki for self-hosted monitoring
- **Alert Channels**: Email, Slack, or other configured notification methods

#### Testing Requirements
- **Unit Tests**: nix-unit tests for storage modules
  - Test disk layout generation
  - Test mount option logic
  - Test snapshot policy calculations
  - Test hardware detection and profile selection
- **Integration Tests**: NixOS VM tests for host profiles
  - Validate host profiles (laptop, server)
  - Test subvolume creation on first boot
  - Test snapshot and backup workflows
  - Verify monitoring integration
- **CI Integration**: GitHub Actions to run all tests on PRs

### Reusability Opportunities

#### Module Reuse Patterns
- **Shared Storage Module**: Core storage logic that all hosts use
- **Hardware Detection Module**: Detect host type and select appropriate profile
- **Snapshot Management Module**: Reusable snapshot creation/cleanup logic
- **Backup Module**: Reusable backup configuration and execution
- **Monitoring Integration Module**: Reusable Datadog monitoring setup

#### Code Patterns to Reference
Based on roadmap and tech stack:
- **flake-parts structure**: Use for organizing storage modules
- **Hardware detection patterns**: Refer to nixos-facter-modules integration
- **Module separation**: Follow modular configuration patterns from roadmap
- **Testing patterns**: Use nix-unit and NixOS VM tests as documented
- **Profile composition**: Hosts import profiles + host-specific overrides (as per Host Profiles system)

### Scope Boundaries

#### In Scope
1. Storage foundation design for all 5 hosts
2. Btrfs subvolume layouts per host profile
3. Disko configuration files for each host
4. Mount options optimization per workload
5. Snapshot automation and retention policies
6. Backup integration with Backblaze B2
7. Datadog monitoring for backup/snapshot health
8. Unit tests for storage modules
9. Integration tests for host profiles
10. CI integration for automated testing
11. Documentation for storage layouts and procedures

#### Out of Scope
1. Container orchestration (handled separately)
2. Application-level database backup (snapshot-level only)
3. Full disaster recovery runbook (future phase)
4. Binary cache management (separate feature)
5. Secrets management for backup credentials (handled by OpNix)
6. Performance benchmarking (future enhancement)
7. Multi-cloud backup targets (B2 only for this phase)

### Technical Considerations

#### Integration Points
- **flake-parts**: Module organization and composition
- **OpNix/1Password**: Backup credentials management
- **Datadog Agent**: Monitoring and alerting
- **GitHub Actions**: CI/CD and automated testing
- **nixos-facter-modules**: Hardware detection
- **Podman**: Container storage optimization
- **PostgreSQL**: Database-specific mount options and backup
- **Redis**: Cache storage optimization
- **Caddy Reverse Proxy**: Integration for web services (backup status endpoints)

#### Existing System Constraints
- **No mature storage modules exist**: This is a net-new design
- **Domain configuration**: hbohlen.systems with wildcard *.hbohlen.systems
- **Reverse proxy**: Caddy 2 with DNS-01 challenge (Cloudflare)
- **Facter.json files**: Exist per host with hardware details
- **Budget constraint**: $5-10/month for Backblaze B2
- **Off-peak schedule**: Backups must run during off-peak hours

#### Technology Preferences
- **Btrfs**: Primary filesystem for copy-on-write and snapshots
- **Disko**: Declarative partitioning and filesystem setup
- **flake-parts**: Module organization
- **nix-unit**: Unit testing framework
- **NixOS VM Tests**: Integration testing
- **Datadog**: Primary monitoring (Pro subscription available)
- **Podman**: Container runtime (no Docker)
- **B2**: Backup target (cost-effective, no egress fees)

## Module Structure Proposal

### Directory Structure

```
modules/storage/
├── default.nix                    # Main entry, imports all storage modules
├── profiles/
│   ├── laptop.nix                 # Common laptop storage profile
│   ├── server.nix                 # Common server storage profile
│   ├── dev-laptop.nix             # Zephyrus-specific profile
│   ├── light-laptop.nix           # Yoga-specific profile
│   ├── production-vps.nix         # Hetzner-specific profile
│   ├── staging-vps.nix            # Contabo-specific profile
│   └── utility-vps.nix            # OVH-specific profile
├── disko/
│   ├── laptop-disk.nix            # Shared laptop disk layout
│   ├── server-disk.nix            # Shared server disk layout
│   ├── dual-nvme-disk.nix         # Zephyrus dual NVMe layout
│   └── single-nvme-disk.nix       # Yoga/standard single NVMe layout
├── btrfs/
│   ├── subvolumes.nix             # Subvolume creation and management
│   ├── mount-options.nix          # Mount option definitions
│   └── compression.nix            # Compression configuration
├── snapshots/
│   ├── default.nix                # Main snapshot configuration
│   ├── policies.nix               # Retention policy definitions
│   └── automation.nix             # Snapshot automation (cron/systemd)
├── backup/
│   ├── default.nix                # Main backup configuration
│   ├── backblaze.nix              # Backblaze B2 integration
│   └── validation.nix             # Backup verification
└── monitoring/
    ├── datadog.nix                # Datadog monitoring integration
    └── alerts.nix                 # Alert configuration
```

```
profiles/storage/
├── laptop-base.nix                # Base laptop storage configuration
├── server-base.nix                # Base server storage configuration
├── with-databases.nix             # Add PostgreSQL/Redis subvolumes
├── with-containers.nix            # Add container subvolumes
└── minimal.nix                    # Minimal storage configuration
```

```
lib/storage/
├── default.nix                    # Entry point for storage helpers
├── hardware-profiles.nix          # Hardware detection and profiling
├── snapshot-helpers.nix           # Snapshot creation/cleanup helpers
├── backup-helpers.nix             # Backup helper functions
└── profile-selectors.nix          # Profile selection logic
```

### flake-parts Integration

The storage modules will be integrated into the flake-parts structure:

```nix
{
  imports = [
    # Storage modules
    ./modules/storage
    ./profiles/storage
    ./lib/storage
  ];

  perSystem = { system, ... }: {
    # Unit tests for storage modules
    checks."storage-unit-tests" = import ./tests/storage-unit-tests.nix { inherit system; };

    # Integration tests for storage profiles
    checks."storage-integration-tests" = import ./tests/storage-integration-tests.nix { inherit system; };

    # Dev shell includes testing tools
    devShells.default.packages = [
      # Testing utilities
    ];
  };
}
```

## Test Strategy

### Unit Tests (nix-unit)
Location: `tests/storage-unit-tests.nix`

Test coverage:
1. **Hardware Detection Tests**
   - Correct profile selection for Zephyrus (dual NVMe)
   - Correct profile selection for Yoga (single NVMe)
   - Correct profile selection for VPS instances
   - Profile attribute validation

2. **Subvolume Layout Tests**
   - Subvolume creation validation
   - Mount point validation
   - Subvolume hierarchy validation
   - Database subvolume configuration

3. **Mount Options Tests**
   - Database mount options (nodatacow)
   - Container mount options (Btrfs-optimized)
   - Nix store mount options (nodatacow)
   - Compression settings per workload

4. **Snapshot Policy Tests**
   - Retention count calculation
   - Snapshot naming convention
   - Policy application per host type
   - Cleanup logic validation

5. **Backup Configuration Tests**
   - Backblaze B2 configuration validation
   - Backup path mapping
   - Schedule validation (off-peak hours)
   - Credential handling (via OpNix)

### Integration Tests (NixOS VM Tests)
Location: `tests/storage-integration-tests.nix`

Test suites:
1. **Laptop Profile Tests** (zephyrus, yoga)
   - Boot with storage configuration
   - Subvolumes created correctly
   - Mount options applied
   - Snapshots created successfully
   - Container storage functional
   - Development workload compatibility

2. **Server Profile Tests** (hetzner, contabo, ovh)
   - Boot with storage configuration
   - Database subvolumes mounted correctly
   - Production workload compatibility
   - Container storage functional
   - Backup integration functional

3. **Snapshot & Backup Workflow Tests**
   - Snapshot creation on schedule
   - Retention policy enforcement
   - Backup to Backblaze B2
   - Backup verification
   - Monitoring alerts firing
   - Failure recovery

### CI Integration
GitHub Actions workflows:
1. **On Pull Request**
   - Run `nix flake check`
   - Run `nix build` for all storage configs
   - Execute unit tests (nix-unit)
   - Execute integration tests (NixOS VM)
   - Report test results

2. **On Merge to Main**
   - Full test suite
   - Deploy to staging (Contabo)
   - Validate staging deployment
   - Optional: Deploy to production (Hetzner) after manual approval

3. **Scheduled**
   - Nightly test runs
   - Backup verification tests
   - Monitoring alert tests

## Integration Points

### flake-parts Integration
- Storage modules imported as flake-parts modules
- Per-system test outputs for unit and integration tests
- Dev shell includes storage testing tools
- Checks exposed for CI validation

### Monitoring Integration
- **Datadog Agent**: Configured via module to collect:
  - Btrfs filesystem metrics
  - Snapshot creation/failure events
  - Backup completion status
  - Disk space utilization
  - Custom metrics for retention compliance
- **Alert Configuration**: Alerts for:
  - Failed snapshot creation
  - Failed backup transfer
  - Retention policy violations
  - Disk space warnings
  - Backup verification failures

### CI/CD Integration
- **GitHub Actions**: Matrix builds for all storage profiles
- **Test Automation**: Automated test execution on PRs
- **Deployment Validation**: Integration tests verify profiles work end-to-end
- **Rollback Support**: Storage configuration supports rollback procedures

### Secrets Management
- **OpNix Integration**: Backup credentials pulled from 1Password at deploy time
- **No Secrets in Config**: All credentials managed via OpNix
- **CI Secrets**: GitHub Actions secrets for CI/CD operations
- **Rotation**: 1Password for credential rotation

## Key Decisions Summary

1. **Separate Pools for Zephyrus**: Two NVMe SSDs as separate pools (not RAID1) to optimize for development workloads vs. data/backups
2. **Database Subvolumes**: Separate subvolumes for PostgreSQL and Redis with nodatacow on all hosts that run databases
3. **Container Subvolumes**: Dedicated /var/lib/containers subvolume on all hosts with Btrfs-optimized mount options
4. **Backblaze B2 Target**: $5-10/month budget, nightly off-peak backups with periodic restore testing
5. **Snapshot Retention**: Different policies for laptops (7/4/12) vs. VPS (30/12/12) for daily/weekly/monthly
6. **Monitoring First-Class**: Datadog integration from day one for snapshot/backup health monitoring
7. **Testing Required**: Unit tests (nix-unit) for module logic and integration tests (NixOS VM) for complete profiles
8. **flake-parts Structure**: Modular NixOS modules organized for reusability and composition
9. **Hardware-Aware Profiles**: Different storage layouts per hardware type (laptop vs VPS, dual vs single NVMe)
10. **Net-New Foundation**: No existing storage modules - building from scratch with best practices

## Next Steps for Write-Spec Phase

1. **Detailed Module Design**
   - Define module interfaces (options and config)
   - Specify implementation details for each module
   - Define profile composition patterns
   - Document module dependencies

2. **Disko Configuration Files**
   - Create disko configurations for each host
   - Define Btrfs subvolume trees
   - Specify mount options per subvolume
   - Validate with nix build

3. **Testing Implementation**
   - Write nix-unit tests for all storage modules
   - Create NixOS VM tests for each host profile
   - Set up CI integration for automated testing
   - Document testing patterns and best practices

4. **Documentation**
   - Write implementation guide for storage foundation
   - Document host profiles and when to use each
   - Create troubleshooting guide
   - Document disaster recovery procedures

5. **Implementation Roadmap**
   - Phase 1: Core storage modules and profiles
   - Phase 2: Snapshot and backup automation
   - Phase 3: Monitoring integration
   - Phase 4: Testing framework
   - Phase 5: Documentation and examples

## Visual Assets

No visual assets provided. User indicated plans for Mermaid/PlantUML diagrams in future phases, but prefers simple, clear designs focused on functionality over aesthetics for now.

## Notes

This requirements document synthesizes all requirements for the PantherOS Storage, Snapshots & Backup Foundation feature. The feature is designed to be modular, testable, and aligned with the broader PantherOS roadmap and technical architecture.

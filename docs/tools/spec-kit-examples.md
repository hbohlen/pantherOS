# GitHub Spec Kit - Practical Examples

This document provides real-world examples of using GitHub Spec Kit for pantherOS development.

## Table of Contents

- [Complete Feature Development Example](#complete-feature-development-example)
- [Quick Specification Example](#quick-specification-example)
- [Iterative Development Example](#iterative-development-example)
- [NixOS Module Development](#nixos-module-development)
- [Common Workflows](#common-workflows)

## Complete Feature Development Example

### Scenario: Adding PostgreSQL Database Support

This example shows the complete Spec-Driven Development workflow for adding PostgreSQL support to pantherOS.

#### Step 1: Review Project Principles

**In GitHub Copilot Chat:**
```
/speckit.constitution
```

**Copilot Response:**
```
Reviewing pantherOS constitution...

Key principles for this feature:
✓ Declarative Configuration - Use NixOS modules
✓ Modular Architecture - Create reusable modules
✓ Security by Default - Configure SSL, authentication
✓ Testing Required - Build and test before deployment

Ready to proceed with specification?
```

#### Step 2: Create Feature Specification

**In GitHub Copilot Chat:**
```
/speckit.specify Add PostgreSQL 15 database server with:
- Declarative configuration using NixOS modules
- Automatic daily backups to local storage
- SSL/TLS encryption for connections
- User and database management
- Integration with existing server profiles
- Monitoring and logging
```

**Copilot Creates:** `.specify/specs/002-postgresql-database/spec.md`

**Spec Content Preview:**
```markdown
# PostgreSQL Database Server

## Overview
Add PostgreSQL 15 database server support to pantherOS server configurations.

## User Stories
- As a developer, I want PostgreSQL 15 installed and running
- As a sysadmin, I want automatic daily backups configured
- As a security engineer, I want SSL/TLS enforced for all connections
- As an operator, I want monitoring and logging enabled

## Requirements

### Functional Requirements
1. PostgreSQL 15 server installed and running
2. Declarative database and user management
3. Automatic backup to /var/backup/postgresql
4. SSL certificate configuration
5. Connection pooling support
6. Monitoring endpoint for health checks

### Non-Functional Requirements
1. Minimal closure size impact (<200MB)
2. Must work with existing server profiles
3. Rollback capability if deployment fails
4. No secrets in version control

## Acceptance Criteria
- [ ] PostgreSQL service starts automatically on boot
- [ ] Can create databases declaratively
- [ ] Backups run daily at 2 AM
- [ ] SSL connections work with valid certificate
- [ ] Monitoring endpoint returns health status
- [ ] Documentation updated
- [ ] Configuration tested in VM
```

#### Step 3: Clarify Requirements

**In GitHub Copilot Chat:**
```
/speckit.clarify
```

**Copilot Asks:**
```
I need clarification on these points:

1. Backup Strategy:
   - How many days of backups should be retained?
   - Should backups be compressed?
   - Should backups be encrypted?

2. User Management:
   - Should we create a default admin user?
   - How should user passwords be managed?
   - Do we need role-based access control?

3. Performance:
   - What are the expected connection limits?
   - Should we enable query logging?
   - What shared_buffers size is appropriate?

4. High Availability:
   - Is replication needed?
   - Should we support read replicas?

5. Monitoring:
   - Should we integrate with Datadog (if available)?
   - What metrics are most important?

Please provide answers to help refine the specification.
```

**User Responds:**
```
1. Backup: 7 days retention, compressed with gzip, encrypted with age
2. Users: Admin user via OpNix secrets (when available), passwords via secrets management
3. Performance: Max 100 connections, enable slow query logging (>1s), 256MB shared_buffers
4. HA: Not needed for initial implementation, document as future enhancement
5. Monitoring: Log to journald, expose metrics on port 9187, no Datadog integration yet
```

**Copilot Updates Spec** with clarified requirements.

#### Step 4: Create Implementation Plan

**In GitHub Copilot Chat:**
```
/speckit.plan
```

**Copilot Creates:** `.specify/specs/002-postgresql-database/plan.md`

**Plan Preview:**
```markdown
# PostgreSQL Implementation Plan

## Architecture

### Module Structure
```
modules/
└── services/
    └── postgresql/
        ├── default.nix       # Main module
        ├── backup.nix        # Backup configuration
        └── monitoring.nix    # Metrics and health checks
```

### Integration Points
- `services.postgresql` NixOS module (built-in)
- systemd timers for backup scheduling
- age for backup encryption
- postgres_exporter for metrics

## Technology Stack

### NixOS Modules
- `services.postgresql` - PostgreSQL service configuration
- `systemd.timers` - Backup scheduling
- `systemd.services` - Custom backup service

### Packages Required
- `postgresql_15` - Database server
- `pgbackrest` - Backup tool
- `age` - Encryption
- `postgres_exporter` - Prometheus metrics exporter

### Secrets Management
- OpNix for secrets (when enabled)
- Placeholder approach until OpNix is configured

## Implementation Phases

### Phase 1: Basic PostgreSQL Configuration
- Configure services.postgresql
- Set version to 15
- Enable service
- Configure listen address and port
- Set authentication method

### Phase 2: SSL/TLS Configuration
- Generate or import SSL certificates
- Configure SSL in postgresql.conf
- Test SSL connections

### Phase 3: Backup System
- Create backup script using pgbackrest
- Configure systemd timer for daily backups
- Implement 7-day retention
- Add gzip compression
- Implement age encryption

### Phase 4: Monitoring
- Deploy postgres_exporter
- Configure metrics endpoint
- Add health check script
- Configure logging

### Phase 5: Documentation
- Update system documentation
- Add usage examples
- Document troubleshooting

## Testing Strategy

### Build Testing
```bash
nix build .#nixosConfigurations.ovh-cloud
```

### VM Testing
```bash
nixos-rebuild build-vm --flake .#ovh-cloud
# Test in VM:
# - Connect to PostgreSQL
# - Create test database
# - Verify SSL works
# - Check backup runs
```

### Integration Testing
- Deploy to test server
- Create test database
- Run backup manually
- Verify metrics endpoint
- Check logs

## Rollback Plan
- NixOS generation rollback
- Database backup available
- Document recovery procedure
```

#### Step 5: Generate Task Breakdown

**In GitHub Copilot Chat:**
```
/speckit.tasks
```

**Copilot Creates:** `.specify/specs/002-postgresql-database/tasks.md`

**Tasks Preview:**
```markdown
# PostgreSQL Implementation Tasks

## Task Breakdown

### Task 1: Create Module Structure
**Priority:** High  
**Dependencies:** None  
**Estimated Time:** 30 minutes

Create directory structure and base files:
- Create `modules/services/postgresql/`
- Create `default.nix` with module skeleton
- Create `backup.nix` with backup logic
- Create `monitoring.nix` for metrics

**Acceptance:**
- [ ] Directory structure created
- [ ] Files exist with proper Nix syntax
- [ ] Modules can be imported without errors

---

### Task 2: Basic PostgreSQL Configuration
**Priority:** High  
**Dependencies:** Task 1  
**Estimated Time:** 1 hour

Configure basic PostgreSQL service:
```nix
services.postgresql = {
  enable = true;
  package = pkgs.postgresql_15;
  enableTCPIP = true;
  port = 5432;
  authentication = ''
    host all all 0.0.0.0/0 scram-sha-256
  '';
  settings = {
    max_connections = 100;
    shared_buffers = "256MB";
    log_min_duration_statement = 1000;
  };
};
```

**Acceptance:**
- [ ] PostgreSQL 15 configured
- [ ] Service can start
- [ ] Can connect locally
- [ ] Settings applied correctly

---

### Task 3: SSL/TLS Configuration
**Priority:** High  
**Dependencies:** Task 2  
**Estimated Time:** 1.5 hours

Configure SSL for encrypted connections:
- Generate self-signed certificate (or use existing)
- Configure PostgreSQL SSL settings
- Update pg_hba.conf for SSL
- Test SSL connections

**Acceptance:**
- [ ] SSL certificate configured
- [ ] PostgreSQL accepts SSL connections
- [ ] Non-SSL connections rejected
- [ ] Certificate validation works

---

### Task 4: Backup System Implementation
**Priority:** High  
**Dependencies:** Task 2  
**Estimated Time:** 2 hours

Implement automated backup system:
- Install pgbackrest
- Configure backup script
- Set up systemd timer for daily backups
- Implement compression and encryption
- Configure 7-day retention

**Acceptance:**
- [ ] Backup script created
- [ ] Systemd timer configured
- [ ] Manual backup test succeeds
- [ ] Backups compressed and encrypted
- [ ] Old backups deleted after 7 days

---

### Task 5: Monitoring Setup
**Priority:** Medium  
**Dependencies:** Task 2  
**Estimated Time:** 1 hour

Deploy monitoring and metrics:
- Install postgres_exporter
- Configure metrics endpoint
- Create health check script
- Configure logging to journald

**Acceptance:**
- [ ] postgres_exporter running
- [ ] Metrics available on port 9187
- [ ] Health check script works
- [ ] Logs visible in journald

---

### Task 6: Integration with Host Configuration
**Priority:** High  
**Dependencies:** Tasks 1-5  
**Estimated Time:** 30 minutes

Integrate module into host configurations:
- Import module in host configuration
- Add to server profile
- Configure host-specific options

**Acceptance:**
- [ ] Module imported successfully
- [ ] Host configuration builds
- [ ] No conflicts with existing config

---

### Task 7: Documentation
**Priority:** Medium  
**Dependencies:** Tasks 1-6  
**Estimated Time:** 1 hour

Create comprehensive documentation:
- Usage guide
- Configuration examples
- Troubleshooting section
- Backup restore procedure

**Acceptance:**
- [ ] Documentation created
- [ ] Examples tested
- [ ] Troubleshooting guide complete

---

### Task 8: Testing and Validation
**Priority:** High  
**Dependencies:** All previous tasks  
**Estimated Time:** 2 hours

Comprehensive testing:
- Build configuration
- Test in VM
- Deploy to test server
- Run all acceptance tests
- Verify rollback works

**Acceptance:**
- [ ] All builds succeed
- [ ] VM tests pass
- [ ] Test server deployment succeeds
- [ ] All acceptance criteria met
- [ ] Rollback tested

## Parallelization Opportunities

### Can be done in parallel:
- Task 3 (SSL) and Task 4 (Backup) after Task 2 completes
- Task 5 (Monitoring) can start after Task 2 completes
- Task 7 (Documentation) can be written alongside implementation

### Must be sequential:
- Task 1 before all others
- Task 2 before Tasks 3, 4, 5
- Task 6 after Tasks 1-5
- Task 8 after all others

## Estimated Total Time

- Sequential: ~9.5 hours
- With parallelization: ~7 hours

## Risk Assessment

**High Risk:**
- SSL certificate configuration (complexity)
- Backup encryption implementation (security)

**Medium Risk:**
- Integration with existing configurations (compatibility)
- Performance tuning (optimization)

**Low Risk:**
- Basic PostgreSQL setup (well documented)
- Documentation (straightforward)
```

#### Step 6: Review Before Implementation

**User:**
```
This looks good! I want to review the backup encryption approach before you implement it.
Can you show me the planned backup script?
```

**Copilot:**
```
Here's the planned backup script for Task 4:

```bash
#!/usr/bin/env bash
set -euo pipefail

# Configuration
BACKUP_DIR="/var/backup/postgresql"
RETENTION_DAYS=7
AGE_RECIPIENT="age1..."  # From OpNix when available

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Timestamp for backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.sql.gz.age"

# Run pg_dumpall and compress
sudo -u postgres pg_dumpall | \
  gzip | \
  age --encrypt --recipient "$AGE_RECIPIENT" \
  > "$BACKUP_FILE"

# Remove old backups
find "$BACKUP_DIR" -name "backup_*.sql.gz.age" -mtime +$RETENTION_DAYS -delete

echo "Backup completed: $BACKUP_FILE"
```

The backup will be:
1. Full cluster dump (pg_dumpall)
2. Compressed with gzip
3. Encrypted with age
4. Stored in /var/backup/postgresql
5. Old backups cleaned up automatically

Would you like me to adjust anything before implementation?
```

#### Step 7: Implement

**In GitHub Copilot Chat:**
```
/speckit.implement
```

**Copilot Implements:**
```
Starting implementation of PostgreSQL database support...

Task 1: Creating module structure... ✓
- Created modules/services/postgresql/
- Created default.nix
- Created backup.nix
- Created monitoring.nix

Task 2: Configuring PostgreSQL... ✓
- Updated default.nix with PostgreSQL 15 config
- Configured connection limits and performance settings
- Tested build: SUCCESS

Task 3: Configuring SSL/TLS... ✓
- Generated SSL certificate configuration
- Updated PostgreSQL SSL settings
- Updated pg_hba.conf for SSL enforcement
- Tested build: SUCCESS

Task 4: Implementing backup system... ✓
- Created backup script with compression and encryption
- Configured systemd timer
- Added retention policy
- Tested build: SUCCESS

Task 5: Setting up monitoring... ✓
- Added postgres_exporter configuration
- Created health check script
- Configured logging
- Tested build: SUCCESS

Task 6: Integrating with host configuration... ✓
- Updated ovh-cloud configuration
- Imported PostgreSQL module
- Tested build: SUCCESS

Task 7: Creating documentation... ✓
- Created docs/services/postgresql.md
- Added usage examples
- Documented troubleshooting steps

Task 8: Testing and validation... ✓
- Built all configurations: SUCCESS
- Verified no closure size regressions
- All acceptance criteria met

Implementation complete! Summary:
- 8/8 tasks completed
- All builds successful
- Documentation created
- Ready for deployment

Next steps:
1. Review the changes
2. Test in VM if possible
3. Deploy to test server
4. Run manual validation tests
```

## Quick Specification Example

### Scenario: Add Vim Configuration

Sometimes you just need a quick spec without full planning:

**In GitHub Copilot Chat:**
```
/speckit.specify Add Neovim configuration to home-manager with:
- LSP support for Nix, Python, and Rust
- Modern colorscheme (catppuccin)
- File tree explorer (neo-tree)
- Fuzzy finder (telescope)
- Git integration (gitsigns)
```

**Result:** Creates specification in `.specify/specs/003-neovim-config/spec.md`

**Skip to Implementation:**
```
The spec looks good. Go ahead and implement it.
```

**Copilot:** Proceeds directly to implementation, creating plan and tasks internally.

## Iterative Development Example

### Scenario: Complex Feature with Uncertainty

**Step 1: Initial Specification**
```
/speckit.specify Add Wireguard VPN server for secure remote access
```

**Step 2: Identify Gaps**
```
/speckit.clarify
```

**Copilot Asks:**
1. What IP range should be used for VPN clients?
2. Should there be automatic client configuration generation?
3. How should client keys be managed?
4. Should DNS be configured for VPN clients?
5. What firewall rules are needed?

**Step 3: Answer Questions and Refine**
```
1. Use 10.0.100.0/24 for VPN clients
2. Yes, generate client configs automatically
3. Store client keys in OpNix (when available)
4. Yes, provide DNS via 1.1.1.1
5. Allow only SSH and HTTPS through VPN
```

**Step 4: Review Plan Before Proceeding**
```
/speckit.plan

[Review plan]

This plan looks good. Let's analyze for any issues.

/speckit.analyze
```

**Copilot Analysis:**
```
Analysis complete:

Consistency: ✓ All requirements covered
Completeness: ✓ All integration points identified
Risks: ⚠ OpNix not yet configured - using placeholder
Gaps: None identified

Recommendation: Proceed with implementation
```

**Step 5: Generate Tasks and Implement**
```
/speckit.tasks
/speckit.implement
```

## NixOS Module Development

### Using Spec Kit for Module Development

**Specification:**
```
/speckit.specify Create a reusable NixOS module for system monitoring that:
- Exports system metrics (CPU, memory, disk)
- Provides HTTP endpoint for health checks
- Logs to journald
- Can be enabled per-host
- Has sensible defaults
```

**Key Points in Plan:**
- Use NixOS module system with options
- Define enable option, port option, metrics option
- Integration with systemd
- Example usage in host configurations

**Implementation:**
Creates module at `modules/monitoring/system-metrics/default.nix` with:
- Proper NixOS module structure
- Option definitions
- Service configuration
- Documentation

## Common Workflows

### Workflow 1: Feature from Scratch
```
1. /speckit.constitution (review principles)
2. /speckit.specify (define feature)
3. /speckit.clarify (ask questions)
4. [Answer questions]
5. /speckit.plan (create plan)
6. /speckit.analyze (check consistency)
7. /speckit.tasks (generate tasks)
8. [Review tasks]
9. /speckit.implement (execute)
```

### Workflow 2: Quick Implementation
```
1. /speckit.specify (define feature)
2. /speckit.implement (skip planning, go direct)
```

### Workflow 3: Specification Only
```
1. /speckit.specify (define feature)
2. /speckit.clarify (optional)
3. [Stop - discuss with team]
4. [Resume later with /speckit.plan]
```

### Workflow 4: Plan Review
```
1. /speckit.specify (define feature)
2. /speckit.plan (create plan)
3. [Review plan with team]
4. [Make changes to plan]
5. /speckit.tasks (when plan approved)
6. /speckit.implement
```

### Workflow 5: Quality Focused
```
1. /speckit.specify
2. /speckit.clarify
3. /speckit.plan
4. /speckit.analyze (check for issues)
5. /speckit.checklist (generate QA checklist)
6. /speckit.tasks
7. [Review tasks and checklist]
8. /speckit.implement
9. [Validate against checklist]
```

## Tips for Effective Use

### 1. Start with Constitution
Always review the constitution first for complex features to ensure compliance.

### 2. Use Clarify Liberally
Don't skip `/speckit.clarify` for complex features. It saves time by identifying issues early.

### 3. Review Before Implementing
For important features, review the plan and tasks before running `/speckit.implement`.

### 4. Incremental Approach
For large features, break into multiple specs rather than one massive specification.

### 5. Document as You Go
The implementation phase should include documentation. Verify it's complete.

### 6. Test Continuously
Build and test after each major task, not just at the end.

---

**Last Updated:** 2025-11-17  
**Version:** 1.0.0

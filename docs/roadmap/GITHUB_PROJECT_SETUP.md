# GitHub Project Setup Guide

> **Purpose:** Step-by-step guide to create GitHub Project board from issue templates  
> **Audience:** Project maintainers  
> **Estimated Time:** 2-3 hours initial setup

## Overview

This guide walks through creating a complete GitHub Project board with:
- 120+ issues organized into epics
- Custom fields for OpenSpec integration
- Multiple views (Kanban, Phase, Area, Dependencies)
- Automated workflows

## Prerequisites

- [ ] GitHub repository access with admin rights
- [ ] `docs/roadmap/GITHUB_ISSUES.md` file available
- [ ] OpenSpec CLI installed
- [ ] Familiarity with GitHub Projects (beta)

---

## Part 1: Create the Project

### Step 1.1: Initialize Project

1. Navigate to repository on GitHub
2. Click **Projects** tab
3. Click **New project** → **Start from scratch**
4. Name: `PantherOS Roadmap`
5. Description: `Comprehensive project roadmap tracking all NixOS configuration work`
6. Set visibility to **Private** (or Public based on preference)

### Step 1.2: Initial Board Setup

Default board created with columns:
- Todo
- In Progress  
- Done

We'll customize these in Part 3.

---

## Part 2: Configure Custom Fields

### Step 2.1: Add Status Field

1. Click **Settings** (gear icon)
2. Click **+ New field**
3. Field name: `Status`
4. Type: **Single select**
5. Add options:
   - Backlog (gray)
   - Ready (blue)
   - Researching (purple)
   - In Progress (yellow)
   - Blocked (red)
   - In Review (orange)
   - Done (green)

### Step 2.2: Add Priority Field

1. Click **+ New field**
2. Field name: `Priority`
3. Type: **Single select**
4. Add options:
   - High (red)
   - Medium (yellow)
   - Low (gray)

### Step 2.3: Add Size Field

1. Click **+ New field**
2. Field name: `Size`
3. Type: **Single select**
4. Add options:
   - XS (15-20 min)
   - S (20-45 min)
   - M (45-75 min)
   - L (75-90 min)
   - XL (Multiple sessions)
   - XXL (Epic level)

### Step 2.4: Add Iteration Field

1. Click **+ New field**
2. Field name: `Iteration`
3. Type: **Single select**
4. Add options:
   - MVP
   - Beta
   - v1.0
   - Post-v1
   - Experiment

### Step 2.5: Add Estimate Field

1. Click **+ New field**
2. Field name: `Estimate`
3. Type: **Number**
4. Description: `Time estimate in minutes`

### Step 2.6: Add OpenSpec Fields

**Field 1: Spec ID**
1. Click **+ New field**
2. Field name: `Spec ID`
3. Type: **Text**
4. Description: `OpenSpec change ID (e.g., add-gitlab-ci-infrastructure)`

**Field 2: Spec Type**
1. Click **+ New field**
2. Field name: `Spec Type`
3. Type: **Single select**
4. Add options:
   - Proposal
   - Change
   - Decision
   - N/A

**Field 3: Doc Path**
1. Click **+ New field**
2. Field name: `Doc Path`
3. Type: **Text**
4. Description: `Link to primary spec or doc file`

---

## Part 3: Create Labels

### Step 3.1: Area Labels

Navigate to **Issues** → **Labels** → **New label**

Create the following area labels (color: blue `#0366d6`):

```
area/infrastructure
area/desktop
area/ci-cd
area/configuration
area/terminal
area/editor
area/power
area/storage
area/networking
area/security
area/hardware
```

### Step 3.2: Type Labels

Create type labels (color: green `#28a745`):

```
type/feature
type/bug
type/research
type/decision
type/task
type/enhancement
type/documentation
```

### Step 3.3: Device/Host Labels

Create device labels (color: yellow `#ffd33d`):

```
device/zephyrus
device/yoga
host/hetzner
host/ovh
host/contabo
```

### Step 3.4: Component Labels

Create component labels (color: purple `#6f42c1`):

```
package/dms
package/ghostty
package/zed
service/postgresql
service/attic
service/caddy
service/systemd
ci/gitlab
ci/github-actions
```

---

## Part 4: Create Issues

### Step 4.1: Epic Issues (Phase-Level)

Create parent epic issues for each phase. Use this template:

**Example: Phase 2 Epic**

```markdown
Title: [EPIC] Personal Device Configuration

Labels: type/epic, device/zephyrus, device/yoga, area/configuration

Description:
Set up full NixOS configurations for personal development laptops (ASUS ROG Zephyrus and Lenovo Yoga) with hardware detection, device-specific optimizations, and desktop environment integration.

**Status:** In Progress
**Priority:** High
**Size:** XXL
**Iteration:** MVP
**OpenSpec ID:** add-personal-device-hosts
**Doc Path:** openspec/changes/add-personal-device-hosts/

## Dependencies
- Blocked by: None (foundation complete)
- Blocks: Desktop environment features

## Acceptance Criteria
- [ ] Both devices have complete hardware configurations
- [ ] Devices build successfully with `nix flake check`
- [ ] Home Manager configurations deployed
- [ ] All hardware features functional (WiFi, GPU, power management)

## Progress
50% complete (Yoga done, Zephyrus pending)

## Sub-issues
- #X: Complete Zephyrus Hardware Scan
- #Y: Create Zephyrus Host Configuration
- #Z: Configure Zephyrus Power Management
```

**Create epics for:**
1. Foundation Infrastructure (✅ Done - create as complete)
2. Personal Device Configuration
3. Desktop Environment Setup
4. Terminal and Editor Setup
5. GitLab CI Pipeline
6. Server Fleet Expansion
7. Advanced Desktop Compositor
8. Material Design Theming
9. BTRFS Optimization

### Step 4.2: Feature Issues

For each feature in `GITHUB_ISSUES.md`, create an issue:

**Example Issue Template:**

```markdown
Title: Complete Zephyrus Hardware Scan

Labels: area/hardware, type/task, device/zephyrus

Description:
Run `nixos-facter` on the ASUS ROG Zephyrus laptop to generate complete hardware configuration.

**Status:** Todo
**Priority:** High
**Size:** S
**Estimate:** 30
**Iteration:** MVP
**Spec ID:** add-personal-device-hosts
**Doc Path:** openspec/changes/add-personal-device-hosts/

## Why
Need accurate hardware detection for proper device configuration

## How
1. Boot Zephyrus with NixOS live USB or existing Linux
2. Run hardware scanning script
3. Transfer JSON output to repository
4. Commit hardware report

## Checklist
- [ ] Access Zephyrus laptop physically
- [ ] Run `sudo scripts/scan-hardware.fish zephyrus`
- [ ] Verify JSON report generated at `docs/hardware/zephyrus-facter.json`
- [ ] Review hardware specifications detected
- [ ] Commit hardware report to repository

## Acceptance Criteria
- Hardware JSON file exists at `docs/hardware/zephyrus-facter.json`
- File contains CPU, GPU, RAM, storage, and network interface data
- File validates as proper JSON

## Dependencies
Requires physical access to Zephyrus laptop

## Reference
docs/hardware-scanning-workflow.md
```

### Step 4.3: Bulk Issue Creation

**Manual Method:**
1. Open `docs/roadmap/GITHUB_ISSUES.md`
2. Copy each issue section
3. Create GitHub issue
4. Set labels and fields
5. Link to parent epic

**Script Method (Advanced):**

Create a script to automate:

```bash
#!/usr/bin/env bash
# create-issues.sh

# Requires: gh CLI tool (GitHub CLI)
# Install: https://cli.github.com/

REPO="${GITHUB_REPOSITORY:-hbohlen/pantherOS}"
PROJECT="PantherOS Roadmap"

# Function to create issue
create_issue() {
  local title="$1"
  local body="$2"
  local labels="$3"
  
  gh issue create \
    --repo "$REPO" \
    --title "$title" \
    --body "$body" \
    --label "$labels"
}

# Example: Create Zephyrus hardware scan issue
create_issue \
  "Complete Zephyrus Hardware Scan" \
  "$(cat issue-zephyrus-scan.md)" \
  "area/hardware,type/task,device/zephyrus"

# ... repeat for all issues
```

---

## Part 5: Configure Project Views

### Step 5.1: Default Kanban View

1. Go to project **Settings**
2. Rename "Board" to "Kanban"
3. Group by: **Status**
4. Sort by: **Priority** (High → Low)
5. Filter: `iteration:MVP` (focus on current iteration)

Columns should be:
- Backlog
- Ready
- In Progress
- Blocked
- In Review
- Done

### Step 5.2: Phase View

1. Click **+ New view**
2. Name: `Phase View`
3. Layout: **Board**
4. Group by: **Iteration**
5. Sort by: **Priority**
6. Filter: `-status:Done` (hide completed)

### Step 5.3: Area View

1. Click **+ New view**
2. Name: `Area View`
3. Layout: **Board**
4. Group by: **Label** (filter to `area/*` labels)
5. Sort by: **Priority**

### Step 5.4: Dependencies Table

1. Click **+ New view**
2. Name: `Dependencies`
3. Layout: **Table**
4. Columns: Title, Status, Priority, Size, Spec ID, Assignee
5. Sort by: **Priority**
6. Grouping: None

### Step 5.5: Timeline View

1. Click **+ New view**
2. Name: `Timeline`
3. Layout: **Board**
4. Group by: **Iteration**
5. Sort by: **Created date**
6. Show: All issues

---

## Part 6: Set Up Automations

### Step 6.1: Auto-add Issues to Project

1. Go to project **Settings**
2. Click **Workflows**
3. Enable "Auto-add to project"
4. Configure:
   - When: Issue is created
   - In: This repository
   - Add to: This project
   - Set status: Backlog

### Step 6.2: Status Transitions

**Workflow: PR Opened → In Review**
1. Create workflow
2. Trigger: Pull request opened
3. Action: Set status to "In Review"

**Workflow: PR Merged → Done**
1. Create workflow
2. Trigger: Pull request merged
3. Action: Set status to "Done"

**Workflow: Issue Closed → Done**
1. Create workflow
2. Trigger: Issue closed
3. Action: Set status to "Done"

### Step 6.3: Priority Escalation

**Workflow: Stale High Priority**
1. Create workflow
2. Trigger: Issue updated > 7 days ago
3. Condition: Priority = High AND Status = In Progress
4. Action: Add comment "This high priority issue needs attention"

---

## Part 7: Link Issues and Dependencies

### Step 7.1: Epic-to-Issue Links

For each feature issue:
1. Open issue
2. In right sidebar, click **Development**
3. Select parent epic issue
4. Click **Link**

### Step 7.2: Issue Dependencies

In issue descriptions, use:
- `Blocked by: #123` - This issue needs #123 complete first
- `Blocks: #456` - #456 cannot start until this completes
- `Related to: #789` - Similar or connected work

### Step 7.3: Milestone Linkage

Create milestones:
1. Go to **Issues** → **Milestones**
2. Create milestone for each phase:
   - MVP (Due: 2024-12-31)
   - Beta (Due: 2025-02-28)
   - v1.0 (Due: 2025-04-30)

Link issues to appropriate milestones.

---

## Part 8: Populate Initial Data

### Step 8.1: Import Completed Work

Mark Phase 1 issues as complete:
- Create issues for completed changes
- Set status to "Done"
- Add completion dates in comments
- Link to merged PRs

### Step 8.2: Set Current Sprint

1. Identify current work items
2. Set status to "In Progress"
3. Assign to team members
4. Set priority and size

### Step 8.3: Backlog Grooming

1. Review all "Backlog" items
2. Ensure proper priority
3. Verify labels and fields
4. Check dependencies

---

## Part 9: Documentation

### Step 9.1: Project README

Add to project description:

```markdown
# PantherOS Roadmap

Complete tracking of NixOS configuration project development.

## Views
- **Kanban**: Current sprint work
- **Phase View**: Work organized by project phase
- **Area View**: Work organized by technical area
- **Dependencies**: Detailed table with all metadata
- **Timeline**: Historical view of all work

## Fields
- **Status**: Current state of work item
- **Priority**: Urgency (High/Medium/Low)
- **Size**: Effort estimate (XS-XXL)
- **Iteration**: Project phase (MVP, Beta, v1.0, etc.)
- **Spec ID**: OpenSpec change ID
- **Spec Type**: Proposal/Change/Decision/N/A
- **Doc Path**: Link to primary documentation

## Labels
- `area/*`: Technical area
- `type/*`: Work item type
- `device/*`: Target device
- `host/*`: Target server host

## Getting Started
1. Check **Kanban** view for current sprint
2. Pick items from **Ready** column
3. Update status as you work
4. Link PRs to issues

## Resources
- [Project Roadmap](../docs/roadmap/PROJECT_ROADMAP.md)
- [Architecture](../docs/roadmap/ARCHITECTURE.md)
- [ADR Index](../docs/decisions/README.md)
```

### Step 9.2: Update Repository README

Add project board link to main README:

```markdown
## 📊 Project Tracking

View our [GitHub Project Board](https://github.com/hbohlen/pantherOS/projects/1) for:
- Current roadmap and progress
- Issue tracking and dependencies
- Phase-based planning
- Technical area breakdown

See also:
- [Project Roadmap](docs/roadmap/PROJECT_ROADMAP.md)
- [Architecture Documentation](docs/roadmap/ARCHITECTURE.md)
```

---

## Part 10: Ongoing Maintenance

### Daily Tasks
- [ ] Update issue statuses
- [ ] Link new PRs to issues
- [ ] Review blocked items

### Weekly Tasks
- [ ] Groom backlog
- [ ] Update priorities
- [ ] Review dependencies
- [ ] Sprint planning

### Monthly Tasks
- [ ] Phase progress review
- [ ] Update roadmap
- [ ] Archive completed epics
- [ ] Update documentation

---

## Tips & Best Practices

### Issue Management

1. **Keep issues atomic**: 15-90 minutes of focused work
2. **Use checklists**: Break down complex tasks
3. **Link liberally**: Connect related issues, PRs, docs
4. **Update promptly**: Keep status current
5. **Close with detail**: Document what was done

### Project Board

1. **Review views regularly**: Each view serves a purpose
2. **Filters are your friend**: Focus on what matters now
3. **Automate what you can**: Reduce manual work
4. **Keep it visual**: Use labels, colors, groups
5. **Document decisions**: Add comments explaining changes

### OpenSpec Integration

1. **Always link Spec ID**: Connect issues to requirements
2. **Reference proposals**: Link to OpenSpec change docs
3. **Update specs**: When work completes, archive specs
4. **Validate frequently**: Run `openspec validate --strict`

---

## Troubleshooting

### Issue: Can't see custom fields

**Solution:** Custom fields are project-specific. Make sure you're viewing the project board, not the repository issues list.

### Issue: Automation not working

**Solution:** Check project workflows are enabled in Settings → Workflows. Verify trigger conditions.

### Issue: Too many issues, overwhelmed

**Solution:** Use filters aggressively. Focus on current iteration only. Hide completed items.

### Issue: Dependencies not clear

**Solution:** Use Dependencies table view. Draw diagrams for complex dependency chains.

### Issue: Labels inconsistent

**Solution:** Create label guidelines. Use label templates. Review labels regularly.

---

## Appendix: Quick Reference

### GitHub CLI Commands

```bash
# List issues
gh issue list --repo hbohlen/pantherOS

# Create issue
gh issue create --title "Title" --body "Body" --label "label1,label2"

# Update issue
gh issue edit 123 --add-label "area/desktop"

# Close issue
gh issue close 123 --comment "Completed in #456"

# List projects
gh project list --owner hbohlen

# View project
gh project view 1
```

### Useful Filters

```
# Current sprint
iteration:MVP status:Ready,In-Progress

# High priority blocked
priority:High status:Blocked

# Personal device work
device/zephyrus OR device/yoga

# CI/CD related
area/ci-cd

# This week's completed work
status:Done updated:>7days
```

---

## Checklist: Project Setup Complete

- [ ] Project created
- [ ] All custom fields added (8 fields)
- [ ] All labels created (20+ labels)
- [ ] Epic issues created (9 epics)
- [ ] Feature issues created (120+ issues)
- [ ] Views configured (5 views)
- [ ] Automations set up (3+ workflows)
- [ ] Dependencies linked
- [ ] Milestones created
- [ ] Documentation updated
- [ ] Team members added
- [ ] Initial sprint planned

---

**Estimated Setup Time**: 2-3 hours

**Maintenance Time**: 15-30 minutes daily

**Review Cycle**: Weekly sprint planning, monthly phase review

**Last Updated**: 2025-12-04

---
description: "Automated Gap Analysis integration with Claude Memory"
category: integration
workflow_type: automated
triggers: [gap-analysis-command, memory-integration-command]
---

# Gap Analysis to Claude Memory Workflow

## Overview

This workflow automates the process of running gap analysis and saving results to Claude Memory for tracking and remediation.

## Workflow Steps

### Step 1: Execute Gap Analysis

**Action**: Run comprehensive gap analysis on pantherOS project

**Command**: `/gap-analyze`

**Context Loaded**:
- `.opencode/context/project/project-context.md`
- `.opencode/context/domain/nixos-configuration.md`
- `.opencode/context/domain/hardware-specifications.md`
- `.bmad-core/data/bmad-kb.md`

**Expected Output**:
```markdown
Gap Analysis Results
====================

1. **Hardware Optimization Documentation** (Priority: High)
   - Missing optimization docs for zephyrus NVIDIA config
   - Incomplete power management settings
   - No thermal profile documentation

2. **Security Hardening** (Priority: High)
   - SSH configuration needs review
   - Firewall rules incomplete for servers
   - No fail2ban configuration for web services

3. **Monitoring & Observability** (Priority: Medium)
   - No system monitoring setup
   - Missing log aggregation
   - No performance metrics collection

4. **Backup Strategy** (Priority: Medium)
   - Incomplete backup automation
   - No offsite backup validation
   - Missing disaster recovery plan

5. **Module Organization** (Priority: Low)
   - Some modules could be more modular
   - Documentation could be better organized
```

### Step 2: Parse and Categorize Gaps

**Action**: Parse gap analysis output and categorize by priority and type

**Categories**:
- **Hardware**: Hardware-specific gaps
- **Security**: Security and hardening gaps
- **Monitoring**: Observability and monitoring gaps
- **Backup**: Backup and disaster recovery gaps
- **Documentation**: Documentation gaps
- **Organization**: Code organization gaps

**Priority Levels**:
- **High**: Critical issues requiring immediate attention
- **Medium**: Important improvements
- **Low**: Nice-to-have enhancements

### Step 3: Save to Claude Memory

**Action**: Save each gap as a task in Claude Memory

**Command Format**:
```bash
claude-memory task add "Gap: [Gap Name]" \
  --priority [high|medium|low] \
  --category gap-analysis \
  --description "[Detailed description]"
```

**Example**:
```bash
# Save Hardware gaps
claude-memory task add "Gap: Hardware optimization documentation incomplete" \
  --priority high \
  --category hardware \
  --description "Missing optimization docs for zephyrus NVIDIA config, incomplete power management settings"

claude-memory task add "Gap: Thermal profile documentation missing" \
  --priority medium \
  --category hardware \
  --description "No thermal profile documentation for high-performance workloads"

# Save Security gaps
claude-memory task add "Gap: SSH configuration security review needed" \
  --priority high \
  --category security \
  --description "SSH configuration needs review for all hosts"

claude-memory task add "Gap: Incomplete firewall rules for servers" \
  --priority high \
  --category security \
  --description "Firewall rules incomplete for hetzner-vps and ovh-vps"

# Save Monitoring gaps
claude-memory task add "Gap: No system monitoring setup" \
  --priority medium \
  --category monitoring \
  --description "Missing system monitoring and performance metrics"
```

**Automated Script**:
```bash
#!/bin/bash
# gap-to-memory.sh

GAP_OUTPUT="$1"

# Parse gaps from output
while IFS= read -r line; do
  if [[ $line =~ ^[0-9]+\.\ \*\*([^*]+)\*\*.*Priority:\ ([A-Za-z]+) ]]; then
    GAP_NAME="${BASH_REMATCH[1]}"
    PRIORITY="${BASH_REMATCH[2],,}"  # lowercase

    # Read next line for description
    read -r desc_line

    # Save to memory
    claude-memory task add "Gap: $GAP_NAME" \
      --priority "$PRIORITY" \
      --category gap-analysis \
      --description "$desc_line"

    echo "✓ Saved gap: $GAP_NAME"
  fi
done <<< "$GAP_OUTPUT"

echo ""
echo "All gaps saved to Claude Memory!"
echo "View with: claude-memory task list --category gap-analysis"
```

### Step 4: Generate Gap Report

**Action**: Create comprehensive gap report with next steps

**Report Structure**:
```markdown
# Gap Analysis Report - $(date)

## Summary
- **Total Gaps**: X
- **High Priority**: X
- **Medium Priority**: X
- **Low Priority**: X

## High Priority Gaps

### 1. Gap Name
**Description**: Details
**Action Items**:
- [ ] Research solution
- [ ] Implement fix
- [ ] Verify solution

## Medium Priority Gaps

[Similar structure]

## Remediation Workflow

For each high-priority gap:

1. **Research** → `/swarm-research "[gap topic]"`
2. **Design Solution** → Create BMad story
3. **Implement** → Apply fix
4. **Verify** → Test solution
5. **Document** → Update docs
6. **Complete Task** → `claude-memory task complete <id>`

## Next Steps

1. Start with high-priority gaps
2. Use `/swarm-research` for solution research
3. Track progress with Claude Memory tasks
4. Review weekly with `claude-memory task list`
```

### Step 5: Provide User Feedback

**Action**: Inform user of results and next steps

**Message Template**:
```
✅ Gap Analysis Complete!

Found X gaps in pantherOS configuration:

📊 Summary:
- High Priority: X gaps
- Medium Priority: X gaps
- Low Priority: X gaps

💾 Saved to Claude Memory:
All gaps saved as tasks with priorities.
View: claude-memory task list --category gap-analysis

🔄 Next Steps:
1. Review high-priority gaps
2. Start with: `/swarm-research "[gap topic]"`
3. Track progress with: `claude-memory task complete <id>`

Would you like me to:
- Research solutions for high-priority gaps?
- Generate implementation plan?
- Start with a specific gap?
```

## Integration Examples

### Example 1: Basic Gap Analysis

**User Input**: "Run gap analysis"

**Assistant Actions**:
1. Execute `/gap-analyze`
2. Parse output
3. Save to Claude Memory with priorities
4. Display summary and next steps

**Output**:
```
✅ Gap Analysis Complete!

Found 8 gaps in pantherOS configuration:

📊 Summary:
- High Priority: 3 gaps
- Medium Priority: 3 gaps
- Low Priority: 2 gaps

💾 Saved to Claude Memory:
Task IDs: 001, 002, 003, 004, 005, 006, 007, 008
View: claude-memory task list --category gap-analysis

🔄 Next Steps:
1. Review high-priority gaps
2. Start with: `/swarm-research security-hardening`
3. Track progress with: `claude-memory task complete <id>`

Would you like me to research solutions for the high-priority gaps?
```

### Example 2: Targeted Gap Analysis

**User Input**: "Analyze NixOS security gaps"

**Assistant Actions**:
1. Execute `/gap-analyze --category security`
2. Parse security-specific gaps
3. Save to Claude Memory with security category
4. Focus on security remediation

**Output**:
```
✅ Security Gap Analysis Complete!

Found 4 security gaps:

🔒 High Priority:
- SSH configuration review
- Firewall rules incomplete
- No fail2ban for web services

💾 Saved to Claude Memory:
Task IDs: sec-001, sec-002, sec-003, sec-004
View: claude-memory task list --category security

🎯 Recommended Actions:
1. Run: `/swarm-research ssh-hardening` (Task: sec-001)
2. Run: `/swarm-research firewall-best-practices` (Task: sec-002)
3. Run: `/swarm-research fail2ban-setup` (Task: sec-003)

Start with any task using: claude-memory task complete <id> --note "Started research"
```

### Example 3: Continuous Gap Monitoring

**Setup**: Run gap analysis weekly

**Automated Process**:
1. Schedule: Weekly gap analysis
2. Compare: New vs existing gaps
3. Update: Task priorities based on changes
4. Report: Gap trends and progress

**Cron Job** (optional):
```bash
# Weekly gap analysis and memory update
0 9 * * 1 /workspace/scripts/gap-analysis-weekly.sh
```

## Error Handling

### If Gap Analysis Fails

**Action**: Provide fallback and manual memory storage

**Message**:
```
❌ Gap analysis command failed.

You can still save gaps manually:
claude-memory task add "Gap: [Your Gap]" --priority high --category manual

Or retry gap analysis with: /gap-analyze --verbose
```

### If Memory Storage Fails

**Action**: Retry once, then provide manual instructions

**Message**:
```
⚠️ Gap analysis succeeded but memory storage failed once.

Retrying...

✅ Memory storage successful!

If issues persist, save manually:
claude-memory task add "Gap: [Name]" --priority high
```

## Benefits

1. **Automated Tracking**: All gaps tracked in Claude Memory
2. **Priority Management**: Automatic priority assignment
3. **Progress Monitoring**: Easy to track remediation
4. **Searchable**: Find gaps by category, priority, date
5. **Handoff Ready**: Include in session handoffs
6. **Trend Analysis**: Monitor gap patterns over time

## Success Metrics

- All gaps saved to Claude Memory
- Priorities assigned correctly
- User can list and filter gaps
- Gaps link to remediation actions
- Progress tracked over time
- Integration with research workflow

---

This workflow ensures gap analysis results are persistently tracked and easily actionable through Claude Memory integration.

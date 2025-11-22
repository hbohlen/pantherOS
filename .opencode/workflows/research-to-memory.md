---
description: "Automated Research integration with Claude Memory"
category: integration
workflow_type: automated
triggers: [swarm-research-command, memory-integration-command]
---

# Research to Claude Memory Workflow

## Overview

This workflow automates the process of running research and saving findings to Claude Memory for future reference and decision-making.

## Workflow Steps

### Step 1: Execute Research

**Action**: Run comprehensive research on specified topic

**Command**: `/swarm-research "Topic Name"`

**Example Topics**:
- "nixos security best practices 2024"
- "hardware optimization zenbook"
- "tailscale enterprise setup"
- "nix flake patterns"

**Context Loaded**:
- `.opencode/context/core/essential-patterns.md`
- `.opencode/context/project/project-context.md`
- Domain-specific context files

**Expected Output**:
```markdown
Research Results: NixOS Security Best Practices 2024
====================================================

## Key Findings

### 1. SSH Hardening
- Use SSH key authentication only
- Disable password authentication
- Implement fail2ban for SSH protection
- Configure SSH to use non-standard port (optional)

### 2. Firewall Configuration
- Use nftables instead of iptables (modern, faster)
- Default deny all, allow specific
- Configure rate limiting for SSH
- Enable logging for all dropped packets

### 3. System Hardening
- Enable automatic security updates
- Use systemd's automatic updates
- Configure automatic reboot after updates
- Keep kernel and firmware updated

### 4. Container Security
- Use rootless Podman
- Implement SELinux/AppArmor
- Scan images for vulnerabilities
- Use minimal base images

### 5. Network Security
- Configure Tailscale for VPN
- Use wireguard instead of OpenVPN
- Implement network segmentation
- Use private networking for cloud servers

## Recommendations

### Immediate Actions (Priority: High)
1. Migrate to nftables firewall
2. Implement fail2ban
3. Enable automatic security updates
4. Configure SSH hardening

### Medium-term Actions (Priority: Medium)
1. Implement container security scanning
2. Set up network monitoring
3. Configure audit logging
4. Implement intrusion detection

### Long-term Actions (Priority: Low)
1. Set up SIEM solution
2. Implement security compliance framework
3. Regular penetration testing
4. Security training and awareness

## Implementation Examples

### SSH Configuration
```nix
services.openssh = {
  enable = true;
  settings = {
    PasswordAuthentication = false;
    PermitRootLogin = "no";
    X11Forwarding = false;
    AllowTcpForwarding = false;
    MaxAuthTries = 3;
  };
};
```

### Firewall Configuration
```nix
networking.nftables = {
  enable = true;
  config = ''
    table inet filter {
      chain input {
        type filter hook input priority 0;
        policy drop;
        ct state established,related accept;
        iifname lo accept;
        tcp dport ssh accept;
      }
    }
  '';
};
```

## Sources
- NixOS Security Manual
- NIST Cybersecurity Framework
- CIS Benchmarks
- Cloud Security Best Practices
```

### Step 2: Extract Key Information

**Action**: Parse research output and extract structured information

**Extract**:
- **Key Findings**: Main discoveries
- **Recommendations**: Actionable items
- **Implementation Examples**: Code/config snippets
- **Sources**: References
- **Priority Levels**: Immediate, medium, long-term

### Step 3: Save Findings to Claude Memory

**Action**: Save research findings as knowledge items

**Knowledge Format**:
```bash
claude-memory knowledge add "research:topic:key-findings" "findings summary" \
  --category research --source "swarm-research"

claude-memory knowledge add "research:topic:recommendations" "recommendations summary" \
  --category research --source "swarm-research"

claude-memory knowledge add "research:topic:examples" "implementation examples" \
  --category research --source "swarm-research"

claude-memory knowledge add "research:topic:sources" "reference sources" \
  --category research --source "swarm-research"
```

**Example**:
```bash
# Save NixOS Security research
claude-memory knowledge add \
  "research:nixos-security:2024:key-findings" \
  "SSH hardening, nftables firewall, automatic updates, container security, network segmentation" \
  --category research --source "swarm-research"

claude-memory knowledge add \
  "research:nixos-security:2024:immediate-actions" \
  "1. Migrate to nftables 2. Implement fail2ban 3. Enable automatic security updates 4. Configure SSH hardening" \
  --category research --priority high --source "swarm-research"

claude-memory knowledge add \
  "research:nixos-security:2024:examples" \
  "SSH config: PasswordAuthentication false, Firewall: nftables table inet filter" \
  --category research --source "swarm-research"

claude-memory knowledge add \
  "research:nixos-security:2024:sources" \
  "NixOS Security Manual, NIST, CIS Benchmarks, Cloud Security Best Practices" \
  --category research --source "swarm-research"
```

### Step 4: Record Research Decision

**Action**: Save research decision to memory

**Command**:
```bash
claude-memory decision \
  "Adopt nftables firewall for pantherOS" \
  "Research shows nftables is modern, faster, and more secure than iptables. It provides better performance and simpler configuration." \
  "Continue using iptables, Use firewalld, Migrate to nftables"
```

**Example**:
```bash
claude-memory decision \
  "Adopt NixOS security best practices from research" \
  "Research identified critical security gaps and provided actionable recommendations. Implementation will significantly improve security posture." \
  "Ignore research findings, Implement selectively, Implement all recommendations"
```

### Step 5: Generate Research Report

**Action**: Create comprehensive research report with next steps

**Report Structure**:
```markdown
# Research Report: [Topic] - $(date)

## Executive Summary
Brief overview of research purpose and key outcomes

## Key Findings
1. Finding 1 - Impact and relevance
2. Finding 2 - Impact and relevance
3. Finding 3 - Impact and relevance

## Recommendations
### Immediate (High Priority)
- [ ] Recommendation 1
- [ ] Recommendation 2

### Medium-term (Medium Priority)
- [ ] Recommendation 3
- [ ] Recommendation 4

### Long-term (Low Priority)
- [ ] Recommendation 5
- [ ] Recommendation 6

## Implementation Examples
Code snippets and configuration examples

## Sources
Reference materials and links

## Next Steps
1. Review findings and recommendations
2. Prioritize based on risk/impact
3. Create implementation plan
4. Start with high-priority items
5. Track progress in Claude Memory

## Related Memory Items
- Knowledge: research:topic:key-findings
- Decision: research:topic:decision
- Tasks: (if recommendations created as tasks)
```

### Step 6: Provide User Feedback

**Action**: Inform user of results and next steps

**Message Template**:
```
🔍 Research Complete: [Topic]

📊 Key Findings:
- Finding 1
- Finding 2
- Finding 3

💾 Saved to Claude Memory:
✅ Knowledge items: 4
✅ Decision recorded: 1
✅ Sources documented: 1

📋 Next Steps:
1. Review findings: claude-memory knowledge list research
2. Check decision: claude-memory decision list
3. Create tasks for recommendations: claude-memory task add "Implement X" --priority high
4. Start implementation

Would you like me to:
- Create implementation tasks for recommendations?
- Start with a specific finding?
- Run additional research on a related topic?
```

## Integration Examples

### Example 1: Security Research

**User Input**: "Research NixOS security best practices"

**Assistant Actions**:
1. Execute `/swarm-research "nixos security best practices 2024"`
2. Parse output for findings, recommendations, examples
3. Save to Claude Memory as knowledge items
4. Record decision
5. Generate report

**Output**:
```
🔍 Research Complete: NixOS Security Best Practices 2024

📊 Key Findings:
- SSH hardening with key-only authentication
- Migrate to nftables from iptables
- Enable automatic security updates
- Implement container security with rootless Podman

💾 Saved to Claude Memory:
✅ Knowledge items: research:nixos-security:findings, recommendations, examples, sources
✅ Decision: "Adopt nftables firewall and security hardening"
✅ Sources: 5 references documented

📋 Next Steps:
1. Review: claude-memory knowledge list research
2. Implement: Start with SSH hardening
3. Track: Use claude-memory task add for each recommendation

Would you like me to create implementation tasks?
```

### Example 2: Hardware Research

**User Input**: "Research zephyrus hardware optimization"

**Assistant Actions**:
1. Execute `/swarm-research "zenbook pro 16 nixos optimization"`
2. Focus on NVIDIA, thermal, power management
3. Save findings
4. Record decision on optimization strategy

**Output**:
```
🔍 Research Complete: Zenbook Pro 16 NixOS Optimization

📊 Key Findings:
- NVIDIA RTX 3070 Ti optimization with nvidia-beta
- Power management with TLP and thermald
- Thermal profiles for different workloads
- Battery life optimization techniques

💾 Saved to Claude Memory:
✅ Hardware optimization patterns
✅ Power management settings
✅ Thermal configuration examples

📋 Next Steps:
1. View findings: claude-memory knowledge list hardware
2. Apply optimizations: Update hardware.nix
3. Test performance: Monitor temperatures and battery

Ready to implement optimizations for zephyrus?
```

### Example 3: Decision Making

**User Input**: "Research and decide between iptables and nftables"

**Assistant Actions**:
1. Execute `/swarm-research "iptables vs nftables comparison 2024"`
2. Compare performance, features, security
3. Save comparison to knowledge
4. Record decision with reasoning
5. Provide implementation path

**Output**:
```
🔍 Research Complete: iptables vs nftables

📊 Comparison:
Performance: nftables 30% faster (source: Phoronix)
Features: nftables more modern, better syntax
Security: nftables has better security track record
Learning: Both well-documented, nftables simpler

💾 Saved to Claude Memory:
✅ Performance benchmarks
✅ Feature comparison
✅ Use case recommendations

✅ Decision: "Migrate to nftables"
Reason: Better performance, modern features, active development
Alternatives: Stay with iptables, use firewalld

📋 Implementation Plan:
1. Research nftables syntax (done)
2. Test nftables on test system
3. Migrate production (plan phase)
4. Monitor and verify

Decision saved to Claude Memory!
```

## Error Handling

### If Research Fails

**Action**: Provide fallback and manual memory storage

**Message**:
```
❌ Research command failed.

You can still save findings manually:
claude-memory knowledge add "research:manual:topic" "findings"

Or retry with: /swarm-research --verbose "[topic]"
```

### If Memory Storage Fails

**Action**: Retry once, then provide instructions

**Message**:
```
⚠️ Research succeeded but memory storage failed once.

Retrying...

✅ Memory storage successful!

If issues persist, save manually with claude-memory knowledge add
```

## Benefits

1. **Persistent Knowledge**: Research findings saved permanently
2. **Searchable**: Find research by topic, date, category
3. **Decision Tracking**: Record why certain choices were made
4. **Implementation Guidance**: Examples and next steps
5. **Shareable**: Include in handoffs and documentation
6. **Traceable**: Link findings to implementation tasks

## Success Metrics

- All research findings saved to Claude Memory
- Decisions recorded with reasoning
- Sources documented for verification
- Next steps clearly defined
- Implementation tasks created (if requested)
- Research easily retrievable

## Usage Patterns

### Research → Knowledge → Decision → Task → Implementation

```
/swarm-research "topic"
  → Claude Memory knowledge
  → claude-memory decision
  → claude-memory task add (recommendations)
  → Implement
  → claude-memory task complete
```

### Continuous Research

```
Daily: Research trending topics
Weekly: Review and consolidate findings
Monthly: Audit knowledge base for outdated info
Quarterly: Major research deep-dive
```

## Automated Workflow

Optional automation:

```bash
# research-to-memory.sh
TOPIC="$1"

# Run research
RESULT=$(/swarm-research "$TOPIC")

# Parse and save to memory
claude-memory knowledge add "research:$(date +%Y-%m-%d):$TOPIC:findings" "$RESULT"

# Record decision
echo "Research completed for: $TOPIC"
echo "Decision: Review findings and implement as needed"
```

---

This workflow ensures research is persistent, actionable, and integrated with the overall pantherOS development process.

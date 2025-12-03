# Quick Start Guide: Using OpenSpec Prompts for Disko Optimization

## What You Get

**[128]** contains 14 structured prompts organized into 5 categories:

1. **Hardware Analysis** (Prompts 1-2) - Understand your hardware and get recommendations
2. **Toolstack Optimization** (Prompts 3-6) - Optimize for your specific applications
3. **Mount Options** (Prompts 7-8) - Fine-tune btrfs mount parameters
4. **Performance & Tuning** (Prompts 9-10) - Optimize performance and backup strategy
5. **Multi-System** (Prompts 11-14) - Manage multiple hosts or validate configurations

## Typical Workflow

### For First-Time Setup (New Host)

```
Step 1: Analyze Hardware
  → Use Prompt 1 with your facter.json
  → Get: Hardware profile + preliminary recommendations

Step 2: Understand Your Toolstack Impact
  → Use Prompt 3 (if laptop) or Prompt 4 (if server)
  → Get: Application-specific optimization suggestions

Step 3: Generate Mount Options
  → Use Prompt 7 with findings from Steps 1-2
  → Get: Complete matrix of mount options per subvolume

Step 4: Create Disko Configuration
  → Use Prompt 11 with all previous findings
  → Get: Ready-to-use disko.nix code
```

### For Existing System Tuning

```
Step 1: Check Performance
  → Measure: df, btrfs filesystem usage, iostat
  
Step 2: Identify Issues
  → Use Prompt 9 to analyze bottlenecks
  → Use Prompt 14 for post-deployment tuning
  → Get: Specific recommendations for improvement

Step 3: Validate Changes
  → Use Prompt 13 to check new configuration
  → Get: Issues caught before deployment
```

### For Multi-Host Management

```
Step 1: Compare Hosts
  → Use Prompt 2 with both facter.json files
  → Get: Clear explanation of why configurations differ

Step 2: Optimize Each Host
  → Use Prompt 3 for Zephyrus laptop
  → Use Prompt 4 for Hetzner VPS
  → Get: Host-specific optimizations

Step 3: Generate Both Configs
  → Use Prompt 11 requesting both configurations
  → Get: Complete cluster setup with management strategy
```

## Copy-Paste Ready Examples

### Example 1: Analyze Your Zephyrus Laptop

Copy this and paste into `/openspec-proposal`:

```
/openspec-proposal

TASK: Optimize disko.nix for Asus ROG Zephyrus development laptop

CONTEXT:
Hardware: Asus ROG Zephyrus with:
- 2x NVMe SSDs (Crucial P3 2TB + Micron 2450 1TB) 
- Podman container runtime
- Niri window manager
- Zed IDE, Vivaldi browser, Ghostty terminal
- Fish shell

FACTER.JSON DATA:
[zephyrus-facter.json](/home/hbohlen/dev/pantherOS/hosts/zephyrus/facter.json)

GENERATE:
1. Hardware profile analysis (extract from facter.json)
2. Identify I/O patterns for Zed IDE, Podman, Vivaldi, Ghostty
3. Optimized subvolume layout (multi-drive strategy)
4. Mount options recommendations with performance impact
5. Ready-to-use disko.nix code snippet
```

### Example 2: Analyze Your Hetzner VPS

Copy this and paste into `/openspec-proposal`:

```
/openspec-proposal

TASK: Optimize disko.nix for Hetzner VPS production server

CONTEXT:
Hardware: Hetzner VPS with:
- Single 458GB virtual disk (virtio_scsi)
- Planned services: [List your services - e.g., PostgreSQL, Podman APIs, nginx]

FACTER.JSON DATA:
[hetzner-vps-facter.json](/home/hbohlen/dev/pantherOS/hosts/servers/hetzner-vps/facter.json)

GENERATE:
1. Hardware profile with virtualization analysis
2. Service I/O pattern analysis
3. Subvolume layout (single-disk strategy)
4. Mount options for reliability + compression
5. Backup/snapshot strategy
6. Ready-to-use disko.nix code snippet
```

### Example 3: Compare Both Hosts

Copy this and paste into `/openspec-proposal`:

```
/openspec-proposal

TASK: Compare hardware profiles and generate host-specific disko.nix configurations

ZEPHYRUS FACTER.JSON:
[zephyrus-facter.json](/home/hbohlen/dev/pantherOS/hosts/zephyrus/facter.json)

[hetzner-vps-facter.json](/home/hbohlen/dev/pantherOS/hosts/servers/hetzner-vps/facter.json)

GENERATE:
1. Side-by-side hardware comparison table
2. Workload profile differences (development vs production)
3. Storage architecture differences (2x NVMe vs 1x virtual)
4. Recommended disko.nix for Zephyrus
5. Recommended disko.nix for Hetzner VPS
6. Why each configuration differs
7. Management strategy for both
```

## Prompt Sections Explained

### Each Prompt Contains:

**TASK**: What you're asking for (clear, specific)

**CONTEXT**: Background information to guide the analysis

**INPUTS**: Data you're providing (facter.json files, hardware specs, workload descriptions)

**GENERATE**: What the tool should create (specific output format)

**CONSTRAINTS**: Guardrails to ensure quality (be specific, base on actual hardware, include rationale)

## Pro Tips

### Tip 1: Be More Specific = Better Results

❌ Vague:
```
/openspec-proposal
Optimize my storage configuration
```

✅ Specific:
```
/openspec-proposal

TASK: Optimize disko.nix for Zed IDE development

CONTEXT:
Hardware: Crucial P3 2TB + Micron 2450 1TB
Workload: Zed IDE with large monorepo (50GB), Podman containers, Vivaldi
FACTER.JSON: [actual data]

GENERATE: Mount options matrix showing which options for which subvolumes
```

### Tip 2: Include Actual Hardware Data

**Always provide your facter.json** - Don't describe it, paste the actual JSON. This enables:
- Exact device path identification
- Actual storage size calculations
- Specific controller analysis
- Realistic performance estimates

### Tip 3: Specify Your Constraints

The prompt templates include sections for:
- Storage limits (458GB for VPS, expandable for laptop)
- Performance priorities (speed vs reliability)
- Backup strategy (snapshots vs rsync)
- Workload type (container-heavy, database, mixed)

**More constraints = better recommendations**

### Tip 4: Use Step-by-Step Prompts

Don't try to get entire disko.nix in one prompt. Instead:

```
Step 1: Use Prompt 1 → Get hardware analysis
Step 2: Use Prompt 7 → Get mount options matrix
Step 3: Use Prompt 9 → Get performance tuning
Step 4: Use Prompt 11 → Get complete disko.nix
```

Each step builds on the previous, giving you better results.

### Tip 5: Ask for Reasoning

Add to any prompt:
```
For each recommendation, explain:
1. Why this option
2. Trade-offs involved
3. Expected impact on your workload
```

## What Each Prompt Category Does

### Hardware Analysis Prompts (1-2)
**Use when**: Setting up new host or comparing systems
**Output**: Hardware profiles, subvolume layouts, mount options matrices
**Input needed**: facter.json files

### Toolstack Optimization Prompts (3-6)
**Use when**: Optimizing for specific applications (IDE, containers, databases)
**Output**: Application-specific subvolume layouts, mount option suggestions
**Input needed**: facter.json + list of applications/services

### Mount Options Prompts (7-8)
**Use when**: Fine-tuning btrfs performance and space
**Output**: Mount option matrices, compression level recommendations
**Input needed**: Hardware profile + workload type

### Performance Prompts (9-10)
**Use when**: Bottlenecks detected or optimizing existing setup
**Output**: Performance analysis, tuning recommendations, monitoring strategy
**Input needed**: Actual performance measurements (iostat, btrfs filesystem usage, etc.)

### Multi-System Prompts (11-14)
**Use when**: Managing multiple hosts or validating complete configuration
**Output**: Complete disko.nix files, configuration validation, upgrade impact analysis
**Input needed**: All facter.json files + actual disko.nix config (if validating)

## Common Scenarios

### Scenario 1: "My IDE is slow on the laptop"

1. Use **Prompt 9** (Performance Bottleneck Analysis)
   - Include: IDE cache location, disk usage stats
   - Get: Bottleneck identification

2. Use **Prompt 7** (Mount Options)
   - Based on bottleneck, adjust compression/autodefrag

3. Use **Prompt 14** (Post-Deployment Tuning)
   - Get: Specific kernel parameters to adjust

### Scenario 2: "VPS is running out of space"

1. Use **Prompt 8** (Compression Optimization)
   - Include: Current disk usage, workload types
   - Get: Compression level recommendations

2. Use **Prompt 10** (Backup Strategy)
   - Include: Current snapshot count
   - Get: Retention policy to free space

3. Use **Prompt 13** (Configuration Validation)
   - Check proposed changes won't break anything

### Scenario 3: "Setting up new VPS with PostgreSQL"

1. Use **Prompt 4** (Server Stack Optimization)
   - Specify: PostgreSQL + other services
   - Get: Database subvolume strategy

2. Use **Prompt 5** (Container Optimization - if using Podman too)
   - Get: Container storage recommendations

3. Use **Prompt 6** (Database Optimization)
   - Get: nodatacow vs CoW analysis for database

4. Use **Prompt 11** (Generate disko.nix)
   - Get: Complete ready-to-deploy configuration

### Scenario 4: "Comparing laptop vs VPS"

1. Use **Prompt 2** (Hardware Comparison)
   - Include both facter.json files
   - Get: Clear explanation of differences

2. Use **Prompt 3** (for laptop) and **Prompt 4** (for VPS)
   - Get: Optimized configs for each

3. Use **Prompt 11** (Multi-System)
   - Get: Management strategy for both

## Output You'll Receive

Each prompt generates:

1. **Analysis**: Detailed explanation of your hardware/workload
2. **Recommendations**: Specific, prioritized suggestions
3. **Rationale**: Why each decision was made
4. **Code**: Ready-to-paste Nix configuration snippets
5. **Trade-offs**: Performance vs reliability, storage vs speed, etc.
6. **Next Steps**: How to validate and deploy

## Validation Checklist

After getting results from any prompt, verify:

✅ Device paths match your actual hardware (`lsblk` command)
✅ Subvolume layout makes sense for your workload
✅ Mount options are explained (not just listed)
✅ Trade-offs are clearly documented
✅ Code is in valid Nix syntax
✅ Recommendations account for your constraints
✅ Backup strategy is realistic for your setup

## Troubleshooting

### "The prompt didn't understand my setup"

→ Be more specific about your toolstack and hardware
→ Paste actual facter.json instead of describing it
→ Include performance metrics if available

### "Recommendations seem generic"

→ Add more constraints to the prompt
→ Specify your workload in detail
→ Ask for step-by-step reasoning

### "I don't understand the recommendations"

→ Ask the prompt to explain its reasoning
→ Request output in different format (table, diagram, code)
→ Ask for before/after comparisons

### "Ready to deploy but want validation"

→ Use **Prompt 13** (Configuration Validation)
→ Paste your proposed disko.nix
→ Get: Issues caught, recommendations for improvement

## Next Steps

1. **Choose your scenario** from "Common Scenarios" above
2. **Copy the appropriate prompt** from [128]
3. **Paste into `/openspec-proposal <prompt>`**
4. **Review recommendations** against your constraints
5. **Use Prompt 13** to validate before deploying
6. **Deploy incrementally** (one drive/subvolume at a time)

---

**Reference**: All prompts available in [128] - openspec-prompts.md

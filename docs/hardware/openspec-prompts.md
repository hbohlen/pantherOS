# OpenSpec Proposal Prompts for NixOS Disko.nix Optimization

This guide provides a collection of structured prompts for use with `/openspec-proposal <prompt>` to generate optimization proposals for disko.nix configurations. Each prompt includes the facter.json hardware analysis and toolstack-specific optimizations.

## Quick Start

Copy and paste any prompt below into `/openspec-proposal <prompt>` to generate a change proposal for your host's disko.nix configuration.

---

## HARDWARE ANALYSIS PROMPTS

### Prompt 1: Complete Hardware Analysis & Subvolume Recommendation

```
/openspec-proposal

TASK: Analyze hardware and generate optimized subvolume layout

CONTEXT:
You are a NixOS storage optimization expert. You will analyze facter.json hardware data and generate a disko.nix subvolume layout proposal.

HARDWARE ANALYSIS:
[Read facter.json and extract:]
- Storage device(s) and size(s)
- Storage controller type(s)
- Total memory available
- CPU core count
- System type (laptop/desktop/VM)
- Virtualization indicators if VPS

GENERATE:
1. Hardware profile summary (2-3 paragraphs)
2. Storage characteristic analysis
3. Performance bottleneck identification
4. Recommended subvolume layout with rationale
5. Suggested mount options per subvolume
6. Backup strategy recommendation

CONSTRAINTS:
- Base recommendations on actual hardware in facter.json
- Be specific: include device paths, sizes, controllers
- Provide rationale for each design decision
- Format subvolume layout as ASCII diagram with properties
```

### Prompt 2: Hardware Comparison Analysis

```
/openspec-proposal

TASK: Compare two facter.json files and identify configuration differences

CONTEXT:
Compare hardware profiles to generate host-specific disko.nix optimizations.

INPUTS:
- zephyrus-facter.json (Laptop development machine)
- hetzner-vps-facter.json (VPS production server)

ANALYSIS REQUIRED:
1. Side-by-side hardware comparison table
2. Workload profile differences
3. Storage architecture differences
4. Performance constraint analysis
5. Reliability/backup requirement differences

OUTPUT:
For each host, generate:
- Optimal subvolume count and layout
- Mount option matrix (which options for which subvolumes)
- Expected performance characteristics
- Backup strategy type

CONSTRAINTS:
- Explain why configurations differ
- Base all recommendations on facter.json data
- Highlight trade-offs in each design choice
```

---

## TOOLSTACK-SPECIFIC OPTIMIZATION PROMPTS

### Prompt 3: Development Stack Optimization (Zephyrus)

```
/openspec-proposal

TASK: Optimize disko.nix for development workflow

CONTEXT:
Hardware: Asus ROG Zephyrus laptop with:
- 2x NVMe SSDs (Crucial P3 2TB + Micron 2450 1TB)
- Podman container runtime
- Niri window manager
- Zed IDE, Vivaldi browser, Ghostty terminal
- Fish shell
- DankMaterialShell theme

GENERATE OPTIMIZATION PROPOSAL:
1. Identify I/O patterns for each tool:
   - Zed IDE (cache location, project directory patterns)
   - Podman (container storage, overlay2 layers)
   - Vivaldi (browser cache, profile storage)
   - Niri/Ghostty/Fish (config files, state)

2. Subvolume layout optimized for workflow:
   - Which tools benefit from compression
   - Which need fast random I/O
   - Which should avoid CoW overhead

3. Mount option recommendations:
   - autodefrag candidates (IDE caches, browser caches)
   - nodatacow candidates (none for laptop)
   - Compression levels per subvolume

4. Multi-drive strategy:
   - Primary drive (Crucial P3): system + home
   - Secondary drive (Micron 2450): containers + project data
   - Rationale for split

5. Performance tuning parameters for development workflow

CONSTRAINTS:
- Prioritize development speed
- Minimize IDE compile time
- Optimize Podman container startup
- Balance compression vs responsiveness
```

### Prompt 4: Server Stack Optimization (Hetzner VPS)

```
/openspec-proposal

TASK: Optimize disko.nix for server production workload

CONTEXT:
Hardware: Hetzner VPS with:
- Single 458GB virtual disk (virtio_scsi)
- KVM-based virtualization (QEMU)
- Planned services: [Specify your services]
  Example options:
  - PostgreSQL/MySQL database
  - Podman containers (web services, APIs)
  - NixOS system packages
  - Git repositories
  - Static file serving
  - Backup storage

GENERATE OPTIMIZATION PROPOSAL:
1. Identify service I/O patterns:
   - Database workload (if applicable) - write frequency, transaction size
   - Container workload - image layers, volume patterns
   - Log generation - volume, rotation requirements
   - Package store - access patterns, frequency

2. Subvolume layout for production:
   - Snapshottable system state
   - Non-snapshottable volatile data
   - Database storage (if needed) with nodatacow analysis
   - Container storage (overlay2 vs direct btrfs)
   - Backup/restore friendly layout

3. Mount option strategy:
   - Compression benefits for limited storage (458GB)
   - CoW impact on database workload
   - TRIM optimization for virtual SSD
   - Space cache tuning

4. Backup strategy:
   - Snapshot scheduling (timeline-based)
   - Send/receive to external storage
   - Disaster recovery timeline

5. Space management:
   - Quota limits per subvolume (prevent runaway)
   - Compression ratio estimates
   - Snapshot retention policy

CONSTRAINTS:
- Fixed 458GB storage - compression critical
- Reliability > performance
- Uptime priority
- No expansion possible
```

### Prompt 5: Container/Podman Specific Optimization

```
/openspec-proposal

TASK: Optimize disko.nix for Podman container workload

CONTEXT:
Container runtime: Podman with specific workload:
- Container image storage location
- Volume mount patterns
- Expected container count
- Persistence requirements
- Performance sensitivity

FACTER.JSON DATA:
[Include relevant storage/network sections]

GENERATE:
1. Podman storage driver analysis:
   - btrfs with overlay2 vs direct btrfs subvolume
   - Container layer storage implications
   - Volume mount performance

2. Subvolume layout for containers:
   - Should /var/lib/containers be separate subvolume?
   - nodatacow requirements (performance vs safety)
   - Compression impact on layers

3. Mount options impact:
   - How nodatacow affects container performance
   - CoW overhead with container writes
   - Compression ratio for container images

4. Performance characteristics:
   - Expected container startup time
   - Volume mount latency
   - Layer caching efficiency

5. Recommendations for your specific workload:
   - Recommended storage location
   - Mount option matrix
   - Performance expectations

CONSTRAINTS:
- Be specific about Podman driver implications
- Include CoW performance data
- Distinguish between image storage and volume storage
```

### Prompt 6: Database Workload Optimization

```
/openspec-proposal

TASK: Optimize disko.nix for database workload

CONTEXT:
Database type: [PostgreSQL/MySQL/SQLite/etc]
- Expected database size
- Transaction rate (queries/sec)
- Write frequency
- Backup strategy

ANALYSIS REQUIRED:
1. CoW (Copy-on-Write) impact analysis:
   - Performance penalty with btrfs CoW
   - Comparison: btrfs CoW vs ext4 vs nodatacow

2. Subvolume strategy:
   - Should database live on separate subvolume?
   - nodatacow benefits/risks for database
   - Snapshot safety with database workload

3. Optimization recommendations:
   - Mount options for database subvolume
   - nodatacow vs standard CoW decision
   - Compression impact

4. Backup implications:
   - Can database subvolume be snapshotted safely?
   - Hot backup strategy if nodatacow used
   - Crash recovery considerations

5. Performance expectations:
   - Write throughput estimates
   - Random IOPS impact
   - Comparison to ext4 baseline

CONSTRAINTS:
- Prioritize data consistency
- Balance performance vs reliability
- Account for backup requirements
```

---

## MOUNT OPTIONS OPTIMIZATION PROMPTS

### Prompt 7: Mount Options Matrix Generation

```
/openspec-proposal

TASK: Generate mount options matrix for all subvolumes

CONTEXT:
Hardware: [Laptop/Server/VPS - specify]
Subvolumes: [List all planned subvolumes]
Workload: [Primary use case]

GENERATE:
A comprehensive matrix showing:

| Subvolume | Purpose | Compression | noatime | autodefrag | nodatacow | discard | space_cache |
|-----------|---------|-------------|---------|-----------|-----------|---------|-------------|
| /@root    | System  | zstd:3      | yes     | [based on workload] | no  | async   | v2 |
| ...       | ...     | ...         | ...     | ...       | ...       | ...     | ... |

For each option, provide:
1. Recommended setting
2. Rationale for this workload
3. Performance impact
4. Data safety implications

INCLUDE SPECIAL CASES:
- Database subvolumes (CoW analysis)
- Container storage (layer implications)
- Log/cache directories (snapshot implications)
- Temporary directories (tmpfs vs subvolume)

CONSTRAINTS:
- Base recommendations on actual hardware
- Explain trade-offs for each decision
- Include performance impact estimates
```

### Prompt 8: Compression Level Optimization

```
/openspec-proposal

TASK: Recommend optimal compression levels per subvolume

CONTEXT:
Hardware: [CPU cores, storage, workload characteristics]
Storage constraints: [Total size, available space]
Workload profile: [I/O patterns, write volume]

ANALYSIS:
1. CPU cost analysis:
   - zstd:1 vs zstd:3 vs zstd:6 tradeoffs
   - CPU utilization impact
   - Throughput impact

2. Compression ratio by data type:
   - Source code/configs: ~50-60% (best compression)
   - Database files: ~10-20% (poor compression)
   - Container images: ~25-35% (moderate compression)
   - Logs: ~60-80% (excellent compression)
   - Binary files: ~5-15% (poor compression)

3. Per-subvolume recommendations:
   - Which subvolumes can use aggressive compression
   - Which benefit from fast decompression
   - Which should skip compression entirely

4. Storage impact:
   - Total space savings with recommended levels
   - Effective capacity increase
   - Growth rate implications

CONSTRAINTS:
- Account for your actual data types
- Include performance vs space trade-offs
- Recommend different levels for different subvolumes
```

---

## PERFORMANCE & TUNING PROMPTS

### Prompt 9: Performance Bottleneck Analysis

```
/openspec-proposal

TASK: Identify storage performance bottlenecks and recommendations

CONTEXT:
Hardware configuration: [Facter.json data]
Current workload: [Describe typical I/O patterns]
Performance goals: [What should be fast?]

ANALYSIS:
1. Bottleneck identification:
   - Storage controller characteristics
   - Virtualization overhead (if VPS)
   - Bus bandwidth limitations
   - Random vs sequential I/O balance

2. Disko configuration impact:
   - How subvolume layout affects performance
   - Mount options performance implications
   - Compression CPU vs I/O trade-off

3. Workload-specific optimizations:
   - Development tools: IDE compile time
   - Database: transaction latency
   - Containers: startup time
   - Browser: cache hit rates

4. Recommendations:
   - Which options improve performance
   - Expected improvement magnitude
   - Trade-offs for each optimization

5. Monitoring strategy:
   - Key metrics to measure
   - Before/after comparison baseline

CONSTRAINTS:
- Be realistic about virtualization overhead
- Account for actual hardware capabilities
- Include both throughput and latency impact
```

### Prompt 10: Snapshot & Backup Strategy Optimization

```
/openspec-proposal

TASK: Design optimal snapshot and backup strategy

CONTEXT:
System type: [Laptop/Server/VPS]
Data criticality: [High/Medium/Low]
Backup medium: [USB drive/Cloud storage/Remote server]
Recovery RTO: [Recovery Time Objective in hours]
Recovery RPO: [Recovery Point Objective in hours]

ANALYSIS:
1. Snapshot strategy:
   - Which subvolumes to snapshot
   - Snapshot frequency (hourly/daily/weekly)
   - Retention policy (how many snapshots)
   - Storage overhead calculations

2. Backup strategy:
   - Local snapshots vs remote backups
   - Incremental vs full backup
   - Compression during transfer
   - Verification strategy

3. Recovery procedures:
   - Per-file recovery
   - Full system rollback
   - Point-in-time recovery

4. Implementation:
   - snapper configuration
   - Backup automation (cron/systemd.timer)
   - Testing/validation procedure

5. Storage impact:
   - Snapshot overhead
   - Backup storage requirements
   - Retention vs space trade-off

CONSTRAINTS:
- Base on actual RPO/RTO requirements
- Account for storage limitations
- Include testing recommendations
```

---

## MULTI-SYSTEM PROMPTS

### Prompt 11: Generate disko.nix for Entire Cluster

```
/openspec-proposal

TASK: Generate optimized disko.nix for multiple hosts

CONTEXT:
Hosts:
1. Zephyrus laptop (facter.json provided)
2. Hetzner VPS (facter.json provided)
[Add more hosts if applicable]

GENERATE:
For each host:
1. Specific disko.nix configuration
   - Device paths
   - Partition scheme
   - Subvolume layout
   - Mount options

2. Configuration comparison
   - What differs and why
   - What's shared (if any)

3. Management strategy
   - How to maintain both configurations
   - Version control recommendations
   - Update procedure

CONSTRAINTS:
- Base each on actual facter.json data
- Explain host-specific decisions
- Provide ready-to-use Nix code blocks
```

### Prompt 12: Hardware Upgrade Impact Analysis

```
/openspec-proposal

TASK: Analyze impact of hardware changes on disko.nix

CONTEXT:
Current hardware: [Facter.json current state]
Planned upgrade: [New storage device specs]
Example scenarios:
- Add external SSD to laptop
- Upgrade VPS storage plan
- Add secondary NVMe to existing system

ANALYSIS:
1. Current configuration review
2. New hardware characteristics
3. Updated optimization opportunities
4. Migration strategy (if needed)
5. New recommended subvolume layout
6. Performance improvement estimates

CONSTRAINTS:
- Explain what changes and what stays same
- Include migration steps if needed
- Estimate benefit of new hardware
```

---

## TROUBLESHOOTING & VALIDATION PROMPTS

### Prompt 13: Configuration Validation & Issue Prevention

```
/openspec-proposal

TASK: Validate disko.nix configuration against best practices

CONTEXT:
Proposed disko.nix: [Paste your configuration]
Hardware: [Facter.json data]
Expected workload: [Describe intended use]

VALIDATION CHECKS:
1. Hardware compatibility
   - Device paths correct
   - Partition scheme appropriate
   - Subvolume count reasonable

2. Mount options consistency
   - Required options present
   - Conflicting options identified
   - Performance-safety trade-offs documented

3. Subvolume layout analysis
   - Unnecessary subvolumes
   - Missing subvolumes
   - Snapshot strategy alignment

4. Potential issues
   - Known problems with this configuration
   - Performance concerns
   - Maintenance challenges

5. Recommendations
   - Improvements
   - Safety enhancements
   - Performance optimizations

OUTPUT:
- Issues found (if any)
- Recommended fixes
- Updated configuration snippet
```

### Prompt 14: Post-Deployment Performance Tuning

```
/openspec-proposal

TASK: Analyze actual performance and recommend tuning

CONTEXT:
After deploying disko.nix configuration, measure:
- Current disk usage: [df output]
- Compression ratio achieved: [btrfs filesystem usage output]
- Performance observation: [Describe slowness/problems]
- Workload changed since deployment: [Yes/No, describe]

ANALYSIS:
1. Actual vs expected performance comparison
2. Compression effectiveness
3. Workload mismatch identification
4. Bottleneck analysis

RECOMMENDATIONS:
1. Mount option adjustments
   - Change compression level
   - Toggle noatime/autodefrag
   - Adjust discard strategy

2. Subvolume restructuring
   - Redistribute across drives
   - Change snapshot strategy
   - Adjust compression per subvolume

3. Kernel parameter tuning
   - vm.dirty_writeback_centisecs
   - vm.dirty_expire_centisecs
   - Other sysctl optimizations

CONSTRAINTS:
- Include before/after metric estimates
- Provide commands to measure impact
```

---

## USAGE EXAMPLES

### Example 1: Analyzing Zephyrus for Optimization

```
/openspec-proposal

[Copy from Prompt 3: Development Stack Optimization]
[Add at end: "Zephyrus-facter.json data to analyze: [paste content]"]
```

### Example 2: Analyzing Hetzner VPS for Optimization

```
/openspec-proposal

[Copy from Prompt 4: Server Stack Optimization]
[Specify services: PostgreSQL, Podman containers for microservices APIs, git server]
[Add at end: "Hetzner-facter.json data to analyze: [paste content]"]
```

### Example 3: Complete Setup for New Host

```
/openspec-proposal

[Copy from Prompt 11: Generate disko.nix for Entire Cluster]
[Add: "Generate separate optimized configurations for both hosts"]
[Add: "Provide complete flake.nix snippet for managing both"]
```

---

## PROMPT COMBINATION STRATEGY

### Multi-Step Analysis (Recommended for First-Time Setup)

1. **First**, use **Prompt 1** for hardware analysis
2. **Then**, use **Prompt 7** to generate mount options matrix
3. **Then**, use **Prompt 3 or 4** for toolstack optimization
4. **Finally**, use **Prompt 11** to generate complete disko.nix files

### Iterative Refinement (For Tuning Existing Setup)

1. Use **Prompt 9** to identify bottlenecks
2. Use **Prompt 8** for compression level optimization
3. Use **Prompt 14** for post-deployment tuning
4. Use **Prompt 13** to validate changes

### Multi-Host Management

1. Use **Prompt 2** for comparison analysis
2. Use **Prompt 3** for laptop optimization
3. Use **Prompt 4** for VPS optimization
4. Use **Prompt 11** to generate cluster configuration

---

## BEST PRACTICES FOR USING THESE PROMPTS

### Before Running Any Prompt

1. **Prepare your facter.json data**
   - Extract the file and have it ready
   - Identify key hardware characteristics

2. **Define your toolstack clearly**
   - List all applications/services
   - Describe I/O patterns
   - Specify performance requirements

3. **Clarify constraints**
   - Storage capacity limits
   - Budget (performance vs reliability)
   - Backup requirements
   - Uptime/recovery requirements

### After Getting Results

1. **Validate the recommendations**
   - Check device paths are correct
   - Verify subvolume layout makes sense
   - Review mount options for your workload

2. **Test incrementally**
   - Don't deploy everything at once
   - Start with one drive/subvolume
   - Measure performance impact

3. **Iterate based on results**
   - Use Prompt 14 for post-deployment tuning
   - Adjust compression/mount options as needed
   - Document what works for your workload

### Prompt Engineering Tips for These Prompts

1. **Be specific about your toolstack**
   - Generic prompts get generic answers
   - More detail = better recommendations

2. **Include actual performance numbers**
   - If you have iostat/iotop output, include it
   - Actual metrics beat estimates

3. **Ask for step-by-step reasoning**
   - "Explain your reasoning for each decision"
   - "Show the trade-offs for each option"

4. **Request output format explicitly**
   - "Format as Nix code ready to paste"
   - "Show as ASCII diagram"
   - "Provide as comparison table"

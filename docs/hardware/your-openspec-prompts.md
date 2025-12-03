# Your Specific OpenSpec Prompts - Ready to Use

This document contains copy-paste-ready prompts optimized for YOUR specific hardware: Zephyrus laptop and Hetzner VPS.

## For Your Zephyrus Laptop

### Ready-to-Use Prompt 1: Zephyrus Hardware Analysis

```
/openspec-proposal

TASK: Analyze Asus ROG Zephyrus laptop hardware and generate optimized subvolume layout

CONTEXT:
You are optimizing storage for an Asus ROG Zephyrus laptop with:
- Development workload: Zed IDE, Vivaldi browser, Ghostty terminal, Fish shell
- Container runtime: Podman for local testing and development
- Window manager: Niri (wayland)
- Theme: DankMaterialShell
- Additional tools: opencode.ai, git repositories, project files

Hardware to analyze from facter.json:
- Storage device(s) and controller types
- Total memory and CPU cores
- System form factor
- Any virtualization indicators

FACTER.JSON DATA TO ANALYZE:
[zephyrus-facter.json](/home/hbohlen/dev/pantherOS/hosts/zephyrus/facter.json)

GENERATE:
1. Hardware profile summary (2-3 paragraphs)
   - Extract actual device names (e.g., nvme0n1, nvme1n1)
   - Storage controller types (NVMe drivers)
   - Performance capabilities of each drive
   
2. Development workload analysis:
   - I/O patterns for Zed IDE (cache, project directories)
   - Podman container storage needs (overlay2 layers, volumes)
   - Vivaldi browser cache patterns
   - Git repository access patterns
   
3. Subvolume layout recommendation:
   - Primary drive (Crucial P3): which subvolumes
   - Secondary drive (Micron 2450): which subvolumes
   - Rationale for split strategy
   
4. Mount options matrix:
   - Show in table format
   - Include autodefrag candidates (IDE caches)
   - Show compression recommendations
   - Include nodatacow decisions
   
5. Backup strategy:
   - Local snapshot strategy
   - External USB backup approach
   - Restore testing procedure

CONSTRAINTS:
- Base ALL recommendations on actual facter.json data
- Be specific: use actual device paths from facter.json
- Explain the rationale for multi-drive split
- Include performance impact of each decision
- Format subvolume layout as ASCII diagram
```

### Ready-to-Use Prompt 2: Zephyrus Mount Options Matrix

```
/openspec-proposal

TASK: Generate complete mount options matrix for Zephyrus dual-NVMe setup

CONTEXT:
Asus ROG Zephyrus laptop with:
- Primary: Crucial P3 (2TB) - system + home
- Secondary: Micron 2450 (1TB) - containers + projects
- Development workload: IDE, containers, browser, git

WORKLOAD I/O PATTERNS:
- Zed IDE: frequent small file updates, compilation caches
- Podman: container image layers, volume mounts
- Vivaldi: browser cache, profile updates
- Git: repository metadata, working tree changes
- General: config files, home directory

GENERATE:
A detailed matrix showing for each subvolume:

| Subvolume | Location | Purpose | compress | noatime | autodefrag | nodatacow | discard | space_cache |
|-----------|----------|---------|----------|---------|-----------|-----------|---------|-------------|
| root      | Primary  | System  | ...      | ...     | ...       | ...       | ...     | ...         |
| [etc]     | [etc]    | [etc]   | ...      | ...     | ...       | ...       | ...     | ...         |

For each entry, provide:
1. Recommended setting value
2. Why this choice for this subvolume
3. Expected performance impact
4. Data safety implications

SPECIAL ANALYSIS:
- Which subvolumes benefit from autodefrag (IDE/browser caches)
- Whether nodatacow needed anywhere (no - keep CoW for all)
- Compression level per subvolume (zstd:3 vs zstd:1)
- TRIM strategy implications

CONSTRAINTS:
- Prioritize development speed
- Include auto-defrag for cache-heavy subvolumes
- No nodatacow for laptop (no high-write databases)
- Explain autodefrag rationale for IDE/browser
```

### Ready-to-Use Prompt 3: Zephyrus Complete disko.nix

```
/openspec-proposal

TASK: Generate complete disko.nix configuration for Zephyrus

CONTEXT:
Asus ROG Zephyrus laptop optimized for development

Workload: Zed IDE, Podman, Vivaldi, Niri, Git, OpenCode.ai

FACTER.JSON DATA:
[zephyrus-facter.json](/home/hbohlen/dev/pantherOS/hosts/zephyrus/facter.json)

REQUIRED OUTPUTS:
1. Device path verification
   - Extract actual device paths from facter.json
   - Verify Crucial P3 is primary
   - Verify Micron 2450 is secondary

2. Complete disko.nix code:
   - EFI partition configuration
   - Crucial P3 subvolumes (root, home, nix, var, cache, log, tmp)
   - Micron 2450 subvolumes (containers, data)
   - All mount options fully specified
   - Ready to paste into flake.nix

3. Supporting NixOS configuration:
   - fstrim.timer setup
   - Podman configuration
   - snapper snapshot setup
   - kernel sysctl tuning recommendations

4. Deployment instructions:
   - How to test configuration
   - Device path update procedure
   - Partition and mount steps
   - Verification checklist

CONSTRAINTS:
- All device paths from actual facter.json
- Mount options based on development workload
- Include multi-drive split rationale
- Code must be valid Nix syntax
- Include comments explaining each section
```

---

## For Your Hetzner VPS

### Ready-to-Use Prompt 1: Hetzner Hardware Analysis

```
/openspec-proposal

TASK: Analyze Hetzner VPS hardware and generate optimized subvolume layout

CONTEXT:
You are optimizing storage for a Hetzner VPS (KVM-based) with:
- Fixed 458GB virtual disk (virtio_scsi controller)
- Server production workload
- Limited, non-expandable storage
- Snapshots critical for backup/recovery strategy

Services to plan for (specify your actual services):
Example: PostgreSQL database, Podman microservices, nginx web server, git repository
[SPECIFY YOUR ACTUAL SERVICES]

FACTER.JSON DATA TO ANALYZE:
[PASTE YOUR hetzner-vps-facter.json HERE]

GENERATE:
1. Hardware profile summary:
   - VPS characteristics (virtualization type, storage model)
   - Actual disk size calculation (from facter.json sectors)
   - Storage controller analysis (virtio_scsi implications)
   - Performance expectations for VPS environment
   
2. Service I/O analysis:
   - Database workload pattern (if applicable)
   - Container/service write volume
   - Log generation rate
   - Package store access patterns
   
3. Single-disk subvolume layout:
   - All services on one filesystem
   - Snapshottable vs non-snapshottable
   - Database handling (nodatacow decision)
   - Container storage strategy
   
4. Mount options for VPS:
   - Compression on all subvolumes (storage limited)
   - No autodefrag (continuous server writes)
   - CoW preservation for snapshots
   - Async TRIM for virtual SSD
   
5. Space management:
   - Compression ratio estimates per subvolume
   - Effective storage gain calculation
   - Quota recommendations per subvolume
   
6. Backup strategy:
   - Snapshot scheduling
   - Send/receive to external storage
   - Recovery procedure

CONSTRAINTS:
- Base on actual facter.json data
- Account for 458GB total storage limitation
- Reliability > performance for server
- Include compression benefit calculations
- No expansion possible (space critical)
```

### Ready-to-Use Prompt 2: Hetzner Database Analysis (if applicable)

```
/openspec-proposal

TASK: Optimize disko.nix for Hetzner VPS with PostgreSQL database

CONTEXT:
Hetzner VPS with:
- Single 458GB virtual disk
- PostgreSQL database (production workload)
- Podman containers (if applicable)
- Web services and logging

Database specifics:
- Expected database size: [YOUR SIZE]
- Transaction rate: [YOUR RATE] queries/sec
- Backup strategy: [snapshots/dump/both]
- Recovery RTO: [YOUR RTO] hours
- Recovery RPO: [YOUR RPO] hours

FACTER.JSON:
[PASTE YOUR hetzner-vps-facter.json HERE]

ANALYSIS REQUIRED:
1. CoW (Copy-on-Write) impact for PostgreSQL
   - Performance penalty with btrfs CoW
   - Comparison to ext4 baseline
   - nodatacow benefits/risks

2. Subvolume strategy decision:
   - Should /var/lib/postgresql be separate subvolume?
   - Use nodatacow for database? Analysis of trade-offs
   - Snapshot safety implications

3. Specific recommendations:
   - Mount options for database subvolume
   - nodatacow vs standard CoW decision with rationale
   - Compression strategy for database files

4. Backup implications:
   - Hot backup strategy if using nodatacow
   - Snapshot-based backup limitations
   - Crash recovery considerations
   - Testing/restore procedure

5. Performance expectations:
   - Write throughput estimates
   - Comparison to recommended alternative (ext4)
   - Expected impact on application response time

CONSTRAINTS:
- Prioritize data consistency over performance
- Account for backup requirements
- Include actual performance numbers
- Provide nodatacow vs CoW decision matrix
```

### Ready-to-Use Prompt 3: Hetzner Complete disko.nix

```
/openspec-proposal

TASK: Generate complete disko.nix for Hetzner VPS production server

CONTEXT:
Hetzner VPS production server with single 458GB virtual disk

Services running:
- [LIST YOUR ACTUAL SERVICES]
- Example: PostgreSQL, Podman microservices, nginx, monitoring

FACTER.JSON DATA:
[PASTE YOUR hetzner-vps-facter.json HERE]

REQUIRED OUTPUTS:
1. Device verification:
   - Confirm /dev/sda is the main disk (from facter.json)
   - Calculate actual size (sectors × sector size)
   - Verify virtio_scsi controller

2. Complete disko.nix code:
   - EFI partition
   - Main btrfs partition with all subvolumes:
     * /@root → /
     * /@home → /home
     * /@nix → /nix
     * /@var → /var
     * /@cache → /var/cache
     * /@log → /var/log
     * /@tmp → /var/tmp
     * /@persist → /persist (impermanence)
     * /@postgresql → /var/lib/postgresql (if using postgres, with nodatacow analysis)
   - All mount options fully specified
   - Comments explaining server-specific choices

3. NixOS configuration:
   - fstrim setup
   - Snapper snapshot configuration
   - Service-specific tuning (PostgreSQL, Podman, etc.)
   - Kernel sysctl parameters for VPS

4. Backup/snapshot procedure:
   - snapper automatic snapshot setup
   - Manual send/receive to backup storage
   - Restore procedure documentation
   - Snapshot retention policy

5. Post-deployment steps:
   - How to verify configuration
   - Compression ratio verification
   - Performance baseline measurement
   - Backup testing procedure

CONSTRAINTS:
- Device path from actual facter.json
- Single-disk strategy (no multi-drive split)
- Prioritize reliability and snapshots
- Include compression calculations
- Account for 458GB storage limit
- Valid Nix syntax, production-ready
```

### Ready-to-Use Prompt 4: Hetzner Multi-Service Analysis (if complex)

```
/openspec-proposal

TASK: Optimize disko.nix for Hetzner VPS with multiple services

CONTEXT:
Hetzner VPS 458GB with multiple services:

PRIMARY SERVICES:
- [Service 1]: [I/O pattern], [typical size]
- [Service 2]: [I/O pattern], [typical size]
- [Service 3]: [I/O pattern], [typical size]

Example:
- PostgreSQL: continuous writes, 50GB expected
- Redis cache: moderate writes, 20GB expected
- Podman containers: image storage 100GB, volumes 30GB
- Logs: 50GB total allocation

FACTER.JSON:
[PASTE YOUR hetzner-vps-facter.json HERE]

GENERATE:
1. Service interaction analysis:
   - Which services compete for I/O
   - Separation requirements (subvolume strategy)
   - Storage allocation per service

2. Subvolume layout:
   - Should high-write services be separate subvolumes?
   - nodatacow requirements per service
   - Snapshot strategy implications

3. Mount options per service:
   - Database subvolume options
   - Container storage options
   - Cache/log options
   - Impact matrix showing interactions

4. Space allocation:
   - Recommended quota per service
   - Growth rate projections
   - Compression ratio per service type
   - Total capacity estimates

5. Monitoring/alerting:
   - Key metrics per service
   - When to alert for growth
   - When to consider cleanup/upgrade

CONSTRAINTS:
- Total storage: 458GB fixed
- Include actual service sizes
- Show quota recommendations
- Provide growth rate projections
- Explain service separation decisions
```

---

## Quick Examples to Copy-Paste

### Minimal Example: Just Get Me disko.nix (Zephyrus)

```
/openspec-proposal

TASK: Generate disko.nix for Asus ROG Zephyrus with Zed IDE, Podman, Vivaldi

Hardware (from facter.json):
- Crucial P3 2TB
- Micron 2450 1TB
- NVMe controllers

FACTER.JSON:
[zephyrus-facter.json](/home/hbohlen/dev/pantherOS/hosts/zephyrus/facter.json)

GENERATE: Complete, ready-to-deploy disko.nix code with all subvolumes and mount options
```

### Minimal Example: Just Get Me disko.nix (Hetzner)

```
/openspec-proposal

TASK: Generate disko.nix for Hetzner VPS production server with [YOUR SERVICES]

Hardware (from facter.json):
- 458GB virtual disk
- virtio_scsi

FACTER.JSON:
[PASTE hetzner-vps-facter.json]

GENERATE: Complete, ready-to-deploy disko.nix code optimized for [YOUR SERVICES]
```

---

## Using These Prompts

### Step 1: Choose Your Scenario

- **Zephyrus + Prompt 1**: Hardware analysis with actual facter.json
- **Zephyrus + Prompt 2**: Get mount options matrix
- **Zephyrus + Prompt 3**: Get complete disko.nix

- **Hetzner + Prompt 1**: Hardware analysis with actual facter.json
- **Hetzner + Prompt 2**: If using PostgreSQL (nodatacow analysis)
- **Hetzner + Prompt 3**: Get complete disko.nix
- **Hetzner + Prompt 4**: If running multiple complex services

### Step 2: Paste Your facter.json

Replace `[PASTE YOUR facter.json HERE]` with actual content:
```bash
cat zephyrus-facter.json | xclip  # Copy to clipboard
# Then paste into the prompt
```

### Step 3: Specify Your Services (for Hetzner)

In prompts mentioning services, add your actual services:
- Replace `[YOUR SERVICES]` with: PostgreSQL, Podman, nginx
- Replace `[YOUR SIZE]` with actual sizes if known

### Step 4: Run the Prompt

Copy the entire prompt (all the way from `/openspec-proposal` to the end) and paste into `/openspec-proposal <prompt>`

### Step 5: Review & Validate

1. Check device paths match your hardware
2. Verify subvolume layout makes sense
3. Look for rationale on each decision
4. Note the expected performance/space impact
5. Use **Prompt 13** from [128] to validate before deploying

---

## Troubleshooting Your Prompts

### Device Path Not Found
→ Ensure facter.json is actually from that machine
→ Run `lsblk` on the actual machine to verify device names

### Services Not Recognized
→ Be more specific: "PostgreSQL, Podman with microservices, nginx"
→ Include typical I/O patterns for each service

### Results Don't Match Your Hardware
→ Make sure you pasted the complete facter.json
→ Include actual hardware details in the prompt
→ Ask the tool to "explain your reasoning" for each decision

### Want More Detail
→ Add: "Explain your reasoning for each decision"
→ Add: "Show trade-offs for each option"
→ Add: "Include performance impact estimates"

---

## Next Steps

1. Choose a prompt from above
2. Replace placeholder values with your actual data
3. Paste into `/openspec-proposal <prompt>`
4. Review the results
5. Use [129] quick reference if you need clarification
6. Use [128] for additional prompts

**All 14 prompts available in [128] - openspec-prompts.md**
**Quick reference guide available in [129] - openspec-quick-reference.md**

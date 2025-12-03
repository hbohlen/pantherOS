# Your Specific OpenSpec Prompts - Ready to Use (Updated with Yoga Host)

This document contains copy-paste-ready prompts optimized for YOUR specific hardware: Zephyrus laptop, Yoga laptop, and Hetzner VPS.

## For Your Yoga Host

Your **Yoga host** is a lightweight development machine with a single 954GB NVMe drive. Unlike the heavy development focus of Zephyrus, Yoga prioritizes portability and light programming work with dedicated optimization for your `~/dev` project folder.

### Ready-to-Use Prompt 1: Yoga Hardware Analysis

```
/openspec-proposal

TASK: Analyze Yoga host hardware and generate optimized subvolume layout

CONTEXT:
You are optimizing storage for a Yoga laptop (lightweight development machine) with:
- Primary use: Light programming and development work
- Project files: All in ~/dev folder (primary optimization point)
- Container runtime: Optional, small containers only (not primary workload)
- Development tools: IDEs, text editors, compilers
- Form factor: Laptop/Ultrabook
- Single NVMe drive (~954GB)

Key optimization focus:
- ~/dev folder should have dedicated subvolume for best performance
- Light development workload (vs Zephyrus which is heavy)
- Optional container support (not required)
- Efficient use of available storage

FACTER.JSON DATA TO ANALYZE:
[PASTE YOUR yoga-facter.json HERE]

GENERATE:
1. Hardware profile summary (2-3 paragraphs)
   - Extract actual device names and sizes
   - Storage controller type (NVMe controller analysis)
   - Performance capabilities
   - Single-drive configuration implications
   
2. Development workload analysis:
   - I/O patterns for light programming
   - ~/dev folder access patterns (source code, compilation)
   - Typical project sizes and frequency
   - Editor/IDE cache patterns
   
3. Subvolume layout recommendation:
   - /@home/dev dedicated subvolume (for ~/dev optimization)
   - Standard system subvolumes
   - Optional container storage location (if future interest)
   - Rationale for each subvolume
   
4. Mount options matrix:
   - Show in table format
   - Autodefrag candidates for development caches
   - Compression strategy for source code
   - Optional nodatacow planning for future containers
   
5. Backup strategy:
   - Local snapshot strategy
   - Priority for ~/dev folder protection
   - External backup approach
   - Restore testing procedure

CONSTRAINTS:
- Base ALL recommendations on actual facter.json data
- Optimize specifically for ~/dev folder access patterns
- Keep configuration simple and lightweight (portable device)
- Include optional container support planning (not primary)
- Format subvolume layout as ASCII diagram with properties
- Explain why Yoga differs from Zephyrus
```

### Ready-to-Use Prompt 2: Yoga ~/dev Optimization Deep-Dive

```
/openspec-proposal

TASK: Deep optimization for ~/dev project folder on Yoga host

CONTEXT:
Yoga host development machine with dedicated focus on ~/dev optimization:

Development patterns:
- All programming projects in ~/dev folder
- Typical project structure: source code, build directories, dependencies, git repos
- Frequent compilation and builds during active development
- Version control (git) repositories accessed frequently
- Documentation and notes alongside code
- Portable: needs efficient caching for offline work

FACTER.JSON DATA:
[PASTE YOUR yoga-facter.json HERE]

GENERATE:
1. ~/dev folder analysis:
   - Typical I/O patterns for source code access
   - Compilation impact on storage (build artifacts)
   - Build cache management strategies
   - Git repository metadata overhead
   - IDE/editor working set performance

2. Subvolume strategy for ~/dev:
   - Should ~/dev be separate subvolume from /home?
   - Rationale for dedicated subvolume (vs single /home)
   - Mount options optimized for development workload
   - Compression impact on source code and builds

3. Fine-grained subvolume structure within home:
   - /@home/dev → ~/dev (dedicated for projects)
   - /@home/cache → ~/.cache (IDE caches, build caches)
   - /@home/config → ~/.config (IDE configuration)
   - /@home/local → ~/.local (build artifacts, pip packages)
   - Separate or consolidated? Recommendation with rationale

4. Mount options for dev-specific optimization:
   - Compression strategy (source code compresses well ~50%)
   - autodefrag for build artifacts and IDE caches
   - noatime for read-heavy source code access
   - Optional nodatacow planning for build artifacts

5. Optional container support planning:
   - Where /var/lib/containers would mount if later needed
   - Integration with existing ~/dev workflow
   - Performance implications if containers added
   - Don't implement now, but design for future expansion

6. Performance characteristics:
   - Expected compilation speed
   - IDE responsiveness on light hardware
   - Build cache hit performance
   - Git operation speed (status, add, commit)
   - Typical project access latency

CONSTRAINTS:
- Prioritize ~/dev performance over system
- Keep configuration focused and lightweight (not over-engineered)
- Plan for future optional containers without over-designing
- Include autodefrag rationale for development caches
- Estimate compression ratio specifically for source code
- Explain trade-offs for portable development machine
```

### Ready-to-Use Prompt 3: Yoga Complete disko.nix Configuration

```
/openspec-proposal

TASK: Generate complete disko.nix configuration for Yoga host

CONTEXT:
Yoga host lightweight development machine

Primary workload: Light programming with ~/dev folder focus
Optional future: Small containers (Podman support but not primary)
Storage: Single NVMe drive (~954GB, virtio-scsi or native NVMe)
Portability: Important - need fast, responsive system

FACTER.JSON DATA:
[PASTE YOUR yoga-facter.json HERE]

REQUIRED OUTPUTS:
1. Device path verification
   - Extract actual device path from facter.json (nvme0n1 or /dev/sda)
   - Confirm storage size calculation from sectors
   - Verify storage controller type

2. Complete disko.nix code:
   - EFI partition configuration
   - Main btrfs partition with development-optimized subvolumes:
     * /@root → / (system)
     * /@home → /home (home base)
     * /@home/dev → /home/user/dev (DEDICATED for ~/dev projects)
     * /@home/cache → /home/user/.cache (IDE/build caches)
     * /@home/config → /home/user/.config (IDE configuration)
     * /@home/local → /home/user/.local (build artifacts)
     * /@nix → /nix (package store)
     * /@var → /var (system runtime)
     * /@cache → /var/cache (package caches)
     * /@log → /var/log (system logs)
     * /@tmp → /var/tmp (temporary files)
     * /@persist → /persist (impermanence pattern, optional)
     * FUTURE-READY: Comment showing where /var/lib/containers would go
   - All mount options fully specified
   - Ready to paste into flake.nix

3. Supporting NixOS configuration:
   - fstrim.timer setup for SSD health
   - Optional Podman configuration (stub/comments for future use)
   - snapper snapshot setup with ~/dev folder priority
   - kernel sysctl tuning for portable device
   - IDE/build cache optimization settings

4. Development environment setup:
   - IDE cache optimization strategy
   - Build artifact handling recommendations
   - Git repository performance tips
   - Compilation performance recommendations for portable device

5. Deployment instructions:
   - How to test configuration before committing
   - Device path update procedure (if needed)
   - Partition and mount steps
   - Verification checklist
   - Future container expansion path (if interested)

CONSTRAINTS:
- Device path from actual facter.json data
- Single-drive strategy (no multi-drive complexity)
- Prioritize ~/dev folder access performance
- Plan for optional container support (design for future, don't over-implement)
- Code must be valid Nix syntax
- Include clear comments explaining each section
- Keep configuration focused and lightweight
- Show how it differs from Zephyrus (explain trade-offs)
```

### Ready-to-Use Prompt 4: Yoga vs Zephyrus Comparison

```
/openspec-proposal

TASK: Compare Yoga and Zephyrus hosts, show why configurations differ

CONTEXT:
Comparing two development laptops:
1. Zephyrus: Heavy development + Podman containers + multiple high-performance NVMe drives
2. Yoga: Light development + optional containers + single portable NVMe

Both share ~/dev project folder (sync between hosts), but optimize differently.

ZEPHYRUS FACTER.JSON:
[PASTE zephyrus-facter.json for comparison]

YOGA FACTER.JSON:
[PASTE yoga-facter.json for analysis]

GENERATE:
1. Hardware comparison (Yoga vs Zephyrus):
   - Storage capacity differences (954GB vs 3TB)
   - Single-drive vs multi-drive implications
   - Performance characteristics
   - Use case alignment
   - Feature capability differences

2. Workload profile differences:
   - Zephyrus: Heavy development + container testing + aggressive builds
   - Yoga: Light development + optional containers + portable efficiency
   - How they complement each other

3. Subvolume layout differences:
   - Zephyrus: Multi-drive split (primary + secondary for containers)
   - Yoga: Single-drive optimization with dedicated ~/dev subvolume
   - Which subvolumes each has/lacks and why

4. Mount options differences:
   - Zephyrus: Aggressive autodefrag, multi-drive tuning, nodatacow for containers
   - Yoga: Lightweight, focused on ~/dev, future-ready for containers
   - Comparison table showing differences

5. Configuration recommendations for each host:
   - Zephyrus: Ready-to-use multi-drive disko.nix
   - Yoga: Ready-to-use single-drive lightweight disko.nix with ~/dev focus
   - How to keep ~/dev synchronized between hosts
   - When to use which host (recommend portable Yoga for travel, Zephyrus for heavy work)

6. Management strategy:
   - ~/dev folder synchronization approach
   - Configuration maintenance pattern
   - Backup strategy differences (both support snapshots)
   - Development workflow recommendations

CONSTRAINTS:
- Base all recommendations on actual facter.json data for both
- Clearly explain WHY configurations differ
- Show design trade-offs for each host
- Provide ready-to-use disko.nix for both hosts
- Include comparative analysis (side-by-side tables)
- Explain how lightweight design of Yoga differs from aggressive Zephyrus design
```

---

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
- Note: Projects in ~/dev folder (synced with Yoga host)

Hardware to analyze from facter.json:
- Storage device(s) and controller types
- Total memory and CPU cores
- System form factor
- Multi-disk configuration (Crucial P3 + Micron 2450)

FACTER.JSON DATA TO ANALYZE:
[PASTE YOUR zephyrus-facter.json HERE]

GENERATE:
1. Hardware profile summary (2-3 paragraphs)
   - Extract actual device names (nvme0n1, nvme1n1)
   - Storage controller types and performance
   - Multi-drive capabilities
   - Performance potential

2. Development workload analysis:
   - I/O patterns for Zed IDE
   - Podman container storage needs
   - Vivaldi browser cache patterns
   - Git repository access patterns
   - ~/dev folder access (in context of shared projects with Yoga)

3. Subvolume layout recommendation:
   - Primary drive (Crucial P3): system + home
   - Secondary drive (Micron 2450): containers + projects
   - Rationale for aggressive split strategy

4. Mount options matrix:
   - Show in table format
   - Include autodefrag candidates
   - Compression recommendations
   - nodatacow for container performance

5. Backup strategy:
   - Local snapshot strategy
   - External USB backup
   - Shared ~/dev sync considerations

CONSTRAINTS:
- Base ALL recommendations on actual facter.json data
- Use actual device paths from facter.json
- Explain multi-drive split strategy
- Include performance impact of each decision
- Note how this differs from lighter Yoga configuration
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

FACTER.JSON:
[PASTE zephyrus-facter.json]

GENERATE:
A detailed matrix showing for each subvolume:

| Subvolume | Location | Purpose | compress | noatime | autodefrag | nodatacow | discard | space_cache |

For each entry, provide:
1. Recommended setting value
2. Why this choice for this subvolume
3. Expected performance impact
4. Data safety implications

CONSTRAINTS:
- Prioritize development speed
- Include auto-defrag for cache-heavy subvolumes
- Explain autodefrag rationale for IDE/browser
```

### Ready-to-Use Prompt 3: Zephyrus Complete disko.nix

```
/openspec-proposal

TASK: Generate complete disko.nix configuration for Zephyrus

CONTEXT:
Asus ROG Zephyrus laptop optimized for heavy development

Workload: Zed IDE, Podman, Vivaldi, Niri, Git, OpenCode.ai
Projects: ~/dev folder (synced with Yoga host)

FACTER.JSON DATA:
[PASTE YOUR zephyrus-facter.json HERE]

REQUIRED OUTPUTS:
1. Device path verification from facter.json
2. Complete disko.nix code with all mount options
3. Supporting NixOS configuration
4. Deployment instructions
5. Notes on heavy-duty development optimization

CONSTRAINTS:
- Multi-drive aggressive optimization
- Device paths from facter.json
- Valid Nix syntax, production-ready
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

FACTER.JSON DATA TO ANALYZE:
[PASTE YOUR hetzner-vps-facter.json HERE]

GENERATE:
1. Hardware profile summary
2. Service I/O analysis
3. Single-disk subvolume layout
4. Mount options for VPS
5. Space management strategy
6. Backup strategy

CONSTRAINTS:
- Base on actual facter.json data
- Account for 458GB storage limitation
- Prioritize reliability over performance
- Include compression calculations
```

### Ready-to-Use Prompt 2: Hetzner Database Analysis (if applicable)

```
/openspec-proposal

TASK: Optimize disko.nix for Hetzner VPS with PostgreSQL database

CONTEXT:
Hetzner VPS with PostgreSQL production workload

FACTER.JSON:
[PASTE YOUR hetzner-vps-facter.json HERE]

GENERATE:
1. CoW impact analysis for PostgreSQL
2. Subvolume strategy decision
3. Mount options for database
4. Backup implications
5. Performance expectations

CONSTRAINTS:
- Prioritize data consistency
- Include performance comparisons
```

### Ready-to-Use Prompt 3: Hetzner Complete disko.nix

```
/openspec-proposal

TASK: Generate complete disko.nix for Hetzner VPS

CONTEXT:
Hetzner VPS production server with single 458GB virtual disk

Services running: [LIST YOUR ACTUAL SERVICES]

FACTER.JSON DATA:
[PASTE YOUR hetzner-vps-facter.json HERE]

GENERATE:
1. Device verification
2. Complete disko.nix code
3. NixOS configuration
4. Backup/snapshot procedure
5. Post-deployment steps

CONSTRAINTS:
- Single-disk strategy
- Production-ready configuration
- Valid Nix syntax
```

---

## Quick Examples to Copy-Paste

### Yoga Quick Example

```
/openspec-proposal

TASK: Generate disko.nix for Yoga lightweight development laptop with ~/dev optimization

Hardware: Single 954GB NVMe, light development focus

FACTER.JSON:
[PASTE yoga-facter.json]

GENERATE: Complete ready-to-deploy disko.nix with /@home/dev subvolume for ~/dev folder
```

### Zephyrus Quick Example

```
/openspec-proposal

TASK: Generate disko.nix for Zephyrus heavy development laptop

Hardware: Crucial P3 2TB + Micron 2450 1TB, heavy development + containers

FACTER.JSON:
[PASTE zephyrus-facter.json]

GENERATE: Complete ready-to-deploy disko.nix with multi-drive split strategy
```

### All Three Hosts Comparison

```
/openspec-proposal

TASK: Compare all three hosts and show why each configuration differs

CONTEXT:
Three development + production machines:
- Yoga: Lightweight portable development (~954GB)
- Zephyrus: Heavy development + containers (3TB multi-drive)
- Hetzner: Production server (458GB single virtual disk)

All share ~/dev project folder (where applicable)

YOGA FACTER.JSON:
[PASTE yoga-facter.json]

ZEPHYRUS FACTER.JSON:
[PASTE zephyrus-facter.json]

HETZNER FACTER.JSON:
[PASTE hetzner-vps-facter.json]

GENERATE:
1. Three-way hardware comparison table
2. Workload profile differences for each
3. Configuration comparison (design trade-offs)
4. Specific recommendations for each host
5. Multi-host management strategy
```

---

## Your Three Host Summary

| Host | Storage | Purpose | Config Focus |
|------|---------|---------|--------------|
| **Yoga** | 954GB NVMe (single) | Light development | Portable, ~/dev optimized |
| **Zephyrus** | 2TB + 1TB NVMe (dual) | Heavy development + containers | Aggressive, multi-drive split |
| **Hetzner** | 458GB virtual (single) | Production server | Reliability, snapshots |

---

## Next Steps

1. Choose your host (Yoga, Zephyrus, or all three)
2. Select appropriate prompt from above
3. Replace placeholder values with actual data
4. Paste into `/openspec-proposal <prompt>`
5. Review results and validate

**All 14 original prompts available in [128] - openspec-prompts.md**
**Quick reference guide available in [129] - openspec-quick-reference.md**
**This updated guide includes Yoga host-specific prompts for ~/dev optimization**

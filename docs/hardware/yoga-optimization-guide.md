# Yoga Host Optimization Guide - ~/dev Focused

## Your Yoga Host Hardware Profile

**Storage**: Single 954GB NVMe (WD PC SN7100S)
**Controller**: NVMe with native driver
**Form Factor**: Laptop/Ultrabook (portable)
**CPU**: Efficient mobile processor
**Memory**: Laptop-class RAM

## Why Yoga Needs Different Optimization Than Zephyrus

### Zephyrus (Heavy Development)
- **Drives**: 2 NVMe (3TB total) - aggressive split
- **Workload**: Heavy builds, intensive containers, testing
- **Strategy**: Maximize performance, separate concerns
- **Container**: Primary consideration (nodatacow on dedicated drive)

### Yoga (Light Development)
- **Drives**: 1 NVMe (954GB) - single, efficient
- **Workload**: Coding, light builds, portable development
- **Strategy**: Focus on ~/dev folder, keep lightweight
- **Container**: Optional future support, not primary

## Key Optimization: ~/dev Dedicated Subvolume

Unlike generic home directory setup, Yoga gets a **dedicated subvolume for ~/dev** because:

1. **Access Pattern**: Most I/O goes to project folder
2. **Compression**: Source code compresses extremely well (~50%)
3. **Snapshots**: Can snapshot projects independently
4. **Performance**: Separate mount options for development pattern
5. **Sharing**: Make it easy to sync with Zephyrus if needed

### Proposed Subvolume Layout for Yoga

```
YOGA HOST STORAGE LAYOUT (954GB NVMe)

/@root           → /                    (snapshottable, system state)
/@home           → /home                (user files)
  └─ /@home/dev  → ~/dev               (PROJECT FOCUS - dedicated subvolume)
  └─ /@home/cache → ~/.cache           (IDE/build caches)
  └─ /@home/config → ~/.config         (IDE configuration)
  └─ /@home/local  → ~/.local          (build artifacts, packages)
/@nix            → /nix                (package store)
/@var            → /var                (system runtime)
/@cache          → /var/cache          (volatile cache)
/@log            → /var/log            (system logs)
/@tmp            → /var/tmp            (temporary files)
/@persist        → /persist            (impermanence, optional)

FUTURE PLACEHOLDER (if containers needed):
  [Would add /@containers → /var/lib/containers here]
  [Currently documented but not implemented]
```

## Mount Options by Subvolume

### /@home/dev (Your Project Folder) - OPTIMIZED

```nix
mountpoint = "/home/user/dev";
mountOptions = [
  "subvol=home/dev"
  "compress=zstd:3"       # Source code ~50% compression ratio
  "noatime"               # Skip atime for read-heavy operations
  "autodefrag"            # Helps with frequent edits and builds
  "discard=async"         # SSD-friendly async TRIM
  "space_cache=v2"        # Modern free space tracking
];
```

**Why these options**:
- `compress=zstd:3`: Source code, configs compress excellently; CPU not bottleneck
- `noatime`: Projects are read-heavy; skipping atime improves performance
- `autodefrag`: Build artifacts and IDE working files benefit from defrag
- `discard=async`: Laptop SSD needs efficient TRIM (async better for responsiveness)
- `space_cache=v2`: Default modern setting

### /@home/cache (IDE/Build Caches)

```nix
mountpoint = "/home/user/.cache";
mountOptions = [
  "subvol=home/cache"
  "compress=zstd:3"
  "noatime"
  "autodefrag"        # Caches are written and replaced frequently
  "discard=async"
];
```

**Why separate from /@home/dev**:
- Exclude from snapshots (volatile, rebuild-able)
- Different access pattern (write-heavy cache management)
- Can manage retention independently

### /@home/config (IDE Configuration)

```nix
mountpoint = "/home/user/.config";
mountOptions = [
  "subvol=home/config"
  "compress=zstd:3"
  "noatime"
  "discard=async"
  "space_cache=v2"
];
```

**Why separate**:
- Keep IDE settings with snapshots (important for config history)
- Different access pattern than projects
- Easier to restore specific IDE state

### /@home/local (Build Artifacts, Packages)

```nix
mountpoint = "/home/user/.local";
mountOptions = [
  "subvol=home/local"
  "compress=zstd:3"
  "noatime"
  "discard=async"
];
```

**Why separate**:
- Build artifacts (node_modules, pip cache, etc.) can be rebuilt
- Exclude from snapshots (saves space)
- Different backup strategy

### Other Subvolumes

**/@root, /@nix, /@var, /@log, /@cache, /@persist**: Same as Zephyrus/Hetzner patterns
- `compress=zstd:3` on all (storage limited to 954GB)
- `noatime` everywhere
- `discard=async` for SSD
- Standard snapshottable/non-snapshottable split

## Space Allocation Strategy for 954GB

With 954GB total and btrfs compression:

```
Allocation (with compression estimates):

/@root (system)          ~50GB allocated, ~35GB effective
/@home (configs, misc)   ~30GB allocated, ~25GB effective
/@home/dev (PROJECTS)    ~400GB allocated, ~300GB effective (50% compression)
/@home/cache (caches)    ~100GB allocated, ~80GB effective
/@home/local (artifacts) ~100GB allocated, ~80GB effective
/@nix (packages)         ~150GB allocated, ~110GB effective
/@var, /@log, /@tmp     ~50GB allocated, ~35GB effective

Total allocation: 880GB
Effective capacity: ~665GB usable (with compression)
Free space buffer: ~74GB (for snapshots, metadata, growth)
```

**Key insight**: With compression, your single NVMe effectively behaves like 1.4TB for typical development workloads (lots of text, source code, configs).

## Optional Container Support Planning

If you later want to run small containers on Yoga:

**Where containers would go** (future, not in initial setup):
```nix
/@containers → /var/lib/containers
mountOptions = [
  "subvol=containers"
  "noatime"
  "discard=async"
  "nodatacow"        # Only if we want performance over CoW safety
];
```

**Design considerations**:
- Keep container storage separate from ~/dev
- Can use overlay2 driver (default) without subvolume
- If images stored directly as subvolume, would use nodatacow for performance
- Current design leaves this path open but doesn't over-implement

**Current recommendation**: Use Podman with overlay2 driver (default), don't use btrfs directly for container storage. This keeps Yoga lightweight and focused.

## Performance Expectations for Yoga

### Realistic Numbers
- **Source code access**: ~instant (cached by filesystem)
- **Compilation speed**: Depends on CPU (portable = less powerful than Zephyrus)
- **IDE responsiveness**: Good with autodefrag and compression
- **Git operations**: Fast (metadata cached)
- **Build caches**: Help significantly with incremental builds
- **Effective storage**: ~1.4TB usable (due to compression)

### Vs Zephyrus Comparison
- **Storage**: 954GB (Yoga) vs 3TB (Zephyrus) - portable trade-off
- **Speed**: Slightly slower CPU (Yoga) vs high-end (Zephyrus)
- **But**: Dedicated ~/dev subvolume on Yoga optimizes project access
- **Result**: Similar responsiveness for project work, lighter hardware

## Backup Strategy for Yoga

### Local Snapshots
```bash
# Automatic snapshots every hour/day
snapper -c root create-config /
snapper -c home create-config /home

# Yoga-specific: Can snapshot ~/dev independently
snapper -c dev create-config /home/user/dev
```

### External Backup
```bash
# Sync to Zephyrus or external drive
rsync -av ~/dev /mnt/backup-usb/dev

# Or send to cloud
btrfs send /home/dev/.snapshots/123/snapshot | \
  aws s3 cp - s3://backup/yoga-dev.btrfs
```

### Shared ~/dev with Zephyrus
Since both Yoga and Zephyrus have ~/dev folders with same projects:

**Option 1: Sync primary (Zephyrus) to secondary (Yoga)**
```bash
# On Yoga (pull from Zephyrus)
rsync -av user@zephyrus:~/dev/ ~/dev/
```

**Option 2: Backup both to cloud**
```bash
# Both machines backup to same cloud bucket
btrfs send /home/dev-snapshot | aws s3 cp - s3://dev-backup/host-name/
```

## OpenSpec Prompts for Yoga

Ready-to-use prompts available in [131]:

1. **Yoga Hardware Analysis**: Analyze [yoga-facter.json](/home/hbohlen/dev/pantherOS/hosts/yoga/facter.json) and get subvolume recommendations
2. **Yoga ~/dev Deep-Dive**: Optimize project folder specifically
3. **Yoga Complete disko.nix**: Generate ready-to-deploy configuration
4. **Yoga vs Zephyrus**: Compare and show why configurations differ

## Implementation Steps

1. **Analyze hardware**:
   ```bash
   /openspec-proposal [Prompt 1 from 131]
   ```

2. **Deep dive on ~/dev optimization**:
   ```bash
   /openspec-proposal [Prompt 2 from 131]
   ```

3. **Generate disko.nix**:
   ```bash
   /openspec-proposal [Prompt 3 from 131]
   ```

4. **Compare with Zephyrus** (optional):
   ```bash
   /openspec-proposal [Prompt 4 from 131]
   ```

5. **Deploy and validate**:
   ```bash
   # Test configuration
   nix run github:nix-community/disko -- --mode test --file ./disko.nix
   
   # Deploy with nixos-anywhere (from local machine)
   nixos-anywhere --flake .#yoga --target-host root@yoga-ip
   ```

## Key Differences: Yoga vs Zephyrus vs Hetzner

| Aspect | Yoga | Zephyrus | Hetzner |
|--------|------|----------|---------|
| **Storage** | 954GB single | 2TB + 1TB dual | 458GB virtual |
| **~/dev focus** | PRIMARY | Secondary | N/A (server) |
| **Containers** | Optional future | Primary feature | N/A |
| **Approach** | Lightweight portable | Aggressive high-perf | Reliable production |
| **Subvolume count** | 11 (focused) | 7 per drive (split) | 8 (unified) |
| **Compression** | Yes (source code) | Yes (all drives) | Yes (limited storage) |
| **autodefrag** | Yes (dev caches) | Yes (both drives) | No (server writes) |
| **nodatacow** | None (not needed) | Yes (containers) | Optional (database) |
| **Backup** | Snapshots + rsync | Snapshots + external | Snapshots + send/receive |

## Summary

Your **Yoga host** is optimized for:
- ✅ Portable development machine
- ✅ Dedicated ~/dev project folder optimization
- ✅ Light programming workloads
- ✅ Optional future container support
- ✅ Efficient single-drive strategy
- ✅ Easy synchronization with Zephyrus

Unlike Zephyrus's aggressive multi-drive setup, Yoga focuses on doing one thing well: optimizing project folder access on limited, portable storage. The dedicated /@home/dev subvolume ensures your most-accessed data (source code, projects) gets maximum optimization, while optional container support remains available if needed.

---

**See [131] for copy-paste-ready prompts for your Yoga host**

# Phase 1: Hardware Discovery Tasks

**Phase 1 Goal:** Complete hardware discovery and documentation for all hosts

## High Priority Tasks

### Hardware Specification Research
**Priority:** High
**Status:** TODO

Research what hardware information is relevant to collect from each host to determine configuration and optimization strategies.

**Hosts requiring hardware scan:**
- [ ] yoga (Lenovo Yoga 7 2-in-1 14AKP10)
- [ ] zephyrus (ASUS ROG Zephyrus M16 GU603ZW)
- [ ] hetzner-vps (Hetzner Cloud VPS)
- [ ] ovh-vps (OVH Cloud VPS)

### Hardware Scanning Script Development
**Priority:** High
**Status:** TODO

Develop a plan for scanning devices to collect hardware specifications.

**Deliverables:**
- Script to scan hardware specifications
- Standardized output format
- Documentation on hardware attributes collected

### Hardware Specification Documentation
**Priority:** High
**Status:** TODO

Update and record hardware specifications for all hosts.

**For each host, document:**
- [ ] CPU details (model, cores, threads, features)
- [ ] GPU details (integrated/discrete)
- [ ] RAM (total, type, speed)
- [ ] Disk layout (SSDs, capacity, interface)
- [ ] Network adapters
- [ ] Other relevant hardware (battery, sensors, etc.)

### Disk Layout Planning
**Priority:** High
**Status:** TODO
**Dependencies:** Hardware specifications collected

Determine optimal disk layout configurations for each host, optimized for:

**Considerations:**
- Btrfs sub-volume layout
- Host-specific purpose (workstation vs server)
- SSD longevity optimizations
- Podman/Podman Compose requirements
- Development projects location (~/dev)

**Deliverables:**
- [ ] disk-layouts.md document with plans per host
- [ ] Requirements for each host type
- [ ] Sub-volume strategy documentation

### Disko Configuration Creation
**Priority:** High
**Status:** TODO
**Dependencies:** Disk layout planning complete

Create `disko.nix` files for each host using Disko.

**Deliverables:**
- [ ] `hosts/yoga/disko.nix`
- [ ] `hosts/zephyrus/disko.nix`
- [ ] `hosts/servers/hetzner-vps/disko.nix`
- [ ] `hosts/servers/ovh-vps/disko.nix`

Each configuration should:
- Use Btrfs filesystem
- Implement optimal sub-volume layout
- Support host-specific requirements

## Success Criteria for Phase 1

- [ ] All 4 hosts have complete hardware documentation
- [ ] Hardware scanning script exists and is tested
- [ ] Disk layout strategy is documented
- [ ] Disko configurations created for all hosts
- [ ] Hardware specs visible in `docs/hardware/`

## Next Phase

Once Phase 1 is complete, proceed to [Phase 2: Module Development](./phase2-module-development.md)

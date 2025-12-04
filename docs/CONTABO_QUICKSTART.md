# Contabo VPS Quick Start Guide

## TL;DR - Get Hardware Specs

```bash
# 1. Boot Contabo server into NixOS live environment
# 2. Copy setup script to server
scp /home/user/pantherOS/scripts/setup-contabo-vps.sh root@<your-contabo-ip>:/tmp/

# 3. SSH to server
ssh root@<your-contabo-ip>

# 4. Run setup script (on Contabo server)
bash /tmp/setup-contabo-vps.sh

# 5. Copy hardware output back (from local machine)
scp root@<your-contabo-ip>:/tmp/contabo-detection/hardware-info.json \
    /home/user/pantherOS/hosts/servers/contabo-vps/facter.json

# 6. Update configuration files with hardware specs
# - Edit disko.nix: update device path
# - Edit default.nix: update network interface name
# - Edit hardware.nix: verify kernel modules
```

## What the Setup Script Does

- ✓ Verifies NixOS environment
- ✓ Installs Determinate Nix
- ✓ Detects CPU, RAM, disk, network interfaces
- ✓ Generates `hardware-info.json` with system specs
- ✓ Provides next steps

## Setup Script Output

After running, you'll find:
- Hardware information in: `/tmp/contabo-detection/hardware-info.json`
- Detailed instructions in script output

## Configuration Files to Update

After getting hardware specs:

### 1. `disko.nix` - Update disk device
```nix
device = "/dev/disk/by-id/scsi-XXXXXXX";  # From facter
```

### 2. `default.nix` - Update network interface
```nix
matchConfig.Name = "eth0";  # From facter (could be enp*, ens*, eth0)
```

### 3. `hardware.nix` - Verify kernel modules
- Check CPU type (kvm-amd vs kvm-intel)
- Verify available storage modules

## Next: Deploy

After configuration is ready:
```bash
./scripts/verify-contabo-deployment.fish
# Then
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#contabo-vps" \
  --no-reboot \
  root@<contabo-ip>
```

## OpenSpec Proposal

Full specification available at:
- `openspec/changes/add-contabo-vps-server/`
  - `proposal.md` - Why and what
  - `tasks.md` - Implementation checklist
  - `specs/` - Requirements and scenarios

## Reference Configs

- **Hetzner** (`hosts/servers/hetzner-vps/`) - UEFI boot, 480GB, smaller
- **OVH** (`hosts/servers/ovh-vps/`) - BIOS boot, 200GB, smaller
- **Contabo** (`hosts/servers/contabo-vps/`) - Likely BIOS, 250GB, larger

## Hardware Specs

**Contabo Cloud VPS 40:**
- 12 vCPU cores
- 48 GB RAM
- 250 GB NVMe
- Unlimited traffic @ 800 Mbit/s

**Optimization includes:**
- 15 Btrfs subvolumes for different workloads
- 10GB swap for intensive builds
- Container-optimized storage (nodatacow)
- AI tools subvolume for models/caches
- Performance tuning for development

## Support Files

- `HETZNER_DEPLOYMENT.md` - Detailed deployment guide (mostly applicable)
- `scripts/README.md` - Verification scripts documentation
- `scripts/setup-contabo-vps.sh` - Bash setup
- `scripts/setup-contabo-vps.fish` - Fish setup

---

**Your Contabo VPS is ready to go!** 🚀
Just run the setup script to get hardware specs and follow the next steps.

# Hardware Detection Implementation – Quick Summary

## What Was Done

Converted the CachyOS imperative hardware detection system into a declarative NixOS implementation. Instead of bash/fish scripts that run at system startup, hardware specifications are now discovered from the existing `zephyrus-facter.json` manifest during NixOS evaluation.

## Files Created

### Core Implementation

| Path                                     | Purpose                                                                                            |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `lib/hardware-detection.nix`             | Utility library for parsing facter JSON data (CPU, GPU, memory, storage, network detection)        |
| `modules/hardware/asus-rog.nix`          | ASUS ROG hardware support module (power management, asusctl daemon, battery threshold, udev rules) |
| `modules/hardware/detection-scripts.nix` | Runtime diagnostic scripts (hardware-inventory, verify-hardware, power-status)                     |
| `modules/hardware/default.nix`           | Module aggregator                                                                                  |
| `hosts/zephyrus/hardware-facter.nix`     | Zephyrus-specific hardware config using facter data                                                |

### Documentation

| Path                                   | Purpose                                                     |
| -------------------------------------- | ----------------------------------------------------------- |
| `docs/HARDWARE_DETECTION.md`           | Complete usage guide, architecture, troubleshooting         |
| `HARDWARE_DETECTION_IMPLEMENTATION.md` | Detailed implementation notes, design decisions, next steps |
| `openspec-zephyrus-migration-plan.md`  | Original multi-phase migration plan (reference)             |

### Modified

| Path                         | Changes                                                |
| ---------------------------- | ------------------------------------------------------ |
| `flake.nix`                  | Added zephyrus nixosConfiguration with facter support  |
| `hosts/zephyrus/default.nix` | Added imports for hardware-facter.nix and hardware.nix |

## Architecture

```
zephyrus-facter.json (existing hardware manifest from nixos-facter)
           ↓
lib/hardware-detection.nix (parse, extract CPU/GPU/memory/storage specs)
           ↓
modules/hardware/asus-rog.nix (ASUS ROG features: asusctl, power profiles, battery management)
modules/hardware/detection-scripts.nix (runtime diagnostics: hardware-inventory, verify-hardware, power-status)
           ↓
hosts/zephyrus/hardware-facter.nix (apply to system config)
           ↓
NixOS build with hardware-specific settings
```

## Key Features

### 1. Automatic Detection
- **CPU**: Model, manufacturer, clock speeds (from facter JSON)
- **GPU**: Display capability, vendors, hybrid detection (from facter JSON)
- **Memory**: Modules, sizes, speeds (from facter JSON)
- **Storage**: All devices, NVMe count, models (from facter JSON)
- **ASUS ROG**: Platform auto-detect via manufacturer/product fields
- **Laptop**: Battery presence detection

### 2. ASUS ROG Support
- `asusctl` system control daemon (enabled automatically on ROG hardware)
- `power-profiles-daemon` for AC/battery profile switching
- Battery charge limit (configurable, default: 80%)
- Keyboard backlight control
- Udev rules for unprivileged hardware access
- Polkit rules for profile switching without sudo

### 3. Runtime Diagnostic Scripts
- **`hardware-inventory`** – Full hardware report (CPU, GPU, memory, storage, power, ROG features, thermal zones)
- **`verify-hardware`** – Automated validation of critical components
- **`power-status`** – Quick power and battery status report

## How It Works

### At Build Time
1. NixOS evaluates `hosts/zephyrus/hardware-facter.nix`
2. Reads `zephyrus-facter.json` to extract hardware specs
3. `lib/hardware-detection.nix` parses CPU, GPU, memory, storage, network info
4. Applies appropriate kernel modules, drivers, and services based on detected hardware
5. Generates configuration documentation at `/etc/hardware-summary.txt`

### At Runtime
Users can run diagnostic scripts to verify hardware detection:
```bash
hardware-inventory  # Full report
verify-hardware /tmp/hw.txt  # Validation
power-status  # Quick battery/power check
```

## Verification Status

### ✅ Build Verification
- ✅ `nix-instantiate --parse lib/hardware-detection.nix` – Syntax OK
- ✅ `nix-instantiate --parse modules/hardware/asus-rog.nix` – Syntax OK
- ✅ `nix-instantiate --parse modules/hardware/detection-scripts.nix` – Syntax OK
- ✅ `nix-instantiate --parse hosts/zephyrus/hardware-facter.nix` – Syntax OK
- ⏳ `nix flake check` – Pending (repository has unrelated merge conflicts in other modules)

### ⏳ Runtime Verification (requires actual system boot)
- [ ] `hardware-inventory` output matches actual hardware
- [ ] `verify-hardware` reports all checks passed
- [ ] `/etc/hardware-summary.txt` matches detected hardware
- [ ] ASUS WMI detected: `lsmod | grep asus` shows modules loaded
- [ ] Power profiles working: `systemctl status power-profiles-daemon`
- [ ] asusctl daemon running: `systemctl status asusctl`

## Known Limitations

1. **Facter Data Staleness** – If hardware is upgraded (SSD, RAM), must regenerate facter.json
2. **ASUS WMI Not Guaranteed** – Not all ROG models expose all features
3. **Battery Threshold Support** – Firmware-dependent, may not work on all models
4. **Hybrid GPU Driver Selection** – Requires manual testing for NVIDIA open vs proprietary drivers
5. **1Password Not Included** – Handled separately in security modules (future prompts)

## Next Steps

### Immediate (Validation)
1. Resolve existing merge conflicts in repository (pre-existing, not from this work)
2. Run `nix flake check` to verify all configurations
3. Test actual system build with `nix build .#nixosConfigurations.zephyrus`

### Short Term (Testing)
1. Boot into zephyrus system
2. Run diagnostic scripts: `hardware-inventory`, `verify-hardware`, `power-status`
3. Verify ASUS ROG features are working (power profiles, battery threshold, etc.)

### Later (Integration)
- **Prompt 2**: Power management module (battery/AC profile switching)
- **Prompt 3**: Storage optimization (TRIM, I/O schedulers, BTRFS)
- **Prompts 4-8**: Shell, security, desktop, development environments

## Quick Reference

### Enable ASUS Features
```nix
hardware.asus = {
  enable = true;  # Auto-detected from facter
  asusc = true;   # System control daemon
  powerProfiles = true;  # Profile switching
  enableBatteryThreshold = 80;  # Charge limit (%))
  enableKeyboardBacklight = true;
};
```

### View Hardware Summary
```bash
cat /etc/hardware-summary.txt
```

### Troubleshoot Missing Hardware
```bash
cat hosts/zephyrus/zephyrus-facter.json | jq '.hardware | keys'
# Should show: processor, disk, memory, display, network, system, etc.
```

### Regenerate Facter Data (if hardware changed)
```bash
nix run github:nix-community/nixos-facter -- \
  --output ./hosts/zephyrus/zephyrus-facter.json
git add hosts/zephyrus/zephyrus-facter.json
```

## Documentation

- **Complete Guide**: See `docs/HARDWARE_DETECTION.md`
- **Implementation Details**: See `HARDWARE_DETECTION_IMPLEMENTATION.md`
- **Design Plan**: See `openspec-zephyrus-migration-plan.md`

---

**Status**: Ready for testing and validation  
**Syntax Validation**: All modules pass `nix-instantiate --parse`  
**Next Phase**: Prompt 2 – Power Management & Profile Switching

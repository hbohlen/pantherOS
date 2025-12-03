# Hardware Detection Implementation Summary

**Date**: 2025-01-01  
**Status**: verificationStatus = pending  
**Step**: Hardware Detection & Inventory System (Prompt 1 Conversion)

## Overview

Converted the CachyOS imperative hardware detection system into a declarative NixOS implementation using:

1. **Facter-based hardware discovery** – Leverages existing `zephyrus-facter.json`
2. **Nix utility library** – Parses facter data with `lib/hardware-detection.nix`
3. **NixOS modules** – Declarative ASUS ROG support and diagnostics
4. **Runtime scripts** – Hardware inventory, verification, and power status tools

This replaces bash/fish imperative scripts with pure Nix declarative configuration while maintaining diagnostic capabilities.

## Files Created

### Core Infrastructure

| File                                     | Purpose                                                                                   |
| ---------------------------------------- | ----------------------------------------------------------------------------------------- |
| `lib/hardware-detection.nix`             | Utility functions to extract CPU, GPU, memory, storage, network info from facter JSON     |
| `modules/hardware/asus-rog.nix`          | ASUS ROG hardware support (asusctl, power-profiles-daemon, battery threshold, udev rules) |
| `modules/hardware/detection-scripts.nix` | Runtime diagnostic scripts (hardware-inventory, verify-hardware, power-status)            |
| `modules/hardware/default.nix`           | Module aggregator                                                                         |
| `hosts/zephyrus/hardware-facter.nix`     | Zephyrus-specific hardware configuration using facter data                                |

### Documentation & Integration

| File                                   | Purpose                                             |
| -------------------------------------- | --------------------------------------------------- |
| `docs/HARDWARE_DETECTION.md`           | Complete usage guide and architecture documentation |
| `HARDWARE_DETECTION_IMPLEMENTATION.md` | This file – implementation summary                  |

### Modified Files

| File                         | Changes                                                 |
| ---------------------------- | ------------------------------------------------------- |
| `hosts/zephyrus/default.nix` | Added imports for hardware-facter.nix and hardware.nix  |
| `flake.nix`                  | Enabled zephyrus nixosConfiguration with facter support |

## Key Design Decisions

### 1. Facter-Based Detection (vs Imperative Runtime Queries)

**Decision**: Use existing `zephyrus-facter.json` as primary hardware source.

**Rationale**:
- Declarative, reproducible hardware config
- Doesn't require root/sudo during normal system operation
- Single source of truth (facter manifest)
- Can be version-controlled

**Trade-off**: Facter data must be regenerated if hardware changes (SSD upgrade, RAM addition).

### 2. Hardware Detection Library (`lib/hardware-detection.nix`)

**Decision**: Create utility functions to extract specs from facter data.

**Functions Provided**:
- `extractCPU` – CPU model, manufacturer, clock speeds
- `extractGPU` – Display capability, vendor info, count
- `extractMemory` – RAM count, sizes, speeds
- `extractStorage` – Disk devices, NVMe detection
- `extractNetwork` – Network device info
- `isASUSROG` – ASUS platform detection
- `isLaptop` – Battery presence detection
- `detectHybridGPU` – Intel iGPU + NVIDIA dGPU detection
- `summarizeHardware` – Complete hardware manifest

**Rationale**: Encapsulates facter parsing logic, reusable across modules.

### 3. ASUS ROG Module (`modules/hardware/asus-rog.nix`)

**Decision**: Declarative ASUS hardware support with auto-detection.

**Features**:
- Auto-enable based on facter (detectable via manufacturer/product fields)
- `asusctl` system control daemon
- `power-profiles-daemon` for AC/battery profile switching
- Battery charge limit (configurable, default 80%)
- Udev rules for unprivileged hardware access
- Polkit rules for power profile switching without sudo

**Configuration Options**:
```nix
hardware.asus = {
  enable = true;  # Auto-detected
  asusc = true;
  powerProfiles = true;
  enableBatteryThreshold = 80;  # Set to null to disable
  enableKeyboardBacklight = true;
};
```

**Sources**:
- [asusctl in nixpkgs](https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/system/asusctl/default.nix)
- [power-profiles-daemon in nixpkgs](https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/system/power-profiles-daemon/default.nix)
- [ASUS ROG on Arch Wiki](https://wiki.archlinux.org/title/ASUS_ROG_utilities)

### 4. Hardware Detection Scripts

**Decision**: Declarative script generation instead of source files.

**Scripts Provided**:
1. **`hardware-inventory`** – Full hardware report (CPU, GPU, memory, storage, power, ROG features, thermal)
2. **`verify-hardware`** – Automated validation of critical components
3. **`power-status`** – Quick power/battery status report

**Implementation**: `pkgs.writeScriptBin` in `modules/hardware/detection-scripts.nix`

**Rationale**: No need to maintain separate shell script files; Nix generates them during build.

### 5. Facter-Driven Host Configuration

**Decision**: Use `hardware-facter.nix` to consume facter data and apply settings.

**CPU Detection**:
```nix
isAMDCPU = hasInfix "AMD" (hw.cpu.model or "");
isIntelCPU = hasInfix "Intel" (hw.cpu.model or "");

boot.kernelModules = 
  if isAMDCPU then [ "kvm-amd" ]
  else if isIntelCPU then [ "kvm-intel" ]
  else [ ];
```

**GPU Detection**:
```nix
hardware.nvidia = mkIf hw.hasHybridGPU {
  open = true;
  modesetting.enable = true;
};
```

**Storage Detection**:
- NVMe support: Always enabled (required for Crucial P310 Plus)
- Assertions fail if NVMe not detected (catches facter errors early)

## Verification Checklist

### Build-Time Verification

- [ ] `nix flake check` passes
- [ ] `nix build .#nixosConfigurations.zephyrus.config.system.build.toplevel --dry-run` succeeds
- [ ] No evaluation errors in `hardware-detection.nix`
- [ ] No evaluation errors in `modules/hardware/asus-rog.nix`
- [ ] No evaluation errors in `modules/hardware/detection-scripts.nix`
- [ ] No evaluation errors in `hosts/zephyrus/hardware-facter.nix`

### Post-Build Verification (After System Boot)

- [ ] Run `hardware-inventory` and check for all hardware sections
- [ ] Run `verify-hardware /tmp/hw-report.txt` – expect all checks to pass
- [ ] Run `power-status` and verify power profile detection works
- [ ] Check `cat /etc/hardware-summary.txt` matches actual hardware
- [ ] Verify ASUS ROG detection: `lsmod | grep asus`
- [ ] Verify power-profiles-daemon: `systemctl status power-profiles-daemon`
- [ ] Verify asusctl daemon: `systemctl status asusctl`

## Known Limitations

### 1. Facter Data Staleness

If hardware is modified (SSD upgrade, RAM addition), facter data must be regenerated:

```bash
nix run github:nix-community/nixos-facter -- --output ./hosts/zephyrus/zephyrus-facter.json
git add hosts/zephyrus/zephyrus-facter.json
```

### 2. ASUS WMI Module Availability

Not all ASUS ROG models expose `/sys/devices/platform/asus-nb-wmi`. Some features may fail silently. Fallback to manual udev rules or kernel module tweaks if needed.

### 3. Battery Threshold Not Guaranteed

Battery charge limit (`charge_control_end_threshold`) requires kernel module support. Not all ASUS ROG models support it. The udev rule is declarative, but actual hardware support is firmware-dependent.

**If battery threshold doesn't work**:
```bash
# Check if sysfs path exists
ls -la /sys/class/power_supply/BAT*/charge_control_end_threshold

# Manual fallback
echo 80 | sudo tee /sys/class/power_supply/BAT*/charge_control_end_threshold
```

### 4. Hybrid GPU Driver Selection

Hybrid GPU detection works, but NVIDIA driver selection (`hardware.nvidia.open` vs proprietary) requires manual testing. Default is `open = true` for modern GPUs; change if needed.

### 5. No First-Class 1Password Support

This module does NOT configure 1Password (handled by security modules in future prompts). Power management and ASUS tools are independent.

## Integration Points

### Already Integrated

- ✅ `flake.nix` – zephyrus configuration added with facter support
- ✅ `hosts/zephyrus/default.nix` – imports hardware modules

### Future Integration (Subsequent Prompts)

1. **Prompt 2: Power Management** – Uses hardware detection to trigger profile switching based on battery state
2. **Prompt 3: Storage Optimization** – Uses NVMe detection to enable TRIM/scheduler optimization
3. **Prompt 4-8: Shell, Security, Desktop, Dev** – All consume hardware detection for feature flags

## Next Steps

### Before Proceeding to Prompt 2

1. **Verify build succeeds**:
   ```bash
   nix flake check
   nix build .#nixosConfigurations.zephyrus.config.system.build.toplevel --dry-run
   ```

2. **Review hardware detection logic** in:
   - `lib/hardware-detection.nix`
   - `modules/hardware/asus-rog.nix`
   - `hosts/zephyrus/hardware-facter.nix`

3. **Confirm facter data accuracy**:
   ```bash
   cat hosts/zephyrus/zephyrus-facter.json | jq '.hardware | keys'
   # Should show: processor, disk, memory, display, network, system, etc.
   ```

4. **Test runtime scripts** (after actual system boot):
   ```bash
   hardware-inventory
   verify-hardware /tmp/hw-report.txt
   power-status
   ```

### Prompt 2: Power Management (Battery/AC Profiles)

Will depend on:
- Hardware detection to identify laptop capability (`isLaptop`)
- ASUS ROG module for battery threshold and power profiles
- Runtime service to monitor battery state and switch profiles automatically

## References

- [NixOS Manual – Boot Options](https://nixos.org/manual/nixos/stable/#ch-booting)
- [NixOS Manual – Hardware Configuration](https://nixos.org/manual/nixos/stable/#sec-hardware-configuration)
- [nixos-facter-modules](https://github.com/nix-community/nixos-facter-modules)
- [NixOS Hardware Modules](https://github.com/nix-community/nixos-hardware)
- [Arch Wiki – ASUS ROG utilities](https://wiki.archlinux.org/title/ASUS_ROG_utilities)
- [asusctl GitHub](https://github.com/flubberding/asusctl)

## Summary

✅ **Complete**: Hardware detection system converted from imperative CachyOS scripts to declarative NixOS configuration

**Key achievements**:
- Facter-based hardware discovery
- ASUS ROG platform support with auto-detection
- Declarative hardware scripts (hardware-inventory, verify-hardware, power-status)
- Reusable hardware detection library (`lib/hardware-detection.nix`)
- Comprehensive documentation

**Ready for**: Verification and testing, followed by Prompt 2 (Power Management)

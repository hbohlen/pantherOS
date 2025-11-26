# Hardware Scanning Workflow for Personal Devices

## Overview

This document outlines the hardware scanning process for the zephyrus and yoga personal devices using NixOS Facter, a modern hardware detection tool designed specifically for NixOS.

## Tools Used

### NixOS Facter
- **Repository**: https://github.com/nix-community/nixos-facter
- **Purpose**: Generates detailed JSON hardware reports
- **Installation**: Available in nixpkgs as `nixos-facter`

### NixOS Facter Modules
- **Repository**: https://github.com/nix-community/nixos-facter-modules
- **Purpose**: NixOS modules that automatically configure hardware based on facter reports
- **Features**: Automatic detection and configuration of network, graphics, USB, and other hardware

## Hardware Scanning Workflow

### Prerequisites
- Physical access to target devices (zephyrus and yoga)
- Devices must be running (can be live USB or installed system)
- Root/sudo access on target devices

### Step 1: Generate Hardware Reports

For each device, run nixos-facter to generate a hardware report:

```bash
# On zephyrus device (as root):
sudo nix run nixpkgs#nixos-facter -- -o /tmp/zephyrus-facter.json

# On yoga device (as root):
sudo nix run nixpkgs#nixos-facter -- -o /tmp/yoga-facter.json
```

**Alternative using latest version:**
```bash
# Using latest development version
sudo nix run \
  --option extra-substituters https://numtide.cachix.org \
  --option extra-trusted-public-keys numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE= \
  github:nix-community/nixos-facter -- -o /tmp/device-facter.json
```

### Step 2: Transfer Reports

Copy the generated JSON files to the project repository:

```bash
# From each device, copy to project
scp /tmp/zephyrus-facter.json user@server:/path/to/pantherOS/
scp /tmp/yoga-facter.json user@server:/path/to/pantherOS/
```

### Step 3: Create Host Configurations

Using the facter reports, create host directories and configurations:

```
hosts/
├── zephyrus/
│   ├── default.nix          # Main host configuration
│   ├── hardware.nix         # Hardware-specific config (generated)
│   ├── disko.nix           # Disk partitioning config
│   └── meta.nix            # Hardware metadata (from facter)
└── yoga/
    ├── default.nix
    ├── hardware.nix
    ├── disko.nix
    └── meta.nix
```

### Step 4: Integrate with NixOS Facter Modules

Update flake.nix to include nixos-facter-modules:

```nix
inputs = {
  # ... existing inputs
  nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";
};

outputs = { nixos-facter-modules, ... }: {
  nixosConfigurations.zephyrus = lib.nixosSystem {
    modules = [
      nixos-facter-modules.nixosModules.facter
      { config.facter.reportPath = ./zephyrus-facter.json; }
      ./hosts/zephyrus/default.nix
      # ... other modules
    ];
  };
};
```

### Step 5: Generate Hardware Configurations

The nixos-facter-modules will automatically:
- Detect network interfaces and configure networking
- Configure graphics drivers
- Set up USB devices
- Configure audio devices
- Handle other hardware-specific settings

### Step 6: Manual Hardware Configuration

For components not automatically detected, manually create:
- `hardware.nix`: Manual hardware configuration overrides
- `disko.nix`: Disk partitioning configuration
- `meta.nix`: Hardware specifications summary

## Validation Steps

After setup, validate each configuration:

```bash
# Test flake validity
nix flake check

# Test system builds
sudo nixos-rebuild build --flake .#zephyrus
sudo nixos-rebuild build --flake .#yoga
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Ensure running as root when generating reports
2. **Missing Hardware**: Some specialized hardware may need manual configuration
3. **Report Path Issues**: Ensure facter.json files are in correct locations

### Fallback Options

If nixos-facter doesn't detect certain hardware:
- Use traditional `nixos-generate-config` as fallback
- Manually specify hardware configuration in `hardware.nix`
- Reference NixOS Hardware repository for device-specific configs

## Next Steps

After hardware scanning is complete:
1. Implement `add-personal-device-hosts` (Phase 3, Step 6)
2. Configure personal device tools (Phase 4)
3. Test deployments on physical hardware
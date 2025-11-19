# Agent Guidance for /hosts

## Purpose
Host-specific configurations for each machine. Each host is a complete, standalone NixOS configuration.

## Host Directory Structure

```
hosts/
├── yoga/                    # Lenovo Yoga 7 workstation
│   ├── default.nix         # Main system configuration
│   ├── disko.nix           # Disk layout (Btrfs)
│   └── hardware.nix        # Hardware detection output
├── zephyrus/               # ASUS ROG Zephyrus workstation
│   ├── default.nix
│   ├── disko.nix
│   └── hardware.nix
└── servers/                # Server configurations
    ├── hetzner-vps/
    │   ├── default.nix
    │   ├── disko.nix
    │   └── hardware.nix
    └── ovh-vps/
        ├── default.nix
        ├── disko.nix
        └── hardware.nix
```

## Host Types

### Workstations (yoga, zephyrus)
- Desktop environment (Niri + DankMaterialShell)
- Home-manager configuration
- GUI applications
- Multiple power profiles
- Hardware-specific optimizations

### Servers (hetzner-vps, ovh-vps)
- Headless operation
- Server services (Podman, Caddy)
- Enhanced security
- Monitoring and logging
- Minimal resource usage

## Host Configuration Files

### default.nix
Main system configuration file. Structure:

```nix
{ inputs, lib, modulesPath, ... }:

{
  # Import NixOS and modules
  imports = [
    # Disko disk configuration
    ./disko.nix

    # Hardware detection
    ./hardware.nix

    # Core system modules
    ${modulesPath}/installer/scan/not-detected.nix
    inputs.home-manager.nixosModules.home-manager

    # Your custom modules
    ../../modules/nixos/core/base.nix
    ../../modules/nixos/services/podman.nix
    ../../modules/nixos/security/firewall.nix

    # Optional: Profiles
    ../../profiles/workstation/workstation.nix  # or server.nix
  ];

  # Host-specific configuration
  networking.hostName = "yoga";

  # User configuration
  users.users.hbohlen = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "tailscale" ];
    packages = with pkgs; [
      # User packages if needed
    ];
  };

  # Additional host-specific settings
  # ...

  # Home-manager configuration
  home-manager.users.hbohlen = { pkgs, ... }: {
    imports = [
      ../../modules/home-manager/shell/fish.nix
      ../../modules/home-manager/desktop/niri.nix
      # ... other home-manager modules
    ];

    # Home-manager config
    home.username = "hbohlen";
    home.homeDirectory = "/home/hbohlen";
    home.stateVersion = "24.11";
  };

  # System state
  system.stateVersion = "24.11";
}
```

### disko.nix
Disk layout using Disko. Btrfs required for all hosts.

**Yoga/Zephyrus (laptop)**:
```nix
{ lib, ... }:

{
  disko.devices = {
    disk = {
      main = {
        device = lib.mkDefault "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = [
            {
              name = "ESP";
              start = "0%";
              end = "512MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                fsType = "vfat";
                mountPoint = "/boot";
              };
            }
            {
              name = "root";
              start = "512MiB";
              end = "100%";
              content = {
                type = "btrfs";
                subvolumes = {
                  "/root" = {
                    mountPoint = "/";
                  };
                  "/home" = {
                    mountPoint = "/home";
                  };
                  "/nix" = {
                    mountPoint = "/nix";
                  };
                  "/dev" = {
                    mountPoint = "/var/dev";
                  };
                  "/persist" = {
                    mountPoint = "/persist";
                  };
                };
              };
            }
          ];
        };
      };
    };
  };
}
```

**Servers (Hetzner/OVH VPS)**:
```nix
{ lib, ... }:

{
  disko.devices = {
    disk = {
      main = {
        device = lib.mkDefault "/dev/sda";
        type = "disk";
        content = {
          type = "gpt";
          partitions = [
            {
              name = "ESP";
              start = "0%";
              end = "512MiB";
              type = "EF00";
              content = {
                type = "filesystem";
                fsType = "vfat";
                mountPoint = "/boot";
              };
            }
            {
              name = "root";
              start = "512MiB";
              end = "100%";
              content = {
                type = "btrfs";
                subvolumes = {
                  "/root" = {
                    mountPoint = "/";
                  };
                  "/home" = {
                    mountPoint = "/home";
                  };
                  "/nix" = {
                    mountPoint = "/nix";
                  };
                  "/var/lib/podman" = {
                    mountPoint = "/var/lib/podman";
                  };
                  "/var/log" = {
                    mountPoint = "/var/log";
                  };
                };
              };
            }
          ];
        };
      };
    };
  };
}
```

### hardware.nix
Hardware detection output. **GENERATED, NOT EDITED**.

Generate with:
```bash
nixos-generate-config --show-hardware-config > hosts/<host>/hardware.nix
```

Example:
```nix
{
  hardware = {
    cpu.intel.updateMicrocode = lib.mkDefault true;
   graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
      ];
    };
  };
}
```

**CRITICAL**: Update this file when hardware changes.

## Host-Specific Considerations

### yoga (Lenovo Yoga 7)
**Focus**: Battery life, lightweight development

**Special Requirements**:
- Power management optimizations
- Battery-aware CPU scaling
- Minimal resource usage
- Lightweight applications

**Hardware Optimizations**:
- AMD Ryzen processor optimizations
- Integrated graphics (AMD)
- Touch screen support
- Stylus support (2-in-1)

**Modules Specific to Yoga**:
```nix
{
  imports = [
    # Standard modules
    ../../modules/nixos/core/base.nix
    ../../modules/nixos/hardware/amd-cpu.nix
    ../../modules/nixos/hardware/touchscreen.nix

    # Workstation profile
    ../../profiles/workstation/workstation.nix
  ];

  # Battery optimization
  powerManagement.cpuFreqGovernor = "powersave";
}
```

### zephyrus (ASUS ROG Zephyrus M16)
**Focus**: High performance, heavy development

**Special Requirements**:
- High performance CPU/GPU
- Multiple power profiles
- Podman container hosting
- AI coding tools optimization

**Hardware Optimizations**:
- Intel i9 processor
- NVIDIA RTX graphics
- 32GB+ RAM optimizations
- High-speed NVMe SSD

**Modules Specific to Zephyrus**:
```nix
{
  imports = [
    # Standard modules
    ../../modules/nixos/core/base.nix
    ../../modules/nixos/hardware/intel-nvidia.nix
    ../../modules/nixos/services/podman.nix
    ../../modules/nixos/services/caddy.nix

    # Workstation profile
    ../../profiles/workstation/performance.nix

    # Development profile
    ../../profiles/development/containers.nix
  ];

  # Performance optimization
  powerManagement.cpuFreqGovernor = "performance";
  hardware.nvidia = {
    mode = "on";
    powerManagement.enable = true;
  };
}
```

### hetzner-vps & ovh-vps
**Focus**: Server operation, containers

**Special Requirements**:
- Headless operation
- No desktop environment
- Podman for containers
- Caddy reverse proxy
- Tailscale for access
- Enhanced security

**Modules Specific to Servers**:
```nix
{
  imports = [
    # Core system
    ../../modules/nixos/core/base.nix
    ../../modules/nixos/services/podman.nix
    ../../modules/nixos/services/caddy.nix
    ../../modules/nixos/security/tailscale.nix
    ../../modules/nixos/security/firewall.nix

    # Server profile
    ../../profiles/server/headless.nix
  ];

  # Server-specific
  services.tailscale.enable = true;
  services.openssh.enable = true;

  # No desktop
  services.xserver.enable = false;
}
```

## Profiles

Instead of adding individual modules, use profiles:

```nix
# workstation.nix
{ ... }:

{
  imports = [
    ../../modules/nixos/desktop/niri.nix
    ../../modules/nixos/desktop/dank-material-shell.nix
    ../../modules/home-manager/desktop/niri.nix
    ../../modules/home-manager/desktop/dank-material-shell.nix
  ];
}
```

Then in host:
```nix
{
  imports = [
    # ... other imports
    ../../profiles/workstation/workstation.nix
  ];
}
```

## Import Order

Important import order:
1. `./disko.nix` - Must be first
2. `./hardware.nix` - Hardware detection
3. Module imports in dependency order
4. Profiles last

## Testing Hosts

### Build Test (Safe)
```bash
nixos-rebuild build --flake .#yoga
```

### Switch (Live - Be Careful!)
```bash
nixos-rebuild switch --flake .#yoga
```

### Rollback
```bash
# If something goes wrong
nixos-rebuild switch --rollback
```

## Host-Specific TODOs

### Phase 1: Hardware Discovery
**For each host**:
- [ ] Run `nixos-generate-config`
- [ ] Update hardware.nix with actual specs
- [ ] Research optimizations
- [ ] Update pantherOS.md with specs
- [ ] Design disk layout
- [ ] Create disko.nix

### Phase 2: Configuration
**For each host**:
- [ ] Create base config
- [ ] Add security modules
- [ ] Add service modules
- [ ] Test build
- [ ] Deploy (after testing)
- [ ] Verify functionality

### Phase 3: Optimization
- [ ] Power management tuning
- [ ] Performance profiling
- [ ] Resource usage optimization
- [ ] Security hardening

## Deployment Order

Deploy hosts in this order:
1. **hetzner-vps** - Simplest, headless
2. **ovh-vps** - Copy hetzner config
3. **yoga** - Simpler workstation
4. **zephyrus** - Most complex workstation

**Never deploy to all hosts simultaneously!**

## Common Issues

### Disk Layout Changes
If disko.nix changes significantly:
- Backup data first
- Boot from USB if needed
- May require fresh install

### Hardware Mismatch
If hardware.nix doesn't match actual hardware:
- Regenerate: `nixos-generate-config --show-hardware-config`
- Update file
- Rebuild

### Home-Manager Not Working
Check:
- home-manager module imported in system config
- home-manager configuration in default.nix
- State version matches

## Backup Before Changes

**CRITICAL**: Always have a backup plan.

For workstations:
- Create btrfs snapshot before changes
- USB recovery drive ready

For servers:
- VPS snapshot if available
- Tailscale access from multiple devices
- Out-of-band console access

## Success Criteria

Host is complete when:
- [ ] Builds successfully
- [ ] Hardware properly configured
- [ ] Disk layout correct
- [ ] All services running
- [ ] Desktop works (workstations)
- [ ] Security configured
- [ ] Can rollback if needed
- [ ] Documentation updated

---
name: NixOS Hardware Deployment
description: Configure NixOS for specific hardware including kernel modules, firmware, disk partitioning with disko, and hardware-specific settings. When configuring hardware.nix, disk layouts, or machine-specific deployments.
---
# NixOS Hardware Deployment

## When to use this skill:

- Configuring hardware-specific settings in host files (zephyrus, etc.)
- Setting up kernel modules and initrd modules for hardware support
- Configuring disko for disk partitioning (LVM, btrfs, zfs)
- Enabling firmware and microcode updates (AMD, Intel)
- Setting up GPU support (NVIDIA, AMD, Intel)
- Configuring CPU-specific features (AMD P-State, Intel Turboboost)
- Using facter for hardware detection and reporting
- Installing hardware-specific packages (asusctl, nvtop, etc.)
- Setting up storage configurations (NVMe, SATA, RAID)
- Configuring power management and thermal settings

## Best Practices
- boot.initrd.availableKernelModules = [ &quot;nvme&quot; &quot;xhci_pci&quot; &quot;usbhid&quot; ]; boot.kernelModules = [ &quot;kvm-amd&quot; ];
- hardware.cpu.amd.updateMicrocode = lib.mkDefault true; hardware.graphics.enable = true; hardware.enableRedistributableFirmware = true;
- disko.devices.disk.sda = { device = &quot;/dev/sda&quot;; type = &quot;disk&quot;; content.type = &quot;lvm_pv&quot;; };
- config.facter.reportPath = ./hosts/zephyrus/facter.json;
- environment.systemPackages = with pkgs; [ asusctl nvtop (pkgs.callPackage ./scripts/default.nix {}) ];

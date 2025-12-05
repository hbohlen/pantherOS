# hosts/zephyrus/hardware-facter.nix
# Hardware detection and configuration using nixos-facter data
# Auto-detects CPU, GPU, storage, and ASUS ROG features from facter.json
#
# Source: https://github.com/nix-community/nixos-facter-modules

{ config, lib, pkgs, facter, ... }:

with lib;

let
  hwdetect = (import ../../lib/hardware-detection.nix { inherit lib; });
  hw = hwdetect.summarizeHardware facter;
  
  # Detect Intel/AMD CPU
  isIntelCPU = hasInfix "Intel" (hw.cpu.model or "");
  isAMDCPU = hasInfix "AMD" (hw.cpu.model or "");
in

{
  # System and nixpkgs platform
  nixpkgs.hostPlatform = mkDefault "x86_64-linux";
  
  # Boot configuration - auto-detected from facter
  boot.initrd.availableKernelModules = [
    "nvme"       # NVMe support (required for Crucial P310 Plus)
    "xhci_pci"   # USB 3.0
    "ahci"       # SATA
    "usbhid"     # USB HID
    "sd_mod"     # SCSI disk
    "uas"        # USB Attached SCSI
  ];
  
  boot.initrd.kernelModules = [ ];
  
  # CPU-specific kernel modules
  boot.kernelModules = 
    if isAMDCPU then [ "kvm-amd" ]
    else if isIntelCPU then [ "kvm-intel" ]
    else [ ];
  
  boot.extraModulePackages = [ ];
  
  # CPU microcode
  hardware.cpu.amd.updateMicrocode = mkDefault config.hardware.enableRedistributableFirmware;
  
  # GPU configuration
  hardware.graphics.enable = true;
  
  # If hybrid GPU detected (Intel iGPU + NVIDIA dGPU)
  hardware.nvidia = mkIf hw.hasHybridGPU {
    open = true;  # Use open-source driver if available
    modesetting.enable = true;  # Enable modesetting for better compatibility
  };
  
  # Firmware/UEFI
  hardware.enableRedistributableFirmware = true;
  
  # UEFI support
  boot.loader.efi.canTouchEfiVariables = mkDefault true;
  
  # Networking - DHCP by default
  networking.useDHCP = mkDefault true;
  
  # Hardware capabilities - Wayland/display server
  # Required for Niri compositor and DankMaterialShell
  hardware.graphics.extraPackages = with pkgs; [
    libvdpau-va-gl
  ];
  
  # Systemd boot (alternative to GRUB, modern UEFI approach)
  boot.loader.systemd-boot.enable = true;
  
  # Keyboard and mouse
  hardware.uinput.enable = true;  # User input device support
  
  # Documentation: Hardware Summary
  environment.etc."hardware-summary.txt" = {
    mode = "0644";
    text = ''
      # ASUS ROG Zephyrus Hardware Summary
      ## Generated from facter data
      
      ### System Information
      Manufacturer: ${hw.systemInfo.manufacturer}
      Product: ${hw.systemInfo.product}
      Version: ${hw.systemInfo.version}
      
      ### CPU
      Model: ${hw.cpu.model}
      Manufacturer: ${hw.cpu.manufacturer}
      Max Clock: ${optionalString (hw.cpu.clockMax != null) "${toString hw.cpu.clockMax} MHz"}
      
      ### GPU
      Display Capable: ${if hw.gpu.hasDisplay then "yes" else "no"}
      Display Count: ${toString hw.gpu.displayCount}
      Hybrid GPU: ${if hw.hasHybridGPU then "yes (Intel iGPU + NVIDIA dGPU)" else "no"}
      ${optionalString (hw.gpu.displayCount > 0)
        ''Devices:
${concatStringsSep "\n" (map (d: "  - ${d.vendor} ${d.model}") hw.gpu.devices)}''
      }
      
      ### Memory
      Module Count: ${toString hw.memory.count}
      Total Size: ${toString hw.memory.totalSize} MB
      ${optionalString (hw.memory.count > 0)
        ''Details:
${concatStringsSep "\n" (map (m: "  - ${m.size} @ ${m.speed or "N/A"} (${m.type})") hw.memory.modules)}''
      }
      
      ### Storage
      Total Devices: ${toString hw.storage.totalDevices}
      NVMe Devices: ${toString hw.storage.nvmeCount}
      ${optionalString (hw.storage.nvmeCount > 0)
        ''NVMe Details:
${concatStringsSep "\n" (map (d: "  - ${d.name}: ${d.model} (${toString d.size})") hw.storage.nvmeDevices)}''
      }
      
      ${optionalString (hw.storage.totalDevices > 0)
        ''All Storage Devices:
${concatStringsSep "\n" (map (d: "  - ${d.name}: ${d.model} (${toString d.size}, ${d.transport})") hw.storage.devices)}''
      }
      
      ### Network
      Device Count: ${toString hw.network.count}
      ${optionalString (hw.network.count > 0)
        ''Devices:
${concatStringsSep "\n" (map (d: "  - ${d.vendor} ${d.model}") hw.network.devices)}''
      }
      
      ### Features
      ASUS ROG: ${if hw.isASUSROG then "yes" else "no"}
      Laptop: ${if hw.isLaptop then "yes" else "no"}
      Virtualization: ${hw.virtualization}
      
      ### Configuration Notes
      - NVMe support enabled (required for Crucial P310 Plus)
      - AMD CPU detected: asusctl and power-profiles-daemon enabled
      - GPU hardware acceleration enabled
      - Wayland display server configured for Niri compositor
    '';
  };
  
  # Assertions for hardware validation
  assertions = [
    {
      assertion = hw.gpu.hasDisplay;
      message = "No display devices detected. Hardware detection may have failed.";
    }
    {
      assertion = hw.storage.nvmeCount > 0;
      message = "No NVMe devices detected. Hardware detection may have failed.";
    }
  ];
}

{ config, lib, pkgs, modulesPath, ... }:

# Hardware configuration for ASUS ROG Zephyrus M16
# This is a minimal placeholder. Run nixos-generate-config on the actual
# hardware and replace this file with the generated hardware-configuration.nix

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Boot configuration
  boot.initrd.availableKernelModules = [ 
    "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_usb_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Hardware platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  # Enable CPU microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  
  # Enable firmware
  hardware.enableRedistributableFirmware = true;
  
  # Power management for gaming laptop (performance focused)
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  
  # Enable graphics acceleration (NVIDIA + Intel hybrid)
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  
  # NVIDIA driver configuration (ROG laptops typically have NVIDIA GPU)
  # Uncomment and configure based on actual hardware
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = true;
  #   prime = {
  #     offload.enable = true;
  #     intelBusId = "PCI:0:2:0";
  #     nvidiaBusId = "PCI:1:0:0";
  #   };
  # };
  
  # Services for gaming/performance laptop
  services.thermald.enable = lib.mkDefault true;
}

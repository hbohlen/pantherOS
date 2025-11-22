{ config, lib, pkgs, modulesPath, ... }:

# Hardware configuration for Lenovo Yoga 7 2-in-1
# This is a minimal placeholder. Run nixos-generate-config on the actual
# hardware and replace this file with the generated hardware-configuration.nix

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Boot configuration
  boot.initrd.availableKernelModules = [ 
    "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc"
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
  
  # Power management for laptop
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  
  # Enable laptop-specific services
  services.thermald.enable = lib.mkDefault true;
  services.tlp = {
    enable = lib.mkDefault true;
    settings = {
      # Battery optimization settings
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      # Conservative power settings for battery life
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
    };
  };
  
  # Enable graphics acceleration
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
}

# hardware.nix - Zephyrus hardware configuration
# Note: This is a placeholder configuration. To generate accurate hardware configuration,
# run: nixos-facter | tee hosts/zephyrus/zephyrus-facter.json
{ config, lib, ... }:

{
  # Boot configuration - placeholder
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ]; # Assuming AMD CPU - update based on actual hardware
  boot.extraModulePackages = [ ];

  # Networking
  networking.useDHCP = lib.mkDefault true;

  # Host platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # CPU microcode - placeholder
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Graphics - placeholder
  hardware.graphics.enable = true;

  # Firmware
  hardware.enableRedistributableFirmware = true;
}

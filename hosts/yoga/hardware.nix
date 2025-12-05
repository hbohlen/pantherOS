# hardware.nix - Yoga hardware configuration
# Generated based on nixos-facter report
{ config, lib, ... }:

{
  # Boot configuration
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # File systems - handled by disko.nix
  # fileSystems."/" = { ... }

  # Swap - handled by disko.nix if needed
  # swapDevices = [ ];

  # Networking
  networking.useDHCP = lib.mkDefault true;

  # Host platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # CPU microcode updates
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Graphics - AMD Radeon 860M (integrated)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # Radeon graphics drivers are included by default
  };

  # Bluetooth support
  hardware.bluetooth.enable = true;

  # Sound
  hardware.pulseaudio.enable = false; # Using pipewire
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Power management
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  # Firmware
  hardware.enableRedistributableFirmware = true;
}
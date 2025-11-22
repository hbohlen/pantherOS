{ config, lib, pkgs, ... }:

# Hardware configuration for OVH Cloud VPS
# Similar to Hetzner VPS configuration for cloud environment

{
  # Use generic x86_64 configuration for cloud environment
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  # Enable virtualization support
  boot.initrd.availableKernelModules = [ 
    "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" 
    "virtio_blk" "virtio_balloon" "virtio_console"
  ];
  
  boot.kernelModules = [ 
    "kvm-intel" "kvm-amd"
  ];
  
  # Enable hardware drivers
  hardware.enableRedistributableFirmware = true;
  
  # CPU frequency scaling
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  
  # Configure for virtualized environment
  services.qemuGuest.enable = true;
  services.udev.enable = true;
  
  # Network configuration
  networking.useDHCP = true;
  
  # Disable laptop-specific services
  services.tlp = null;
  powerManagement.powertop.enable = false;
}

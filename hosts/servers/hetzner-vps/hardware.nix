{ lib, ... }:

{
  # Hardware configuration for Hetzner Cloud VPS
  # Based on common Hetzner VPS specifications and virtualized environment

  # Use generic x86_64 configuration for cloud environment
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  # Enable virtualization support (KVM/VMware modules work in cloud environments)
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
    "virtio_pci"
    "virtio_scsi"
    "virtio_blk"
    "sr_mod"
    "virtio_balloon"
    "virtio_console"
  ];

  boot.kernelModules = [
    "kvm-intel"
    "kvm-amd" # Enable KVM for nested virtualization support
  ];

  # Enable necessary hardware drivers for cloud environment
  hardware.enableRedistributableFirmware = true;

  # Enable CPU frequency scaling for performance optimization
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  # File system configuration is handled by disko.nix, not here
  # to prevent conflicts with the Btrfs impermanence setup
  # Remove these as they conflict with disko's partitioning
  # fileSystems and swapDevices are configured via disko

  # Enable swap using the partition defined in disko.nix
  swapDevices = [
    {
      device = "/dev/disk/by-label/swap";
    }
  ];

  # Configure for virtualized environment
  services.qemuGuest.enable = true;

  # Enable hardware-specific services that are appropriate for cloud
  services.udev.enable = true;

  # Virtualization support for containers (needed for Podman/Docker)
  virtualisation = {
    # Podman configured in main host configuration
    # Enable support for virtualization tools as needed
    libvirtd.enable = false; # Disable full libvirt for security unless needed
  };

  # Network interface configuration (usually handled by cloud init)
  # but we'll specify basic requirements
  networking = {
    useDHCP = true; # Use DHCP for IP assignment
  };

  # Disable laptop-specific services
  services.tlp.enable = false; # Disable TLP which is for laptops
  powerManagement.powertop.enable = false;
}

# hosts/servers/contabo-vps/hardware.nix
# Hardware configuration for Contabo Cloud VPS
# Server: Contabo Cloud VPS 40 (12 vCPU, 48GB RAM, 250GB NVMe)
#
# NOTE: This file will be refined after running setup script on actual hardware
# Run: ./scripts/setup-contabo-vps.sh (or .fish) to detect actual hardware

{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Kernel modules for Contabo Cloud KVM with virtio-scsi
  # These are typical for Contabo but will be verified by facter
  boot.initrd.availableKernelModules = [
    "ahci"         # AHCI for potential SATA
    "xhci_pci"     # USB 3.0 support
    "virtio_pci"   # Virtio PCI devices
    "virtio_scsi"  # Virtio SCSI controller (for disk)
    "sd_mod"       # SCSI disk support
    "sr_mod"       # CD-ROM support
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];  # AMD KVM guest
  boot.extraModulePackages = [ ];

  # Serial console for Contabo Cloud console access
  # (likely available similar to Hetzner)
  boot.kernelParams = [ "console=ttyS0,115200" ];

  # Enable QEMU guest agent for Contabo integration
  services.qemuGuest.enable = true;

  # NOTE: Update after facter.json shows actual hardware
  # - Verify CPU type (KVM-AMD or Intel)
  # - Confirm kernel modules match actual hardware
  # - Check boot type (BIOS vs UEFI) in facter output
}

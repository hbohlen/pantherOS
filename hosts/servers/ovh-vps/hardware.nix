# hosts/servers/ovh-vps/hardware.nix
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Kernel modules for OVH VPS (QEMU/KVM with virtio)
  # Based on lsmod output showing virtio_net, virtio_scsi, virtio_balloon
  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Serial console for OVH VPS console access
  boot.kernelParams = [ "console=ttyS0,115200n8" ];

  # Enable QEMU guest agent for OVH VPS integration
  services.qemuGuest.enable = true;
}
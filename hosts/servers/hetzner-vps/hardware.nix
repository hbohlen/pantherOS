# hosts/servers/hetzner-vps/hardware.nix
{ modulesPath, ... }:
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # Platform
  nixpkgs.hostPlatform = "x86_64-linux";

  # Kernel modules for Hetzner Cloud KVM with virtio-scsi
  # Based on lsmod output showing virtio_gpu, virtio_rng
  # and lspci showing virtio SCSI controller
  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_scsi"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Serial console for Hetzner Cloud console access
  boot.kernelParams = [ "console=ttyS0,115200" ];

  # Enable QEMU guest agent for Hetzner Cloud integration
  services.qemuGuest.enable = true;
}

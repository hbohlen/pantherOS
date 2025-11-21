# hosts/servers/hetzner-cloud/disko.nix
# Declarative disk configuration for Hetzner Cloud VPS
#
# Hardware: 457.8GB SSD (/dev/sda)
# Architecture: GPT with BIOS boot, ESP, and Btrfs root
{ config, lib, ... }:

{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            # BIOS boot partition - Required for GRUB on GPT disks
            # Hetzner Cloud VMs use BIOS boot, not pure UEFI
            bios-boot = {
              size = "1M";
              type = "EF02";  # BIOS boot partition type
              priority = 1;   # First partition on disk
            };

            # EFI System Partition - Boot loader and kernels
            # 512M is sufficient for single-kernel server configuration
            esp = {
              size = "512M";
              type = "EF00";  # EFI System Partition type
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "umask=0077"  # Restrict access to root only
                  "fmask=0077"
                  "dmask=0077"
                ];
              };
              priority = 2;
            };

            # Btrfs root partition - Remaining space (~457GB)
            root = {
              size = "100%";
              type = "8300";  # Linux filesystem type
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];  # Force creation (wipe existing)
                # Subvolumes defined in next task
              };
              priority = 3;
            };
          };
        };
      };
    };
  };
}

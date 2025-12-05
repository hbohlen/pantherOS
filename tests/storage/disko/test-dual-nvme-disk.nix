# Test dual-nvme-disk.nix module evaluation
# Tests that the dual-NVMe disko module can be loaded and configured without errors

{ pkgs, ... }:

{
  nodes = {
    dual-nvme-test = { config, ... }: {
      # Enable storage modules
      imports = [
        ../../../modules/storage
        ../../../modules/storage/btrfs
        ../../../modules/storage/disko
      ];

      # Configure dual-NVMe disk layout
      storage.disks.dualNvme = {
        enable = true;
        primaryDevice = "/dev/nvme0n1";
        secondaryDevice = "/dev/nvme1n1";
        enableDatabases = false;
      };

      # Minimal system configuration for test
      boot.loader.systemd-boot.enable = false;
      boot.loader.grub.enable = false;

      # Required for disko to work
      environment.systemPackages = [ pkgs.disko ];

      # Network configuration (minimal)
      networking.useDHCP = false;
    };
  };

  testScript = ''
    dual-nvme-test.succeed("echo 'Dual-NVMe disk configuration loaded successfully'")
  '';
}

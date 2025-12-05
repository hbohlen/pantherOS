# Test laptop-disk.nix module evaluation
# Tests that the disko module can be loaded and configured without errors

{ pkgs, ... }:

{
  nodes = {
    laptop-test = { config, ... }: {
      # Enable storage modules
      imports = [
        ../../../modules/storage
        ../../../modules/storage/btrfs
        ../../../modules/storage/disko
      ];

      # Configure laptop disk layout
      storage.disks.laptop = {
        enable = true;
        device = "/dev/nvme0n1";
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
    laptop-test.succeed("echo 'Laptop disk configuration loaded successfully'")
  '';
}

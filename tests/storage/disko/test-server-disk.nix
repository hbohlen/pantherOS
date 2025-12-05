# Test server-disk.nix module evaluation
# Tests that the server disko module can be loaded and configured without errors

{ pkgs, ... }:

{
  nodes = {
    server-test = { config, ... }: {
      # Enable storage modules
      imports = [
        ../../../modules/storage
        ../../../modules/storage/btrfs
        ../../../modules/storage/disko
      ];

      # Configure server disk layout
      storage.disks.server = {
        enable = true;
        device = "/dev/sda";
        diskSize = "500GB";
        enableDatabases = true;
        swapSize = "4G";
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
    server-test.succeed("echo 'Server disk configuration loaded successfully'")
  '';
}

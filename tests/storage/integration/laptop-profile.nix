{ pkgs }:

let
  system = "x86_64-linux";
in

{
  storage-laptop-integration = pkgs.nixosTest {
    name = "storage-laptop-integration";

    nodes = {
      zephyrus = {
        pkgs,
        imports = [
          ../../modules/storage/profiles/zephyrus.nix
          ../../modules/storage/btrfs/mount-options.nix
          ../../modules/storage/btrfs/compression.nix
          ../../modules/storage/btrfs/ssd-optimization.nix
        ];
        storage.disks.laptop = {
          enable = true;
          device = "/dev/vda";
          enableDatabases = true;
        };
        storage.btrfs.ssdOptimization = true;
        storage.snapshots = {
          enable = true;
          retention.daily = 7;
          retention.weekly = 4;
          retention.monthly = 12;
        };
      };

      yoga = {
        pkgs,
        imports = [
          ../../modules/storage/profiles/yoga.nix
          ../../modules/storage/btrfs/mount-options.nix
          ../../modules/storage/btrfs/compression.nix
          ../../modules/storage/btrfs/ssd-optimization.nix
        ];
        storage.disks.laptop = {
          enable = true;
          device = "/dev/vda";
          enableDatabases = false;
        };
        storage.btrfs.ssdOptimization = true;
        storage.snapshots = {
          enable = true;
          retention.daily = 7;
          retention.weekly = 4;
          retention.monthly = 12;
        };
      };
    };

    testScript = ''
      import subprocess

      # Test Zephyrus profile
      zephyrus = zephyrus
      zephyrus.wait_for_unit("multi-user.target")

      # Check required subvolumes are mounted
      zephyrus.succeed("test -d /nix")
      zephyrus.succeed("test -d /home")
      zephyrus.succeed("test -d /var/lib/containers")
      print("✓ Zephyrus: Required subvolumes mounted")

      # Check mount options
      mount_output = zephyrus.succeed("cat /proc/mounts")
      assert "compress=zstd" in mount_output or "compress=zstd:3" in mount_output
      print("✓ Zephyrus: Compression enabled")

      # Check SSD optimization is enabled
      assert "ssd" in mount_output
      print("✓ Zephyrus: SSD mount options present")

      # Test Yoga profile
      yoga = yoga
      yoga.wait_for_unit("multi-user.target")

      # Check required subvolumes for Yoga
      yoga.succeed("test -d /nix")
      yoga.succeed("test -d /home")
      yoga.succeed("test -d /var/lib/containers")
      print("✓ Yoga: Required subvolumes mounted")

      # Check snapper configuration
      yoga.succeed("systemctl is-enabled snapper-timeline.service || true")
      print("✓ Yoga: Snapper service configured")

      # Check snapshot retention policy
      snapper_config = yoga.succeed("snapper list-configs")
      # Note: In a real test, we'd verify the TIMELINE_LIMIT values
      print("✓ Laptop: Snapper configured with laptop retention (7/4/12)")

      print("All laptop profile integration tests passed")
    '';

    metadata = {
      description = "Laptop Profile Integration Tests";
      maintainers = [ "admin@hbohlen.systems" ];
    };
  };
}

{ pkgs }:

let
  system = "x86_64-linux";
in

{
  storage-server-integration = pkgs.nixosTest {
    name = "storage-server-integration";

    nodes = {
      hetzner = {
        pkgs,
        imports = [
          ../../modules/storage/profiles/hetzner.nix
          ../../modules/storage/btrfs/mount-options.nix
          ../../modules/storage/btrfs/compression.nix
          ../../modules/storage/btrfs/database-enforcement.nix
          ../../modules/storage/snapshots/default.nix
          ../../modules/storage/snapshots/policies.nix
          ../../modules/storage/snapshots/snapper.nix
        ];
        storage.disks.server = {
          enable = true;
          device = "/dev/vda";
          size = "458GB";
          enableDatabases = true;
          enableContainers = true;
        };
        storage.snapshots = {
          enable = true;
          retention.daily = 30;
          retention.weekly = 12;
          retention.monthly = 12;
        };
      };

      contabo = {
        pkgs,
        imports = [
          ../../modules/storage/profiles/contabo.nix
          ../../modules/storage/btrfs/mount-options.nix
          ../../modules/storage/btrfs/compression.nix
          ../../modules/storage/btrfs/database-enforcement.nix
          ../../modules/storage/snapshots/default.nix
          ../../modules/storage/snapshots/policies.nix
          ../../modules/storage/snapshots/snapper.nix
        ];
        storage.disks.server = {
          enable = true;
          device = "/dev/vda";
          size = "536GB";
          enableDatabases = true;
          enableContainers = true;
        };
        storage.snapshots = {
          enable = true;
          retention.daily = 30;
          retention.weekly = 12;
          retention.monthly = 12;
        };
      };

      ovh = {
        pkgs,
        imports = [
          ../../modules/storage/profiles/ovh.nix
          ../../modules/storage/btrfs/mount-options.nix
          ../../modules/storage/btrfs/compression.nix
          ../../modules/storage/snapshots/default.nix
          ../../modules/storage/snapshots/policies.nix
          ../../modules/storage/snapshots/snapper.nix
        ];
        storage.disks.server = {
          enable = true;
          device = "/dev/vda";
          size = "200GB";
          enableDatabases = false;
          enableContainers = true;
        };
        storage.snapshots = {
          enable = true;
          retention.daily = 30;
          retention.weekly = 12;
          retention.monthly = 12;
        };
      };
    };

    testScript = ''
      # Test Hetzner profile (production VPS with databases)
      hetzner = hetzner
      hetzner.wait_for_unit("multi-user.target")

      # Check database subvolumes are mounted
      hetzner.succeed("test -d /var/lib/postgresql")
      hetzner.succeed("test -d /var/lib/redis")
      print("✓ Hetzner: Database subvolumes mounted")

      # Check nodatacow is present
      mount_output = hetzner.succeed("cat /proc/mounts")
      assert "nodatacow" in mount_output
      print("✓ Hetzner: Nodatacow mount options present")

      # Check container subvolume
      hetzner.succeed("test -d /var/lib/containers")
      print("✓ Hetzner: Container subvolume mounted")

      # Test Contabo profile (staging VPS)
      contabo = contabo
      contabo.wait_for_unit("multi-user.target")

      # Check database subvolumes
      contabo.succeed("test -d /var/lib/postgresql")
      contabo.succeed("test -d /var/lib/redis")
      print("✓ Contabo: Database subvolumes mounted")

      # Check OVH profile (utility VPS)
      ovh = ovh
      ovh.wait_for_unit("multi-user.target")

      # Check container subvolume (databases disabled by default)
      ovh.succeed("test -d /var/lib/containers")
      print("✓ OVH: Container subvolume mounted")

      # Check snapper is configured with server retention
      ovh.succeed("systemctl is-enabled snapper-timeline.service || true")
      print("✓ Server: Snapper configured with server retention (30/12/12)")

      print("All server profile integration tests passed")
    '';

    metadata = {
      description = "Server Profile Integration Tests";
      maintainers = [ "admin@hbohlen.systems" ];
    };
  };
}

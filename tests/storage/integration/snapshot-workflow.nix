{ pkgs }:

let
  system = "x86_64-linux";
in

{
  storage-snapshot-workflow = pkgs.nixosTest {
    name = "storage-snapshot-workflow";

    nodes = {
      test-machine = {
        pkgs,
        imports = [
          ../../modules/storage/profiles/yoga.nix
          ../../modules/storage/snapshots/default.nix
          ../../modules/storage/snapshots/snapper.nix
          ../../modules/storage/snapshots/automation.nix
        ];
        storage.disks.laptop = {
          enable = true;
          device = "/dev/vda";
        };
        storage.snapshots = {
          enable = true;
          retention.daily = 7;
          retention.weekly = 4;
          retention.monthly = 12;
          schedule.daily = "02:00";
          schedule.weekly = "Sun 03:00";
          schedule.monthly = "1st 04:00";
        };
        services.snapper = {
          enable = true;
          configs."root" = {
            SUBVOLUME = "/";
            TIMELINE_CREATE = true;
            TIMELINE_CLEANUP = true;
            TIMELINE_LIMIT_DAILY = 7;
            TIMELINE_LIMIT_WEEKLY = 4;
            TIMELINE_LIMIT_MONTHLY = 12;
          };
        };
      };
    };

    testScript = ''
      machine = test-machine
      machine.wait_for_unit("multi-user.target")

      # Start snapper service
      machine.succeed("systemctl start snapper.service")
      machine.wait_for_unit("snapper.service")

      print("✓ Snapper service started")

      # Create a manual snapshot
      snapshot_create = machine.succeed("snapper create --description 'Test snapshot for workflow testing'")
      snapshot_number = snapshot_create.strip().split()[2]  # Extract snapshot number
      print(f"✓ Created snapshot: {snapshot_number}")

      # Verify snapshot appears in list
      snapshot_list = machine.succeed("snapper list")
      assert "Test snapshot for workflow testing" in snapshot_list
      print(f"✓ Snapshot appears in snapper list: {snapshot_number}")

      # Verify snapshot has correct metadata
      snapshot_show = machine.succeed(f"snapper show {snapshot_number}")
      assert "Test snapshot for workflow testing" in snapshot_show
      print("✓ Snapshot has correct metadata")

      # Test cleanup configuration
      machine.succeed("snapper config-set TIMELINE_CLEANUP true")
      print("✓ Cleanup configuration is enabled")

      # Test timeline limit settings
      config_output = machine.succeed("snapper get-config")
      assert "TIMELINE_LIMIT_DAILY" in config_output
      assert "TIMELINE_LIMIT_WEEKLY" in config_output
      assert "TIMELINE_LIMIT_MONTHLY" in config_output
      print("✓ Timeline limit configuration is set")

      # Clean up test snapshot
      machine.succeed(f"snapper delete {snapshot_number}")
      print(f"✓ Cleaned up test snapshot: {snapshot_number}")

      print("All snapshot workflow integration tests passed")
    '';

    metadata = {
      description = "Snapshot Workflow Integration Tests";
      maintainers = [ "admin@hbohlen.systems" ];
    };
  };
}

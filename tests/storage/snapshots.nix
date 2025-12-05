{ pkgs, nix-unit }:

{
  test_laptop_preset_7_4_12 = {
    name = "Laptop snapshot preset is 7/4/12";
    testScript = ''
      let
        lib = pkgs.lib;
        snapshotLib = import ../../lib/storage/snapshot-helpers { inherit lib; };
        retention = snapshotLib.getSnapshotRetention "laptop";
      in
      assert retention.daily == 7
      && retention.weekly == 4
      && retention.monthly == 12
    '';
  };

  test_server_preset_30_12_12 = {
    name = "Server snapshot preset is 30/12/12";
    testScript = ''
      let
        lib = pkgs.lib;
        snapshotLib = import ../../lib/storage/snapshot-helpers { inherit lib; };
        retention = snapshotLib.getSnapshotRetention "server";
      in
      assert retention.daily == 30
      && retention.weekly == 12
      && retention.monthly == 12
    '';
  };

  test_custom_retention_values = {
    name = "Custom retention values work";
    testScript = ''
      let
        lib = pkgs.lib;
        snapshotLib = import ../../lib/storage/snapshot-helpers { inherit lib; };
        laptopRetention = snapshotLib.getSnapshotRetention "laptop";
        serverRetention = snapshotLib.getSnapshotRetention "server";
      in
      # Should default to laptop values when unknown profile
      assert retention.daily == 7
      && retention.weekly == 4
      && retention.monthly == 12
    '';
  };

  test_daily_limit_matches_laptop_preset = {
    name = "Daily timeline limit matches laptop preset";
    testScript = ''
      let
        lib = pkgs.lib;
        snapshotLib = import ../../lib/storage/snapshot-helpers { inherit lib; };
        retention = snapshotLib.getSnapshotRetention "custom";
      in
      assert laptopRetention.daily == 7
    '';
  };

  test_weekly_limit_matches_server_preset = {
    name = "Weekly timeline limit matches server preset";
    testScript = ''
      let
        lib = pkgs.lib;
        snapshotLib = import ../../lib/storage/snapshot-helpers { inherit lib; };
        serverRetention = snapshotLib.getSnapshotRetention "server";
      in
      assert serverRetention.weekly == 12
    '';
  };

  test_monthly_limit_consistent = {
    name = "Monthly limit is consistent across profiles";
    testScript = ''
      let
        lib = pkgs.lib;
        snapshotLib = import ../../lib/storage/snapshot-helpers { inherit lib; };
        laptopRetention = snapshotLib.getSnapshotRetention "laptop";
      in
      assert laptopRetention.monthly == serverRetention.monthly
      && serverRetention.monthly == 12
    '';
  };
}

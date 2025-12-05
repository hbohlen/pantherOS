# Debug script to understand disk data structure
{ lib }:
let
  testZephyrus = builtins.fromJSON (builtins.readFile ./hosts/zephyrus/facter.json);
  disks = testZephyrus.hardware.disk or [];
  diskInfo = map (d: {
    name = d.name or "no-name";
    driver = d.driver or "no-driver";
    unixNames = d.unix_device_names or [];
  }) disks;
in
{
  diskCount = lib.length disks;
  diskDetails = diskInfo;
}

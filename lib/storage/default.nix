# lib/storage/default.nix
# Storage Library Helper Functions
# Aggregates all storage helper submodules

{ lib }:

{
  # Export hardware profiles
  hardwareProfiles = import ./hardware-profiles.nix { inherit lib; };

  # Export snapshot helpers
  snapshotHelpers = import ./snapshot-helpers.nix { inherit lib; };

  # Export backup helpers
  backupHelpers = import ./backup-helpers.nix { inherit lib; };
}

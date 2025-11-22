# PantherOS NixOS Core Users Modules
# Aggregates all user-related modules

{
  user-management = import ./user-management.nix;
  sudo-config = import ./sudo-config.nix;
  user-defaults = import ./user-defaults.nix;
}
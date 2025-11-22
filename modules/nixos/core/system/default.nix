# PantherOS NixOS Core System Modules
# Aggregates all system-related modules

{
  boot-config = import ./boot-config.nix;
  systemd-config = import ./systemd-config.nix;
  base-config = import ./base-config.nix;
}
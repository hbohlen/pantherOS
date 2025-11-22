# PantherOS NixOS Services Modules
# Aggregates all service modules

{
  # Networking-related service modules
  networking = import ./networking;

  # Standalone service modules
  ssh-service-config = import ./ssh-service-config.nix;
}
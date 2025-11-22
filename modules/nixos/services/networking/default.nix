# PantherOS NixOS Services Networking Modules
# Aggregates all networking-related service modules

{
  tailscale-service = import ./tailscale-service.nix;
  tailscale-firewall = import ./tailscale-firewall.nix;
}
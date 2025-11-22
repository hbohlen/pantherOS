# PantherOS NixOS Security Modules
# Aggregates all security modules

{
  # Firewall-related security modules
  firewall = import ./firewall;

  # Standalone security modules
  ssh-security-config = import ./ssh-security-config.nix;
}
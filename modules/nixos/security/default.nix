# PantherOS NixOS Security Modules
# Aggregates all security modules

{
  # Firewall-related security modules
  firewall = import ./firewall;

  # Secrets management modules
  secrets = import ./secrets;

  # Standalone security modules
  ssh-security-config = import ./ssh-security-config.nix;
}

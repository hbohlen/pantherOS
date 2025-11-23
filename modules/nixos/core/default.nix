# PantherOS NixOS Core Modules
# Aggregates all core modules

{
  # User-related modules
  users = import ./users;

  # System-related modules
  system = import ./system;
}

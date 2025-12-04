# Hercules CI configuration for pantherOS
# This file defines the systems and builds for Hercules CI
{ ... }:
{
  # Define which systems Hercules CI should build for
  herculesCI.ciSystems = [ "x86_64-linux" ];

  # Hercules CI will automatically discover and build:
  # - All nixosConfigurations from flake.nix
  # - All checks defined in the flake
  # - All packages defined in the flake
  # - Development shells
}

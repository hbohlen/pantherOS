# Hercules CI configuration for pantherOS
# This file defines what Hercules CI should build and test
#
# Hercules CI uses flake.nix by default and will automatically discover:
# - All nixosConfigurations
# - All checks
# - All packages
# - Development shells
#
# This file provides additional configuration for the CI evaluation.
{ ... }:
{
  # Define which systems Hercules CI should build for
  herculesCI.ciSystems = [ "x86_64-linux" ];

  # You can add additional configuration here:
  # - Custom build jobs
  # - Effect configurations (for deployments)
  # - Secret requirements

  # Example: Define which attributes to build
  # herculesCI.onPush.default.enable = true;

  # Example: Configure effects (advanced usage)
  # herculesCI.onPush.default.outputs.effects = {
  #   deploy = {
  #     # Deployment configuration
  #   };
  # };
}

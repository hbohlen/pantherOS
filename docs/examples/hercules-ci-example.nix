# Example configuration for Hercules CI Agent
# 
# This example shows how to enable and configure the Hercules CI Agent
# in your NixOS configuration.
#
# For more information, see: https://docs.hercules-ci.com

{ config, lib, pkgs, ... }:

{
  # Import the pantherOS modules
  imports = [
    ../../modules
  ];

  # Enable the CI infrastructure with Hercules CI
  services.ci = {
    enable = true;
    
    herculesCI = {
      enable = true;
      
      # Option 1: Use OpNix for automatic secret provisioning from 1Password
      opnix = {
        enable = true;
        # Secrets will be automatically provisioned from these 1Password references
        clusterJoinTokenReference = "op://pantherOS/hercules-ci/cluster-join-token";
        binaryCachesReference = "op://pantherOS/hercules-ci/binary-caches";
      };
      
      # Option 2: Manual secret management (when opnix.enable = false)
      # Paths where secrets should be placed manually
      # clusterJoinTokenPath = "/var/lib/hercules-ci-agent/secrets/cluster-join-token.key";
      # binaryCachesPath = "/var/lib/hercules-ci-agent/secrets/binary-caches.json";
    };
  };

  # Alternative: Direct configuration without using the wrapper module
  # (This bypasses the pantherOS CI module)
  #
  # services.hercules-ci-agent = {
  #   enable = true;
  #   settings = {
  #     clusterJoinTokenPath = "/var/lib/hercules-ci-agent/secrets/cluster-join-token.key";
  #     binaryCachesPath = "/var/lib/hercules-ci-agent/secrets/binary-caches.json";
  #   };
  # };
  #
  # # Then manually provision secrets with OpNix:
  # services.onepassword-secrets.secrets = {
  #   herculesToken = {
  #     reference = "op://pantherOS/hercules-ci/cluster-join-token";
  #     path = "/var/lib/hercules-ci-agent/secrets/cluster-join-token.key";
  #     owner = "hercules-ci-agent";
  #     group = "hercules-ci-agent";
  #     mode = "0600";
  #     services = ["hercules-ci-agent"];
  #   };
  # };

  # Example binary-caches.json content (stored in 1Password):
  # {
  #   "mycache": {
  #     "kind": "CachixCache",
  #     "authToken": "your-cachix-auth-token-here"
  #   }
  # }
  
  # Setup requirements:
  # 1. Store cluster-join-token in 1Password at: pantherOS/hercules-ci/cluster-join-token
  # 2. Store binary-caches.json in 1Password at: pantherOS/hercules-ci/binary-caches
  # 3. Ensure OpNix token file exists at: /etc/opnix-token
  # 4. Deploy the configuration with: nixos-rebuild switch --flake .#your-host
}

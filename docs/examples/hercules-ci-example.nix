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
      
      # Path to the cluster join token
      # Obtain this from your Hercules CI dashboard
      clusterJoinTokenPath = "/var/lib/hercules-ci-agent/secrets/cluster-join-token.key";
      
      # Path to the binary caches configuration
      # This should be a JSON file with your binary cache settings
      binaryCachesPath = "/var/lib/hercules-ci-agent/secrets/binary-caches.json";
    };
  };

  # Alternative: Direct configuration without using the wrapper module
  # (This is equivalent to the above configuration)
  #
  # services.hercules-ci-agent = {
  #   enable = true;
  #   settings = {
  #     clusterJoinTokenPath = "/var/lib/hercules-ci-agent/secrets/cluster-join-token.key";
  #     binaryCachesPath = "/var/lib/hercules-ci-agent/secrets/binary-caches.json";
  #   };
  # };

  # Example binary-caches.json content:
  # {
  #   "mycache": {
  #     "kind": "CachixCache",
  #     "authToken": "your-cachix-auth-token-here"
  #   }
  # }
}

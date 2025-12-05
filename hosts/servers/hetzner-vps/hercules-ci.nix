# Hercules CI Agent Configuration for hetzner-vps
# This module enables Hercules CI for continuous integration of NixOS configurations
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Enable CI infrastructure with Hercules CI
  services.ci = {
    enable = true;

    herculesCI = {
      enable = true;

      # Number of concurrent build tasks
      concurrentTasks = 4;

      # Enable OpNix integration for automatic secret management
      opnix = {
        enable = true;
        clusterJoinTokenReference = "op://pantherOS/hercules-ci/cluster-join-token";
        binaryCachesReference = "op://pantherOS/hercules-ci/binary-caches";
      };
    };
  };
}

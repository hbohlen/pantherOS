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

      # Cluster join token managed via OpNix/1Password
      clusterJoinTokenPath = config.services.onepassword-secrets.secretPaths.herculesClusterToken;

      # Binary caches configuration managed via OpNix/1Password
      binaryCachesPath = config.services.onepassword-secrets.secretPaths.herculesBinaryCaches;
    };
  };

  # Manage Hercules CI secrets via OpNix
  services.onepassword-secrets.secrets = {
    # Hercules CI cluster join token
    herculesClusterToken = {
      reference = "op://pantherOS/hercules-ci/cluster-join-token";
      path = "/var/lib/hercules-ci-agent/secrets/cluster-join-token.key";
      owner = "hercules-ci-agent";
      group = "hercules-ci-agent";
      mode = "0600";
      services = ["hercules-ci-agent"];
    };

    # Hercules CI binary caches configuration
    herculesBinaryCaches = {
      reference = "op://pantherOS/hercules-ci/binary-caches";
      path = "/var/lib/hercules-ci-agent/secrets/binary-caches.json";
      owner = "hercules-ci-agent";
      group = "hercules-ci-agent";
      mode = "0600";
      services = ["hercules-ci-agent"];
    };
  };

  # Ensure Hercules CI service starts after OpNix has populated secrets
  systemd.services.hercules-ci-agent = {
    after = ["onepassword-secrets.service"];
    wants = ["onepassword-secrets.service"];
  };
}

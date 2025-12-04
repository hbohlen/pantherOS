{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ci;
in {
  options.services.ci = {
    enable = mkEnableOption "Enable CI/CD infrastructure";

    # Hercules CI Agent configuration
    herculesCI = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Hercules CI Agent for continuous integration";
      };

      clusterJoinTokenPath = mkOption {
        type = types.str;
        default = "/var/lib/hercules-ci-agent/secrets/cluster-join-token.key";
        description = "Path to the cluster join token for Hercules CI";
      };

      binaryCachesPath = mkOption {
        type = types.str;
        default = "/var/lib/hercules-ci-agent/secrets/binary-caches.json";
        description = "Path to the binary caches configuration file";
      };

      # OpNix integration for secret provisioning
      opnix = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Enable OpNix-based provisioning of Hercules CI secrets from 1Password";
        };

        clusterJoinTokenReference = mkOption {
          type = types.str;
          default = "op://pantherOS/hercules-ci/cluster-join-token";
          description = "1Password reference path for the cluster join token";
        };

        binaryCachesReference = mkOption {
          type = types.str;
          default = "op://pantherOS/hercules-ci/binary-caches";
          description = "1Password reference path for the binary caches configuration";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # OpNix secret provisioning for Hercules CI
    services.onepassword-secrets = mkIf (cfg.herculesCI.enable && cfg.herculesCI.opnix.enable) {
      secrets = {
        herculesClusterJoinToken = {
          reference = cfg.herculesCI.opnix.clusterJoinTokenReference;
          path = cfg.herculesCI.clusterJoinTokenPath;
          owner = "hercules-ci-agent";
          group = "hercules-ci-agent";
          mode = "0600";
          services = ["hercules-ci-agent"];
        };

        herculesBinaryCaches = {
          reference = cfg.herculesCI.opnix.binaryCachesReference;
          path = cfg.herculesCI.binaryCachesPath;
          owner = "hercules-ci-agent";
          group = "hercules-ci-agent";
          mode = "0600";
          services = ["hercules-ci-agent"];
        };
      };
    };

    # Hercules CI Agent configuration
    services.hercules-ci-agent = mkIf cfg.herculesCI.enable {
      enable = true;
      settings = {
        clusterJoinTokenPath = cfg.herculesCI.clusterJoinTokenPath;
        binaryCachesPath = cfg.herculesCI.binaryCachesPath;
      };
    };

    # Create necessary directories for Hercules CI secrets
    system.activationScripts.create-hercules-ci-dirs = mkIf cfg.herculesCI.enable {
      text = ''
        mkdir -p /var/lib/hercules-ci-agent/secrets
        chmod 700 /var/lib/hercules-ci-agent/secrets
        # Only change ownership if the user exists
        if id hercules-ci-agent >/dev/null 2>&1; then
          chown -R hercules-ci-agent:hercules-ci-agent /var/lib/hercules-ci-agent
        fi
      '';
    };

    # Documentation
    environment.etc."hercules-ci/README".text = mkIf cfg.herculesCI.enable ''
      # Hercules CI Agent Configuration

      This directory contains the Hercules CI Agent configuration.

      ## Required Files

      Before starting the Hercules CI Agent, ensure these files exist:

      1. **Cluster Join Token**: ${cfg.herculesCI.clusterJoinTokenPath}
         - Obtain from your Hercules CI dashboard
         - This token authenticates the agent with your Hercules CI cluster

      2. **Binary Caches Configuration**: ${cfg.herculesCI.binaryCachesPath}
         - JSON file containing binary cache configurations
         - Example:
           {
             "mycache": {
               "kind": "CachixCache",
               "authToken": "your-auth-token"
             }
           }

      ${optionalString cfg.herculesCI.opnix.enable ''
      ## OpNix Secret Provisioning

      OpNix integration is enabled. Secrets are automatically provisioned from 1Password:

      1. **Cluster Join Token**: ${cfg.herculesCI.opnix.clusterJoinTokenReference}
         - Automatically provisioned to: ${cfg.herculesCI.clusterJoinTokenPath}
         - Owner: hercules-ci-agent:hercules-ci-agent
         - Permissions: 0600

      2. **Binary Caches**: ${cfg.herculesCI.opnix.binaryCachesReference}
         - Automatically provisioned to: ${cfg.herculesCI.binaryCachesPath}
         - Owner: hercules-ci-agent:hercules-ci-agent
         - Permissions: 0600

      Secrets are managed via the onepassword-secrets service and will be automatically
      synced before the hercules-ci-agent service starts.

      To update secrets, modify them in 1Password and restart the onepassword-secrets service:
        sudo systemctl restart onepassword-secrets.service
      ''}

      ${optionalString (!cfg.herculesCI.opnix.enable) ''
      ## Manual Setup Instructions

      1. Create the secrets directory:
         sudo mkdir -p /var/lib/hercules-ci-agent/secrets
         sudo chmod 700 /var/lib/hercules-ci-agent/secrets

      2. Add your cluster join token:
         sudo install -o hercules-ci-agent -m 600 /path/to/token.key ${cfg.herculesCI.clusterJoinTokenPath}

      3. Add your binary caches configuration:
         sudo install -o hercules-ci-agent -m 600 /path/to/binary-caches.json ${cfg.herculesCI.binaryCachesPath}

      4. Set appropriate permissions:
         sudo chown -R hercules-ci-agent:hercules-ci-agent /var/lib/hercules-ci-agent

      5. Start the service:
         sudo systemctl start hercules-ci-agent
      ''}

      ## Service Management

      Check status:
        sudo systemctl status hercules-ci-agent

      View logs:
        sudo journalctl -u hercules-ci-agent -f

      Restart service:
        sudo systemctl restart hercules-ci-agent

      For more information, visit: https://docs.hercules-ci.com
    '';
  };
}

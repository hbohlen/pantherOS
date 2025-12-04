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
    };
  };

  config = mkIf cfg.enable {
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
        if [ ! -d "/var/lib/hercules-ci-agent/secrets" ]; then
          mkdir -p /var/lib/hercules-ci-agent/secrets
          chmod 700 /var/lib/hercules-ci-agent/secrets
          chown hercules-ci-agent:hercules-ci-agent /var/lib/hercules-ci-agent/secrets 2>/dev/null || true
        fi
      '';
      deps = [];
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

      ## Setup Instructions

      1. Create the secrets directory:
         sudo mkdir -p /var/lib/hercules-ci-agent/secrets
         sudo chmod 700 /var/lib/hercules-ci-agent/secrets

      2. Add your cluster join token:
         sudo nano ${cfg.herculesCI.clusterJoinTokenPath}

      3. Add your binary caches configuration:
         sudo nano ${cfg.herculesCI.binaryCachesPath}

      4. Set appropriate permissions:
         sudo chown -R hercules-ci-agent:hercules-ci-agent /var/lib/hercules-ci-agent

      5. Start the service:
         sudo systemctl start hercules-ci-agent

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

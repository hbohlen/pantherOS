{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.secrets;
in
{
  options.pantherOS.secrets = {
    enable = mkEnableOption "pantherOS secrets management via 1Password";

    # Backblaze B2 secrets
    backblaze = {
      endpoint = mkOption {
        type = types.str;
        default = "op://pantherOS/backblaze-b2/default/endpoint";
        description = "1Password reference for Backblaze B2 endpoint";
      };

      region = mkOption {
        type = types.str;
        default = "op://pantherOS/backblaze-b2/default/region";
        description = "1Password reference for Backblaze B2 region";
      };

      master = {
        keyID = mkOption {
          type = types.str;
          default = "op://pantherOS/backblaze-b2/master/keyID";
          description = "1Password reference for Backblaze B2 master key ID";
        };

        keyName = mkOption {
          type = types.str;
          default = "op://pantherOS/backblaze-b2/master/keyName";
          description = "1Password reference for Backblaze B2 master key name";
        };

        applicationKey = mkOption {
          type = types.str;
          default = "op://pantherOS/backblaze-b2/master/applicationKey";
          description = "1Password reference for Backblaze B2 master application key";
        };
      };

      cache = {
        keyID = mkOption {
          type = types.str;
          default = "op://pantherOS/backblaze-b2/pantherOS-nix-cache/keyID";
          description = "1Password reference for Backblaze B2 cache key ID";
        };

        keyName = mkOption {
          type = types.str;
          default = "op://pantherOS/backblaze-b2/pantherOS-nix-cache/keyName";
          description = "1Password reference for Backblaze B2 cache key name";
        };

        applicationKey = mkOption {
          type = types.str;
          default = "op://pantherOS/backblaze-b2/pantherOS-nix-cache/applicationKey";
          description = "1Password reference for Backblaze B2 cache application key";
        };
      };
    };

    # Infrastructure secrets
    github = {
      token = mkOption {
        type = types.str;
        default = "op:pantherOS/github-pat/token";
        description = "1Password reference for GitHub personal access token";
      };
    };

    tailscale = {
      authKey = mkOption {
        type = types.str;
        default = "op:pantherOS/Tailscale/authKey";
        description = "1Password reference for Tailscale auth key";
      };
    };

    onepassword = {
      serviceAccountToken = mkOption {
        type = types.str;
        default = "op:pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token";
        description = "1Password reference for service account token";
      };
    };

    # Monitoring (Datadog) secrets
    datadog = {
      ddHost = mkOption {
        type = types.str;
        default = "op://pantherOS/datadog/default/DD_HOST";
        description = "1Password reference for Datadog host";
      };

      pantherOS = {
        applicationKey = mkOption {
          type = types.str;
          default = "op://pantherOS/datadog/pantherOS/APPLICATION_KEY";
          description = "1Password reference for Datadog pantherOS application key";
        };

        keyID = mkOption {
          type = types.str;
          default = "op://pantherOS/datadog/pantherOS/KEY_ID";
          description = "1Password reference for Datadog pantherOS key ID";
        };
      };

      hetzner = {
        apiKey = mkOption {
          type = types.str;
          default = "op://pantherOS/datadog/hetzner-vps/API_KEY";
          description = "1Password reference for Datadog Hetzner API key";
        };

        keyID = mkOption {
          type = types.str;
          default = "op://pantherOS/datadog/hetzner-vps/KEY_ID";
          description = "1Password reference for Datadog Hetzner key ID";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Secrets are configured but not exposed directly
    # They should be accessed through the config.pantherOS.secrets options
    # by other modules that need them
  };
}

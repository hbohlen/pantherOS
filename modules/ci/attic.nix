# Attic Binary Cache Server Configuration
# Provides a private Nix binary cache using Backblaze B2 storage
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.ci.attic;
in {
  options.services.ci.attic = {
    enable = mkEnableOption "Enable Attic binary cache server";

    listen = mkOption {
      type = types.str;
      default = "[::]:8080";
      description = "Address to listen on";
    };

    # Backblaze B2 configuration
    storage = {
      type = mkOption {
        type = types.enum [ "local" "s3" ];
        default = "s3";
        description = "Storage backend type (s3 for Backblaze B2)";
      };

      bucket = mkOption {
        type = types.str;
        default = "pantherOS-nix-cache";
        description = "Backblaze B2 bucket name";
      };

      region = mkOption {
        type = types.str;
        default = "us-west-004";
        description = "Backblaze B2 region";
      };

      endpoint = mkOption {
        type = types.str;
        default = "https://s3.us-west-004.backblazeb2.com";
        description = "Backblaze B2 S3-compatible endpoint";
      };
    };

    # OpNix integration for secret management
    opnix = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable OpNix-based provisioning of Attic secrets from 1Password";
      };

      credentialsReference = mkOption {
        type = types.str;
        default = "op://pantherOS/backblaze-b2/attic-credentials";
        description = "1Password reference for Backblaze B2 credentials";
      };
    };

    database = {
      url = mkOption {
        type = types.str;
        default = "sqlite:///var/lib/atticd/server.db";
        description = "Database URL (SQLite or PostgreSQL)";
      };
    };

    compression = {
      type = mkOption {
        type = types.enum [ "zstd" "brotli" "xz" ];
        default = "zstd";
        description = "Compression algorithm for stored NARs";
      };

      level = mkOption {
        type = types.int;
        default = 8;
        description = "Compression level (1-22 for zstd)";
      };
    };
  };

  config = mkIf cfg.enable {
    # Attic binary cache server
    services.atticd = {
      enable = true;

      # Credentials file path (managed by OpNix or manually)
      credentialsFile = "/var/lib/atticd/credentials.env";

      settings = {
        listen = cfg.listen;

        # JWT token signing (for authentication)
        # This will be generated automatically on first start
        # jwt_secret_file = "/var/lib/atticd/jwt-secret";

        # Chunking configuration
        chunking = {
          # Defaults from attic
          nar-size-threshold = 65536; # 64 KiB
          min-size = 16384;           # 16 KiB
          avg-size = 65536;           # 64 KiB
          max-size = 262144;          # 256 KiB
        };

        # Compression settings
        compression = {
          type = cfg.compression.type;
          level = cfg.compression.level;
        };

        # Storage backend (Backblaze B2 via S3)
        storage = {
          type = cfg.storage.type;
          bucket = cfg.storage.bucket;
          region = cfg.storage.region;
          endpoint = cfg.storage.endpoint;
        };

        # Database
        database = {
          url = cfg.database.url;
        };

        # Garbage collection
        garbage-collection = {
          # Default interval for checking
          interval = "1 day";

          # Keep NARs referenced by any cache
          default-retention-period = "3 months";
        };
      };
    };

    # OpNix secret provisioning for Attic
    services.onepassword-secrets = mkIf cfg.opnix.enable {
      secrets = {
        atticCredentials = {
          reference = cfg.opnix.credentialsReference;
          path = "/var/lib/atticd/credentials.env";
          owner = "atticd";
          group = "atticd";
          mode = "0600";
          services = ["atticd"];
        };
      };
    };

    # Ensure atticd starts after OpNix has populated secrets
    systemd.services.atticd = mkIf cfg.opnix.enable {
      after = ["onepassword-secrets.service"];
      wants = ["onepassword-secrets.service"];
    };

    # Firewall configuration
    networking.firewall.allowedTCPPorts = [ 8080 ];

    # Create necessary directories
    systemd.tmpfiles.rules = [
      "d /var/lib/atticd 0750 atticd atticd -"
    ];

    # Documentation
    environment.etc."attic/README".text = ''
      # Attic Binary Cache Server

      This server provides a private Nix binary cache backed by Backblaze B2.

      ## Configuration

      - Listen address: ${cfg.listen}
      - Storage backend: ${cfg.storage.type}
      - Bucket: ${cfg.storage.bucket}
      - Region: ${cfg.storage.region}
      - Endpoint: ${cfg.storage.endpoint}
      - Database: ${cfg.database.url}
      - Compression: ${cfg.compression.type} (level ${toString cfg.compression.level})

      ## Service Management

      Check status:
        sudo systemctl status atticd

      View logs:
        sudo journalctl -u atticd -f

      Restart service:
        sudo systemctl restart atticd

      ## Backblaze B2 Setup

      ${if cfg.opnix.enable then ''
      OpNix integration is enabled. Credentials are automatically provisioned from:
        ${cfg.opnix.credentialsReference}

      The credentials file should contain:
        AWS_ACCESS_KEY_ID=<your-b2-key-id>
        AWS_SECRET_ACCESS_KEY=<your-b2-application-key>
      '' else ''
      Manual configuration required. Create ${config.services.atticd.credentialsFile} with:
        AWS_ACCESS_KEY_ID=<your-b2-key-id>
        AWS_SECRET_ACCESS_KEY=<your-b2-application-key>

      Then set permissions:
        sudo chown atticd:atticd ${config.services.atticd.credentialsFile}
        sudo chmod 600 ${config.services.atticd.credentialsFile}
      ''}

      ## Creating a Cache

      After the server starts, create a cache:
        atticd-atticadm make-token --sub "my-cache" --validity "1 year" --push "*" --pull "*"

      Configure Nix to use this cache:
        nix.settings = {
          substituters = [ "http://localhost:8080/my-cache" ];
          trusted-public-keys = [ "..." ];  # Get from atticd
        };

      ## Integration with Hercules CI

      Add to your binary-caches.json in 1Password:
      {
        "my-cache": {
          "kind": "AtticCache",
          "endpoint": "http://localhost:8080/my-cache",
          "publicKeys": ["..."],
          "signingKeys": ["..."]
        }
      }

      For more information, visit: https://github.com/zhaofengli/attic
    '';
  };
}

# Backblaze B2 Credential Management Module
# Provides secure credential integration using OpNix/1Password for B2 storage access
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.storage.backup.b2;
in
{
  options.storage.backup.b2 = {
    enable = mkEnableOption "Enable Backblaze B2 backup storage";

    accountId = mkOption {
      type = types.str;
      default = "";
      description = "Backblaze B2 account ID";
      example = "0123456789abcdef";
    };

    keyId = mkOption {
      type = types.str;
      default = "";
      description = "Backblaze B2 key ID";
      example = "0123456789abcdef";
    };

    bucket = mkOption {
      type = types.str;
      default = "pantherOS-backups";
      description = "Backblaze B2 bucket name for backups";
      example = "pantherOS-backups";
    };

    # OpNix integration for secure credential management
    opnix = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable OpNix-based provisioning of B2 credentials from 1Password";
      };

      credentialsReference = mkOption {
        type = types.str;
        default = "op://pantherOS/backblaze-b2/backup-credentials";
        description = "1Password reference for Backblaze B2 credentials";
      };
    };

    # S3-compatible endpoint configuration for B2
    endpoint = mkOption {
      type = types.str;
      default = "https://s3.us-west-004.backblazeb2.com";
      description = "Backblaze B2 S3-compatible endpoint";
    };

    region = mkOption {
      type = types.str;
      default = "us-west-004";
      description = "Backblaze B2 region";
    };
  };

  config = mkIf cfg.enable {
    # Ensure B2 CLI tool is installed
    environment.systemPackages = with pkgs; [
      b2 # Backblaze B2 CLI tool
    ];

    # Configure environment variables for B2 access
    environment.sessionVariables = {
      B2_ACCOUNT_ID = cfg.accountId;
      B2_KEY_ID = cfg.keyId;
      B2_BUCKET = cfg.bucket;
      B2_ENDPOINT = cfg.endpoint;
    };

    # OpNix secret provisioning for B2 credentials
    # Credentials are managed securely via 1Password and never stored in Nix store
    services.onepassword-secrets = mkIf cfg.opnix.enable {
      secrets = {
        b2Credentials = {
          reference = cfg.opnix.credentialsReference;
          path = "/var/lib/panther-backups/b2-credentials.env";
          owner = "root";
          group = "root";
          mode = "0600";
          services = ["panther-backup.service"];
        };
      };
    };

    # Create backup data directory
    systemd.tmpfiles.rules = [
      "d /var/lib/panther-backups 0700 root root -"
    ];

    # Documentation
    environment.etc."backblaze-b2/README".text = ''
      # Backblaze B2 Configuration

      B2 Backup storage is configured with the following settings:
      - Account ID: ${cfg.accountId}
      - Bucket: ${cfg.bucket}
      - Region: ${cfg.region}
      - Endpoint: ${cfg.endpoint}

      ${if cfg.opnix.enable then ''
      ## OpNix Integration

      B2 credentials are automatically provisioned from 1Password:
        ${cfg.opnix.credentialsReference}

      The credentials file contains:
        AWS_ACCESS_KEY_ID=<your-b2-key-id>
        AWS_SECRET_ACCESS_KEY=<your-b2-application-key>

      This is managed securely via OpNix and never stored in the Nix store.
      '' else ''
      ## Manual Configuration Required

      Configure B2 credentials manually:
        export AWS_ACCESS_KEY_ID=<your-b2-key-id>
        export AWS_SECRET_ACCESS_KEY=<your-b2-application-key>

      Or create /var/lib/panther-backups/b2-credentials.env with:
        AWS_ACCESS_KEY_ID=<your-b2-key-id>
        AWS_SECRET_ACCESS_KEY=<your-b2-application-key>
      ''}

      ## Usage

      List buckets:
        b2 list-buckets

      List files in bucket:
        b2 ls ${cfg.bucket}

      Download a file:
        b2 download-file-by-name ${cfg.bucket} <file-name> <local-path>

      For more information: https://b2-command-line-tool.readthedocs.io/en/latest/
    '';
  };
}

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.security.secrets;
in {
  options.security.secrets = {
    enable = mkEnableOption "Enable structured secrets management using OpNix";

    # OpNix configuration options
    opnix = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable OpNix secret management";
      };

      keyFile = mkOption {
        type = types.path;
        default = "/etc/opnix/key";
        description = "Path to OpNix encryption key file";
      };

      secretsDirectory = mkOption {
        type = types.path;
        default = "/etc/opnix/secrets";
        description = "Directory containing OpNix-encrypted secrets";
      };
    };

    # Secret types configuration
    perHost = mkOption {
      type = types.bool;
      default = true;
      description = "Enable per-host secret isolation";
    };

    perUser = mkOption {
      type = types.bool;
      default = true;
      description = "Enable per-user secret isolation";
    };

    shared = mkOption {
      type = types.bool;
      default = true;
      description = "Enable shared secrets across hosts";
    };

    # 1Password integration
    onePassword = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable 1Password integration via OpNix";
      };

      vault = mkOption {
        type = types.str;
        default = "pantherOS";
        description = "1Password vault name for secrets";
      };
    };
  };

  config = mkIf cfg.enable {
    # Import OpNix module if available
    imports = [
      (lib.mkIf cfg.opnix.enable {
        _module.args.opnix = {
          enable = true;
          keyFile = cfg.opnix.keyFile;
          secretsDirectory = cfg.opnix.secretsDirectory;
        };
      })
    ];

    # System packages
    environment.systemPackages = with pkgs; [
      opnix
      gnupg
      age
    ];

    # Create secrets directories
    system.activationScripts.create-secrets-dirs = ''
      if [ ! -d "${cfg.opnix.secretsDirectory}" ]; then
        mkdir -p "${cfg.opnix.secretsDirectory}"
        chmod 700 "${cfg.opnix.secretsDirectory}"
        chown root:root "${cfg.opnix.secretsDirectory}"
      fi
    '';

    # Environment variables for OpNix
    environment.sessionVariables = {
      OPNIX_KEY_FILE = cfg.opnix.keyFile;
      OPNIX_SECRETS_DIR = cfg.opnix.secretsDirectory;
    };

    # Documentation note
    environment.etc."opnix/README".text = ''
      # OpNix Secrets Management

      This directory contains OpNix-encrypted secrets.

      ## Directory Structure

      - `hosts/` - Host-specific secrets
      - `users/` - User-specific secrets
      - `shared/` - Shared secrets across hosts

      ## Usage

      Decrypt secrets using: opnix decrypt
      Encrypt secrets using: opnix encrypt <file>

      For more information, see OpNix documentation.
    '';
  };
}

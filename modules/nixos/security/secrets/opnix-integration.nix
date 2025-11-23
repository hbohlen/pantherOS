{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.security.opnix;
in
{
  options.pantherOS.security.opnix = {
    enable = mkEnableOption "OpNix 1Password service account integration";

    serviceAccountTokenPath = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to 1Password service account token file";
    };

    enableSystemService = mkOption {
      type = types.bool;
      default = true;
      description = "Enable OpNix as a system service";
    };
  };

  config = mkIf cfg.enable {
    # OpNix service configuration
    services.opnix = mkIf cfg.enableSystemService {
      enable = true;
      # Service account token should be provided securely
      # tokenPath = cfg.serviceAccountTokenPath;
    };

    # Environment for OpNix integration
    environment.systemPackages = with pkgs; [
      # OpNix CLI tools if available
    ];

    # System environment variables for OpNix
    environment.sessionVariables = mkIf (cfg.serviceAccountTokenPath != null) {
      OP_SERVICE_ACCOUNT_TOKEN = cfg.serviceAccountTokenPath;
    };
  };
}

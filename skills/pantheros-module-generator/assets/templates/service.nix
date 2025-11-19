# Service Module Template
# Use for: Background services, daemons, APIs

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.MODULE_NAME;
in
{
  options.services.MODULE_NAME = {
    enable = mkEnableOption "MODULE_NAME";

    package = mkOption {
      type = types.package;
      default = pkgs.MODULE_NAME;
      defaultText = literalExpression "pkgs.MODULE_NAME";
      description = ''
        Package to use for MODULE_NAME.
      '';
    };

    port = mkOption {
      type = types.int;
      default = 8080;
      description = ''
        Port for MODULE_NAME to listen on.
      '';
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      example = literalExpression ''
        {
          databaseUrl = "postgresql://user:pass@localhost/db";
          logLevel = "info";
        }
      '';
      description = ''
        Configuration for MODULE_NAME.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open the firewall for the service port.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package
    ];

    systemd.services.MODULE_NAME = {
      description = "MODULE_NAME Service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = "\${cfg.package}/bin/MODULE_NAME --port \${toString cfg.port}";
        Restart = "on-failure";
        User = "MODULE_NAME";
        Group = "MODULE_NAME";
      };

      # Create user if needed
      preStart = ''
        if ! id MODULE_NAME >/dev/null 2>&1; then
          useradd -r -s ${config.security.wrapperDir}/nixos-sandbox MODULE_NAME
        fi
        mkdir -p /var/lib/MODULE_NAME /var/log/MODULE_NAME
        chown MODULE_NAME:MODULE_NAME /var/lib/MODULE_NAME /var/log/MODULE_NAME
      '';
    };

    # Write configuration file
    environment.etc."MODULE_NAME/config.json".source =
      pkgs.writeText "MODULE_NAME-config.json" (toJSON cfg.settings);

    # Open firewall if requested
    networking.firewall = mkIf cfg.openFirewall {
      allowedPorts = [ cfg.port ];
    };

    imports = [
      # Add module imports here
    ];
  };
}

# modules/development/mutagen/default.nix
# Mutagen development synchronization system module

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.mutagen;
in {
  options.programs.mutagen = {
    enable = mkEnableOption "Mutagen file synchronization and forwarding";
    
    package = mkOption {
      type = types.package;
      default = pkgs.mutagen;
      description = "The Mutagen package to use";
    };

    autoStart = mkOption {
      type = types.bool;
      default = false;
      description = "Automatically start Mutagen sessions on login";
    };
  };

  config = mkIf cfg.enable {
    # Install Mutagen and dependencies
    environment.systemPackages = [
      cfg.package
      pkgs.docker-compose
      pkgs.rsync
      pkgs.openssh
    ];

    # Ensure required system services
    services = {
      # SSH for remote synchronization
      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
          X11Forwarding = true;
        };
      };

      # Docker for container-based development
      docker = {
        enable = true;
        autoPrune = {
          enable = true;
          dates = "weekly";
        };
      };
    };

    # User groups for Mutagen operations
    users.groups = {
      docker = {};
      mutagen = {};
    };

    # Systemd user services for Mutagen
    systemd.user.services.mutagen-daemon = {
      description = "Mutagen Daemon";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/mutagen daemon run";
        Restart = "on-failure";
        RestartSec = 1;
        Environment = [
          "MUTAGEN_DATA_DIR=%h/.local/share/mutagen"
          "MUTAGEN_CONFIG_DIR=%h/.config/mutagen"
        ];
      };
    };

    # Environment variables for Mutagen
    environment.sessionVariables = {
      MUTAGEN_DATA_DIR = "$HOME/.local/share/mutagen";
      MUTAGEN_CONFIG_DIR = "$HOME/.config/mutagen";
      MUTAGEN_LOG_LEVEL = "info";
    };

    # Shell aliases for Mutagen
    programs.bash.shellAliases = {
      ms = "mutagen sync";
      mf = "mutagen forward";
      ml = "mutagen sync list";
      mls = "mutagen forward list";
      mr = "mutagen sync resume";
      mp = "mutagen sync pause";
      mc = "mutagen sync create";
      mt = "mutagen sync terminate";
      mm = "mutagen sync monitor";
    };
  };
}
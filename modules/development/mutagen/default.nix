# modules/development/mutagen/default.nix
# Mutagen development synchronization system module

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.mutagen;
in {
<<<<<<< HEAD
  imports = [
    ./sync.nix
    ./forward.nix
    ./projects.nix
  ];

=======
>>>>>>> feature/niri-dankmaterial-integration
  options.programs.mutagen = {
    enable = mkEnableOption "Mutagen file synchronization and forwarding";
    
    package = mkOption {
      type = types.package;
      default = pkgs.mutagen;
      description = "The Mutagen package to use";
    };

<<<<<<< HEAD
    enableSync = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Mutagen synchronization profiles";
    };

    enableForward = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Mutagen port forwarding profiles";
    };

    enableProjects = mkOption {
      type = types.bool;
      default = true;
      description = "Enable project-specific Mutagen configurations";
    };

=======
>>>>>>> feature/niri-dankmaterial-integration
    autoStart = mkOption {
      type = types.bool;
      default = false;
      description = "Automatically start Mutagen sessions on login";
    };
  };

  config = mkIf cfg.enable {
    # Install Mutagen and dependencies
<<<<<<< HEAD
    environment.systemPackages = with pkgs; [
      cfg.package
      mutagen-compose
      docker-compose
      rsync
      openssh
=======
    environment.systemPackages = [
      cfg.package
      pkgs.docker-compose
      pkgs.rsync
      pkgs.openssh
>>>>>>> feature/niri-dankmaterial-integration
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
<<<<<<< HEAD
    systemd.user = {
      # Mutagen daemon service
      services.mutagen-daemon = {
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

      # Mutagen session manager
      services.mutagen-session-manager = {
        description = "Mutagen Session Manager";
        wantedBy = mkIf cfg.autoStart [ "graphical-session.target" ];
        after = [ "graphical-session.target" "mutagen-daemon.service" ];
        partOf = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScript "mutagen-start-sessions" ''
            # Start Mutagen synchronization sessions
            if [ -d "$HOME/.config/mutagen/sync" ]; then
              for config in "$HOME/.config/mutagen/sync"/*.yml; do
                if [ -f "$config" ]; then
                  echo "Starting sync session: $(basename "$config" .yml)"
                  ${cfg.package}/bin/mutagen sync create --configuration-file="$config" || true
                fi
              done
            fi

            # Start Mutagen forwarding sessions
            if [ -d "$HOME/.config/mutagen/forward" ]; then
              for config in "$HOME/.config/mutagen/forward"/*.yml; do
                if [ -f "$config" ]; then
                  echo "Starting forward session: $(basename "$config" .yml)"
                  ${cfg.package}/bin/mutagen forward create --configuration-file="$config" || true
                fi
              done
            fi

            # Start project-specific sessions
            if [ -d "$HOME/.config/mutagen/projects" ]; then
              for config in "$HOME/.config/mutagen/projects"/*.yml; do
                if [ -f "$config" ]; then
                  echo "Starting project session: $(basename "$config" .yml)"
                  ${cfg.package}/bin/mutagen sync create --configuration-file="$config" || true
                fi
              done
            fi
          ''}";
          RemainAfterExit = true;
        };
      };

      # Mutagen session cleanup on logout
      services.mutagen-session-cleanup = {
        description = "Mutagen Session Cleanup";
        wantedBy = [ "shutdown.target" ];
        before = [ "shutdown.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScript "mutagen-cleanup" ''
            # List all active sessions
            SESSIONS=$(${cfg.package}/bin/mutagen sync list --format=csv | tail -n +2 | cut -d, -f1)
            
            # Terminate all sessions
            for session in $SESSIONS; do
              echo "Terminating session: $session"
              ${cfg.package}/bin/mutagen sync terminate "$session" || true
            done

            # List forwarding sessions
            FORWARD_SESSIONS=$(${cfg.package}/bin/mutagen forward list --format=csv | tail -n +2 | cut -d, -f1)
            
            # Terminate all forwarding sessions
            for session in $FORWARD_SESSIONS; do
              echo "Terminating forward session: $session"
              ${cfg.package}/bin/mutagen forward terminate "$session" || true
            done
          ''}";
        };
=======
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
>>>>>>> feature/niri-dankmaterial-integration
      };
    };

    # Environment variables for Mutagen
    environment.sessionVariables = {
      MUTAGEN_DATA_DIR = "$HOME/.local/share/mutagen";
      MUTAGEN_CONFIG_DIR = "$HOME/.config/mutagen";
      MUTAGEN_LOG_LEVEL = "info";
    };

<<<<<<< HEAD
    # Configuration directories
    environment.etc."mutagen/mutagen.yml".text = ''
      # Global Mutagen configuration
      sync:
        defaults:
          permissions:
            defaultFileMode: 0644
            defaultDirectoryMode: 0755
          ignore:
            vcs: true
            paths:
              - ".git"
              - ".svn"
              - ".hg"
              - "node_modules"
              - ".npm"
              - ".cache"
              - ".DS_Store"
              - "Thumbs.db"
          watch:
            mode: "portable"
            pollingInterval: 10

      forward:
        defaults:
          source:
            protocol: "local"
          destination:
            protocol: "local"
            connectTimeout: 30
          socketForwarding:
            mode: "local"

      global:
        log:
          level: "info"
          maximumSize: 10485760  # 10MB
        daemon:
          connectionTimeout: 30
          synchronizationTimeout: 300
    '';

=======
>>>>>>> feature/niri-dankmaterial-integration
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
<<<<<<< HEAD

    programs.fish.shellAliases = {
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
=======
>>>>>>> feature/niri-dankmaterial-integration
  };
}
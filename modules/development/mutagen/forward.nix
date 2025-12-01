# modules/development/mutagen/forward.nix
# Mutagen port forwarding configurations

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.mutagen;
in {
  config = mkIf (cfg.enable && cfg.enableForward) {
    # Default forwarding profiles
    environment.etc."mutagen/forward/database.yml".text = ''
      # Database port forwarding
      forward:
        source:
          protocol: "local"
          address: "localhost"
          port: 5432
        destination:
          protocol: "remote"
          address: "database-server"
          port: 5432
          user: "developer"
          hostname: "db.example.com"
        name: "database"
        socketForwarding:
          mode: "local"
    '';

    environment.etc."mutagen/forward/web-server.yml".text = ''
      # Web server port forwarding
      forward:
        source:
          protocol: "local"
          address: "localhost"
          port: 8080
        destination:
          protocol: "remote"
          address: "localhost"
          port: 80
          user: "developer"
          hostname: "web-server.example.com"
        name: "web-server"
        socketForwarding:
          mode: "local"
    '';

    environment.etc."mutagen/forward/redis.yml".text = ''
      # Redis port forwarding
      forward:
        source:
          protocol: "local"
          address: "localhost"
          port: 6379
        destination:
          protocol: "remote"
          address: "localhost"
          port: 6379
          user: "developer"
          hostname: "redis-server.example.com"
        name: "redis"
        socketForwarding:
          mode: "local"
    '';

    environment.etc."mutagen/forward/docker-compose.yml".text = ''
      # Docker Compose service forwarding
      forward:
        source:
          protocol: "local"
          address: "localhost"
          port: 3000
        destination:
          protocol: "docker"
          address: "web"
          port: 3000
          container: "my-app"
        name: "docker-web"
        socketForwarding:
          mode: "local"
    '';

    # Scripts for managing forwarding sessions
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "mutagen-forward-db" ''
        # Start database forwarding
        ${cfg.package}/bin/mutagen forward create --configuration-file=/etc/mutagen/forward/database.yml || \
        ${cfg.package}/bin/mutagen forward resume database
        echo "Database forwarding started on localhost:5432"
      '')

      (writeShellScriptBin "mutagen-forward-web" ''
        # Start web server forwarding
        ${cfg.package}/bin/mutagen forward create --configuration-file=/etc/mutagen/forward/web-server.yml || \
        ${cfg.package}/bin/mutagen forward resume web-server
        echo "Web server forwarding started on localhost:8080"
      '')

      (writeShellScriptBin "mutagen-forward-redis" ''
        # Start Redis forwarding
        ${cfg.package}/bin/mutagen forward create --configuration-file=/etc/mutagen/forward/redis.yml || \
        ${cfg.package}/bin/mutagen forward resume redis
        echo "Redis forwarding started on localhost:6379"
      '')

      (writeShellScriptBin "mutagen-forward-docker" ''
        # Start Docker service forwarding
        ${cfg.package}/bin/mutagen forward create --configuration-file=/etc/mutagen/forward/docker-compose.yml || \
        ${cfg.package}/bin/mutagen forward resume docker-web
        echo "Docker web service forwarding started on localhost:3000"
      '')

      (writeShellScriptBin "mutagen-forward-all" ''
        # Start all forwarding sessions
        for config in /etc/mutagen/forward/*.yml; do
          if [ -f "$config" ]; then
            echo "Starting forward session: $(basename "$config" .yml)"
            ${cfg.package}/bin/mutagen forward create --configuration-file="$config" || true
          fi
        done
        echo "All forwarding sessions started"
      '')

      (writeShellScriptBin "mutagen-forward-terminate-all" ''
        # Terminate all forwarding sessions
        SESSIONS=$(${cfg.package}/bin/mutagen forward list --format=csv | tail -n +2 | cut -d, -f1)
        for session in $SESSIONS; do
          echo "Terminating forward session: $session"
          ${cfg.package}/bin/mutagen forward terminate "$session"
        done
        echo "All forwarding sessions terminated"
      '')
    ];
  };
}
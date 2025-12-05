# modules/development/mutagen/sync.nix
# Mutagen synchronization configurations

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.mutagen;
in {
  config = mkIf (cfg.enable && cfg.enableSync) {
    # Default synchronization profiles
    environment.etc."mutagen/sync/development.yml".text = ''
      # Development environment synchronization
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
              - "*.log"
              - ".env.local"
              - ".env.*.local"
          watch:
            mode: "portable"
            pollingInterval: 10

      alpha: "~/projects"
      beta: "~/sync/projects"
      mode: "two-way-resolved"
      name: "development-projects"
    '';

    environment.etc."mutagen/sync/dotfiles.yml".text = ''
      # Dotfiles synchronization
      sync:
        alpha: "~/.dotfiles"
        beta: "~/sync/dotfiles"
        mode: "two-way-resolved"
        name: "dotfiles"
        ignore:
          paths:
            - ".git"
            - ".DS_Store"
            - "*.swp"
            - "*.swo"
            - ".local/share/Trash"
        permissions:
          defaultFileMode: 0600
          defaultDirectoryMode: 0700
    '';

    environment.etc."mutagen/sync/documents.yml".text = ''
      # Documents synchronization
      sync:
        alpha: "~/Documents"
        beta: "~/sync/documents"
        mode: "two-way-resolved"
        name: "documents"
        ignore:
          paths:
            - ".git"
            - "node_modules"
            - ".cache"
            - "*.tmp"
            - "*.temp"
        permissions:
          defaultFileMode: 0644
          defaultDirectoryMode: 0755
    '';

    environment.etc."mutagen/sync/configs.yml".text = ''
      # Configuration files synchronization
      sync:
        alpha: "~/.config"
        beta: "~/sync/configs"
        mode: "two-way-resolved"
        name: "configs"
        ignore:
          paths:
            - ".git"
            - "cache"
            - "*.log"
            - ".local/state"
            - ".cache"
            - "autostart"
        permissions:
          defaultFileMode: 0600
          defaultDirectoryMode: 0700
        symlink:
          mode: "portable"
    '';

    environment.etc."mutagen/sync/docker-compose.yml".text = ''
      # Docker Compose project synchronization
      sync:
        alpha: "~/docker-projects"
        beta: "~/sync/docker-projects"
        mode: "two-way-resolved"
        name: "docker-projects"
        ignore:
          paths:
            - ".git"
            - "node_modules"
            - ".npm"
            - ".cache"
            - "*.log"
            - "data"
            - "volumes"
            - ".env.local"
        permissions:
          defaultFileMode: 0644
          defaultDirectoryMode: 0755
    '';

    # Scripts for managing sync sessions
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "mutagen-sync-dev" ''
        # Start development sync session
        ${cfg.package}/bin/mutagen sync create --configuration-file=/etc/mutagen/sync/development.yml || \
        ${cfg.package}/bin/mutagen sync resume development-projects
        echo "Development sync session started"
      '')

      (writeShellScriptBin "mutagen-sync-dots" ''
        # Start dotfiles sync session
        ${cfg.package}/bin/mutagen sync create --configuration-file=/etc/mutagen/sync/dotfiles.yml || \
        ${cfg.package}/bin/mutagen sync resume dotfiles
        echo "Dotfiles sync session started"
      '')

      (writeShellScriptBin "mutagen-sync-all" ''
        # Start all sync sessions
        for config in /etc/mutagen/sync/*.yml; do
          if [ -f "$config" ]; then
            echo "Starting sync session: $(basename "$config" .yml)"
            ${cfg.package}/bin/mutagen sync create --configuration-file="$config" || true
          fi
        done
        echo "All sync sessions started"
      '')

      (writeShellScriptBin "mutagen-sync-status" ''
        # Show status of all sync sessions
        echo "=== Sync Sessions Status ==="
        ${cfg.package}/bin/mutagen sync list
        echo ""
        echo "=== Forward Sessions Status ==="
        ${cfg.package}/bin/mutagen forward list
      '')

      (writeShellScriptBin "mutagen-sync-terminate-all" ''
        # Terminate all sync sessions
        SESSIONS=$(${cfg.package}/bin/mutagen sync list --format=csv | tail -n +2 | cut -d, -f1)
        for session in $SESSIONS; do
          echo "Terminating sync session: $session"
          ${cfg.package}/bin/mutagen sync terminate "$session"
        done
        echo "All sync sessions terminated"
      '')
    ];
  };
}
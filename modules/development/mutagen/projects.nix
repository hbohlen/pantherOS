# modules/development/mutagen/projects.nix
# Project-specific Mutagen configurations

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.mutagen;
in {
  config = mkIf (cfg.enable && cfg.enableProjects) {
    # Project-specific configurations
    environment.etc."mutagen/projects/nixos-config.yml".text = ''
      # NixOS configuration project
      sync:
        alpha: "~/dev/nixos-config"
        beta: "~/sync/projects/nixos-config"
        mode: "two-way-resolved"
        name: "nixos-config"
        ignore:
          paths:
            - ".git"
            - "result"
            - "*.qcow2"
            - "*.img"
            - ".direnv"
        permissions:
          defaultFileMode: 0644
          defaultDirectoryMode: 0755
    '';

    environment.etc."mutagen/projects/web-development.yml".text = ''
      # Web development project
      sync:
        alpha: "~/projects/web-app"
        beta: "~/sync/projects/web-app"
        mode: "two-way-resolved"
        name: "web-development"
        ignore:
          paths:
            - ".git"
            - "node_modules"
            - ".npm"
            - ".cache"
            - "dist"
            - "build"
            - ".next"
            - ".nuxt"
            - ".svelte-kit"
            - "*.log"
        permissions:
          defaultFileMode: 0644
          defaultDirectoryMode: 0755
        symlink:
          mode: "portable"
    '';

    environment.etc."mutagen/projects/python-development.yml".text = ''
      # Python development project
      sync:
        alpha: "~/projects/python-app"
        beta: "~/sync/projects/python-app"
        mode: "two-way-resolved"
        name: "python-development"
        ignore:
          paths:
            - ".git"
            - "__pycache__"
            - "*.pyc"
            - ".pytest_cache"
            - ".mypy_cache"
            - ".tox"
            - "venv"
            - ".venv"
            - "*.egg-info"
            - ".coverage"
        permissions:
          defaultFileMode: 0644
          defaultDirectoryMode: 0755
    '';

    environment.etc."mutagen/projects/rust-development.yml".text = ''
      # Rust development project
      sync:
        alpha: "~/projects/rust-app"
        beta: "~/sync/projects/rust-app"
        mode: "two-way-resolved"
        name: "rust-development"
        ignore:
          paths:
            - ".git"
            - "target"
            - "Cargo.lock"
            - "*.pdb"
            - ".cargo"
        permissions:
          defaultFileMode: 0644
          defaultDirectoryMode: 0755
    '';

    environment.etc."mutagen/projects/container-development.yml".text = ''
      # Container development project
      sync:
        alpha: "~/projects/container-app"
        beta: "~/sync/projects/container-app"
        mode: "two-way-resolved"
        name: "container-development"
        ignore:
          paths:
            - ".git"
            - "node_modules"
            - ".npm"
            - ".cache"
            - "data"
            - "volumes"
            - ".env.local"
            - "*.log"
            - "docker-compose.override.yml"
        permissions:
          defaultFileMode: 0644
          defaultDirectoryMode: 0755
    '';

    # Scripts for managing project sessions
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "mutagen-project-nixos" ''
        # Start NixOS config project sync
        ${cfg.package}/bin/mutagen sync create --configuration-file=/etc/mutagen/projects/nixos-config.yml || \
        ${cfg.package}/bin/mutagen sync resume nixos-config
        echo "NixOS config project sync started"
      '')

      (writeShellScriptBin "mutagen-project-web" ''
        # Start web development project sync
        ${cfg.package}/bin/mutagen sync create --configuration-file=/etc/mutagen/projects/web-development.yml || \
        ${cfg.package}/bin/mutagen sync resume web-development
        echo "Web development project sync started"
      '')

      (writeShellScriptBin "mutagen-project-python" ''
        # Start Python development project sync
        ${cfg.package}/bin/mutagen sync create --configuration-file=/etc/mutagen/projects/python-development.yml || \
        ${cfg.package}/bin/mutagen sync resume python-development
        echo "Python development project sync started"
      '')

      (writeShellScriptBin "mutagen-project-rust" ''
        # Start Rust development project sync
        ${cfg.package}/bin/mutagen sync create --configuration-file=/etc/mutagen/projects/rust-development.yml || \
        ${cfg.package}/bin/mutagen sync resume rust-development
        echo "Rust development project sync started"
      '')

      (writeShellScriptBin "mutagen-project-container" ''
        # Start container development project sync
        ${cfg.package}/bin/mutagen sync create --configuration-file=/etc/mutagen/projects/container-development.yml || \
        ${cfg.package}/bin/mutagen sync resume container-development
        echo "Container development project sync started"
      '')

      (writeShellScriptBin "mutagen-project-all" ''
        # Start all project sync sessions
        for config in /etc/mutagen/projects/*.yml; do
          if [ -f "$config" ]; then
            echo "Starting project sync: $(basename "$config" .yml)"
            ${cfg.package}/bin/mutagen sync create --configuration-file="$config" || true
          fi
        done
        echo "All project sync sessions started"
      '')

      (writeShellScriptBin "mutagen-project-create" ''
        # Create new project sync configuration
        if [ $# -lt 2 ]; then
          echo "Usage: mutagen-project-create <project-name> <source-path> [destination-path]"
          exit 1
        fi

        PROJECT_NAME="$1"
        SOURCE_PATH="$2"
        DEST_PATH="''${3:-~/sync/projects/$PROJECT_NAME}"

        # Create configuration file
        cat > "$HOME/.config/mutagen/projects/$PROJECT_NAME.yml" << EOF
      sync:
        alpha: "$SOURCE_PATH"
        beta: "$DEST_PATH"
        mode: "two-way-resolved"
        name: "$PROJECT_NAME"
        ignore:
          paths:
            - ".git"
            - "node_modules"
            - ".cache"
            - "*.log"
        permissions:
          defaultFileMode: 0644
          defaultDirectoryMode: 0755
EOF

        echo "Created project configuration: $PROJECT_NAME"
        echo "Source: $SOURCE_PATH"
        echo "Destination: $DEST_PATH"
        
        # Start the sync session
        ${cfg.package}/bin/mutagen sync create --configuration-file="$HOME/.config/mutagen/projects/$PROJECT_NAME.yml"
        echo "Project sync started: $PROJECT_NAME"
      '')
    ];
  };
}
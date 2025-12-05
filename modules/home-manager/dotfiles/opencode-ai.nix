{ config, lib, ... }:

with lib;

let
  cfg = config.dotfiles.opencode-ai;
in {
  imports = [
    ./opencode
  ];

  config = mkIf cfg.enable {
    # Enhanced environment variables for OpenAgent
    home.sessionVariables = {
      OPENAGENT_DEBUG = if cfg.openAgent.debug then "true" else "false";
      OPENAGENT_DCP_ENABLED = if cfg.openAgent.dcp.enable then "true" else "false";
      OPENAGENT_THEME = cfg.theme;
      OPENAGENT_DCP_PRUNING_MODE = "smart";
      OPENAGENT_DCP_DEBUG = if cfg.openAgent.debug then "true" else "false";
    };

    # DCP configuration as managed dotfile
    xdg.configFile."opencode/dcp.jsonc" = {
      text = ''
        {
          "enabled": ${lib.boolToString cfg.openAgent.dcp.enable},
          "debug": ${lib.boolToString cfg.openAgent.debug},
          "pruningMode": "smart",
          "pruning_summary": "detailed",
          "protectedTools": ["task", "todowrite", "todoread"],
          "$$schema": {
            "onIdle": ["deduplication", "ai-analysis"],
            "onTool": ["deduplication"]
          }
        }
      '';
      # Don't force - allow manual customizations if needed
    };

    # OpenCode main configuration as managed dotfile
    xdg.configFile."opencode/opencode.jsonc" = {
      text = let
        mcpConfig = {
          nixos = {
            type = "local";
            command = ["nix" "run" "github:utensils/mcp-nixos" "--"];
          };
        };
        lspConfig = {
          nix = {
            command = ["nixd"];
            extensions = [".nix"];
          };
        };
        formatterConfig = {
          nix = {
            command = ["nixpkgs-fmt"];
            extensions = [".nix"];
          };
        };
        
        baseConfig = {
          "$schema" = "https://opencode.ai/config.json";
          autoupdate = true;
          username = "hbohlen";
          theme = cfg.theme;
          plugin = cfg.plugins;
        } // lib.optionalAttrs cfg.mcp.enable {
          mcp = if cfg.mcp.nixos.enable then mcpConfig else {};
        } // lib.optionalAttrs cfg.lsp.enable {
          lsp = if cfg.lsp.nix.enable then lspConfig else {};
        } // lib.optionalAttrs cfg.formatter.enable {
          formatter = if cfg.formatter.nix.enable then formatterConfig else {};
        };
      in lib.generators.toJSON {} baseConfig;
      # Don't force - allow manual customizations if needed
    };

    # Create base OpenAgent directories and manage .opencode/ files
    home.file =
      let
        baseDirectories = {
          "OpenAgent context directory" = {
            target = "${config.home.homeDirectory}/.cache/opencode/sessions";
            recursive = true;
            ensureDir = true;
          };
          "OpenAgent logs directory" = {
            target = "${config.home.homeDirectory}/.local/share/opencode/logs";
            recursive = true;
            ensureDir = true;
          };
          "OpenAgent plugins directory" = {
            target = "${config.home.homeDirectory}/.local/share/opencode/plugins";
            recursive = true;
            ensureDir = true;
          };
          "OpenAgent tools directory" = {
            target = "${config.home.homeDirectory}/.local/share/opencode/tools";
            recursive = true;
            ensureDir = true;
          };
        };
        
        # .opencode/ directory structure management
        opencodeDirectories = {
          ".opencode/agent directory" = {
            target = ".opencode/agent";
            recursive = true;
            ensureDir = true;
          };
          ".opencode/command directory" = {
            target = ".opencode/command";
            recursive = true;
            ensureDir = true;
          };
          ".opencode/context directory" = {
            target = ".opencode/context";
            recursive = true;
            ensureDir = true;
          };
          ".opencode/skills directory" = {
            target = ".opencode/skills";
            recursive = true;
            ensureDir = true;
          };
          ".opencode/tool directory" = {
            target = ".opencode/tool";
            recursive = true;
            ensureDir = true;
          };
          ".opencode/workflows directory" = {
            target = ".opencode/workflows";
            recursive = true;
            ensureDir = true;
          };
        };
        
        # Essential .opencode/ files to copy from project
        projectPath = "/home/hbohlen/dev/pantherOS";
        essentialFiles = {
          ".opencode/README.md" = {
            source = "${projectPath}/.opencode/README.md";
            target = ".opencode/README.md";
          };
          ".opencode/dcp.jsonc" = {
            source = "${projectPath}/.opencode/dcp.jsonc";
            target = ".opencode/dcp.jsonc";
          };
          ".opencode/agent/openagent.md" = {
            source = "${projectPath}/.opencode/agent/openagent.md";
            target = ".opencode/agent/openagent.md";
          };
          ".opencode/context/core/critical-rules.md" = {
            source = "${projectPath}/.opencode/context/core/critical-rules.md";
            target = ".opencode/context/core/critical-rules.md";
          };
          ".opencode/context/core/static-context.md" = {
            source = "${projectPath}/.opencode/context/core/static-context.md";
            target = ".opencode/context/core/static-context.md";
          };
          ".opencode/context/core/workflows/delegation.md" = {
            source = "${projectPath}/.opencode/context/core/workflows/delegation.md";
            target = ".opencode/context/core/workflows/delegation.md";
          };
          ".opencode/context/core/standards/code.md" = {
            source = "${projectPath}/.opencode/context/core/standards/code.md";
            target = ".opencode/context/core/standards/code.md";
          };
          ".opencode/context/core/standards/patterns.md" = {
            source = "${projectPath}/.opencode/context/core/standards/patterns.md";
            target = ".opencode/context/core/standards/patterns.md";
          };
        };
        
        additionalDirectories = lib.mapAttrs' (
          name: value:
          lib.nameValuePair "additional-config-${name}" {
            target = "${config.home.homeDirectory}/.config/opencode/${name}";
            text = value;
          }
        ) cfg.additionalConfig;
      in
      baseDirectories // opencodeDirectories // essentialFiles // additionalDirectories;

    # Home Manager configuration for OpenAgent
    programs.home-manager.enable = true;
  };
}

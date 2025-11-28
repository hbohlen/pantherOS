{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.home-manager.dotfiles.opencode-ai;
in
{
  options.home-manager.dotfiles.opencode-ai = {
    enable = mkEnableOption "Enable OpenCode.ai and OpenAgent configuration management";

    theme = mkOption {
      type = types.enum [ "light" "dark" "auto" ];
      default = "auto";
      description = ''
        Theme preference for OpenCode.ai interface
      '';
    };
    
    openAgent = {
      enable = mkEnableOption "Enable OpenAgent system integration";
      debug = mkOption {
        type = types.bool;
        default = true;
        description = "Enable OpenAgent debug mode";
      };
      dcp = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable DCP (Distributed Computing Protocol) for OpenAgent";
        };
      };
    };
    
    plugins = mkOption {
      type = types.listOf types.str;
      default = [ "@tarquinen/opencode-dcp" ];
      description = "List of OpenCode plugins to load";
    };
    
    additionalConfig = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Additional configuration files to add to OpenCode directory";
    };
  };

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
      text = ''
        {
          "$$schema": "https://opencode.ai/config.json",
          "autoupdate": true,
          "username": "hbohlen",
          "theme": "${cfg.theme}",
          "plugin": ${lib.generators.toJSON cfg.plugins}
        }
      '';
      # Don't force - allow manual customizations if needed
    };
    
    # Create base OpenAgent directories
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
      additionalDirectories = lib.mapAttrs' (name: value: 
        lib.nameValuePair "additional-config-${name}" {
          target = "${config.home.homeDirectory}/.config/opencode/${name}";
          text = value;
        })
        cfg.additionalConfig;
      allDirectories = baseDirectories // additionalDirectories;
    in
    home.file = allDirectories;
    
    # Home Manager configuration for OpenAgent
    programs.home-manager.enable = true;
  };
}
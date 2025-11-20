# Home-Manager Development for pantherOS

## Overview

Home-Manager in pantherOS manages user-level configurations including shell environments, desktop settings, applications, and development tools. All user configurations are modular and follow the single-concern principle.

## User Environment Modules

### Shell Configuration
Terminal and shell environment setup:

#### Fish Shell Module
```nix
{ lib, config, pkgs, ... }:

{
  programs.fish = {
    enable = true;
    
    shellAliases = {
      ll = "ls -la";
      la = "ls -la";
      ".." = "cd ..";
      "..." = "cd ../..";
    };
    
    shellInit = ''
      # Auto-activate devShell in ~/dev
      if test -d ~/dev
        cd ~/dev
        if test -e shell.nix -o -e default.nix
          nix develop
        end
        cd -
      end
    '';
    
    functions = {
      fish_greeting = {
        body = "";
        description = "Disable fish greeting";
      };
    };
  };
}
```

#### Ghostty Terminal Module
```nix
{ lib, config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    
    settings = {
      font-family = "JetBrains Mono";
      font-size = 14;
      theme = "auto";
      
      # Wayland integration
      window-theme = "dark";
      background-opacity = 0.95;
      
      # Key bindings
      keybind = [
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+t=new_tab"
        "ctrl+shift+w=close_tab"
      ];
    };
  };
}
```

### Application Integration
User application configuration:

#### 1Password Module
```nix
{ lib, config, pkgs, ... }:

{
  programs._1password = {
    enable = true;
    settings = {
      # Biometric unlock
      biometric_unlock = true;
      
      # Integration with system auth
      system_auth = true;
      
      # SSH agent
      ssh_agent = true;
    };
  };
  
  # 1Password CLI
  home.packages = with pkgs; [ _1password-cli ];
  
  # OpNix integration
  programs.opnix = {
    enable = true;
    vault = "pantherOS";
  };
}
```

#### Browser Module
```nix
{ lib, config, pkgs, ... }:

{
  programs.zen-browser = {
    enable = true;
    
    settings = {
      # Privacy settings
      privacy.trackingProtection = "strict";
      privacy.resistFingerprinting = true;
      
      # Development settings
      devtools.enabled = true;
      
      # Extensions
      extensions = {
        ublock-origin = true;
        dark-reader = true;
        react-devtools = true;
      };
    };
  };
}
```

### Development Tools
Development environment configuration:

#### Zed IDE Module
```nix
{ lib, config, pkgs, ... }:

{
  programs.zed = {
    enable = true;
    
    settings = {
      # Theme
      theme = "One Dark";
      
      # Font
      font_family = "JetBrains Mono";
      font_size = 14;
      
      # Features
      features = {
        copilot = true;
        git = true;
        diagnostics = true;
      };
      
      # Language configurations
      languages = {
        nix = {
          formatter = "alejandra";
          lsp_server = "nil";
        };
        
        typescript = {
          formatter = "prettier";
          lsp_server = "typescript-language-server";
        };
        
        python = {
          formatter = "black";
          lsp_server = "pylsp";
        };
      };
    };
  };
}
```

### Desktop Environment
Desktop and window manager configuration:

#### Niri Window Manager Module
```nix
{ lib, config, pkgs, ... }:

{
  programs.niri = {
    enable = true;
    
    settings = {
      # Input configuration
      input = {
        keyboard = {
          repeat-delay = 600;
          repeat-rate = 25;
          track-layout = "window";
        };
        
        touchpad = {
          tap = true;
          dwt = true;
          natural-scroll = true;
        };
        
        mouse = {
          accel-speed = 0.5;
        };
      };
      
      # Output configuration
      output = {
        "eDP-1" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 60.0;
          };
          position = { x = 0; y = 0; };
        };
      };
      
      # Layout configuration
      layout = {
        focus-ring = {
          width = 4;
          active-color = "#7fc8ff";
          inactive-color = "#505050";
        };
        
        border = {
          width = 2;
          active-color = "#333333";
          inactive-color = "#222222";
        };
        
        gaps = 8;
        
        preset-column-widths = [
          { proportion = 1.0; }
          { proportion = 0.5; }
          { proportion = 0.33; }
        ];
      };
      
      # Window rules
      window-rules = [
        {
          matches = [
            { app-id = "zen"; }
          ];
          default-column-width = { proportion = 0.7; };
        }
        
        {
          matches = [
            { app-id = "zed"; }
          ];
          default-column-width = { proportion = 0.8; };
        }
      ];
      
      # Key bindings
      keybind = [
        # System
        { mods = ["Super" "Shift"]; key = "Q"; action = "quit"; }
        { mods = ["Super"]; key = "Return"; action = "spawn"; command = "ghostty"; }
        
        # Window management
        { mods = ["Super"]; key = "J"; action = "focus-column-left"; }
        { mods = ["Super"]; key = "K"; action = "focus-column-right"; }
        { mods = ["Super" "Shift"]; key = "J"; action = "move-column-left"; }
        { mods = ["Super" "Shift"]; key = "K"; action = "move-column-right"; }
        
        # Layout
        { mods = ["Super"]; key = "D"; action = "toggle-column-width"; }
        { mods = ["Super"]; key = "F"; action = "toggle-fullscreen-column"; }
        
        # Workspaces
        { mods = ["Super"]; key = "1"; action = "focus-workspace"; args = ["1"]; }
        { mods = ["Super"]; key = "2"; action = "focus-workspace"; args = ["2"]; }
        { mods = ["Super"]; key = "3"; action = "focus-workspace"; args = ["3"]; }
        { mods = ["Super" "Shift"]; key = "1"; action = "move-column-to-workspace"; args = ["1"]; }
        { mods = ["Super" "Shift"]; key = "2"; action = "move-column-to-workspace"; args = ["2"]; }
        { mods = ["Super" "Shift"]; key = "3"; action = "move-column-to-workspace"; args = ["3"]; }
      ];
    };
  };
}
```

#### DankMaterialShell Integration Module
```nix
{ lib, config, pkgs, ... }:

{
  programs.dankmaterialshell = {
    enable = true;
    
    settings = {
      # Theme configuration
      theme = {
        mode = "auto"; # light, dark, auto
        primary = "#6200ee";
        secondary = "#03dac6";
        surface = "#ffffff";
        on-surface = "#000000";
      };
      
      # Components
      components = {
        dankgreeter = {
          enable = true;
          background = "blur";
          show-clock = true;
        };
        
        dankgop = {
          enable = true;
          update-interval = 1000; # ms
          show-gpu = true;
        };
        
        danksearch = {
          enable = true;
          fuzzy-search = true;
          show-icons = true;
        };
      };
      
      # Integration
      niri = {
        integration = true;
        keybindings = true;
      };
    };
  };
}
```

## AI Tools Integration

### Claude Code CLI Module
```nix
{ lib, config, pkgs, ... }:

{
  programs.claude-code = {
    enable = true;
    
    settings = {
      # API configuration
      api-key = "op:pantherOS/claude-api/key";
      
      # Model configuration
      model = "claude-3-5-sonnet-20241022";
      max-tokens = 8192;
      
      # Project configuration
      project-root = "~/dev";
      auto-detect-project = true;
      
      # Integration
      editor-integration = {
        zed = true;
        vscode = false;
      };
    };
  };
}
```

### OpenCode Integration Module
```nix
{ lib, config, pkgs, ... }:

{
  programs.opencode = {
    enable = true;
    
    settings = {
      # Global configuration
      auto-update = true;
      telemetry = false;
      
      # Agent configuration
      agents = {
        architect = {
          enabled = true;
          model = "claude-3-5-sonnet";
        };
        
        engineer = {
          enabled = true;
          model = "claude-3-5-sonnet";
        };
        
        librarian = {
          enabled = true;
          model = "claude-3-5-sonnet";
        };
        
        reviewer = {
          enabled = true;
          model = "claude-3-5-sonnet";
        };
      };
      
      # Tool configuration
      tools = {
        nixos-search = true;
        context7 = true;
        brave-search = true;
        puppeteer = true;
      };
    };
  };
  
  # OpenCode configuration files
  home.file.".config/opencode/opencode.jsonc" = {
    text = builtins.toJSON config.programs.opencode.settings;
  };
  
  # Feature directories
  home.file.".config/opencode/agent/.gitkeep".text = "";
  home.file.".config/opencode/tool/.gitkeep".text = "";
  home.file.".config/opencode/plugin/.gitkeep".text = "";
  home.file.".config/opencode/skills/.gitkeep".text = "";
  home.file.".config/opencode/command/.gitkeep".text = "";
}
```

### Development Environment Automation
```nix
{ lib, config, pkgs, ... }:

{
  # Auto-activate devShell in ~/dev
  programs.fish.functions.dev-activate = {
    body = ''
      # Function to activate devShell when entering ~/dev
      function __dev_activate --on-variable PWD
        if test "$PWD" = ~/dev
          if test -e shell.nix -o -e default.nix
            if not set -q IN_NIX_SHELL
              echo "🔧 Activating development environment..."
              nix develop
            end
          end
        end
      end
      
      # Initial activation
      __dev_activate
    '';
    description = "Auto-activate devShell in ~/dev directory";
  };
  
  # Development utilities
  home.packages = with pkgs; [
    # File management
    exa
    bat
    ripgrep
    fzf
    
    # Navigation
    zoxide
    
    # Git utilities
    gitui
    delta
    
    # Development tools
    nil # Nix LSP
    alejandra # Nix formatter
    
    # AI tools
    claude-code-cli
    opencode
  ];
  
  # Git configuration
  programs.git = {
    enable = true;
    
    userName = "hbohlen";
    userEmail = "hbohlen@example.com";
    
    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
    };
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      
      # Delta pager
      core.pager = "delta";
      delta.enable = true;
      delta.line-numbers = true;
      
      # Signing
      commit.gpgsign = true;
      gpg.format = "ssh";
      user.signingkey = "op:pantherOS/ssh-keys/desktopSSH/public";
    };
  };
}
```

## Workflow Integration

### Module Development Patterns
Follow consistent patterns for home-manager modules:

#### Basic Module Structure
```nix
{ lib, config, pkgs, ... }:

{
  options = {
    programs.myApp = {
      enable = lib.mkEnableOption "myApp";
      
      settings = lib.mkOption {
        type = lib.types.attrs;
        default = { };
        description = "Configuration for myApp";
      };
    };
  };

  config = lib.mkIf config.programs.myApp.enable {
    # Package installation
    home.packages = with pkgs; [ myApp ];
    
    # Configuration files
    home.file.".config/myApp/config.json" = {
      text = builtins.toJSON config.programs.myApp.settings;
    };
    
    # Environment variables
    home.sessionVariables = {
      MY_APP_CONFIG = "${config.xdg.configHome}/myApp/config.json";
    };
  };
}
```

#### Conditional Features
```nix
{ lib, config, pkgs, ... }:

{
  config = lib.mkIf config.programs.development.enable {
    # Base development tools
    home.packages = with pkgs; [
      git
      vim
    ];
    
    # Optional language support
    home.packages = with pkgs; [
    ] ++ lib.optionals config.programs.development.languages.node [
      nodejs
      npm
    ] ++ lib.optionals config.programs.development.languages.python [
      python3
      pip
    ] ++ lib.optionals config.programs.development.languages.rust [
      rustc
      cargo
    ];
  };
}
```

### Testing Procedures
Test home-manager configurations:

#### Build Testing
```bash
# Test home-manager build
home-manager build --flake .#hbohlen

# Test activation
home-manager switch --flake .#hbohlen

# Test specific host
home-manager build --flake .#hbohlen@yoga
```

#### Configuration Testing
```bash
# Test with different configurations
home-manager build --flake .#hbohlen --option extra-experimental-features nix-command

# Check configuration
home-manager check --flake .#hbohlen
```

### Cross-Host Consistency
Maintain consistency across workstations:

#### Shared Base Configuration
```nix
# home/hbohlen/common.nix
{ lib, config, pkgs, ... }:

{
  # Shared configuration for all hosts
  programs.fish.enable = true;
  programs.ghostty.enable = true;
  programs._1password.enable = true;
  
  # Shared packages
  home.packages = with pkgs; [
    git
    ripgrep
    fzf
  ];
}
```

#### Host-Specific Configuration
```nix
# home/hbohlen/yoga.nix
{ lib, config, pkgs, ... }:

{
  imports = [ ./common.nix ];
  
  # Yoga-specific configuration
  programs.fish.shellAliases = {
    battery = "upower -i /org/freedesktop/UPower/devices/battery_BAT0";
  };
  
  # Battery optimization tools
  home.packages = with pkgs; [
    tlp
    powertop
  ];
}
```

## Best Practices

### Configuration Organization
- **Modular Structure**: One concern per module
- **Shared Configuration**: Common settings in base modules
- **Host-Specific**: Separate files for host differences
- **Feature Flags**: Use options to enable/disable features

### Package Management
- **Declarative**: Define all packages in configuration
- **Version Pinning**: Pin critical package versions
- **Security**: Regular security updates
- **Optimization**: Remove unused packages

### Security Considerations
- **No Secrets**: Never commit secrets or API keys
- **1Password Integration**: Use OpNix for secrets
- **SSH Keys**: Manage through 1Password
- **File Permissions**: Proper permissions for config files

### Performance Optimization
- **Startup Optimization**: Minimize startup services
- **Resource Management**: Monitor resource usage
- **Cache Management**: Clean caches regularly
- **Profile Optimization**: Optimize for specific hardware

## Troubleshooting

### Common Issues

#### Home-Manager Build Fails
```bash
# Check for syntax errors
home-manager check --flake .#hbohlen

# Show build trace
home-manager build --flake .#hbohlen --show-trace

# Check for missing dependencies
nix-store --query --requisites $(home-manager build --flake .#hbohlen)
```

#### Configuration Not Applied
```bash
# Check activation
home-manager switch --flake .#hbohlen --verbose

# Check generation
home-manager generations

# Rollback if needed
home-manager switch --generation <number>
```

#### Package Conflicts
```bash
# Check for conflicts
nix-store --query --roots

# Clean up
nix-collect-garbage -d

# Rebuild
home-manager switch --flake .#hbohlen
```

### Debug Procedures

#### Enable Debug Logging
```bash
# Enable verbose output
home-manager switch --flake .#hbohlen --verbose --print-build-logs

# Check environment
home-manager exec --flake .#hbohlen env | grep -i home
```

#### Test Individual Modules
```bash
# Test specific module
home-manager build --flake .#hbohlen --option extra-experimental-features nix-command -I nixos-config=modules/home-manager/shell/fish.nix
```

## Related Documentation

- [Module Development Guide](../guides/module-development.md)
- [Architecture Overview](../architecture/overview.md)
- [Phase 2 Tasks](../todos/phase2-module-development.md)
- [AI Tools Integration](../README.md#ai-development-tools)

---

**Maintained by:** pantherOS User Experience Team
**Last Updated:** 2025-11-19
**Version:** 1.0
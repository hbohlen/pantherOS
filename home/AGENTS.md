# Agent Guidance for /home

## Purpose
Home-manager configurations for user-specific settings, applications, and dotfiles.

## Directory Structure

```
home/
└── hbohlen/              # Username-specific directory
    ├── home.nix          # Main home-manager config
    ├── configs/          # Config file templates
    │   ├── fish/
    │   ├── ghostty/
    │   ├── opencode/
    │   ├── zed/
    │   └── ...
    └── profiles/         # User-specific profiles
        ├── development/
        └── workstation/
```

## home.nix Structure

```nix
{ inputs, pkgs, ... }:

{
  # Import home-manager modules
  imports = [
    inputs.home-manager.nixosModules.home-manager

    # Your custom home-manager modules
    ../../modules/home-manager/shell/fish.nix
    ../../modules/home-manager/applications/zed.nix
    ../../modules/home-manager/development/languages/node.nix
    ../../modules/home-manager/desktop/niri.nix

    # User profiles
    ./profiles/development/development.nix
  ];

  # Home-manager configuration
  home.username = "hbohlen";
  home.homeDirectory = "/home/hbohlen";
  home.sessionName = "fish";  # or "bash", "zsh"

  # Nix configuration
  home.nix = {
    package = pkgs.nix;
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
      home-manager.flake = inputs.home-manager;
    };
    extraOptions = "experimental-features = nix-command flakes";
  };

  # Programs
  programs.home-manager.enable = true;

  # Packages
  home.packages = with pkgs; [
    # Additional packages not in modules
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "zed";
    VISUAL = "zed";
    TERM = "ghostty";
  ];

  # Shell configuration
  programs = {
    fish = {
      enable = true;
      # Fish config in modules/home-manager/shell/fish.nix
    };
  };

  # File management
  home.file = {
    # Config files managed directly
    ".config/opencode/opencode.jsonc".text = ''
      {
        "global": {
          "model": "claude-3-sonnet",
          "temperature": 0.7
        }
      }
    '';
  };

  # Services
  services = {
    # User services
  };

  # State version (must match system)
  home.stateVersion = "24.11";
}
```

## Config File Management

### Using Config Directories

For complex applications, use `configs/` directory:

```
home/hbohlen/
├── configs/
│   ├── fish/
│   │   └── config.fish
│   ├── ghostty/
│   │   └── config.toml
│   ├── opencode/
│   │   ├── opencode.jsonc
│   │   ├── agent/
│   │   ├── tool/
│   │   ├── plugin/
│   │   ├── skills/
│   │   └── command/
│   └── zed/
│       ├── settings.json
│       └── keymap.json
```

Then in `home.nix`:
```nix
home.file = {
  ".config/fish/config.fish".source = ./configs/fish/config.fish;
  ".config/ghostty/config.toml".source = ./configs/ghostty/config.toml;
  ".config/opencode".source = ./configs/opencode;
};
```

### Template Files

Use Nix templates for dynamic configs:

```nix
home.file.".config/myapp/config".text = lib.mkTemplate ./template.conf.tmpl {
  USER = config.home.username;
  HOSTNAME = config.networking.hostName;
  HOME_DIR = config.home.homeDirectory;
};
```

## OpenCode Configuration

**Critical**: OpenCode has specific directory structure:

```nix
home.file = {
  # Main config
  ".config/opencode/opencode.jsonc".text = ''
    {
      "global": {
        "model": "claude-3-sonnet",
        "temperature": 0.7,
        "theme": "catppuccin"
      },
      "ui": {
        "mode": "pane"
      }
    }
  '';

  # Feature directories (can be empty initially)
  ".config/opencode/agent".source = ./configs/opencode/agent;
  ".config/opencode/tool".source = ./configs/opencode/tool;
  ".config/opencode/plugin".source = ./configs/opencode/plugin;
  ".config/opencode/skills".source = ./configs/opencode/skills;
  ".config/opencode/command".source = ./configs/opencode/command;
};
```

## Fish Shell Configuration

Fish configuration is in `modules/home-manager/shell/fish.nix`:

```nix
{ config, lib, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      # System-wide fish init
      set -gx PATH $PATH $HOME/.local/bin $HOME/.cargo/bin
    '';

    interactiveInit = ''
      # Fish-specific initialization
      if status is-interactive
        # Commands to run in interactive shells only
        zoxide init fish | source
        starship init fish | source
      end
    '';

    plugins = [
      # Plugins from nixpkgs
      {
        name = "z";
        src = pkgs.fishPlugins.z;
      }
      {
        name = "nix-env";
        src = pkgs.fishPlugins.nix-env;
      }
    ];

    functions = {
      my-custom-function = ''
        echo "Custom function"
      '';
    };

    abbreviations = {
      ll = "ls -lah";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline -10";
    };

    promptInit = ''
      # Custom prompt if not using starship
    '';
  };
}
```

## Ghostty Configuration

```nix
programs.ghostty = {
  enable = true;

  config = {
    theme = "catppuccin";
    font-family = "JetBrains Mono";
    font-size = 14;

    shell-integration = "fish";

    keybinds = {
      "ctrl+shift+p" = "command_palette";
      "ctrl+`" = "toggle_split";
    };
  };
};
```

## Zed Configuration

```nix
programs.zed = {
  enable = true;

  settings = {
    theme = "Catppuccin Mocha";
    font_size = 14;
    font_family = "JetBrains Mono";
    line_height = 1.5;

    ai = {
      enabled = true;
      provider = "openai";
    };

    rust = {
      formatting = "rustfmt";
    };
  };

  extensions = [
    "nix"
    "rust"
    "python"
    "typescript"
    "tailwindcss"
  ];

  keymap = {
    "ctrl-p" = "command_palette";
    "ctrl+shift+f" = "project_search";
    "ctrl+/" = "toggle_comment";
  };
};
```

## Dev Environment Auto-activation

### Using direnv

In `home.nix`:
```nix
programs.direnv = {
  enable = true;
  enableNixDirenvIntegration = true;
  nix.envName = ".envrc";
};
```

Then in `~/dev`, create `.envrc`:
```
use_nix
```

This automatically activates the Nix environment when entering `~/dev`.

### Using atuin

```nix
programs.atuin = {
  enable = true;
  enableBashIntegration = false;
  enableFishIntegration = true;
  history = {
    databasePath = "${config.home.homeDirectory}/.local/share/atuin/history.db";
  };
};
```

## Profiles

User-specific profiles for different use cases:

### development.nix
```nix
{ pkgs, ... }:

{
  imports = [
    ../../../../modules/home-manager/development/languages/node.nix
    ../../../../modules/home-manager/development/languages/python.nix
    ../../../../modules/home-manager/development/languages/go.nix
    ../../../../modules/home-manager/development/languages/rust.nix
    ../../../../modules/home-manager/development/ai-tools.nix
  ];

  # Dev-specific settings
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
  };

  home.packages = with pkgs; [
    # Dev tools
    git
    gh
    just
    fd
    ripgrep
  ];
}
```

### workstation.nix
```nix
{ ... }:

{
  imports = [
    ../../../../modules/home-manager/desktop/niri.nix
    ../../../../modules/home-manager/applications/zed.nix
    ../../../../modules/home-manager/applications/zen-browser.nix
  ];

  programs.fish.shellInit = ''
    # Workstation-specific init
  '';
}
```

## Environment Variables

Set in `home.nix`:

```nix
home.sessionVariables = {
  # Editors
  EDITOR = "zed";
  VISUAL = "zed";

  # Terminal
  TERM = "ghostty";

  # Development
  CARGO_HOME = "${config.home.homeDirectory}/.cargo";
  GOPATH = "${config.home.homeDirectory}/go";
  NODE_ENV = "development";

  # Paths
  PATH = "${config.home.homeDirectory}/.local/bin:${config.home.homeDirectory}/.cargo/bin";

  # App-specific
  ZED_THEME = "catppuccin";
};
```

## Services

User-level systemd services:

```nix
services = {
  atuin-daemon = {
    enable = true;
  };

  # Custom user service
  my-service = {
    enable = true;
    Package = pkgs.my-package;
    ServiceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.my-package}/bin/my-service";
    };
  };
};
```

## Testing Home Configuration

### Build (Safe)
```bash
home-manager build
```

### Switch (Live)
```bash
home-manager switch
```

### Rollback
```bash
home-manager generations
home-manager switch --profile 'home-manager-file' <generation-number>
```

## Common Patterns

### Package Installation
```nix
home.packages = with pkgs; [
  # System packages available to user
  vim
  htop
  tree
];

# Or per-profile
home.packages = pkgs.lib.mkIf config.profiles.development.enable (with pkgs; [
  # Development packages
]);
```

### Symlink Existing Config
```nix
home.file.".config/exists".source = /existing/config;
```

### Conditional Configuration
```nix
home.file.".config/app/config" = lib.mkIf config.services.app.enable {
  source = ./configs/app;
  recursive = true;
};
```

### Multiple Config Files
```nix
home.file = {
  ".config/app/conf1".source = ./configs/app/conf1;
  ".config/app/conf2".source = ./configs/app/conf2;
  ".config/app/conf3".source = ./configs/app/conf3;
};
```

## Directory Permissions

```nix
home.file = {
  ".ssh/id_rsa".source = ./configs/ssh/id_rsa;
  ".ssh/id_rsa.pub".source = ./configs/ssh/id_rsa.pub;
};

home.activation = {
  setupSSH = lib.mkAfter ''
    chmod 600 ~/.ssh/id_rsa
    chmod 644 ~/.ssh/id_rsa.pub
    ssh-add
  '';
};
```

## Activation Scripts

For custom setup logic:

```nix
home.activation = {
  mySetup = ''
    echo "Running custom setup"
    mkdir -p ~/.local/share/my-app
  '';

  after = "linkConfig";  # Run after file linking
};
```

## Documentation

Each user configuration section should be documented in:
- `docs/modules/home-manager/` - Module documentation
- `docs/users/hbohlen/` - User-specific documentation

## Integration with System Config

Home-manager config is invoked from `hosts/<host>/default.nix`:

```nix
home-manager.users.hbohlen = { pkgs, ... }: {
  imports = [
    ../../../modules/home-manager/shell/fish.nix
    # ... other imports
  ];

  # Config
  home.username = "hbohlen";
  # ...
};
```

## Success Criteria

Home configuration is complete when:
- [ ] Builds successfully with `home-manager build`
- [ ] All dotfiles in correct locations
- [ ] Applications configured correctly
- [ ] Shell works properly
- [ ] Dev environment auto-activates in ~/dev
- [ ] Fish shell fully configured
- [ ] Ghostty terminal working
- [ ] Zed IDE configured
- [ ] AI tools integrated
- [ ] OpenCode properly configured
- [ ] No hardcoded secrets
- [ ] Documentation complete

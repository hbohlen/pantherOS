# Agent Guidance for /modules/home-manager

## Purpose
User-level modules managed by home-manager. These configure the user environment, applications, and personal configuration files.

## Module Categories

### shell/
Terminal, shell, and command-line tools.

**Key Modules**:
- `fish.nix` - Fish shell configuration
  - Completions
  - Abbreviations
  - Key bindings
  - Functions
- `ghostty.nix` - Terminal emulator config
  - Theme
  - Fonts
  - Keybindings
  - Shell integration
- `fzf.nix` - Fuzzy finder
- `zoxide.nix` - Smart directory jumper

### applications/
Desktop and terminal applications.

**Key Modules**:
- `zed.nix` - Zed IDE configuration
  - Extensions
  - Settings
  - Keybindings
- `zen-browser.nix` - Privacy browser setup
  - User.js preferences
  - Extensions
  - Search engines
- `onepassword.nix` - 1Password integration
  - CLI configuration
  - GUI settings
  - SSH agent integration
- `ghostty.nix` - Terminal configuration

### development/
Development environment and tools.

**Language Modules**:
- `node.nix` - Node.js environment
  - Package manager configuration
  - npm compatibility (NixOS special handling)
  - Global packages
  - LSP servers
- `python.nix` - Python environment
  - pip/pipx configuration
  - Virtual environment handling
  - LSP servers
  - Formatters (black, yapf)
- `go.nix` - Go environment
  - Go toolchain
  - GOPATH handling
  - LSP servers
  - Formatters
- `rust.nix` - Rust environment
  - rustup/cargo
  - rust-analyzer
  - Formatters (rustfmt)
  - Clippy integration

**AI Tool Modules**:
- `claude-code.nix` - Claude Code CLI
  - Configuration file
  - API settings
  - Model preferences
- `opencode.nix` - OpenCode.ai CLI
  - `opencode.jsonc` global config
  - Agent configurations
  - Tool configurations
  - Plugin setups
  - Skills and commands
- `qwen-code.nix` - Qwen Code CLI
- `gemini-cli.nix` - Gemini CLI
- `nix-ai-tools.nix` - Combined AI tools

**General Dev Tools**:
- `lsp.nix` - Language Server Protocol
  - nixd for Nix
  - pyright for Python
  - typescript-language-server for JS/TS
  - gopls for Go
  - rust-analyzer for Rust
- `formatters.nix` - Code formatters
  - alejandra for Nix
  - black for Python
  - prettier for JS/TS
  - gofmt for Go
  - rustfmt for Rust
- `git.nix` - Git configuration
  - Aliases
  - Settings
  - Hooks
- `tmux.nix` - Terminal multiplexer

### desktop/
Desktop environment and window manager.

**Key Modules**:
- `niri.nix` - Niri window manager
  - Keybindings
  - Layouts
  - Rules
  - Workspaces
- `dank-material-shell.nix` - Material Design UI
  - Theme
  - Components
  - DankGreeter integration
  - DankGop monitoring
  - DankSearch launcher
  - Niri integration
- `wallpapers.nix` - Dynamic wallpapers
- `themes.nix` - Color schemes and themes

## Module Structure Example

### fish.nix
```nix
{ config, lib, pkgs, ... }:

{
  programs.fish = {
    enable = true;

    shellInit = ''
      # Fish initialization
    '';

    plugins = [
      {
        name = "fish-plug";
        src = pkgs.fishPlugins.fish-plug;
      }
    ];

    functions = {
      my-function = "body";
    };

    abbreviations = {
      ll = "ls -la";
      ga = "git add";
    };
  };
}
```

### zed.nix
```nix
{ config, lib, pkgs, ... }:

{
  programs.zed = {
    enable = true;

    settings = {
      theme = "catppuccin";
      font_size = 14;
      # Additional settings
    };

    extensions = [
      "nix"
      "rust"
      "python"
    ];

    keybindings = {
      "ctrl-p" = "palette::Toggle";
      # Additional keybindings
    };
  };
}
```

## Configuration File Management

Home-manager excels at managing dotfiles and config files.

### Dotfile Patterns

**Single file**:
```nix
home.file.".config/myapp/config".text = ''
  key=value
'';
```

**From source**:
```nix
home.file.".config/myapp/config".source = ./myapp-config;
```

**Template with variables**:
```nix
home.file.".config/myapp/config".text = lib.mkTemplate ./template.conf.tmpl {
    USER = config.home.username;
    HOSTNAME = config.networking.hostName;
};
```

### Config Directories

For complex configs:
```nix
home.file.".config/opencode" = {
  source = ./configs/opencode;
  recursive = true;
};
```

## OpenCode Configuration

OpenCode requires special handling:

```nix
# Main config file
home.file.".config/opencode/opencode.jsonc".text = ''
  {
    "global": {
      "model": "claude-3-sonnet",
      "temperature": 0.7
    }
  }
'';

# Feature directories (empty for now, ready for customization)
home.file.".config/opencode/agent" = {
  source = ./configs/opencode/agent;
  recursive = true;
};

home.file.".config/opencode/tool".text = "";
home.file.".config/opencode/plugin".text = "";
home.file.".config/opencode/skills".text = "";
home.file.".config/opencode/command".text = "";
```

## autoActivate

Configure auto-activation in ~/dev:
```nix
programs.direnv = {
  enable = true;
  enableNixDirenvIntegration = true;
};

# Or use shell.nix in ~/dev
home.file.".config/direnvrc".text = ''
  use_nix() {
    watch_file flake.nix
    watch_file flake.lock
    eval "$(nix print-dev-env --profile ./dev-profile)"
  }
'';
```

## Testing Home-Manager Modules

```bash
# Build home-manager configuration
home-manager build

# Switch home-manager configuration
home-manager switch
```

## Common Patterns

### Package Installation
```nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    package1
    package2
  ];
}
```

### Service Activation
```nix
{ config, lib, ... }:

{
  services.lorri = {
    enable = true;
  };
}
```

### Environment Variables
```nix
{ config, ... }:

{
  home.sessionVariables = {
    EDITOR = "zed";
    VISUAL = "zed";
  };
}
```

### Path Management
```nix
{ config, ... }:

{
  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.cargo/bin"
  ];
}
```

## Documentation Requirements

Each home-manager module needs:
- Purpose and scope
- Configuration options
- Example usage
- File locations managed
- Integration notes

Save in `docs/modules/home-manager/<category>/<module-name>.md`

## Integration with NixOS Modules

Some features need both system and user config:

### Example: 1Password
**nixos module** (system):
```nix
{ ... }:

{
  services.opnix = {
    enable = true;
    serviceAccount = "pantherOS";
  };
}
```

**home-manager module** (user):
```nix
{ ... }:

{
  programs.onepassword = {
    enable = true;
    enableGui = true;
  };
}
```

## Auto-activation in ~/dev

Configure dev shell activation:
```nix
{ config, ... }:

{
  programs.direnv = {
    enable = true;
    enableNixDirenvIntegration = true;
    nix.envName = ".envrc";
  };
}
```

Then add .envrc to ~/dev:
```
use_nix
```

## Package vs Program

- **home.packages** - System packages available to user
- **programs.*.enable** - Program-specific configuration
- Use programs.* when the app has rich configuration options
- Use packages for simple installations

## Best Practices

1. **Separate config from logic** - Keep Nix config separate from template files
2. **Use recursive for directories** - Easier to maintain complex configs
3. **Document managed files** - List all files managed by the module
4. **Test with different hosts** - Ensure reusability
5. **Follow naming** - programs.feature not feature.config
6. **Leverage templates** - For complex config files
7. **Group related settings** - Keep related configs together

## Testing Checklist

- [ ] Module builds successfully
- [ ] Creates expected config files
- [ ] Files have correct permissions
- [ ] Backup existing configs if needed
- [ ] Test on multiple hosts
- [ ] Document all managed files

## Success Criteria

Home-manager module is complete when:
- [ ] Packages installed correctly
- [ ] Config files created in right locations
- [ ] Settings applied as expected
- [ ] No conflicts with system config
- [ ] Works across different hosts
- [ ] Documentation complete

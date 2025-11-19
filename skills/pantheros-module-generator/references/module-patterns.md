# Module Development Patterns

## Module Structure

### NixOS Module Format

NixOS modules follow this standard format:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.my-module;
in
{
  # Module options
  options.services.my-module = {
    enable = mkEnableOption "my-module";

    package = mkOption {
      type = types.package;
      default = pkgs.my-package;
      description = "Package to use";
    };

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Configuration options";
    };
  };

  # Module implementation
  config = mkIf cfg.enable {
    # System package installation
    environment.systemPackages = [ cfg.package ];

    # Service definition (optional)
    systemd.services.my-module = {
      description = "My Module Service";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/my-module";
      };
    };

    # Configuration files
    environment.etc."my-module/config".source =
      pkgs.writeText "my-module-config" (toJSON cfg.settings);

    # Imports
    imports = [ ];
  };
}
```

### Home-Manager Module Format

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.my-program;
in
{
  options.programs.my-program = {
    enable = mkEnableOption "my-program";

    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Program configuration";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages to install";
    };
  };

  config = mkIf cfg.enable {
    # Home package installation
    home.packages = [
      cfg.package
    ] ++ cfg.extraPackages;

    # Program configuration file
    xdg.configFile."my-program/config".text = toJSON cfg.settings;

    # Shell configuration
    programs.bash.initExtra = ''
      export MY_PROGRAM_CONFIG="${config.xdg.configHome}/my-program/config"
    '';

    imports = [ ];
  };
}
```

## Common Patterns

### Service Pattern

For services that run in the background:

```nix
options.services.my-service = {
  enable = mkEnableOption "my-service";

  port = mkOption {
    type = types.int;
    default = 8080;
    description = "Port to listen on";
  };
};

config = mkIf cfg.enable {
  systemd.services.my-service = {
    description = "My Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${cfg.package}/bin/my-service --port ${toString cfg.port}";
      Restart = "on-failure";
      User = "my-service";
      Group = "my-service";
    };

    # Create user and group
    preStart = ''
      if ! id my-service >/dev/null 2>&1; then
        useradd -r -s ${config.security.wrapperDir}/nixos-sandbox my-service
      fi
    '';
  };

  # Open firewall
  networking.firewall.allowedPorts = [ cfg.port ];

  # Create log directory
  systemd.tmpfiles.rules = [
    "d /var/log/my-service 0755 my-service my-service -"
  ];
};
```

### Configuration File Pattern

For programs that read configuration files:

```nix
options.services.my-app.settings = mkOption {
  type = types.attrs;
  default = { };
  description = "Application settings";
};

config = mkIf cfg.enable {
  environment.etc."my-app/config.json".source =
    pkgs.writeText "my-app-config.json" (toJSON cfg.settings);

  environment.sessionVariables = {
    MY_APP_CONFIG = "/etc/my-app/config.json";
  };
};
```

### Package Installation Pattern

For packages that need configuration:

```nix
options.programs.my-tool = {
  enable = mkEnableOption "my-tool";

  package = mkOption {
    type = types.package;
    default = pkgs.my-tool;
    description = "Tool package";
  };

  settings = mkOption {
    type = types.attrs;
    default = { };
    example = { theme = "dark"; };
  };
};

config = mkIf cfg.enable {
  environment.systemPackages = [ cfg.package ];

  # Add config to home directory
  home.file.".config/my-tool/config".text = toJSON cfg.settings;
};
```

## Option Types

### Common Types

```nix
# Boolean
enable = mkEnableOption "my-module";  # Recommended

# String
message = mkOption {
  type = types.str;
  default = "Hello";
  description = "Message to display";
};

# Integer
port = mkOption {
  type = types.int;
  default = 8080;
  description = "Port number";
};

# List
domains = mkOption {
  type = types.listOf types.str;
  default = [ "example.com" ];
  description = "List of domains";
};

# Attribute Set (Dictionary)
settings = mkOption {
  type = types.attrs;
  default = { };
  description = "Configuration options";
};

# Package
package = mkOption {
  type = types.package;
  default = pkgs.my-package;
  description = "Package to use";
};
```

### Advanced Types

```nix
# One Of
logLevel = mkOption {
  type = types.enum [ "debug" "info" "warn" "error" ];
  default = "info";
  description = "Log level";
};

# Submodule
databases = mkOption {
  type = types.listOf (types.submodule {
    options = {
      name = mkOption { type = types.str; };
      port = mkOption { type = types.int; };
    };
  });
  default = [ ];
  description = "Database configurations";
};

# Path
configFile = mkOption {
  type = types.path;
  description = "Path to configuration file";
};
```

## Validation Patterns

### Basic Validation

```nix
# Validate port range
port = mkOption {
  type = types.int;
  default = 8080;
  description = "Port to use";
};

# Custom validator
enable = mkEnableOption "my-service"
  // {
    validator = check: if check && cfg.port < 1024
      then throw "Port must be >= 1024 for non-root users"
      else true;
  };
```

### Option Description

```nix
options.services.my-module = {
  message = mkOption {
    type = types.str;
    default = "Hello World";
    description = ''
      Message to display by the service.
      This message will be shown when the service starts.
    '';
    example = "Welcome to my service!";
  };
};
```

## Imports and Dependencies

### Declaring Dependencies

```nix
config = mkIf cfg.enable {
  imports = [
    # Import dependencies
    ./dependency-module.nix
  ];

  # Use dependencies
  services.dependency-module.someOption = true;
};
```

### Optional Imports

```nix
config = mkIf cfg.enable {
  imports = mkIf cfg.enableDependency [
    ./optional-module.nix
  ];
};
```

## Module Composition

### Combining Modules

```nix
# main-module.nix
{ config, lib, ... }:

let
  cfg = config.services.main-module;
in
{
  options.services.main-module = {
    enable = mkEnableOption "main-module";
    useComponent = mkOption {
      type = types.bool;
      default = true;
      description = "Use component module";
    };
  };

  config = mkIf cfg.enable {
    imports = [
      ./component-module.nix
    ];

    services.component-module.enable = cfg.useComponent;
  };
}
```

### Profile Modules

```nix
# profiles/desktop.nix
{
  imports = [
    # Desktop-specific modules
    ./modules/nixos/desktop
    ./modules/home-manager/applications
  ];

  # Desktop configuration
  services.desktop-manager.enable = true;
}
```

## Testing Modules

### Syntax Check

```bash
# Check module syntax
nix-instantiate --eval modules/nixos/services/my-service.nix

# Check with sample config
nix-instantiate --eval --arg config '{
  services.my-service.enable = true;
  services.my-service.settings = {};
}' modules/nixos/services/my-service.nix
```

### Build Test

```bash
# Test build for specific host
nixos-rebuild build .#yoga

# Test in dry-run
nixos-rebuild dry-activate --flake .#yoga
```

### Unit Tests

```nix
# tests/my-module.nix
{ pkgs, ... }:

{
  test = pkgs.runCommand "test-my-module" { } ''
    ${pkgs.nix}/bin/nix-instantiate --eval \
      --arg config '{
        services.my-module.enable = true;
        services.my-module.settings = {};
      }' \
      ${./modules/nixos/services/my-module.nix} > $out
    touch $out
  '';
}
```

## Best Practices

1. **Use mkEnableOption** - Standard way to create enable options
2. **Provide defaults** - Always set reasonable defaults
3. **Document options** - Write clear descriptions and examples
4. **Validate input** - Check for invalid configurations
5. **Keep modules small** - One module, one responsibility
6. **Use imports** - Reuse common functionality
7. **Test thoroughly** - Verify builds and configurations

## Troubleshooting

### Common Errors

**"assertion failed"**
- Check option validation logic
- Ensure all required options are provided

**"infinite recursion"**
- Avoid circular imports
- Check option references

**"value is not a boolean"**
- Provide default values
- Check option types

**"module not found"**
- Verify import path
- Check file permissions

### Debugging

```bash
# Show module options
nixos-option services.my-module

# Evaluate configuration
nix-instantiate --eval configuration.nix

# Check system configuration
nixos-rebuild build --show-trace .#yoga
```

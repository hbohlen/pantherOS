---
name: pantheros-module-generator
description: Automates Phase 2 module scaffolding for pantherOS development. Generates complete NixOS and home-manager modules with proper structure, options, documentation, examples, and validation tools. Essential for creating reusable, maintainable configurations. Use when: (1) Creating a new NixOS module (system-level service/package), (2) Creating a new home-manager module (user-level configuration), (3) Following pantherOS modular architecture, (4) Generating module documentation automatically.
---

# PantherOS Module Generator

## Overview

This skill automates the Phase 2 module development process for pantherOS, generating complete NixOS and home-manager modules with proper structure, comprehensive documentation, examples, and validation tools. It follows pantherOS conventions and creates production-ready modules.

**What it does:**
- Generates NixOS and home-manager modules with standard structure
- Creates module options with proper types and validation
- Generates comprehensive Markdown documentation
- Provides example configurations
- Includes validation and testing scripts
- Updates module index files automatically

## Quick Start

### Basic Usage

```bash
# Generate a NixOS service module
./scripts/generate-module.sh nixos services nginx

# Generate a home-manager application module
./scripts/generate-module.sh home-manager applications zathura

# Generate a hardware module
./scripts/generate-module.sh nixos hardware nvidia
```

### Command Arguments

```
Usage: ./generate-module.sh <type> <category> <name>

Types:
  nixos           - System-level modules (NixOS)
  home-manager    - User-level modules (home-manager)

Categories for nixos:
  core            - Essential system services
  services        - Network services, databases
  security        - Security modules
  hardware        - Hardware-specific configs

Categories for home-manager:
  shell           - Shell and terminal tools
  applications    - User applications
  development     - Dev tools and languages
  desktop         - Desktop environment
```

### Example Workflow

```bash
# 1. Generate module
./scripts/generate-module.sh nixos services my-service

# 2. Edit the generated module file
vim modules/nixos/services/my-service.nix

# 3. Add to configuration
cat >> hosts/yoga/configuration.nix << 'EOF'
  imports = [
    ./modules/nixos/services/my-service.nix
  ];

  services.my-service.enable = true;
EOF

# 4. Test build
nixos-rebuild build .#yoga

# 5. Validate module
./modules/nixos/services/my-service/validate.sh modules/nixos/services/my-service.nix
```

## Module Structure

Generated modules follow this standard structure:

```
modules/
├── nixos/
│   └── services/
│       └── my-service/
│           ├── my-service.nix        # Main module file
│           ├── examples.nix          # Usage examples
│           ├── validate.sh           # Validation script
│           └── README.md             # Module list
└── home-manager/
    └── applications/
        └── zathura/
            ├── zathura.nix           # Main module file
            ├── examples.nix          # Usage examples
            ├── validate.sh           # Validation script
            └── README.md             # Module list
```

### Module File Structure

Generated module file includes:

1. **Options Definition** - Module interface
   ```nix
   options.services.my-service = {
     enable = mkEnableOption "my-service";
     port = mkOption { type = types.int; default = 8080; };
     settings = mkOption { type = types.attrs; default = { }; };
   };
   ```

2. **Implementation** - Module behavior
   ```nix
   config = mkIf cfg.enable {
     environment.systemPackages = [ cfg.package ];
     systemd.services.my-service = { ... };
   };
   ```

3. **Documentation** - Inline help
   ```nix
   description = ''
     Port for my-service to listen on.
   '';
   ```

### Documentation Structure

Generated documentation (`docs/modules/.../*.md`) includes:

- Overview and purpose
- Basic usage examples
- Configuration options reference
- Integration instructions
- Testing procedures
- Troubleshooting guide
- Related modules list

## Common Module Types

### NixOS Service Module

For background services, daemons, APIs:

```bash
./scripts/generate-module.sh nixos services my-api
```

**Generated features:**
- Systemd service definition
- Package installation
- Configuration file generation
- Firewall integration
- User/group creation

**Customize for:**
- Web servers (nginx, apache)
- Databases (postgresql, redis)
- APIs and microservices

### NixOS Hardware Module

For hardware-specific configuration:

```bash
./scripts/generate-module.sh nixos hardware nvidia
```

**Generated features:**
- Hardware detection
- Driver installation
- Device configuration
- Performance tuning

**Customize for:**
- GPU drivers (NVIDIA, AMD)
- Audio configuration
- Network cards

### Home-Manager Application Module

For user-level applications:

```bash
./scripts/generate-module.sh home-manager applications zathura
```

**Generated features:**
- Package installation
- Configuration file creation
- Desktop integration
- Shell integration

**Customize for:**
- Terminal applications
- GUI applications
- Development tools

### Home-Manager Shell Module

For shell and terminal tools:

```bash
./scripts/generate-module.sh home-manager shell fish
```

**Generated features:**
- Shell configuration
- Plugin management
- Aliases and functions
- Theme integration

## Module Categories

### NixOS Categories

**Core** - Essential system functionality
- Boot configuration
- Network setup
- System services
- User management

**Services** - Network and system services
- Web servers (nginx, caddy)
- Databases (postgresql, mysql, redis)
- Application servers
- Monitoring tools

**Security** - Security modules
- Firewall (iptables, nftables)
- AppArmor/SELinux
- SSH configuration
- Certificate management

**Hardware** - Hardware-specific modules
- Graphics drivers
- Audio configuration
- Storage controllers
- Network adapters

### Home-Manager Categories

**Shell** - Shell configuration
- Fish shell setup
- Terminal emulators
- Prompt configuration
- Shell plugins

**Applications** - User applications
- Document viewers (zathura)
- Media players
- Image viewers
- File managers

**Development** - Development tools
- Programming languages
- IDEs and editors
- Build tools
- Debugging tools

**Desktop** - Desktop environment
- Window managers (niri)
- Wallpapers
- Theming
- Desktop utilities

## Customization Guide

### Editing the Module

After generation, customize `modules/.../my-module.nix`:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.my-module;
in
{
  options.services.my-module = {
    # Add custom options here
    customOption = mkOption {
      type = types.str;
      default = "default-value";
      description = "Custom configuration option";
    };
  };

  config = mkIf cfg.enable {
    # Add custom implementation here
    customImplementation = ''
      # Custom configuration logic
    '';

    # Override generated content
    systemd.services.my-module.serviceConfig = {
      ExecStart = "${cfg.package}/bin/my-module --custom ${cfg.customOption}";
    };
  };
}
```

### Adding Dependencies

```nix
config = mkIf cfg.enable {
  imports = [
    # Add dependency modules
    ./dependency-module.nix
    <nixpkgs/nixos/modules/services/networking/nginx.nix>
  ];

  # Use dependencies
  services.nginx.enable = true;
};
```

### Validating Configuration

```bash
# Syntax check
nix-instantiate --eval modules/nixos/services/my-service.nix

# Test with sample config
nix-instantiate --eval --arg config '{
  services.my-service.enable = true;
  services.my-service.settings = {};
}' modules/nixos/services/my-service.nix

# Build test
nixos-rebuild build .#yoga
```

## Advanced Usage

### Custom Templates

Use predefined templates:

```bash
# Service template (systemd + config files)
cp assets/templates/service.nix modules/nixos/services/my-service/my-service.nix

# Package template (just package installation)
cp assets/templates/package.nix modules/nixos/services/my-tool/my-tool.nix

# Home-manager template
cp assets/templates/home-manager.nix modules/home-manager/applications/my-app/my-app.nix
```

### Module Validation

Use the generated validation script:

```bash
# Validate module structure
./modules/nixos/services/my-service/validate.sh modules/nixos/services/my-service.nix

# Output:
# ✓ Checking syntax...
# ✓ Checking options...
# ✓ Checking module structure...
# ✓ Module validation passed!
```

### Cross-Module Dependencies

Reference other modules:

```nix
# In your module
{ config, lib, ... }:

let
  cfg = config.services.my-service;
  nginxCfg = config.services.nginx;
in
{
  config = mkIf cfg.enable {
    # Configure nginx as reverse proxy
    services.nginx = mkIf (cfg.reverseProxy && nginxCfg.enable) {
      virtualHosts."my-service.local" = {
        locations."/".proxyPass = "http://127.0.0.1:${toString cfg.port}";
      };
    };
  };
}
```

## Testing Modules

### Build Testing

```bash
# Test build for each host
nixos-rebuild build .#yoga
nixos-rebuild build .#zephyrus
nixos-rebuild build .#hetzner-vps
nixos-rebuild build .#ovh-vps
```

### Dry Run Testing

```bash
# Test without applying
nixos-rebuild dry-activate --flake .#yoga
```

### Unit Testing

Create test file:

```nix
# tests/my-service.nix
{ pkgs, ... }:

{
  test = pkgs.runCommand "test-my-service" { } ''
    ${pkgs.nix}/bin/nix-instantiate --eval \
      --arg config '{
        services.my-service.enable = true;
        services.my-service.settings = { port = 8080; };
      }' \
      ${./modules/nixos/services/my-service.nix} > $out
    ${pkgs.jq}/bin/jq '.config' $out > /dev/null
    touch $out
  '';
}
```

Run test:
```bash
nix-build tests/my-service.nix
```

### Integration Testing

Test with profile:

```bash
# Build with profile
nixos-rebuild build .#yoga --include ' profils/desktop'
```

## Best Practices

### Module Design

1. **One Responsibility** - Each module should have one clear purpose
2. **Composability** - Design modules to work together
3. **Sensible Defaults** - Provide reasonable default configurations
4. **Documentation** - Always document options and usage
5. **Validation** - Validate inputs and provide helpful errors

### Option Design

```nix
# Good: Clear, composable options
options.services.my-service = {
  enable = mkEnableOption "my-service";

  port = mkOption {
    type = types.port;
    default = 8080;
    description = "Port to listen on";
  };

  settings = mkOption {
    type = types.attrs;
    default = { };
    description = "Service settings";
  };
};

# Avoid: Overly specific options
# options.services.my-service.port8080 = mkEnableOption...
```

### Error Handling

```nix
# Validate dependencies
config = mkIf cfg.enable {
  assertions = [
    { assertion = config.services.nginx.enable;
      message = "my-service requires nginx to be enabled"; }
  ];
};
```

## Common Patterns

### Service Pattern

```nix
config = mkIf cfg.enable {
  systemd.services.my-service = {
    description = "My Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      ExecStart = "${cfg.package}/bin/my-service";
      Restart = "on-failure";
      User = "my-service";
    };

    preStart = ''
      if ! id my-service >/dev/null 2>&1; then
        useradd -r my-service
      fi
    '';
  };
};
```

### Configuration Pattern

```nix
config = mkIf cfg.enable {
  environment.etc."my-service/config".source =
    pkgs.writeText "my-service-config" (toJSON cfg.settings);

  environment.sessionVariables = {
    MY_SERVICE_CONFIG = "/etc/my-service/config";
  };
};
```

### Package Pattern

```nix
config = mkIf cfg.enable {
  environment.systemPackages = [
    cfg.package
  ] ++ cfg.extraPackages;
};
```

## Troubleshooting

### Module Not Found

**Error:** `error: module not found`

**Solutions:**
- Check import path is correct
- Verify file exists and is readable
- Check syntax with `nix-instantiate --eval`

### Infinite Recursion

**Error:** `infinite recursion encountered`

**Solutions:**
- Check for circular imports
- Avoid referencing config in options
- Use `mkIf` for conditional logic

### Type Errors

**Error:** `value is not a bool`

**Solutions:**
- Provide default values
- Check option types
- Use proper Nix types (`types.bool`, not `boolean`)

### Service Won't Start

**Error:** `service failed to start`

**Solutions:**
```bash
# Check service status
systemctl status my-service.service

# View logs
journalctl -u my-service.service -n 50

# Check configuration
cat /etc/my-service/config

# Test executable manually
/my-service/bin/my-service --help
```

### Configuration Not Applied

**Error:** Changes don't take effect

**Solutions:**
```bash
# Rebuild system
nixos-rebuild switch --flake .#yoga

# Check module is imported
nixos-option services.my-service

# Verify option value
nixos-option services.my-service.settings
```

## Integration with Other Skills

- **Hardware Scanner** - Use hardware info to determine required modules
- **Host Manager** - Organize modules by host type
- **Deployment Orchestrator** - Test modules during deployment
- **Nix Analyzer** - Analyze module dependencies and structure

## Resources

This skill provides:
- **Scripts**: `generate-module.sh` - Module generation script
- **References**: Module patterns, best practices, examples
- **Templates**: Pre-built module templates for common use cases
- **Validation**: Automated module structure validation

# Agent Guidance for /modules

## Purpose
All modular Nix configurations live here. Modules are the building blocks of this NixOS setup.

## Module Structure

```
modules/
├── nixos/              # System-level modules
│   ├── core/           # Essential system services
│   ├── services/       # Network services, databases
│   ├── security/       # Firewall, SSH, Tailscale
│   └── hardware/       # Hardware-specific configs
├── home-manager/       # User-level modules
│   ├── shell/          # Fish, Ghostty, terminals
│   ├── applications/   # Zed, Zen, 1Password
│   ├── development/    # Languages, AI tools
│   └── desktop/        # Niri, DankMaterialShell
└── shared/             # Shared modules (nixos + hm)
```

## Module Standards

### Module Template
```nix
{ config, lib, pkgs, ... }:

{
  options = {
    services.my-module = {
      enable = lib.mkEnableOption "my-module";
      # Additional options here
    };
  };

  config = lib.mkIf config.services.my-module.enable {
    # Configuration here
  };
}
```

### Key Requirements
1. **Single Concern** - Each module handles ONE thing
2. **Self-Contained** - No dependencies on other modules
3. **Documented** - Add docs/modules/ entry
4. **Tested** - Build succeeds

## Working in nixos/

### Core Modules
Essential system functionality:
- `base.nix` - Base system configuration
- `users.nix` - User accounts and groups
- `locale.nix` - Language, timezone, keyboard
- `networking.nix` - Network configuration
- `boot.nix` - Boot loader and initrd

### Services Modules
Network services and daemons:
- `podman.nix` - Container runtime
- `caddy.nix` - Reverse proxy
- `tailscale.nix` - VPN configuration
- `ssh.nix` - SSH server
- `firewall.nix` - Firewall rules

### Security Modules
Security-related configurations:
- `hardening.nix` - System hardening
- `opnix.nix` - 1Password integration
- `audit.nix` - System auditing

### Hardware Modules
Hardware-specific configs:
- `optimizations.nix` - CPU/GPU optimizations per host
- `power.nix` - Power management
- ` sensors.nix` - Hardware sensors

## Working in home-manager/

### Shell Modules
Terminal and shell configurations:
- `fish.nix` - Fish shell setup
- `ghostty.nix` - Terminal emulator
- `completions.nix` - Shell completions

### Application Modules
User applications:
- `zed.nix` - Zed IDE configuration
- `zen-browser.nix` - Zen Browser setup
- `onepassword.nix` - 1Password CLI/GUI

### Development Modules
Development environment:
- `languages/` - Language-specific configs
  - `node.nix` - Node.js/npm
  - `python.nix` - Python/pip
  - `go.nix` - Go toolchain
  - `rust.nix` - Rust toolchain
- `ai-tools.nix` - AI coding assistants
- `lsp.nix` - Language server protocol
- `formatters.nix` - Code formatters

### Desktop Modules
Desktop environment:
- `niri.nix` - Window manager
- `dank-material-shell.nix` - Material Design UI
- `wallpapers.nix` - Wallpaper management

## Module Documentation

Each module MUST have documentation:

```markdown
# Module Name

## Purpose
Brief description of what this module does.

## Requirements
- Packages, inputs, or other modules required
- Hardware requirements
- Configuration prerequisites

## Usage
```nix
{
  imports = [
    # Add the module
  ];

  services.my-module.enable = true;
}
```

## Configuration Options
- `services.my-module.option` - Description of option
- List all configurable options

## Testing
```bash
nixos-rebuild build .#<hostname>
```

## Notes
- Important caveats
- Known issues
- Future plans
```

Save as: `docs/modules/<category>/<module-name>.md`

## Import Patterns

### In Host Config
```nix
{
  imports = [
    # NixOS modules
    ./disko.nix
    ./hardware.nix
    ../../modules/nixos/core/base.nix
    ../../modules/nixos/services/podman.nix

    # Home-manager modules (in home-manager config)
    # These go in home/hbohlen/home.nix
  ];
}
```

### In Other Modules
```nix
{
  imports = [
    # Shared module
    ../../modules/shared/feature.nix
  ];
}
```

## Testing Modules

Before committing a module:
```bash
# Build test
nixos-rebuild build .#yoga

# Or specific module
nix-build -A nixosConfigurations.yoga.config

# Check for errors
nix-env -qaP | grep error  # Check for errors
```

## Common Module Patterns

### Enable Pattern
```nix
options = {
  services.my-service.enable = lib.mkEnableOption "my-service";
};

config = lib.mkIf config.services.my-service.enable {
  # config
};
```

### Package Pattern
```nix
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    package1
    package2
  ];
}
```

### Service Pattern
```nix
{ config, pkgs, ... }:

{
  services.my-service = {
    enable = true;
    package = pkgs.my-service;
  };
}
```

## Module Organization Tips

### What Makes a Good Module
- **Focused**: One clear purpose
- **Reusable**: Can be used across hosts
- **Composable**: Works well with other modules
- **Documented**: Clear purpose and options
- **Tested**: Known to work

### When to Split a Module
If a module does multiple things:
- Base config + specialized variants
- Multiple services that can be used independently
- Different features that can be enabled separately

### When to Merge Modules
If modules are:
- Always used together
- Share heavy interdependencies
- Single concern split artificially

## Troubleshooting

### Module Not Loading
Check imports in host config:
```nix
# Relative path from host file
../../modules/nixos/category/module.nix

# Verify file exists
ls -la modules/nixos/category/module.nix
```

### Options Not Working
- Check `options` section defined correctly
- Verify `config` section uses `mkIf` or proper conditional
- Check for typos in option names

### Build Failures
- Import errors: Check paths
- Undefined variables: Check `{ pkgs, ... }:` in arguments
- Type errors: Check option types (bool vs string vs int)

## Best Practices

1. **Use `lib.mkEnableOption`** for boolean options
2. **Use `lib.mkOption`** with type for typed options
3. **Use `lib.mkIf`** for conditional config
4. **Use `lib.mkDefault`** for sensible defaults
5. **Document all options** in module and docs
6. **Test with multiple hosts** to ensure reusability
7. **Keep modules small** - easier to debug and maintain
8. **Version module dependencies** if needed

## Module Categories Reference

### System Categories
- `core/` - Core system functionality
- `services/` - Network services
- `security/` - Security configurations
- `hardware/` - Hardware-specific
- `virtualization/` - VMs, containers
- `programs/` - System-wide programs

### Home-Manager Categories
- `shell/` - Terminal and shell
- `applications/` - User applications
- `development/` - Dev tools and languages
- `desktop/` - Desktop environment
- `services/` - User services
- `utilities/` - Utilities and helpers

## Success Criteria

Module is complete when:
- [ ] Single, clear purpose
- [ ] Options properly defined
- [ ] Documentation created
- [ ] Builds successfully
- [ ] Used by at least one host
- [ ] Follows naming conventions
- [ ] No hardcoded values
- [ ] Relative imports correct

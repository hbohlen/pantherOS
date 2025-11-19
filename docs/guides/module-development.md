# Module Development Guide

This guide explains how to create and maintain NixOS and home-manager modules in pantherOS.

## Overview

pantherOS uses a modular architecture where each module has a single concern. This guide covers:
- Module structure and organization
- Creating new modules
- Testing modules
- Documentation standards

## Module Organization

### Directory Structure

```
modules/
├── nixos/                    # System modules
│   ├── core/                # Core system functionality
│   ├── services/            # Network services
│   ├── security/            # Security configurations
│   └── hardware/            # Hardware-specific
├── home-manager/            # User modules
│   ├── shell/               # Terminal and shell
│   ├── applications/        # User applications
│   ├── development/         # Dev tools and languages
│   └── desktop/             # Desktop environment
└── shared/                  # Shared between nixos and home-manager
```

### Module Categories

**NixOS (System Modules):**
- Core: Boot, systemd, basic system configuration
- Services: Network services, servers, daemons
- Security: Firewall, access control, encryption
- Hardware: Device-specific configurations

**Home-Manager (User Modules):**
- Shell: Fish, Ghostty, terminal utilities
- Applications: User applications (1Password, browsers, etc.)
- Development: Languages, LSPs, AI tools
- Desktop: Niri, DankMaterialShell, UI elements

**Shared:**
- Utilities used by both system and user modules
- Common configuration patterns
- Reusable functions

## Creating a New Module

### Step 1: Choose Location

Decide where your module fits:
- Which category (nixos/home-manager/shared)?
- Which subdirectory?
- Will it be used by other modules? (→ shared/)

### Step 2: Create Module File

Create a new file following naming conventions:
- Use kebab-case: `my-module.nix`
- Avoid spaces and special characters
- Be descriptive but concise

Example locations:
- `modules/nixos/services/my-service.nix`
- `modules/home-manager/applications/my-app.nix`
- `modules/shared/my-utility.nix`

### Step 3: Write Module Structure

Use this template:

```nix
{ lib, config, ... }:

{
  options = {
    # Define module options here
    programs.myModule.enable = lib.mkEnableOption "Enable myModule";

    programs.myModule.settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Configuration for myModule";
    };
  };

  config = lib.mkIf config.programs.myModule.enable {
    # Define module implementation here

    # Example system configuration
    systemPackages = with pkgs; [
      my-module-package
    ];

    # Example service
    services.my-service = {
      enable = true;
      inherit (config.programs.myModule.settings) setting;
    };
  };
}
```

### Step 4: Import Module

#### For NixOS Modules

Add to host configuration or imports:

```nix
{ imports = [
  ./modules/nixos/services/my-service.nix
]; }
```

#### For Home-Manager Modules

Add to home configuration:

```nix
{ programs.myModule = {
  enable = true;
  settings = {
    example = "value";
  };
}; }
```

## Module Design Principles

### Single Concern
Each module should do ONE thing well:
- ✅ Good: `modules/nixos/security/firewall.nix`
- ✅ Good: `modules/home-manager/shell/fish.nix`
- ❌ Bad: `modules/nixos/core-everything.nix`

### Explicit Dependencies
If module A needs module B:
- Document in comments
- Use `mkIf` to ensure proper order
- Consider if A should import B

### Configurable, Not Hardcoded
- Use options for all configuration
- Provide sensible defaults
- Allow users to override

Example:
```nix
# Good: Configurable
programs.myModule.port = lib.mkOption {
  type = lib.types.port;
  default = 8080;
  description = "Port to use";
};

# Bad: Hardcoded
# services.myService.port = 8080;  # Don't do this
```

### Keep Options Simple
- Prefer simple types (bool, int, str, attrs)
- Use enums for limited choices
- Document all options with `description`

```nix
programs.myModule.mode = lib.mkOption {
  type = lib.types.enum [ "light" "dark" "auto" ];
  default = "auto";
  description = "Color theme mode";
};
```

## Module Testing

### Build Test

Test that your module compiles:

```bash
# Test build for specific host
nixos-rebuild build .#yoga

# Test build for all hosts
nixos-rebuild build .#zephyrus
nixos-rebuild build .#hetzner-vps
nixos-rebuild build .#ovh-vps
```

### Dry Run Test

Test activation without changes:

```bash
nixos-rebuild dry-activate --flake .#yoga
```

### Development Shell

Test in isolated environment:

```bash
# Enter development shell
nix develop

# Build specific configuration
nix build .#nixosConfigurations.yoga.config.system.build.toplevel
```

### Module-Specific Testing

Test individual modules:

```nix
# In a test file test-module.nix
{ ... }:

{
  imports = [
    ./modules/nixos/services/my-service.nix
  ];

  # Test configuration
  services.my-service.enable = true;

  # Verification
  systemPackages = [ pkgs.my-service ];
}
```

Then build:
```bash
nixos-rebuild build -I nixos-config=test-module.nix
```

## Module Documentation

### Documentation File

Create documentation for each module category:

```
docs/modules/
├── nixos/
│   ├── core/
│   │   └── README.md
│   ├── services/
│   │   └── README.md
│   └── security/
│       └── README.md
├── home-manager/
│   ├── shell/
│   │   └── README.md
│   └── applications/
│       └── README.md
└── shared/
    └── README.md
```

### Documentation Template

```markdown
# Module Category: Name

## Overview
<What this category contains>

## Modules

### Module Name
- **File**: `modules/path/to/module.nix`
- **Purpose**: What it does
- **Options**:
  - `module.enable` - Enable/disable (default: false)
  - `module.setting` - Description (default: value)
- **Usage**: How to enable and configure
- **Dependencies**: Other modules required (if any)

## Usage Examples

### Basic
```nix
{ programs.module = {
  enable = true;
}; }
```

### Advanced
```nix
{ programs.module = {
  enable = true;
  settings = {
    custom = "value";
  };
}; }
```

## Related
- Related modules
- Guides
- Architecture decisions
```

### In-Code Documentation

Document complex logic in the module itself:

```nix
{ lib, config, ... }:

{
  # This module provides X functionality
  # It depends on Y service being enabled
  # Configuration affects Z behavior

  options = {
    programs.myModule.enable = lib.mkEnableOption ''
      Enable myModule. This provides functionality for X
      and requires Y to be configured separately.
    '';
  };
}
```

## Best Practices

### Import Patterns

Use relative imports:
```nix
# In host configuration
imports = [
  ./modules/nixos/services/my-service.nix
];
```

Not absolute:
```nix
# Avoid
imports = [
  /home/user/pantherOS/modules/nixos/services/my-service.nix
];
```

### Option Naming

Follow conventions:
- `enable` - Boolean to enable/disable
- `settings` - Attrset for configuration
- `package` - Which package to use
- `path` - File/directory paths

### Default Values

- Boolean options: Default to `false`
- Package options: Default to `pkgs.package-name`
- Path options: Default to reasonable location
- String options: Provide sensible default or leave empty

### Error Handling

Validate options:
```nix
lib.mkIf config.programs.myModule.enable (lib.mkIf
  (config.programs.myModule.settings.port < 1024 || config.programs.myModule.settings.port > 65535)
  (lib.throw "Port must be between 1024 and 65535"))
```

## Troubleshooting

### Module Not Found
- Check imports are correct (relative paths)
- Verify file exists
- Check for typos in filename

### Option Not Working
- Check option name spelling
- Verify module is imported
- Check option type is correct

### Build Errors
- Run `nixos-rebuild build` to see full error
- Check for syntax errors (missing semicolons, etc.)
- Verify all required options are set

### Circular Dependencies
- Module A imports Module B, B imports A
- Solution: Redesign or move to shared/

## Migration Guide

### When to Create New Module
- New functionality added
- Existing module has multiple concerns
- Reusable across multiple hosts

### When to Modify Existing
- Bug fixes
- Adding options to existing concern
- Performance improvements

### Breaking Changes
- Version the module if incompatible changes needed
- Document migration path
- Provide backward compatibility if possible

---

**See also:**
- [Module Architecture](../architecture/module-organization.md)
- [Phase 2 Tasks](../todos/phase2-module-development.md)
- [Testing Guide](./testing-deployment.md)

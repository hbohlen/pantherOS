# Module Development for pantherOS

## Overview

pantherOS follows a strict modular architecture where each module addresses exactly one concern. This ensures maintainability, reusability, and clear separation of responsibilities.

## Single-Concern Principle

Every module must address exactly one well-defined concern:

### Good Examples
- `modules/nixos/security/firewall.nix` - Only firewall configuration
- `modules/home-manager/shell/fish.nix` - Only Fish shell configuration
- `modules/nixos/services/tailscale.nix` - Only Tailscale integration
- `modules/shared/nixpkgs-config.nix` - Only Nixpkgs configuration

### Avoid
- Combining unrelated functionality
- Creating "kitchen sink" modules
- Hard-coding host-specific settings in general modules
- Mixing system and user concerns

## Module Categories

### System Modules (modules/nixos/)
System-level configuration that affects the entire system:

#### Core Modules
- **Purpose**: Essential system functionality
- **Examples**: Boot configuration, systemd, basic system settings
- **Location**: `modules/nixos/core/`

#### Service Modules
- **Purpose**: Network services and daemons
- **Examples**: SSH, Tailscale, Caddy, Podman
- **Location**: `modules/nixos/services/`

#### Security Modules
- **Purpose**: Security configurations
- **Examples**: Firewall, SSH hardening, access control
- **Location**: `modules/nixos/security/`

#### Hardware Modules
- **Purpose**: Hardware-specific configurations
- **Examples**: GPU drivers, power management, device-specific settings
- **Location**: `modules/nixos/hardware/`

### User Modules (modules/home-manager/)
User-level configuration that affects individual users:

#### Shell Modules
- **Purpose**: Terminal and shell configuration
- **Examples**: Fish, Ghostty, terminal utilities
- **Location**: `modules/home-manager/shell/`

#### Application Modules
- **Purpose**: User applications
- **Examples**: 1Password, browsers, development tools
- **Location**: `modules/home-manager/applications/`

#### Development Modules
- **Purpose**: Development tools and environments
- **Examples**: Languages, LSPs, AI tools
- **Location**: `modules/home-manager/development/`

#### Desktop Modules
- **Purpose**: Desktop environment
- **Examples**: Niri, DankMaterialShell, UI elements
- **Location**: `modules/home-manager/desktop/`

### Shared Modules (modules/shared/)
Modules used by both system and user configurations:

#### Base Modules
- **Purpose**: Common configuration patterns
- **Examples**: Utility functions, shared options
- **Location**: `modules/shared/base/`

#### Option Modules
- **Purpose**: Shared option definitions
- **Examples**: Global configuration options
- **Location**: `modules/shared/options/`

#### Utility Modules
- **Purpose**: Helper functions and libraries
- **Examples**: Custom functions, validation helpers
- **Location**: `modules/shared/utils/`

## Development Workflow

### 1. Hardware Analysis
Before creating any module:
```bash
# Scan hardware if relevant
./skills/pantheros-hardware-scanner/scripts/scan-hardware.sh <host>

# Review hardware specifications
cat docs/hardware/<host>.md

# Identify hardware-specific requirements
```

### 2. Module Design
Plan your module before implementation:

#### Determine Module Type
- **System module**: Affects entire system → `modules/nixos/`
- **User module**: Affects user environment → `modules/home-manager/`
- **Shared module**: Used by both → `modules/shared/`

#### Define Single Concern
- What specific problem does this solve?
- Is this truly a single concern?
- Can this be split into smaller modules?

#### Plan Interface
- What options are needed?
- What are sensible defaults?
- How will users configure this?

### 3. Implementation
Create the module following pantherOS patterns:

#### File Structure
```bash
# Create module file
touch modules/<category>/<subcategory>/<module-name>.nix

# Create documentation
touch docs/modules/<category>/<subcategory>/<module-name>.md
```

#### Module Template
```nix
{ lib, config, pkgs, ... }:

{
  options = {
    # Define module options here
    programs.myModule.enable = lib.mkEnableOption "myModule";

    programs.myModule.settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Configuration for myModule";
    };
  };

  config = lib.mkIf config.programs.myModule.enable {
    # Define module implementation here
    
    # Example: Add packages
    environment.systemPackages = with pkgs; [
      my-module-package
    ];

    # Example: Configure service
    services.my-service = {
      enable = true;
      inherit (config.programs.myModule.settings) setting;
    };
  };
}
```

### 4. Documentation
Create comprehensive documentation:

#### Module Documentation
```markdown
# <Category>: <Module Name>

## Overview
<What this module does and why it exists>

## Options
### `module.enable`
- **Type**: Boolean
- **Default**: `false`
- **Description**: Enable <module functionality>

### `module.setting`
- **Type**: <type>
- **Default**: <value>
- **Description**: <what it controls>

## Usage Examples
### Basic
```nix
{
  <module>.enable = true;
}
```

### Advanced
```nix
{
  <module> = {
    enable = true;
    setting = "custom-value";
  };
}
```

## Integration
- Required modules
- Optional dependencies
- Conflicts with other modules
- Best practices

## Troubleshooting
- Common issues
- Debug procedures
- Log locations
```

### 5. Testing
Thoroughly test your module:

#### Build Testing
```bash
# Test build for each host type
nixos-rebuild build .#yoga      # Workstation
nixos-rebuild build .#zephyrus   # Performance workstation
nixos-rebuild build .#hetzner-vps # Server
nixos-rebuild build .#ovh-vps    # Server
```

#### Configuration Testing
```bash
# Test with different configurations
nixos-rebuild build .#yoga --option extra-experimental-features nix-command

# Test dry-run activation
nixos-rebuild dry-activate --flake .#yoga
```

#### Integration Testing
- Test with other modules enabled
- Test on different hardware
- Test with various option combinations

## Integration with Skills

### Module Generator Skill
Use the automated module generator for consistent patterns:
```bash
# Generate a new module
./skills/pantheros-module-generator/scripts/generate-module.sh \
  --category nixos \
  --subcategory services \
  --name my-service \
  --description "My custom service"
```

### Hardware-Specific Patterns
When creating hardware-specific modules:
- Use hardware scanner data
- Consider optimization requirements
- Document hardware dependencies
- Test on relevant hardware

### Security Requirements
All modules must follow security guidelines:
- No hardcoded secrets
- Proper file permissions
- Secure defaults
- Security documentation

## Module Design Patterns

### Enable/Disable Pattern
```nix
options = {
  services.myService.enable = lib.mkEnableOption "myService";
};

config = lib.mkIf config.services.myService.enable {
  # Configuration when enabled
};
```

### Settings Pattern
```nix
options = {
  services.myService = {
    enable = lib.mkEnableOption "myService";
    
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Configuration for myService";
    };
  };
};
```

### Package Selection Pattern
```nix
options = {
  programs.myApp = {
    enable = lib.mkEnableOption "myApp";
    
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.myApp;
      description = "myApp package to use";
    };
  };
};
```

### Conditional Features Pattern
```nix
config = lib.mkIf config.programs.myModule.enable {
  # Base configuration
  
  # Optional features
  programs.myModule.advancedFeature = lib.mkIf 
    config.programs.myModule.enableAdvanced true;
};
```

## Import Patterns and Conventions

### Relative Imports
Always use relative imports:
```nix
# In host configuration
imports = [
  ./modules/nixos/services/my-service.nix
  ../../modules/nixos/security/firewall.nix
];
```

### Module Organization
Group related imports:
```nix
imports = [
  # Core modules
  ../../modules/nixos/core/base.nix
  ../../modules/nixos/core/boot.nix
  
  # Security modules
  ../../modules/nixos/security/firewall.nix
  ../../modules/nixos/security/ssh.nix
  
  # Service modules
  ../../modules/nixos/services/tailscale.nix
  ../../modules/nixos/services/caddy.nix
];
```

### Conditional Imports
Use conditional imports for optional features:
```nix
imports = [
  ../../modules/nixos/core/base.nix
] ++ lib.optionals config.services.desktop.enable [
  ../../modules/nixos/desktop/niri.nix
];
```

## Testing and Validation

### Build Validation
Every module must pass build testing:
```bash
# Test all hosts
for host in yoga zephyrus hetzner-vps ovh-vps; do
  echo "Testing $host..."
  nixos-rebuild build .#$host || echo "Build failed for $host"
done
```

### Configuration Validation
- Test with default settings
- Test with custom settings
- Test edge cases
- Test error conditions

### Integration Validation
- Test with other modules
- Test on different hardware
- Test upgrade scenarios
- Test rollback procedures

## Documentation Requirements

### Module Documentation
Every module must have documentation:
- Purpose and scope
- Options and types
- Usage examples
- Integration notes
- Troubleshooting guide

### Category Documentation
Each module category must have:
- Overview of category purpose
- List of modules in category
- Common patterns
- Best practices
- Related categories

### Cross-References
- Link between related modules
- Reference dependencies
- Document alternatives
- Provide migration paths

## Best Practices

### Code Quality
- Follow Nix formatting standards
- Use descriptive variable names
- Add comments for complex logic
- Keep functions pure

### Option Design
- Use appropriate types
- Provide sensible defaults
- Document all options
- Validate input values

### Performance
- Minimize evaluation overhead
- Use lazy evaluation appropriately
- Avoid unnecessary dependencies
- Optimize for common cases

### Security
- Never hardcode secrets
- Use secure defaults
- Validate all inputs
- Document security implications

## Troubleshooting

### Module Not Found
- Check import paths are correct
- Verify file exists
- Check for typos in filename
- Ensure proper relative paths

### Option Not Working
- Check option name spelling
- Verify module is imported
- Check option type is correct
- Ensure module is enabled

### Build Errors
- Run `nixos-rebuild build` to see full error
- Check for syntax errors
- Verify all required options are set
- Check for circular dependencies

### Circular Dependencies
- Module A imports Module B, B imports A
- Solution: Redesign or move to shared/
- Use conditional imports
- Split into smaller modules

## Migration Guide

### When to Create New Module
- New functionality added
- Existing module has multiple concerns
- Reusable across multiple hosts
- Breaking changes needed

### When to Modify Existing
- Bug fixes
- Adding options to existing concern
- Performance improvements
- Documentation updates

### Breaking Changes
- Version the module if incompatible changes needed
- Document migration path
- Provide backward compatibility if possible
- Update all dependent configurations

## Related Documentation

- [Module Development Guide](../guides/module-development.md)
- [Architecture Overview](../architecture/overview.md)
- [Testing and Deployment](../guides/testing-deployment.md)
- [Phase 2 Tasks](../todos/phase2-module-development.md)

---

**Maintained by:** pantherOS Module Team
**Last Updated:** 2025-11-19
**Version:** 1.0
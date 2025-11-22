# PantherOS Module Development Guide

This guide details how to create and maintain modules for PantherOS following established patterns and best practices.

## Module Patterns

PantherOS follows standard NixOS module patterns with some additional conventions:

### Basic Module Structure

```nix
{ config, lib, ... }:

with lib;

let
  cfg = config.pantherOS.moduleName;
in
{
  options.pantherOS.moduleName = {
    enable = mkEnableOption "Description of the module";
    
    # Additional options with proper types
    optionName = mkOption {
      type = types.str;  # Use appropriate type
      default = "defaultValue";
      description = "Description of the option";
    };
  };

  config = mkIf cfg.enable {
    # Module implementation
  };
}
```

### Option Types

Always specify appropriate types for options:

- Use `types.str` for string values
- Use `types.bool` for boolean values
- Use `types.int` for integer values
- Use `types.port` for port numbers
- Use `types.listOf` for lists (e.g., `types.listOf types.str`)
- Use `types.attrsOf` for attribute sets
- Use `types.package` for package options

### Conditional Configuration

Use `mkIf` to conditionally apply configuration based on option values:

```nix
config = mkIf cfg.enable {
  # Only apply if module is enabled
  services.myservice = {
    enable = true;
    setting = cfg.optionName;
  };
};
```

## Module Categories

Follow the existing category structure when creating new modules:

- **Core**: Fundamental system configuration that many other modules depend on
- **Services**: Network services and system daemons
- **Security**: Security hardening and access controls
- **Filesystems**: Storage, encryption, and impermanence
- **Hardware**: Hardware-specific configurations

## Naming Conventions

- Use prefix `pantherOS.` for all module options
- Use descriptive names for option properties
- Use camelCase for multi-word option names
- Use descriptive names that clearly indicate purpose

## Security Considerations

- Implement security by default when possible
- Use secure defaults for all options
- Add appropriate hardening options for security-sensitive modules
- Consider security implications of each option

## Example: Creating a New Service Module

Here's how to create a service module following PantherOS patterns:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.services.serviceName;
in
{
  options.pantherOS.services.serviceName = {
    enable = mkEnableOption "PantherOS Service Name configuration";
    
    package = mkOption {
      type = types.package;
      default = pkgs.serviceName;
      defaultText = "pkgs.serviceName";
      description = "Service package to use";
    };
    
    settings = mkOption {
      type = types.attrs;
      default = { };
      description = "Service-specific settings";
    };
    
    enableService = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the system service";
    };
  };

  config = mkIf cfg.enable {
    # Install the package
    environment.systemPackages = mkIf cfg.enable [ cfg.package ];
    
    # Configure the service
    services.serviceName = mkIf cfg.enableService {
      enable = cfg.enableService;
      # Import settings
    };
    
    # Additional configurations as needed
  };
}
```

## Testing Modules

1. Verify the module syntax with `nix-instantiate`
2. Test the configuration in a VM before applying to real systems
3. Validate that the enable/disable patterns work correctly
4. Check that default values are appropriate
5. Verify that dependencies are properly handled

## Documentation

Each module should include:

1. A clear description in the enable option
2. Descriptive text for each option
3. Example usage if not obvious
4. Appropriate default values that follow security best practices

## Integration with Host Configurations

Modules should be designed to work seamlessly with host configurations. Avoid requiring complex setup in host configurations when possible.

## Performance Considerations

- Minimize the use of complex computations in module evaluation
- Use lazy evaluation where possible
- Be mindful of the performance impact of options and configurations
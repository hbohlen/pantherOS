# PantherOS Implementation Guide

This document provides step-by-step guidance for implementing changes in PantherOS. This is specifically designed for AI agents working on the codebase.

## Standard Implementation Process

### 1. Planning Phase
Before implementing any changes, follow these steps:

1. **Analyze Requirements**: Read through existing proposals in `openspec/changes/` to understand dependencies and requirements
2. **Determine Scope**: Understand if your change affects core modules, services, security, or hardware-specific configurations
3. **Check for Conflicts**: Verify that your change doesn't conflict with other planned or in-progress changes
4. **Plan Implementation**: Break your change into discrete, testable steps

### 2. Development Phase

#### If Implementing a New Feature
1. **Check if it's already planned** in `openspec/changes/`
2. **If not planned**, create an OpenSpec proposal first
3. **Create/modify modules** in the appropriate directory under `modules/nixos/`
4. **Follow module patterns** as described in the Module Development Guide
5. **Test changes** in a VM environment
6. **Update documentation** in the `docs/` directory
7. **Update OpenSpec files** to mark tasks as completed

#### If Modifying Existing Functionality
1. **Identify affected modules** by examining the module structure
2. **Check for dependencies** that might be affected
3. **Follow the same implementation patterns** as the existing code
4. **Update related documentation** to reflect the changes
5. **Verify backward compatibility** where appropriate

### 3. Code Implementation Steps

#### Creating a New Module

**Step 1**: Choose the appropriate category:
- Core functionality → `modules/nixos/core/`
- Service configuration → `modules/nixos/services/`
- Security features → `modules/nixos/security/`
- Filesystem features → `modules/nixos/filesystems/`
- Hardware-specific → `modules/nixos/hardware/`

**Step 2**: Follow the standard module template:

```nix
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.category.moduleName;
in
{
  options.pantherOS.category.moduleName = {
    enable = mkEnableOption "Description of what this module enables";
    
    # Define additional options with proper types
    optionName = mkOption {
      type = types.str;  # or appropriate type
      default = "defaultValue";
      description = "Clear, descriptive text about what this option does";
    };
  };

  config = mkIf cfg.enable {
    # Implementation goes here
    # Use other NixOS options as needed
  };
}
```

**Step 3**: Add the module to the appropriate `default.nix` file in the parent directory.

**Step 4**: Test the module by importing it in a host configuration and building the system.

#### Modifying an Existing Module

**Step 1**: Locate the appropriate module file in `modules/nixos/`

**Step 2**: Add new options following the same pattern as existing options

**Step 3**: Implement the functionality inside the `config = mkIf cfg.enable { ... };` block

**Step 4**: Ensure all changes maintain backward compatibility

**Step 5**: Update module documentation if needed

### 4. Testing Your Changes

#### Syntax Validation
```bash
# Validate Nix syntax without building
nix-instantiate --eval --strict -E 'builtins.fromJSON (builtins.readFile ./flake.lock)'
```

#### Building Test Configuration
```bash
# Build a specific host configuration to test your changes
nixos-rebuild build --flake .#hostname --impure
```

#### VM Testing (Recommended)
```bash
# Test changes in a virtual machine
nixos-rebuild build-vm --flake .#hostname --impure
result/bin/run-*-vm
```

### 5. Documentation Updates

When implementing changes, update the appropriate documentation:

- **New modules**: Add to relevant guide documentation
- **New features**: Create or update how-to guides
- **Architecture changes**: Update architecture documentation
- **User-facing changes**: Update quick reference guides

### 6. Host Configuration Updates

If your changes affect host configurations:

1. **Update affected hosts** in the `hosts/` directory
2. **Test the updated configurations** build successfully
3. **Verify functionality** in VM environment before applying to real systems
4. **Update any hardware-specific settings** if needed

### 7. OpenSpec Updates

When implementing changes that were proposed with OpenSpec:

1. **Update task status** in `openspec/changes/*/tasks.md`
2. **Update proposal status** to reflect implementation completion
3. **Verify requirements** in the proposal are satisfied
4. **Update the checklist** to mark completed tasks

### 8. Common Implementation Scenarios

#### Adding a New Service

```nix
# Example: Adding a new service module
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.pantherOS.services.newService;
in
{
  options.pantherOS.services.newService = {
    enable = mkEnableOption "Enable NewService daemon";
    
    package = mkOption {
      type = types.package;
      default = pkgs.newservice;
      description = "NewService package to use";
    };
    
    settings = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "NewService configuration settings";
    };
  };

  config = mkIf cfg.enable {
    # Install the package
    environment.systemPackages = [ cfg.package ];
    
    # Configure the service
    services.newservice = {
      enable = true;
      # Import settings
    };
  };
}
```

#### Adding Security Hardening

1. **Create in `modules/nixos/security/`** if it's general security
2. **Use `mkIf` conditions** to apply settings only when enabled
3. **Follow security best practices** (no unnecessary permissions, etc.)
4. **Test thoroughly** to ensure hardening doesn't break functionality

#### Updating Filesystem Configuration

1. **Use existing Btrfs patterns** when appropriate
2. **Consider impermanence implications** of your changes
3. **Test snapshot operations** if they're affected
4. **Update mount options** consistently

### 9. Quality Assurance

Before finalizing implementation:

- [ ] All modules follow standard patterns
- [ ] Options have proper types and descriptions
- [ ] Default values follow security best practices
- [ ] Dependencies are properly handled with `mkIf`
- [ ] Changes build successfully in test configuration
- [ ] Documentation has been updated appropriately
- [ ] OpenSpec tasks have been marked completed

### 10. Common Pitfalls to Avoid

1. **Not Using Proper Module Patterns**: Always use `mkEnableOption` and `mkIf` for conditional configuration
2. **Ignoring Security Implications**: Consider security in all changes
3. **Breaking Dependencies**: Verify that your changes don't break other modules that depend on the modified functionality
4. **Not Testing Adequately**: Always test in an isolated environment first
5. **Missing Documentation**: Update documentation for all user-facing changes

### 11. Troubleshooting Implementation Issues

#### Build Failures
- Check syntax with `nix-instantiate --eval`
- Verify module imports are correct
- Ensure all required options are defined

#### Runtime Issues
- Check logs with `journalctl -u servicename`
- Verify configuration file generation
- Test in VM environment first

#### Dependency Issues
- Use `nix-store --query --references` to check dependencies
- Ensure proper ordering in module imports
- Use `mkIf` for conditional dependencies

This guide should help ensure consistent and high-quality implementations across the PantherOS project.
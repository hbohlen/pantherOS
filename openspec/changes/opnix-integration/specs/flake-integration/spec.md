# Spec Delta: Flake Integration for OpNix

## Overview
This specification defines the requirements for integrating OpNix (brizzbuzz/opnix) as a flake input in the pantherOS NixOS configuration, establishing the foundation for 1Password secret management.

## ADDED Requirements

### Add OpNix as flake input (Requirement)
**Requirement**: Integrate OpNix as a flake input in the pantherOS configuration to enable 1Password secret management functionality through the OpNix module system.

**File**: `flake.nix`  
**Type**: ADDED

#### Scenario: Basic flake input configuration
Given the current empty `flake.nix` file, when OpNix is added as a flake input, then the flake should include:
- OpNix input with URL `github:brizzbuzz/opnix`
- Input follows nixpkgs for consistency (`inputs.nixpkgs.follows = "nixpkgs"`)
- OpNix available in `outputs.inputs` and `outputs.nixosModules`

#### Scenario: Flake validation passes
Given the updated flake configuration, when `nix flake check` is executed, then the command should:
- Complete without errors
- Show OpNix input as a resolved dependency
- Validate all flake output types (packages, nixosModules, etc.)

#### Scenario: OpNix module accessibility
Given the flake configuration, when accessing OpNix modules, then:
- `opnix.nixosModules.default` should be available for import
- Module should expose expected options (`services.onepassword-secrets.*`)
- No additional setup should be required beyond flake import

### Maintain flake compatibility
**Requirement**: Ensure that adding OpNix as a flake input maintains compatibility with existing flake patterns and doesn't break current NixOS configuration workflows.

**File**: `flake.nix`  
**Type**: ADDED

#### Scenario: Existing flake functionality preserved
Given the current flake structure (even though currently empty), when OpNix is added, then:
- All existing flake inputs and outputs remain functional
- No breaking changes to existing configurations
- Backward compatibility with current NixOS channel

#### Scenario: Standard flake outputs available
Given the updated flake configuration, when building NixOS configurations, then:
- `nixosConfigurations.*` outputs should work as expected
- Home manager configurations should remain compatible
- Development shell should include OpNix tools

## Implementation Details

### Flake Structure
```nix
{
  description = "pantherOS - Declarative NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    
    # OpNix for 1Password secret management
    opnix = {
      url = "github:brizzbuzz/opnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Additional inputs as needed
    # disko, impermanence, etc.
  };

  outputs = { self, nixpkgs, opnix, ... }: {
    # Standard flake outputs
    nixosConfigurations = {
      # Host configurations
    };
    
    # Expose OpNix module for easy import
    opnixModule = opnix.nixosModules.default;
  };
}
```

### Integration Points
- **NixOS Modules**: Import via `imports = [ inputs.opnix.nixosModules.default ];`
- **Package Access**: Available via `pkgs.opnix` if needed
- **Service Definition**: `services.onepassword-secrets.*` options exposed

## Validation Criteria

### Functional Validation
- [ ] `nix flake check` completes without errors
- [ ] `nix flake eval` shows OpNix input as resolved dependency  
- [ ] `nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel` succeeds
- [ ] OpNix module can be imported in host configuration

### Compatibility Validation  
- [ ] Existing flake patterns maintained
- [ ] No conflicts with future flake inputs
- [ ] Module import works with standard NixOS patterns

## Dependencies
- **External**: OpNix repository availability at `github:brizzbuzz/opnix`
- **Internal**: None (this is the foundational change)

## Related Capabilities
- **Service Configuration**: Requires this flake integration to be complete
- **Secret Mappings**: Depends on OpNix module availability
- **Bootstrap Process**: Needs OpNix service to be functional

## Notes
- This specification focuses only on flake integration, not service configuration
- Follows standard flake input patterns for consistency
- Minimal scope to reduce risk and ensure solid foundation
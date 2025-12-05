# Flake Organization

Best practices for organizing nix flakes and managing dependencies.

## Flake Structure

```nix
{
  description = "NixOS configuration for <project>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Other inputs
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      lib = nixpkgs.lib;
    in {
      # Outputs
    };
}
```

- **Include description**: Document what the flake is for
- **Pin dependencies**: Use specific branches or revisions
- **Extract common variables**: Define system and lib once
- **Document inputs**: Comment on why each input is needed

## Input Management

```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  home-manager = {
    url = "github:nix-community/home-manager/release-25.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

- **Follow nixpkgs**: Use `inputs.nixpkgs.follows = "nixpkgs"` when appropriate
- **Use stable channels**: Prefer release branches over unstable for dependencies
- **Pin versions**: Use specific versions or branches, not moving targets
- **Document version choices**: Comment on why specific versions are used

## NixOS Configurations

```nix
nixosConfigurations.hostname = lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    # Import modules here
  ];
  specialArgs = { inherit lib; };
};
```

- **One config per host**: Create separate configurations for each host
- **Use descriptive names**: Name configurations by hostname or function
- **Pass lib in specialArgs**: Makes lib available in all modules
- **Group related modules**: Organize imports logically

## DevShells

```nix
devShells.${system}.default = pkgs.mkShell {
  buildInputs = with pkgs; [
    # Development tools
  ];

  shellHook = ''
    # Setup commands
  '';
};
```

- **Create a default shell**: Provide a default development environment
- **Document tools**: Comment on what each tool is used for
- **Use shellHook for setup**: Initialize environment in shellHook
- **Group tools logically**: Organize by category (build, test, docs, etc.)

## Package Overlays

```nix
pkgs = import nixpkgs {
  inherit system;
  config = {
    allowUnfree = true;
  };
  overlays = [
    (final: prev: {
      # Custom package modifications
    })
  ];
};
```

- **Document overlays**: Comment on what each overlay does
- **Keep overlays minimal**: Only modify what's necessary
- **Handle unfree packages**: Set config.allowUnfree if needed
- **Use overrideAttrs**: For simple package modifications

## Checks

```nix
checks.${system} = {
  # Integration tests
};
```

- **Create checks**: Test configurations before deployment
- **Use nixosTest**: For integration testing
- **Document test coverage**: Comment on what is tested
- **Run checks in CI**: Ensure checks run automatically

## Output Organization

```nix
outputs = { self, nixpkgs, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    # NixOS configurations
    nixosConfigurations = {
      hostname1 = # ...;
      hostname2 = # ...;
    };

    # Development shells
    devShells.${system} = {
      default = # ...;
    };

    # Checks
    checks.${system} = {
      # Test definitions
    };

    # Apps (if applicable)
    apps.${system} = {
      # Command-line applications
    };
  };
```

- **Group outputs logically**: Separate NixOS, devShells, checks
- **Name outputs descriptively**: Use clear, descriptive names
- **Document output purpose**: Comment on what each output is for
- **Include all necessary outputs**: Don't forget checks and apps

## flake.lock Management

- **Commit flake.lock**: Keep flake.lock in version control
- **Update intentionally**: Run `nix flake update` deliberately, not automatically
- **Review lock changes**: Check what versions changed when updating
- **Document major updates**: Comment on significant version bumps

## flake.nix Tips

```nix
# Use flake check to validate
# nix flake check

# Build specific configuration
# nixos-rebuild build --flake .#hostname

# Update dependencies
# nix flake update

# Show flake info
# nix flake info
```

- **Use flake check**: Validate flake before committing
- **Document common commands**: Comment on useful flake commands
- **Test builds**: Always test configurations before deploying
- **Keep flake simple**: Don't overcomplicate the flake structure

## Dependency Versioning

```nix
# Good: Pin to specific version
home-manager = {
  url = "github:nix-community/home-manager/release-25.05";
};

# Avoid: Moving target
home-manager.url = "github:nix-community/home-manager";
```

- **Pin to releases**: Use release branches or tags
- **Update periodically**: Review and update dependencies regularly
- **Document breaking changes**: Comment on known breaking changes
- **Test updates**: Always test configuration after updating dependencies

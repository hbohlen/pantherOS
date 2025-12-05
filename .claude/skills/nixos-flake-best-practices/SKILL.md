---
name: NixOS Flake Best Practices
description: Structure NixOS flake.nix files for multi-host deployments with proper inputs/outputs, devShells, checks, and CI integration. When creating or modifying flake.nix, nixosConfigurations, devShells, or NixOS system configurations.
---
# NixOS Flake Best Practices

## When to use this skill:

- Creating or updating flake.nix for multi-host NixOS configurations
- Defining nixosConfigurations for different machines (zephyrus, server, workstation)
- Setting up inputs.nixpkgs with pinned versions (nixos-unstable, nixos-24.05)
- Adding overlays for custom packages (quickshell, custom tools)
- Configuring devShells for development environments
- Setting up checks and test suites with nix-unit
- Configuring CI with hercules-ci, GitHub Actions, or other CI systems
- Using attic for binary cache management
- Managing flake.lock and updating dependencies
- Creating flake outputs for packages, overlays, and apps

## Best Practices
- inputs.nixpkgs.url = &quot;github:NixOS/nixpkgs/nixos-unstable&quot;; pin disko/home-manager/nixvim/DankMaterialShell.
- outputs.nixosConfigurations.&quot;zephyrus&quot; = lib.nixosSystem { modules = [ disko.nixosModules.disko ./hosts/zephyrus/default.nix ]; specialArgs = { inherit lib pkgs; }; };
- pkgs = import nixpkgs { overlays = [ (final: prev: { quickshell = quickshell.packages.x86_64-linux.default; }) ]; config.allowUnfree = true; };
- devShells.x86_64-linux.default = pkgs.mkShell { buildInputs = [ nil statix nix-unit nixpkgs-fmt ]; shellHook = ''echo &quot;pantherOS dev env&quot;''; };
- checks.x86_64-linux = import ./tests/integration/default.nix { inherit self nixpkgs; };

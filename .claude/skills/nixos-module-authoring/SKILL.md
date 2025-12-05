---
name: NixOS Module Authoring
description: Create reusable NixOS modules with proper options, configuration, and aggregator patterns for modular system configurations. When authoring NixOS modules, defining options, or creating module collections.
---
# NixOS Module Authoring

## When to use this skill:

- Creating new NixOS modules with { options, config, lib } parameters
- Defining module options with lib.mkEnableOption or lib.types
- Implementing configuration logic with lib.mkIf and lib.mkMerge
- Creating aggregator modules that import multiple sub-modules
- Organizing modules in directories (packages, environment, users, etc.)
- Using module composition and imports effectively
- Setting default values with lib.mkDefault
- Creating type definitions for options (attrsOf, str, bool)
- Reusing common patterns across modules
- Documenting module options and usage

## Best Practices
- { options, config, lib }: { options.myModule.enable = lib.mkEnableOption &quot;feature&quot;; config = lib.mkIf config.myModule.enable { ... }; };
- Aggregator: { imports = [ ./packages ./environment ./users ./window-managers ./desktop-shells ./development ./security ./ci ]; };
- Options: lib.types.attrsOf lib.types.str; default = lib.mkDefault {};

# Module Organization

Guidelines for organizing and structuring NixOS modules to maintain a clean, maintainable configuration.

## Directory Structure

- **Use descriptive names**: Name module directories by their function (e.g., `backup`, `monitoring`, `security`)
- **Create default.nix files**: Every module directory should have a default.nix that imports submodules
- **Group related functionality**: Keep related modules together (e.g., `desktop-shells/dankmaterial/`)

## Module Composition

- **Single responsibility**: Each module should configure one logical concern (not configure both networking and firewall in one module)
- **Clear imports**: Use clean import lists in module aggregators like `modules/default.nix`
- **Modular hierarchy**: Create clear levels of abstraction (core modules, specific implementations)

## Module Attributes

```nix
# Good: Self-describing module header
# modules/packages/default.nix
# Aggregator for all package modules

{
  imports = [
    ./core
    ./dev
  ];
}
```

- **Always include comments**: Document what each module does
- **Use consistent headers**: Follow pattern `# modules/<name>/default.nix\n# Description`
- **Organize by concern**: Separate system packages from development tools

## Host-Specific vs Shared Modules

- **Shared modules in /modules**: Configuration applicable to multiple hosts goes in `modules/`
- **Host-specific in /hosts**: Hardware and host-specific configuration goes in `hosts/<name>/`
- **Import hierarchy**: Host modules import shared modules, not the other way around

## Best Practices

- **Keep modules small**: If a module gets large, break into submodules
- **Use NixOS options**: Prefer NixOS options over ad-hoc configuration
- **Document complex logic**: Add comments explaining why non-obvious choices were made
- **Maintain clean imports**: Avoid circular dependencies between modules

# Nix Language Conventions

Style guide and best practices for writing Nix expressions.

## Indentation & Formatting

- **Use 2 spaces for indentation**: Consistent with nixpkgs convention
- **No tabs**: Use spaces only
- **Use trailing commas**: Always include trailing comma in lists and attribute sets
- **Keep lines reasonably short**: Wrap lines at ~80-100 characters when possible

```nix
# Good
networking.firewall = {
  enable = true;
  allowedTCPPorts = [
    22
    80
    443
  ];
};
```

## Attribute Naming

- **Use camelCase for attributes**: `enable`, `useGlobalPkgs`, `homeDirectory`
- **Use kebab-case for file paths**: `default.nix`, `hardware-configuration.nix`
- **Use descriptive names**: `homeManagerConfig`, not `hmc`
- **Be consistent**: Follow the naming patterns used in nixpkgs options

## Attribute Sets

```nix
# Prefer attribute sets over nested lists
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Configuration
}
```

- **Always destructure parameters**: Extract what you need
- **Include `...`** in parameters: Allows extensibility
- **Group related options**: Keep related configuration together

## Lists

```nix
# Good
home.packages = with pkgs; [
  package1
  package2
  package3
];

# Avoid
home.packages = [ package1 package2 package3 ];
```

- **Use with pkgs when appropriate**: For package lists
- **One item per line**: For multi-line lists
- **Use trailing commas**: For easier diffs

## Functions

```nix
# Keep function definitions concise
let
  functionName = param: doSomething param;
in {
  result = functionName value;
}
```

- **Use descriptive names**: `getUserPackageList` not `getPackages`
- **Keep functions focused**: One function should do one thing
- **Use let bindings**: For local function definitions

## Imports

```nix
{
  imports = [
    ./module1
    ./module2
  ];
}
```

- **Sort imports alphabetically**: Easier to find and maintain
- **Use relative paths**: `./default.nix` not `modules/default.nix`
- **Group related imports**: Separate system and custom imports with comments

## String Interpolation

```nix
script = ''
  echo "Starting service"
  ${pkgs.package}/bin/command --flag
  echo "Service started"
'';
```

- **Use double quotes for multiline strings**: For scripts and multi-line text
- **Use `${}` for interpolation**: For variable substitution
- **Quote package paths**: `${pkgs.package}/bin/command`

## Boolean Values

```nix
# Good
enable = true;
useFeature = false;

# Avoid
enable = "yes";
useFeature = "off";
```

- **Use true/false only**: Not "yes"/"no" or 1/0
- **Name boolean options clearly**: `enable`, `useFeature`, `shouldConfigure`

## Comments

```nix
# Single-line comments for explanations
# modules/packages/default.nix
# Aggregator for all package modules

{
  # Module imports
  imports = [
    ./core
    ./dev
  ];
}
```

- **Use `#` for comments**: Not `/* */` style
- **Comment complex logic**: Explain why non-obvious choices were made
- **Use module headers**: Always document what each module does
- **Document host-specific config**: Comment on why configuration is host-specific

## let Bindings

```nix
let
  # Local variable definitions
  pkg = pkgs.package-name;
  configPath = "/etc/config";
in {
  # Use the variables
  environment.systemPackages = [pkg];
}
```

- **Use let for local variables**: Keep code DRY
- **Document complex let bindings**: Explain what the variables represent
- **Keep let bindings simple**: Don't nest let bindings deeply

## Path Values

```nix
# Good
source = ../relative/path;
source = /absolute/path/to/file;

# Avoid hardcoded paths without context
source = "/home/user/file";  # Should use XDG or relative paths
```

- **Use relative paths when possible**: Easier to move the configuration
- **Document absolute paths**: If absolute path is necessary, comment why
- **Use XDG conventions**: For user files, use XDG base directories

## Overlays

```nix
overlays = [
  (final: prev: {
    # Overlay modifications
    package-name = final.package-name.overrideAttrs (old: {
      # Modifications
    });
  })
];
```

- **Document overlay purpose**: Comment on why the overlay is needed
- **Use overrideAttrs**: For modifying package attributes
- **Keep overlays minimal**: Only override what's necessary

## flake.nix Conventions

```nix
{
  description = "Configuration description";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Other inputs
  };

  outputs = {
    self,
    nixpkgs,
    # Other inputs
  }:
    let
      system = "x86_64-linux";
    in {
      # Outputs
    };
}
```

- **Document the flake**: Add a description field
- **Pin nixpkgs**: Use specific revisions or branches
- **Document inputs**: Comment on why each input is needed
- **Extract system variable**: Don't repeat system definition

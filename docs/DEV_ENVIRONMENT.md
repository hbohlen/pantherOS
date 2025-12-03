# pantherOS Development Environment Guide

This guide covers the enhanced development shell for pantherOS, providing comprehensive tooling for NixOS configuration development.

## Getting Started

Enter the development shell:

```bash
nix develop
```

Or for a quick one-off command:

```bash
nix develop -c <command>
```

## Available Tools

### Build and Deployment

#### nixos-rebuild

Build and manage NixOS configurations:

```bash
# Build without switching (test first!)
nixos-rebuild build --flake .#hetzner-vps

# Build and switch (on target system)
sudo nixos-rebuild switch --flake .#zephyrus

# Build and test (temporary activation)
sudo nixos-rebuild test --flake .#yoga
```

#### nix-tree

Visualize dependency trees:

```bash
# Explore dependencies of a configuration
nix-tree .#nixosConfigurations.hetzner-vps.config.system.build.toplevel

# Explore a specific package
nix-tree nixpkgs#hello
```

### Development Tools

#### nix-diff

Compare two derivations to see what changed:

```bash
# Compare two builds
nix-diff \
  $(nix-instantiate -E '(import <nixpkgs> {}).hello') \
  $(nix-instantiate -E '(import <nixpkgs> {}).hello.overrideAttrs (old: { version = "3.0"; })')
```

#### nix-info

Get system and Nix installation information:

```bash
nix-info -m
```

#### nix-index

Search for packages and files:

```bash
# Index packages (run once, takes time)
nix-index

# Find which package provides a file
nix-locate bin/htop

# Search for packages
nix-locate --top-level --minimal --at-root --whole-name /bin/hello
```

#### nix-du

Analyze Nix store disk usage:

```bash
# Show disk usage of all paths
nix-du

# Show disk usage of a specific path
nix-du /nix/store/...

# Show top consumers
nix-du | head -20
```

### Code Quality

#### statix

Lint Nix files for anti-patterns and improvements:

```bash
# Check all Nix files
statix check .

# Fix issues automatically where possible
statix fix .

# Check specific file
statix check flake.nix
```

Common checks:
- Unused variables
- Legacy let syntax
- Empty inherit statements
- Deprecated constructs

#### deadnix

Find and remove dead code (unused bindings):

```bash
# Find dead code
deadnix .

# Find and show context
deadnix -e .

# Fix automatically (remove dead code)
deadnix -e . | xargs -I {} sed -i '{}' {}
```

#### shellcheck

Validate shell scripts:

```bash
# Check a shell script
shellcheck scripts/*.fish
shellcheck scripts/*.sh

# Specify shell dialect
shellcheck -s bash script.sh
shellcheck -s fish script.fish
```

### Formatting

Multiple formatters are available - choose your preference:

```bash
# nixpkgs-fmt (most common)
nixpkgs-fmt **/*.nix

# nixfmt-rfc-style (official RFC style)
nixfmt **/*.nix

# alejandra (opinionated)
alejandra .
```

### Documentation

#### manix

Search Nix function documentation:

```bash
# Search for a function
manix lib.attrsets.map

# Browse all documentation
manix ""
```

### Testing

#### nix-unit

Run unit tests for Nix expressions:

```bash
# Run tests in a file
nix-unit tests/

# Run specific test
nix-unit tests/lib_test.nix
```

Example test file structure:

```nix
# tests/example_test.nix
{
  testSimple = {
    expr = 1 + 1;
    expected = 2;
  };
  
  testFunction = {
    expr = let f = x: x * 2; in f 21;
    expected = 42;
  };
}
```

## Common Workflows

### Testing Configuration Changes

1. Make your changes to configuration files
2. Format the code:
   ```bash
   nixpkgs-fmt .
   ```
3. Lint for issues:
   ```bash
   statix check .
   deadnix -e .
   ```
4. Build without switching:
   ```bash
   nixos-rebuild build --flake .#<host>
   ```
5. Review changes with nix-diff (compare old and new)
6. Switch when confident:
   ```bash
   sudo nixos-rebuild switch --flake .#<host>
   ```

### Debugging Build Issues

1. Check for syntax errors:
   ```bash
   nix flake check
   ```

2. Evaluate specific attributes:
   ```bash
   nix eval .#nixosConfigurations.hetzner-vps.config.system.build.toplevel
   ```

3. Build with more verbose output:
   ```bash
   nixos-rebuild build --flake .#<host> --show-trace
   ```

4. Inspect dependency tree:
   ```bash
   nix-tree .#nixosConfigurations.<host>.config.system.build.toplevel
   ```

### Finding Packages

1. Search online:
   - https://search.nixos.org/packages

2. Search locally (after indexing):
   ```bash
   nix-locate <filename>
   ```

3. Browse package options:
   ```bash
   manix pkgs.
   ```

### Code Cleanup

Regular maintenance:

```bash
# Format all Nix files
nixpkgs-fmt **/*.nix

# Find unused code
deadnix -e .

# Lint for improvements
statix check .

# Validate shell scripts
find . -name "*.sh" -exec shellcheck {} \;
find . -name "*.fish" -exec shellcheck -s fish {} \;
```

## Tips and Best Practices

1. **Always build before switching**: Use `nixos-rebuild build` first to catch errors
2. **Keep backups**: NixOS generations provide rollback, but test thoroughly
3. **Use nix-diff**: Compare configurations before and after changes
4. **Index packages early**: Run `nix-index` once to enable fast package searching
5. **Format consistently**: Choose one formatter and use it consistently
6. **Lint regularly**: Run statix and deadnix before commits
7. **Document changes**: Keep README and docs up to date

## Shell Integration

The development shell automatically:
- Sets up all tools in PATH
- Shows available commands on entry
- Provides organized welcome message
- Maintains existing environment variables

## Troubleshooting

### "command not found" in dev shell

Make sure you're in the development shell:
```bash
nix develop
```

### Flake checks failing

Run with trace to see details:
```bash
nix flake check --show-trace
```

### Build takes too long

Use `--no-build-output` to suppress verbose output:
```bash
nixos-rebuild build --flake .#<host> --no-build-output
```

### Need to update flake inputs

```bash
nix flake update
# or update specific input:
nix flake lock --update-input nixpkgs
```

## Reference

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)

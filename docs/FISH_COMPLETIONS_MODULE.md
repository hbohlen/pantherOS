# Fish Shell Completions Module

## Overview

The Fish shell completions module provides a centralized, modular way to enable and manage Fish shell command completions in Home Manager. This module allows users to toggle specific completion categories and optionally enable dynamic completion caching for improved performance.

## Module Location

- **Module path**: `modules/home-manager/completions/default.nix`
- **Imported in**: `modules/home-manager/default.nix`

## Features

- **Modular completion categories**: Toggle completions for OpenCode, OpenAgent, system tools, containers, and development tools
- **Optional caching**: Configurable dynamic completion caching with timeout control
- **Auto-enable Fish**: Automatically enables Fish shell when completions are enabled
- **XDG-compliant**: Uses XDG base directory specification for cache storage

## Configuration Options

### Basic Options

```nix
programs.fish.completions = {
  enable = true;  # Enable Fish shell completions module
  
  # Category-specific completions
  opencode.enable = true;      # OpenCode command completions
  openagent.enable = true;     # OpenAgent command completions
  
  systemManagement = {
    enable = true;             # System management completions
    nix = true;                # Nix command completions
    systemd = true;            # Systemd service completions
    backup = true;             # Backup script completions
    network = true;            # Network management completions
  };
  
  container = {
    enable = true;             # Container management completions
    podman = true;             # Podman completions
    podmanCompose = true;      # Podman-compose completions
  };
  
  development = {
    enable = true;             # Development tool completions
    git = true;                # Git completions
    zellij = true;             # Zellij session completions
    mutagen = true;            # Mutagen session completions
    direnv = true;             # Direnv completions
  };
  
  caching = {
    enable = true;             # Enable completion caching
    cacheTimeout = 300;        # Cache timeout in seconds (default: 300)
  };
};
```

## Behavior

### Automatic Fish Enablement

When `programs.fish.completions.enable = true`, the module automatically sets:

```nix
programs.fish.enable = mkDefault true;
```

This ensures Fish is properly initialized when completions are enabled.

### Shell Initialization

The module adds the following to Fish's `shellInit`:

1. **Completion behavior configuration**:
   ```fish
   set -g fish_completion_show_foreign 1  # Show completions for non-built-in commands
   ```

2. **Category-specific initialization**: Each enabled category adds its initialization code to `shellInit`.

3. **Caching setup** (when `caching.enable = true`):
   ```fish
   set -gx FISH_COMPLETION_CACHE_DIR "${config.xdg.cacheHome}/fish/completions"
   set -gx FISH_COMPLETION_CACHE_TIMEOUT "300"
   if not test -d "$FISH_COMPLETION_CACHE_DIR"
     mkdir -p "$FISH_COMPLETION_CACHE_DIR"
   end
   ```

## Cache Directory

When caching is enabled, completions are cached in:

```
${XDG_CACHE_HOME}/fish/completions/
```

Typically: `~/.cache/fish/completions/`

The cache directory is automatically created if it doesn't exist.

## Usage Examples

### Minimal Configuration

Enable completions with default settings:

```nix
programs.fish.completions.enable = true;
```

### OpenCode/OpenAgent Only

Enable only OpenCode and OpenAgent completions:

```nix
programs.fish.completions = {
  enable = true;
  opencode.enable = true;
  openagent.enable = true;
};
```

### Development Environment

Enable completions for development tools with caching:

```nix
programs.fish.completions = {
  enable = true;
  development = {
    enable = true;
    git = true;
    zellij = true;
    direnv = true;
  };
  caching = {
    enable = true;
    cacheTimeout = 600;  # 10 minutes
  };
};
```

### Full Configuration

Enable all completions with custom cache timeout:

```nix
programs.fish.completions = {
  enable = true;
  
  opencode.enable = true;
  openagent.enable = true;
  
  systemManagement = {
    enable = true;
    nix = true;
    systemd = true;
    backup = true;
    network = true;
  };
  
  container = {
    enable = true;
    podman = true;
    podmanCompose = true;
  };
  
  development = {
    enable = true;
    git = true;
    zellij = true;
    mutagen = true;
    direnv = true;
  };
  
  caching = {
    enable = true;
    cacheTimeout = 300;
  };
};
```

## Integration with Home Manager

To use this module in your Home Manager configuration:

1. Ensure the module is imported (already done in `modules/home-manager/default.nix`)
2. Add configuration to your user's home configuration:

```nix
# In home/hbohlen/home.nix or similar
{
  imports = [
    ../../modules/home-manager
  ];
  
  programs.fish.completions = {
    enable = true;
    # ... your configuration
  };
}
```

## Environment Variables

When completions and caching are enabled, the following environment variables are set:

- `FISH_COMPLETION_CACHE_DIR`: Path to completion cache directory
- `FISH_COMPLETION_CACHE_TIMEOUT`: Cache timeout in seconds

## Performance Considerations

- **Cache timeout**: Default is 300 seconds (5 minutes). Adjust based on your needs:
  - Lower values: More up-to-date completions, higher system load
  - Higher values: Better performance, potentially stale completions
  
- **Selective enablement**: Only enable categories you actually use to minimize overhead

## Troubleshooting

### Completions not working

1. Verify Fish is enabled: Check that `programs.fish.enable = true`
2. Check module import: Ensure `modules/home-manager/completions` is imported
3. Rebuild: Run `home-manager switch` or rebuild your NixOS configuration

### Cache directory not created

The module automatically creates the cache directory. If issues persist:

```fish
# Manually check cache directory
echo $FISH_COMPLETION_CACHE_DIR

# Verify it exists
test -d "$FISH_COMPLETION_CACHE_DIR" && echo "Exists" || echo "Missing"

# Manually create if needed
mkdir -p "$FISH_COMPLETION_CACHE_DIR"
```

### Check environment variables

```fish
# View all Fish completion environment variables
env | grep -i fish_completion
```

## Implementation Details

The module uses NixOS Home Manager's module system with:

- `mkEnableOption`: For boolean flags
- `mkOption`: For typed options (cache timeout)
- `mkDefault`: For Fish auto-enable (allows override)
- `mkAfter`: For shell init (ensures correct ordering)
- `optionalString`: For conditional initialization code

## Current Scope and Future Enhancements

### Current Implementation

This module provides the **infrastructure** for Fish shell completions:
- Configuration options to enable/disable completion categories
- Environment setup for completion caching
- Shell initialization with completion behavior defaults

### Future Enhancements

The following features could be added in future iterations:

1. **Actual completion files**: Add Fish completion scripts for each category
2. **Dynamic completion generation**: Scripts to generate completions for running services, containers, etc.
3. **Completion validation**: Tests to ensure completions are installed correctly
4. **Per-tool completion options**: More granular control over individual tools
5. **Completion file management**: Automatic installation of completion files via `xdg.configFile`

The current implementation provides the foundation upon which these enhancements can be built.

## Related Documentation

- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [Fish Shell Completions Tutorial](https://fishshell.com/docs/current/completions.html)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

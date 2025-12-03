# Fish Shell Completions Module

This module provides modular, toggleable command-line completions for Fish shell through Home Manager.

## Overview

The completions module allows users to enable/disable specific sets of command completions based on their workflow needs. It includes optional caching support for dynamic completions to balance performance and freshness.

## Features

- **Modular Options**: Enable/disable completion sets independently
- **Automatic Fish Bootstrap**: Automatically enables Fish shell when completions are enabled
- **Caching Support**: Optional caching for dynamic completions with configurable timeout
- **Foreign Command Completions**: Automatically enables completions for non-built-in commands
- **Zero Configuration**: Completions are installed to `~/.config/fish/completions` automatically

## Usage

To enable completions, add the following to your Home Manager configuration:

```nix
{
  programs.fish.completions = {
    enable = true;  # Master switch for completions
    
    # OpenCode/OpenAgent completions
    opencode.enable = true;
    openagent.enable = true;
    
    # System management completions
    systemManagement = {
      enable = true;    # Enable all system management completions
      # Or enable individually:
      # nix = true;
      # systemd = true;
      # backup = true;
      # network = true;
    };
    
    # Container management completions
    container = {
      enable = true;    # Enable all container completions
      # Or enable individually:
      # podman = true;
      # podmanCompose = true;
    };
    
    # Development tool completions
    development = {
      enable = true;    # Enable all development tool completions
      # Or enable individually:
      # git = true;
      # zellij = true;
      # mutagen = true;
      # direnv = true;
    };
    
    # Optional: Enable caching for dynamic completions
    caching = {
      enable = true;
      cacheTimeout = 300;  # Cache timeout in seconds (default: 300)
    };
  };
}
```

## Completion Categories

### OpenCode/OpenAgent
- **opencode**: Completions for OpenCode AI coding assistant commands
- **openagent**: Completions for OpenAgent workflow commands

### System Management
- **nix**: Enhanced Nix package manager completions with package search caching
- **systemd**: systemctl and journalctl completions with service caching
- **backup**: Completions for restic and borg backup tools
- **network**: Completions for ip, nmcli, iwctl, ss, and ping commands

### Container Management
- **podman**: Podman container management with container/image caching
- **podmanCompose**: Podman Compose orchestration completions

### Development Tools
- **git**: Enhanced Git completions with branch/remote caching
- **zellij**: Zellij terminal multiplexer with session caching
- **mutagen**: Mutagen file synchronization with session caching
- **direnv**: Direnv environment switcher completions

## Caching

When caching is enabled:
- Cache directory: `$HOME/.cache/fish/completions`
- Cache timeout: Configurable (default: 300 seconds)
- Environment variables:
  - `$FISH_COMPLETION_CACHE_DIR`: Points to cache directory
  - `$FISH_COMPLETION_CACHE_TIMEOUT`: Cache timeout in seconds

Caching improves performance for dynamic completions that query external systems (e.g., listing Git branches, Docker containers, systemd services).

## Architecture

### Module Structure
```
modules/home-manager/completions/
├── default.nix         # Main module definition with options and config
├── files/              # Individual completion files
│   ├── opencode.fish
│   ├── openagent.fish
│   ├── nix.fish
│   ├── systemd.fish
│   ├── backup.fish
│   ├── network.fish
│   ├── podman.fish
│   ├── podman-compose.fish
│   ├── git.fish
│   ├── zellij.fish
│   ├── mutagen.fish
│   └── direnv.fish
└── README.md           # This file
```

### How It Works

1. **Option Definition**: The module defines boolean options for each completion category
2. **Configuration**: When enabled, completion files are installed to `~/.config/fish/completions`
3. **Shell Initialization**: Fish shell init script sets up caching and enables foreign completions
4. **Activation**: Home Manager activation ensures cache directory exists
5. **Runtime**: Fish automatically loads completions from the config directory

### Completion Files

Each `.fish` file contains:
- Command completions using Fish's `complete` command
- Subcommand completions where applicable
- Optional caching functions for dynamic completions
- Helper functions to query external systems (when caching is enabled)

## Extending

To add new completions:

1. Create a new `.fish` file in `files/` directory
2. Add option to `default.nix` in the appropriate category
3. Wire up the file in the `config.xdg.configFile` section
4. Update this README with the new completion

Example completion file structure:

```fish
# Fish completions for mycmd
complete -c mycmd -n '__fish_use_subcommand' -a 'start' -d 'Start service'
complete -c mycmd -n '__fish_use_subcommand' -a 'stop' -d 'Stop service'

# Optional: Add caching function for dynamic completions
function __fish_mycmd_items
    set -l cache_file "$FISH_COMPLETION_CACHE_DIR/mycmd-items"
    set -l cache_timeout $FISH_COMPLETION_CACHE_TIMEOUT
    
    if test -n "$cache_file" -a -f "$cache_file"
        set -l cache_age (math (date +%s) - (stat -c %Y "$cache_file" 2>/dev/null || echo 0))
        if test $cache_age -lt $cache_timeout
            cat "$cache_file"
            return
        end
    end
    
    # Generate fresh item list
    if command -v mycmd &>/dev/null
        mycmd list | tee "$cache_file"
    end
end
```

## Testing

Tests are located in `tests/unit/completions-test.nix` and verify:
- Module options are defined correctly
- Default values are appropriate
- Completion files exist
- Option wiring works as expected

Run tests with:
```bash
nix flake check
```

## Troubleshooting

### Completions not showing up
1. Ensure `programs.fish.completions.enable = true`
2. Check that Fish is enabled: `programs.fish.enable = true`
3. Verify completion files exist: `ls ~/.config/fish/completions/`
4. Restart Fish shell or run: `fish_update_completions`

### Slow completions
1. Enable caching: `programs.fish.completions.caching.enable = true`
2. Increase cache timeout if needed: `cacheTimeout = 600` (10 minutes)
3. Check cache directory exists: `ls ~/.cache/fish/completions/`

### Cache not working
1. Verify cache environment variables are set:
   ```fish
   echo $FISH_COMPLETION_CACHE_DIR
   echo $FISH_COMPLETION_CACHE_TIMEOUT
   ```
2. Ensure cache directory has write permissions
3. Clear cache and retry: `rm -rf ~/.cache/fish/completions/*`

## References

- [Fish Shell Documentation](https://fishshell.com/docs/current/)
- [Fish Completions Guide](https://fishshell.com/docs/current/completions.html)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

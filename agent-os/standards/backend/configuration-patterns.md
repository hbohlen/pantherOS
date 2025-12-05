# Configuration Patterns

Common patterns and best practices for NixOS configuration.

## Module Signature

```nix
# Always use this pattern for NixOS modules
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Configuration options go here
}
```

- **Include `...` in parameters**: Allows extensibility and additional options
- **Use destructured parameters**: Extract what you need rather than using the full attrset
- **Use `lib` for utilities**: Leverage nixpkgs.lib functions for cleaner code

## Option Configuration

- **Use descriptive names**: Name options clearly (e.g., `services.tailscale.enable` not `services.tailscale.on`)
- **Group related options**: Keep related configuration together in logical sections
- **Use booleans for enablement**: Use `enable = true/false` rather than magic strings

Example from pantherOS:
```nix
# Group related options together
networking.firewall = {
  enable = true;
  allowedTCPPorts = [22 80 443];
  trustedInterfaces = ["tailscale0"];
};
```

## System Services

- **Prefer NixOS options**: Use built-in NixOS options instead of raw systemd units when available
- **Configure service limits**: Set appropriate resource limits for services
- **Use proper service types**: Choose between oneshot, simple, forking based on service needs
- **Handle dependencies**: Use proper systemd dependencies (Requires, After, Before, etc.)

## File Management

- **Use xdg.baseDirectories**: Follow XDG base directory specification for user files
- **Prefer xdg.configFile**: Use home-manager's xdg.configFile for application configuration
- **Create activation scripts**: Use `system.activationScripts` for complex setup tasks

```nix
system.activationScripts.create-opnix-token-dir = {
  text = ''
    mkdir -p /etc
    touch /etc/opnix-token
    chmod 600 /etc/opnix-token
  '';
  deps = [];
};
```

## Performance Configuration

- **Configure kernel parameters**: Use `boot.kernel.sysctl` for performance tuning
- **Set file descriptor limits**: Increase limits for workloads that need them
- **Enable auto-optimization**: Set `nix.settings.auto-optimise-store = true`

```nix
boot.kernel.sysctl = {
  "vm.swappiness" = 10;
  "fs.file-max" = 2097152;
};
```

## System State

- **Set state version**: Always set `system.stateVersion` to the NixOS version (e.g., "25.05")
- **Update on system upgrade**: Update stateVersion when upgrading major versions
- **Don't change after install**: State version should remain constant after initial installation

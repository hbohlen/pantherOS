# Configuration Examples

> **Category:** Examples  
> **Audience:** Contributors, System Administrators  
> **Last Updated:** 2025-11-17

This section contains practical configuration examples for pantherOS and NixOS.

## Table of Contents

- [NixOS Configuration Examples](#nixos-configuration-examples)
- [Using Examples](#using-examples)
- [Contributing Examples](#contributing-examples)

## NixOS Configuration Examples

Practical examples for common NixOS configuration scenarios:

### Hardware & Power Management

**[Battery Management](nixos/battery-management.md)**
- TLP power management configuration
- Battery threshold management for laptop longevity
- Power profile optimization
- Use case: Laptops and portable devices

### Desktop & Applications

**[Browser Configuration](nixos/browser-config.md)**
- Firefox browser setup and customization
- Privacy and security settings
- Extension management
- Use case: Desktop workstations

### Graphics & Display

**[NVIDIA GPU Configuration](nixos/nvidia-gpu.md)**
- NVIDIA proprietary driver setup
- CUDA support
- Multi-monitor configuration
- Use case: Workstations with NVIDIA graphics

### Security

**[Security Hardening](nixos/security-hardening.md)**
- System security configuration
- Firewall rules
- SSH hardening
- Fail2ban setup
- AppArmor/SELinux integration
- Use case: Production servers and security-conscious systems

### Monitoring & Observability

**[Datadog Agent](nixos/datadog-agent.md)**
- Datadog monitoring agent setup
- Metrics collection configuration
- APM integration
- Use case: Production systems requiring monitoring

## Using Examples

### Understanding Example Structure

Each example follows this format:

1. **Overview** - What the example does and when to use it
2. **Prerequisites** - Required dependencies or conditions
3. **Configuration** - Complete Nix configuration with inline comments
4. **Verification** - Commands to verify the configuration works
5. **Customization** - Key variables and options to customize
6. **Troubleshooting** - Common issues and solutions
7. **References** - Links to official documentation

### Integrating Examples

**Copy-paste approach:**

```bash
# 1. View example
cat docs/examples/nixos/battery-management.md

# 2. Copy relevant sections to your configuration
vim hosts/servers/hostname/configuration.nix

# 3. Test build
nix build .#nixosConfigurations.hostname.config.system.build.toplevel

# 4. Deploy
nixos-rebuild switch --flake .#hostname
```

**Module approach (recommended):**

Create a module file:

```nix
# modules/battery-management.nix
{ config, lib, pkgs, ... }:

with lib;

{
  options.custom.batteryManagement = {
    enable = mkEnableOption "battery management with TLP";
  };

  config = mkIf config.custom.batteryManagement.enable {
    # Configuration from example
    services.tlp = {
      enable = true;
      # ... rest of config
    };
  };
}
```

Then import and enable:

```nix
# hosts/servers/hostname/configuration.nix
{
  imports = [ ../../modules/battery-management.nix ];
  
  custom.batteryManagement.enable = true;
}
```

### Testing Examples

**Safe testing workflow:**

```bash
# 1. Build without switching
nix build .#nixosConfigurations.hostname.config.system.build.toplevel

# 2. Test in VM
nixos-rebuild build-vm --flake .#hostname
./result/bin/run-hostname-vm

# 3. Deploy when confident
nixos-rebuild switch --flake .#hostname
```

## Contributing Examples

### Creating a New Example

1. **Follow Spec-Driven Development:**
   - Check [Spec-Driven Workflow](../contributing/spec-driven-workflow.md)
   - Create a spec for complex examples: `/speckit.specify`

2. **Use the standard template:**

```markdown
# [Feature] Configuration Example

> **Category:** Examples  
> **Audience:** Target Users  
> **Last Updated:** YYYY-MM-DD

Brief description of what this example demonstrates.

## Overview

[2-3 sentences explaining the example]

## Prerequisites

- List of requirements
- Dependencies needed

## Use Cases

- When to use this configuration
- What problems it solves

## Configuration

\```nix
# Complete Nix configuration with inline comments
{ config, lib, pkgs, ... }:

{
  # Configuration here
}
\```

## Verification

\```bash
# Commands to verify it works
systemctl status service-name
```

## Customization

Key options to customize:
- `option1` - Description
- `option2` - Description

## Troubleshooting

### Common Issue 1
**Symptom:** ...
**Solution:** ...

## References

- [Official Documentation](https://example.com)
- [Related Examples](./related.md)
```

3. **Test the example thoroughly:**
   - Test in clean VM
   - Verify all commands work
   - Check for errors in logs

4. **Submit for review:**
   - Follow [Contributing Guidelines](../contributing/)
   - Reference any related specs
   - Include testing results

### Example Guidelines

**Content:**
- Complete, working configurations
- Inline comments explaining non-obvious parts
- Real-world use cases
- Troubleshooting section

**Code Quality:**
- Format with `nixpkgs-fmt`
- Use explicit attribute sets
- Avoid deprecated options
- Include version compatibility notes

**Documentation:**
- Clear, concise writing
- Step-by-step verification
- Links to official documentation
- Cross-references to related examples

## Example Categories

### Current Categories

- **Hardware & Power Management** - Device-specific configurations
- **Desktop & Applications** - User-facing software
- **Graphics & Display** - GPU and display configuration
- **Security** - Hardening and security features
- **Monitoring & Observability** - System monitoring

### Planned Categories

> **Note:** These categories will be added as examples are contributed:

- **Networking** - Network configuration examples
- **Containers** - Podman/Docker examples
- **Databases** - Database server configurations
- **Web Services** - Web server and application examples
- **Development** - Development environment setups
- **Automation** - CI/CD and automation examples

## Finding More Examples

### NixOS Community Resources

- [NixOS Wiki](https://nixos.wiki/) - Community documentation
- [NixOS Discourse](https://discourse.nixos.org/) - Community discussions
- [NixOS Examples Repository](https://github.com/NixOS/nixpkgs/tree/master/nixos/modules)
- [Home Manager Examples](https://github.com/nix-community/home-manager/tree/master/modules)

### Related Documentation

- **[Configuration Reference](../reference/configuration-summary.md)** - Current system configuration
- **[How-To Guides](../howto/)** - Task-oriented guides
- **[Architecture Overview](../architecture/overview.md)** - System architecture

## See Also

- **[Contributing Guide](../contributing/)** - How to contribute
- **[Spec-Driven Workflow](../contributing/spec-driven-workflow.md)** - Development methodology
- **[Feature Specifications](../specs/)** - Formal specs for features

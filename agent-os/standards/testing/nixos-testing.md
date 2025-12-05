# NixOS Configuration Testing

Strategies and patterns for testing NixOS configurations.

## Basic Validation

```bash
# Syntax check
nix-instantiate --parse ./configuration.nix

# Evaluate configuration
nixos-rebuild dry-build --flake .#hostname

# Check configuration
nixos-rebuild check --flake .#hostname
```

- **Parse first**: Use `nix-instantiate --parse` to check syntax
- **Use dry-build**: Test builds without switching
- **Run check command**: Built-in validation of configuration
- **Fix syntax errors early**: Catch errors before deployment

## flake check

```bash
# Comprehensive flake validation
nix flake check

# Check specific output
nix flake check --no-build-outputs

# Check with verbose output
nix flake check --verbose
```

- **Run flake check**: Validates entire flake structure
- **Check all outputs**: Ensures all configurations are valid
- **Review warnings**: Pay attention to warnings, not just errors
- **Fix issues immediately**: Don't ignore flake check results

## Build Testing

```bash
# Build configuration
nix build .#nixosConfigurations.hostname.config.system.build.toplevel

# Build and keep result
nix build .#nixosConfigurations.hostname.config.system.build.toplevel --keep-going

# Build with verbose output
nix build .#nixosConfigurations.hostname.config.system.build.toplevel --print-build-logs
```

- **Test builds before deploy**: Always build and verify
- **Keep build results**: For debugging and inspection
- **Review build logs**: Check for warnings in build output
- **Test all hosts**: Build all configurations, not just one

## Integration Testing with nixosTest

```nix
# tests/integration/basic.nix
{ nixpkgs, ... }:
{
  name = "basic-integration-test";

  nodes.machine = { pkgs, ... }: {
    # Define test machine
    services.openssh.enable = true;
    # ... other configuration
  };

  testScript = ''
    start_all()
    machine.wait_for_unit("sshd.service")
    machine.succeed("ssh -o StrictHostKeyChecking=no localhost 'echo hello'")
  '';
}
```

- **Use nixosTest**: For integration testing of configurations
- **Test services**: Verify services start and work correctly
- **Test connectivity**: Check network connectivity and access
- **Test user scenarios**: Simulate real user workflows

## Unit Testing Modules

```nix
# Test individual module
{ lib, pkgs, ... }:

lib.mkTest {
  test = ''
    # Test that module evaluates correctly
    (import <nixpkgs/nixos> {
      configuration = {
        imports = [ ./modules/module-under-test.nix ];
        # ... test configuration
      };
      system = "x86_64-linux";
    }).config.assertions should beEmpty
  '';
}
```

- **Test modules individually**: Verify each module works correctly
- **Test assertions**: Ensure module assertions are satisfied
- **Test option combinations**: Verify different option combinations
- **Test error cases**: Ensure proper errors for invalid configuration

## CI/CD Integration

```yaml
# .github/workflows/test.yml
name: Test NixOS Configurations

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v20
      - run: nix flake check
      - run: nix build .#nixosConfigurations.hostname1.config.system.build.toplevel
      - run: nix build .#nixosConfigurations.hostname2.config.system.build.toplevel
```

- **Automate tests**: Run tests in CI/CD pipeline
- **Build all configs**: Test all host configurations
- **Fail on warnings**: Treat warnings as failures
- **Cache dependencies**: Use Nix caching for faster builds

## Testing flake.nix

```bash
# Validate flake structure
nix flake info

# Validate inputs
nix flake metadata

# Check for locked inputs
nix show-lock

# Update lock file
nix flake update --dry-run
```

- **Validate flake**: Check flake structure and metadata
- **Review lock file**: Ensure all inputs are properly locked
- **Test updates**: Use `--dry-run` to see what would change
- **Document input versions**: Note important input versions

## Configuration Syntax Validation

```nix
# Use nixos-option to validate options
nixos-option services.openssh.enable

# Test option types
# (nix-instantiate will catch type errors)

# Validate module imports
# (Will fail if imports don't exist or have syntax errors)
```

- **Use nixos-option**: Check that options are valid
- **Catch type errors**: Nix will catch type mismatches
- **Validate imports**: Ensure all modules can be imported
- **Test option combinations**: Verify options work together

## Test Coverage

```markdown
# What to test

## Basic Configuration
- [ ] Configuration parses correctly
- [ ] All imports resolve
- [ ] No undefined options

## Services
- [ ] Services enable correctly
- [ ] Services start successfully
- [ ] Configuration is valid

## Network
- [ ] Network configuration is valid
- [ ] Firewall rules are correct
- [ ] SSH is accessible

## Security
- [ ] Secret management works
- [ ] Permissions are correct
- [ ] Security options are set
```

- **Create test checklist**: Ensure comprehensive coverage
- **Test each module**: Verify each module individually
- **Test integration**: Verify modules work together
- **Document test results**: Track what has been tested

## Testing Development Workflow

```bash
# In development environment

# 1. Check syntax
nix-instantiate --parse ./configuration.nix

# 2. Dry run build
nixos-rebuild dry-build

# 3. Full build test
nixos-rebuild build

# 4. Run tests
nix flake check

# 5. Deploy if all pass
nixos-rebuild switch
```

- **Follow workflow**: Use consistent testing workflow
- **Fail fast**: Catch errors early in the process
- **Test before deploy**: Never skip testing
- **Document process**: Make process clear to team members

## Property Testing

```nix
# Test that configuration satisfies certain properties
{ pkgs, ... }:
let
  config = import ./configuration.nix { inherit pkgs; };
in
{
  test_systemd_service_exists = pkgs.runCommand "test" {} ''
    ${pkgs.jq}/bin/jq -e '.systemd.units | has("myservice.service")' ${config} > /dev/null
    touch $out
  '';

  test_firewall_enabled = pkgs.runCommand "test" {} ''
    ${pkgs.jq}/bin/jq -e '.networking.firewall.enable == true' ${config} > /dev/null
    touch $out
  '';
}
```

- **Test configuration properties**: Verify configuration has expected attributes
- **Use jq for JSON**: Extract and validate configuration
- **Create small tests**: Focus on specific properties
- **Automate property checks**: Run automatically in CI

## Regression Testing

```bash
# After making changes

# 1. Compare configuration
nixos-rebuild dry-build --show-trace

# 2. Check differences
nix diff /run/current-system result

# 3. Review changes
nix show-derivation result
```

- **Compare configurations**: See what changed
- **Review diffs**: Understand impact of changes
- **Check derivations**: See what will be built
- **Document changes**: Note what changed and why

## Testing Hardware-Specific Config

```nix
# Test on actual hardware
{
  hardware = {
    enable = true;
    laptop = {
      enable = true;
      # Hardware-specific tests
    };
  };
}
```

- **Test on target hardware**: Hardware configuration needs real hardware testing
- **Test hardware features**: Verify touchpad, keyboard, etc. work
- **Document hardware quirks**: Note what requires special handling
- **Keep hardware config separate**: Separate from generic configuration

## Performance Testing

```bash
# Test build performance
time nix build .#nixosConfigurations.hostname.config.system.build.toplevel

# Test system boot time
systemd-analyze

# Test service startup time
systemd-analyze blame
```

- **Monitor build time**: Track changes in build performance
- **Analyze boot time**: Check system boot performance
- **Measure service startup**: Identify slow services
- **Document performance targets**: Set expectations for performance

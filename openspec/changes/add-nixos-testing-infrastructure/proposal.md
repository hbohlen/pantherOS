# Change: Add NixOS Configuration Testing Infrastructure

## Why

The system currently lacks comprehensive testing infrastructure for NixOS configurations, particularly for critical operations like disk partitioning (disko.nix). Current limitations:
- No way to test disko.nix partitioning schemes before live installation
- Limited validation of host configurations before deployment
- No automated integration tests for system configurations
- Difficult to catch configuration errors before they cause issues
- No CI/CD validation of configuration changes

Adding robust testing infrastructure would enable safe configuration changes and prevent deployment failures.

## What Changes

- Extend existing NixOS testing framework in `tests/integration/`
- Add VM-based testing for disko.nix partitioning schemes
- Create integration tests for each host configuration
- Add configuration validation tests (syntax, dependencies, module conflicts)
- Create disko.nix simulator for testing partition layouts
- Add pre-deployment validation scripts
- Integrate tests with development workflow and CI/CD
- Document testing procedures and best practices

## Impact

### Affected Specs
- Modified capability: `configuration` (add testing requirements)
- New capability: `nixos-testing` (test framework, validation, simulation)

### Affected Code
- Enhanced: `tests/integration/` with comprehensive test suite
- New: `tests/disko/` for disko.nix testing
- New: `tests/validation/` for configuration validation
- New: `scripts/test-disko.sh` for interactive disko testing
- New: `scripts/validate-config.sh` for pre-deployment checks
- Modified: `flake.nix` to include test infrastructure
- Modified: Development shell to include testing tools

### Benefits
- Safe testing of disk partitioning before installation
- Early detection of configuration errors
- Confidence in system deployments
- Faster iteration on configuration changes
- Documentation through test cases
- Reduced risk of data loss or system failures

### Considerations
- VM testing requires additional resources (CPU, RAM, disk)
- Test execution time may slow development workflow
- Maintaining tests requires discipline and updates
- Some tests may need privileged access or special setup

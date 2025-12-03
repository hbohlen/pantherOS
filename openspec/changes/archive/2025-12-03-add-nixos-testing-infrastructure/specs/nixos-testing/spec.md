# NixOS Testing Specification

## ADDED Requirements

### Requirement: Disko Configuration Testing
The system SHALL provide VM-based testing for disko.nix partitioning schemes before live installation.

#### Scenario: Test disko.nix in virtual machine
- **WHEN** running disko tests for a host configuration
- **THEN** a VM is created with the disko.nix configuration
- **AND** partitioning is performed in the VM
- **AND** test verifies partition layout, sizes, and mount points
- **AND** test completes without errors

#### Scenario: Simulate partition layout
- **WHEN** using the disko simulator
- **THEN** partition layout is visualized
- **AND** disk space allocation is calculated
- **AND** potential issues are identified (overlaps, insufficient space)
- **AND** recommendations are provided

#### Scenario: Test partition edge cases
- **WHEN** testing disko.nix edge cases
- **THEN** tests verify behavior with minimum disk sizes
- **AND** tests verify behavior with maximum partitions
- **AND** tests verify error handling for invalid configurations
- **AND** tests verify partition alignment requirements

### Requirement: Host Configuration Integration Testing
The system SHALL provide integration tests for each host configuration validating system boot, services, and module interactions.

#### Scenario: Test host configuration in VM
- **WHEN** running integration tests for a host
- **THEN** NixOS configuration is built for the host
- **AND** VM is created with the configuration
- **AND** system boots successfully
- **AND** critical services start correctly
- **AND** test results are reported

#### Scenario: Test service dependencies
- **WHEN** testing service interactions
- **THEN** service startup order is validated
- **AND** service dependencies are satisfied
- **AND** service health checks pass
- **AND** service restart behavior is tested

#### Scenario: Test module interactions
- **WHEN** testing module configurations
- **THEN** module option conflicts are detected
- **AND** module dependencies are validated
- **AND** module activation order is correct
- **AND** no circular dependencies exist

### Requirement: Configuration Validation
The system SHALL provide pre-deployment validation to catch configuration errors before they cause issues.

#### Scenario: Validate Nix syntax
- **WHEN** running configuration validation
- **THEN** all .nix files are parsed successfully
- **AND** syntax errors are reported with file and line number
- **AND** undefined variables are detected
- **AND** type errors are identified

#### Scenario: Validate module options
- **WHEN** validating module configuration
- **THEN** all option types are checked
- **AND** required options are present
- **AND** option values are within valid ranges
- **AND** deprecated options trigger warnings

#### Scenario: Validate secrets configuration
- **WHEN** validating secrets
- **THEN** all referenced secrets exist
- **AND** secret paths are correct
- **AND** secret permissions are appropriate
- **AND** OpNix configuration is valid

### Requirement: Test Framework
The system SHALL provide a comprehensive test framework with utilities, runners, and reporting.

#### Scenario: Run test suite
- **WHEN** executing the test suite
- **THEN** tests run in parallel for efficiency
- **AND** test progress is displayed
- **AND** test results are summarized (passed/failed/skipped)
- **AND** failed tests show detailed error information

#### Scenario: Run specific tests
- **WHEN** running specific test categories
- **THEN** only selected tests execute (e.g., disko tests only)
- **AND** test filtering by host or module is supported
- **AND** test execution time is optimized
- **AND** test results are cached when possible

#### Scenario: Test reporting
- **WHEN** tests complete
- **THEN** results are formatted for readability
- **AND** failures include reproduction steps
- **AND** test coverage metrics are generated
- **AND** results can be exported (JSON, TAP, JUnit)

### Requirement: Development Workflow Integration
The system SHALL integrate testing into the development workflow for fast feedback.

#### Scenario: Quick validation during development
- **WHEN** developer makes configuration changes
- **THEN** fast validation tests run automatically
- **AND** feedback is provided within 30 seconds
- **AND** critical errors block further changes
- **AND** warnings are highlighted for review

#### Scenario: Pre-commit validation
- **WHEN** committing configuration changes
- **THEN** validation tests run automatically
- **AND** commit is blocked if tests fail
- **AND** developer is notified of issues
- **AND** fix suggestions are provided

#### Scenario: CI/CD test execution
- **WHEN** pull request is created or updated
- **THEN** full test suite runs in CI
- **AND** test results are reported on PR
- **AND** merge is blocked if tests fail
- **AND** test trends are tracked over time

### Requirement: Documentation Through Tests
The system SHALL use tests as documentation examples showing correct configuration patterns.

#### Scenario: Test as example
- **WHEN** viewing a test case
- **THEN** test demonstrates a working configuration pattern
- **AND** test includes comments explaining the pattern
- **AND** test shows expected behavior clearly
- **AND** test can be adapted for similar use cases

#### Scenario: Generate documentation from tests
- **WHEN** generating documentation
- **THEN** test scenarios are extracted as examples
- **AND** configuration snippets are included
- **AND** expected outcomes are documented
- **AND** links to related tests are provided

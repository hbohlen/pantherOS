# Spec: Development Environment

## ADDED Requirements

### Container Runtime
The system must support rootless container execution.

#### Scenario: Podman
Given the user needs to run containers
When running `podman` commands
Then containers should run in rootless mode with Docker compatibility

### Development Tools
Essential development tools must be available system-wide.

#### Scenario: Tool Availability
Given the user opens a terminal
Then `git`, `nil`, and `nixd` should be available in the PATH

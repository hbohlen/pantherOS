# Spec: Devcontainer Configuration

## ADDED Requirements

### Requirement: The repository MUST contain a valid devcontainer configuration

The repository MUST include a `.devcontainer` directory with a valid `devcontainer.json` file that defines the development environment.

#### Scenario: Opening in Codespaces

Given I am viewing the repository on GitHub
When I choose to create a Codespace
Then the environment should initialize using the configuration in `.devcontainer/devcontainer.json`.

### Requirement: The devcontainer MUST have Nix installed with Flakes enabled

The devcontainer environment MUST include the Nix package manager and have the `flakes` experimental feature enabled by default.

#### Scenario: Checking Nix version

Given I am inside the devcontainer
When I run `nix --version`
Then I should see the Nix version output.

#### Scenario: Checking Flakes support

Given I am inside the devcontainer
When I run `nix flake show`
Then it should execute without erroring about experimental features.

### Requirement: The devcontainer MUST be able to build the hetzner-vps configuration

The devcontainer environment MUST be capable of building the `hetzner-vps` NixOS configuration defined in the flake.

#### Scenario: Building VPS config

Given I am inside the devcontainer
When I run `nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel`
Then the build should complete successfully (assuming valid config).

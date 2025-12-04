# Hercules CI Agent Implementation Summary

## Overview

This document summarizes the implementation of Hercules CI Agent integration for the pantherOS NixOS configuration repository. The integration enables continuous integration workflows powered by Hercules CI and Nix/NixOS.

## Implementation Date

December 4, 2024

## What Was Implemented

### 1. Host Configuration (`hosts/servers/hetzner-vps/hercules-ci.nix`)

Created a dedicated NixOS module for Hercules CI configuration on the hetzner-vps host. This module:

- Enables the CI infrastructure using the existing `modules/ci/default.nix` module
- Configures Hercules CI agent with cluster join token and binary cache settings
- Integrates with OpNix for secure secret management
- Defines systemd service dependencies to ensure secrets are available before the agent starts

**Key Features:**
- Uses `services.ci.herculesCI.enable = true` to activate Hercules CI
- Manages two secrets via OpNix/1Password:
  - `herculesClusterToken`: Cluster join token for agent authentication
  - `herculesBinaryCaches`: Binary cache credentials (JSON format)
- Ensures proper file permissions (0600) and ownership (hercules-ci-agent user)
- Adds service dependencies: `after` and `wants` onepassword-secrets.service

### 2. Host Import Update (`hosts/servers/hetzner-vps/default.nix`)

Updated the hetzner-vps host configuration to import the new hercules-ci.nix module:

```nix
imports = [
  ./hardware.nix
  ./hercules-ci.nix  # Added
  ../../../modules
];
```

### 3. Repository CI Configuration (`ci.nix`)

Created a root-level `ci.nix` file that defines Hercules CI build configuration:

- Specifies `x86_64-linux` as the target system
- Hercules CI automatically discovers:
  - All nixosConfigurations from flake.nix
  - All checks defined in the flake
  - All packages defined in the flake
  - Development shells

### 4. Documentation

Created comprehensive documentation in the `docs/` directory:

#### `docs/HERCULES_CI_SETUP.md` (8.6 KB)
Complete setup and operational guide covering:
- Architecture overview
- Prerequisites (Hercules CI account, 1Password vault)
- Step-by-step setup instructions
- Configuration details and module options
- Service management commands
- Troubleshooting guide for common issues
- Security considerations
- Integration with CI/CD workflows
- Links to additional resources

#### `docs/HERCULES_CI_VALIDATION.md` (9.3 KB)
Detailed validation and testing procedures:
- Pre-deployment validation steps
- Configuration syntax checking
- Module integration verification
- Service configuration checks
- Secret path validation
- Build testing procedures
- Post-deployment validation steps
- Service status verification
- Secret files and permissions checks
- Log analysis
- Agent registration verification
- Comprehensive troubleshooting guide
- Validation checklist

### 5. README Update

Updated the main `README.md` to include a new "Continuous Integration" section that:
- Introduces Hercules CI support
- Links to setup guide
- References the CI module and example configuration

### 6. OpenSpec Change Proposal

Created a complete OpenSpec change proposal under `openspec/changes/integrate-hercules-ci-agent/`:

- **proposal.md**: Explains why, what, and impact of the change
- **tasks.md**: Implementation checklist (all tasks completed)
- **specs/hercules-ci/spec.md**: Formal specification with requirements and scenarios covering:
  - Configuration module requirements
  - Secret management integration
  - Service dependencies
  - Documentation requirements
  - Configuration validation

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Hercules CI Dashboard                    │
│                   (https://hercules-ci.com)                  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            │ HTTPS
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                    hetzner-vps Host                          │
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │         hercules-ci-agent.service                  │    │
│  │                                                     │    │
│  │  Reads:                                            │    │
│  │  • /var/lib/hercules-ci-agent/secrets/            │    │
│  │    cluster-join-token.key                         │    │
│  │  • /var/lib/hercules-ci-agent/secrets/            │    │
│  │    binary-caches.json                             │    │
│  └──────────────────┬──────────────────────────────────┘    │
│                     │                                        │
│                     │ depends on                             │
│                     │                                        │
│  ┌──────────────────▼─────────────────────────────────┐    │
│  │      onepassword-secrets.service (OpNix)          │    │
│  │                                                     │    │
│  │  Fetches from 1Password:                          │    │
│  │  • op://pantherOS/hercules-ci/cluster-join-token  │    │
│  │  • op://pantherOS/hercules-ci/binary-caches       │    │
│  │                                                     │    │
│  │  Writes to files with correct permissions         │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Configuration Flow

1. **System Boot/Rebuild**
   - NixOS reads configuration from flake.nix
   - Imports hosts/servers/hetzner-vps/default.nix
   - Loads hercules-ci.nix module

2. **OpNix Secret Management**
   - onepassword-secrets.service starts
   - Connects to 1Password using token from /etc/opnix-token
   - Retrieves secrets from pantherOS vault
   - Writes secrets to /var/lib/hercules-ci-agent/secrets/
   - Sets correct ownership (hercules-ci-agent:hercules-ci-agent) and permissions (0600)

3. **Hercules CI Agent Startup**
   - Waits for onepassword-secrets.service to complete
   - Reads cluster join token
   - Reads binary caches configuration
   - Connects to Hercules CI infrastructure
   - Registers with the configured cluster
   - Begins listening for build jobs

## Secret Management

Secrets are managed through a secure chain:

1. **Storage**: Secrets stored in 1Password vault (`pantherOS`)
2. **Item**: `hercules-ci` item with two fields:
   - `cluster-join-token`: String containing the cluster join token
   - `binary-caches`: JSON string with cache configuration
3. **Retrieval**: OpNix service fetches secrets using 1Password CLI
4. **Distribution**: OpNix writes secrets to filesystem with proper permissions
5. **Consumption**: Hercules CI agent reads secrets from filesystem

**Security Features:**
- Secrets never committed to git
- File permissions restrict access to hercules-ci-agent user only (mode 0600)
- Directory permissions restrict access to hercules-ci-agent user only (mode 0700)
- Service runs as dedicated system user (hercules-ci-agent)
- Secrets automatically synced on system changes

## Files Changed

1. `README.md` - Added CI section
2. `hosts/servers/hetzner-vps/default.nix` - Added import for hercules-ci.nix
3. `hosts/servers/hetzner-vps/hercules-ci.nix` - New configuration module
4. `ci.nix` - New Hercules CI build configuration
5. `docs/HERCULES_CI_SETUP.md` - New setup guide
6. `docs/HERCULES_CI_VALIDATION.md` - New validation guide
7. `openspec/changes/integrate-hercules-ci-agent/proposal.md` - Change proposal
8. `openspec/changes/integrate-hercules-ci-agent/tasks.md` - Implementation tasks
9. `openspec/changes/integrate-hercules-ci-agent/specs/hercules-ci/spec.md` - Formal spec

## Next Steps for Users

To complete the integration, users need to:

1. **Obtain Hercules CI Cluster Join Token**
   - Sign up at https://hercules-ci.com
   - Create a cluster
   - Generate agent token

2. **Store Secrets in 1Password**
   - Add `hercules-ci` item to `pantherOS` vault
   - Add `cluster-join-token` field with the token
   - Add `binary-caches` field with JSON cache configuration

3. **Deploy Configuration**
   - Build and deploy the updated configuration to hetzner-vps
   - Configuration will automatically enable and start the agent

4. **Verify Installation**
   - Check service status: `sudo systemctl status hercules-ci-agent`
   - View logs: `sudo journalctl -u hercules-ci-agent -f`
   - Confirm agent appears in Hercules CI dashboard

5. **Configure Builds** (Optional)
   - Customize `ci.nix` for specific build requirements
   - Add effects for deployment automation
   - Configure notifications

## Benefits

1. **Native Nix Integration**: Hercules CI understands Nix/NixOS natively
2. **Secure Secret Management**: Leverages existing OpNix/1Password infrastructure
3. **Easy Configuration**: Simple declarative configuration via NixOS modules
4. **Comprehensive Documentation**: Step-by-step guides for setup and troubleshooting
5. **Validated Design**: Complete OpenSpec specification with test scenarios
6. **Service Dependencies**: Proper systemd dependencies ensure reliable startup
7. **Modular Design**: Can be easily enabled on other hosts by importing the module

## Related Infrastructure

This implementation builds on existing pantherOS infrastructure:

- **CI Module** (`modules/ci/default.nix`): Provides the base CI configuration
- **OpNix** (`opnix` flake input): Handles secret management
- **1Password**: Secret storage backend
- **Existing Example** (`docs/examples/hercules-ci-example.nix`): Reference implementation

## Testing Recommendations

Follow the validation guide (`docs/HERCULES_CI_VALIDATION.md`) to:

1. Verify configuration syntax before deployment
2. Check module integration and service configuration
3. Validate secret paths and OpNix configuration
4. Test build process
5. Verify post-deployment service status
6. Check secret files and permissions
7. Analyze logs for errors
8. Confirm agent registration in dashboard

## Support and Resources

- **Setup Guide**: `docs/HERCULES_CI_SETUP.md`
- **Validation Guide**: `docs/HERCULES_CI_VALIDATION.md`
- **CI Module**: `modules/ci/README.md`
- **Example Config**: `docs/examples/hercules-ci-example.nix`
- **Official Docs**: https://docs.hercules-ci.com
- **OpenSpec Proposal**: `openspec/changes/integrate-hercules-ci-agent/`

## Conclusion

The Hercules CI Agent integration is fully implemented and ready for deployment. All configuration files, documentation, and validation procedures are in place. Users need only to obtain their Hercules CI credentials, store them in 1Password, and deploy the configuration to activate the agent.

The implementation follows NixOS best practices, integrates seamlessly with existing infrastructure, and provides comprehensive documentation for setup, operation, and troubleshooting.

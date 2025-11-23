# Secret Management with 1Password

This document describes how pantherOS manages secrets using 1Password service account integration.

## Overview

pantherOS uses 1Password as the single source of truth for all secrets, managed via the `pantherOS` service account. The OpNix integration provides secure access to these secrets during system configuration and operation.

## 1Password Service Account Setup

The 1Password service account is configured with the following parameters:

- **Vault**: `pantherOS`
- **Service Account**: `pantherOS`
- **Token**: Stored securely and accessed via OpNix

## Secret Paths Mapping

All secrets are organized in the 1Password vault with specific paths for different services:

### Backblaze B2

- `op://pantherOS/backblaze-b2/default/endpoint`
- `op://pantherOS/backblaze-b2/default/region`
- `op://pantherOS/backblaze-b2/master/keyID`
- `op://pantherOS/backblaze-b2/master/keyName`
- `op://pantherOS/backblaze-b2/master/applicationKey`
- `op://pantherOS/backblaze-b2/pantherOS-nix-cache/keyID`
- `op://pantherOS/backblaze-b2/pantherOS-nix-cache/keyName`
- `op://pantherOS/backblaze-b2/pantherOS-nix-cache/applicationKey`

### GitHub Personal Access Token

- `op://pantherOS/github-pat/token`

### Tailscale

- `op://pantherOS/Tailscale/authKey`

### 1Password Service Account Token

- `op://pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token`

### Datadog

- `op://pantherOS/datadog/default/DD_HOST`
- `op://pantherOS/datadog/pantherOS/APPLICATION_KEY`
- `op://pantherOS/datadog/pantherOS/KEY_ID`
- `op://pantherOS/datadog/hetzner-vps/API_KEY`
- `op://pantherOS/datadog/hetzner-vps/KEY_ID`

## Implementation Details

### System-Level Secrets

System-level services access secrets through secure file paths or environment variables provided by the OpNix integration. The 1Password module handles authentication and retrieval of secrets during system activation.

### User-Level Secrets

User-level configurations access secrets through Home Manager integration with 1Password, following the same secure patterns as system-level configurations.

## Security Considerations

- No secrets are committed to the repository
- All secrets are accessed dynamically during system activation
- Service account tokens are stored securely and rotated regularly
- Access to secrets is limited based on host classification (workstation vs server)

## Troubleshooting

### Secret Retrieval Issues

If secrets are not being retrieved properly:

1. Verify the 1Password service account token is correctly configured
2. Check that the vault name matches the configuration
3. Confirm that the paths in 1Password match the expected paths in the configuration
4. Ensure the OpNix integration is properly enabled in the system configuration

### Host-Specific Access

Different hosts may have access to different subsets of secrets based on their role and security requirements. Check the host-specific configuration to verify which secrets are available.
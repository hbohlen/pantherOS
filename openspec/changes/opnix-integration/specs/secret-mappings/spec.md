# Spec Delta: Secret Mappings Configuration

## Overview
This specification defines the requirements for configuring secret mappings that connect 1Password vault items to filesystem locations with proper ownership and permissions.

## ADDED Requirements

### Create secrets.json configuration
**Requirement**: Create a secrets.json configuration file that defines the mappings between 1Password vault items and filesystem locations for all required secrets.

**File**: `hosts/servers/hetzner-cloud/secrets.json`  
**Type**: ADDED

#### Scenario: Secrets configuration file created
Given the OpNix service configuration, when secrets.json is created, then:
- File contains declarative mappings for all 5 required secrets
- JSON format follows OpNix configuration schema
- File is referenced in OpNix service configuration

#### Scenario: All specified secrets are mapped
Given the secrets configuration, when secret mappings are defined, then:
- `openai-api-key` maps to `/run/secrets/openai-api-key`
- `datadog-api-key` maps to `/run/secrets/datadog-api-key`
- `cloudflare-api-token` maps to `/run/secrets/cloudflare-token`
- `backblaze-credentials` maps to `/run/secrets/backblaze-credentials.json`
- `opencode-env` maps to `/run/secrets/opencode.env`

### Configure secret ownership and permissions

**Requirement**: Configure proper file ownership and permissions for all secrets to ensure appropriate access control while maintaining security boundaries between different services.

**File**: `hosts/servers/hetzner-cloud/secrets.json`  
**Type**: ADDED

#### Scenario: Opencode user secrets have correct ownership
Given the secret mappings, when secrets are created, then:
- `openai-api-key` is owned by `opencode:opencode` with mode `0400`
- `datadog-api-key` is owned by `opencode:opencode` with mode `0400`
- `backblaze-credentials.json` is owned by `opencode:opencode` with mode `0400`
- `opencode.env` is owned by `opencode:opencode` with mode `0400`

#### Scenario: Caddy user secrets have correct ownership
Given the secret mappings, when secrets are created, then:
- `cloudflare-token` is owned by `caddy:caddy` with mode `0400`
- Reverse proxy services can read Cloudflare credentials

### Configure 1Password item references

**Requirement**: Configure proper 1Password item references using the op:// URI format to enable OpNix to retrieve secrets from the Infrastructure Secrets vault.

**File**: `hosts/servers/hetzner-cloud/secrets.json`  
**Type**: ADDED

#### Scenario: Direct field references work correctly
Given the secret mappings, when 1Password items are accessed, then:
- `openai-api-key` retrieves from `op://Infrastructure Secrets/openai-api-key/password`
- `datadog-api-key` retrieves from `op://Infrastructure Secrets/datadog-api-key/password`
- `cloudflare-token` retrieves from `op://Infrastructure Secrets/cloudflare-api-token/credential`

#### Scenario: Complex field references work correctly
Given the secret mappings, when 1Password items are accessed, then:
- `backblaze-credentials` retrieves from `op://Infrastructure Secrets/backblaze-b2/notesPlain`
- Content is parsed as JSON with `key_id` and `app_key` fields

### Configure template-based composite secret
**Requirement**: Configure a template-based composite secret (opencode-env) that combines multiple individual secrets into a single environment file with proper variable substitution.

**File**: `hosts/servers/hetzner-cloud/secrets.json`  
**Type**: ADDED

#### Scenario: Opencode-env template generates correctly
Given the secret mappings, when the composite secret is created, then:
- Template contains variable substitution for: `OPENAI_API_KEY`, `DD_API_KEY`, `DD_SITE`, `B2_KEY_ID`, `B2_APP_KEY`, `B2_BUCKET`, `FALKORDB_HOST`, `VALKEY_HOST`, `FALKORDB_PORT`, `VALKEY_PORT`
- Final file is a properly formatted environment file
- All referenced variables are substituted with actual secret values

#### Scenario: Template maintains environment file format
Given the template generation, when the env file is created, then:
- File follows standard environment file format (`KEY=value`)
- No literal variable references remain in output
- File is readable by standard environment file parsers

## Implementation Details

### Secret Mapping Structure
```json
{
  "secrets": [
    {
      "name": "openai-api-key",
      "opItem": "Infrastructure Secrets/openai-api-key",
      "opField": "password",
      "target": "/run/secrets/openai-api-key",
      "owner": "opencode:opencode",
      "mode": "0400"
    },
    {
      "name": "datadog-api-key",
      "opItem": "Infrastructure Secrets/datadog-api-key", 
      "opField": "password",
      "target": "/run/secrets/datadog-api-key",
      "owner": "opencode:opencode",
      "mode": "0400"
    },
    {
      "name": "cloudflare-api-token",
      "opItem": "Infrastructure Secrets/cloudflare-api-token",
      "opField": "credential", 
      "target": "/run/secrets/cloudflare-token",
      "owner": "caddy:caddy",
      "mode": "0400"
    },
    {
      "name": "backblaze-credentials",
      "opItem": "Infrastructure Secrets/backblaze-b2",
      "opField": "notesPlain",
      "target": "/run/secrets/backblaze-credentials.json",
      "owner": "opencode:opencode", 
      "mode": "0400"
    },
    {
      "name": "opencode-env",
      "template": {
        "OPENAI_API_KEY": "${openai-api-key}",
        "DD_API_KEY": "${datadog-api-key}",
        "DD_SITE": "datadoghq.com",
        "B2_KEY_ID": "${backblaze-credentials:key_id}",
        "B2_APP_KEY": "${backblaze-credentials:app_key}", 
        "B2_BUCKET": "pantheros-backups",
        "FALKORDB_HOST": "127.0.0.1",
        "VALKEY_HOST": "127.0.0.1",
        "FALKORDB_PORT": "6379",
        "VALKEY_PORT": "6379"
      },
      "target": "/run/secrets/opencode.env",
      "owner": "opencode:opencode",
      "mode": "0400"
    }
  ]
}
```

### OpNix Service Integration
```nix
services.onepassword-secrets = {
  enable = true;
  users = [ "root" "opencode" ];
  tokenFile = "/root/.config/op/token";
  secretsFile = ./secrets.json;  # Reference to configuration file
};
```

## Validation Criteria

### File Creation
- [ ] secrets.json file exists and is valid JSON
- [ ] All 5 secrets are defined in the configuration
- [ ] File is referenced in OpNix service configuration

### Secret Availability
- [ ] All secrets appear in `/run/secrets/` after service activation
- [ ] File contents match expected 1Password item values
- [ ] Template-generated secrets contain substituted variables

### Permissions
- [ ] All files have mode `0400` (read-only for owner)
- [ ] Ownership matches specification (`opencode:opencode` or `caddy:caddy`)
- [ ] Files are readable by intended users/groups

### Integration
- [ ] Services can read secrets via LoadCredential
- [ ] EnvironmentFile integration works for systemd services
- [ ] No secrets exposed in system logs or nix store

## Dependencies
- **Service Configuration**: Requires OpNix service to be enabled
- **1Password Vault**: Requires "Infrastructure Secrets" vault to exist
- **User Setup**: Requires opencode and caddy users to exist

## Related Capabilities
- **Service Configuration**: Builds on enabled OpNix service
- **Bootstrap Process**: Documents how to verify secret availability
- **Persistence Setup**: Ensures secrets cleared on reboot (ramfs)

## Error Handling

### Missing 1Password Items
- Service logs appropriate errors for missing items
- Individual secret failures don't prevent other secrets from being created
- System continues to function with available secrets

### Permission Errors
- Clear error messages when ownership/permission configuration is invalid
- Graceful handling when users/groups don't exist
- Fallback to reasonable defaults when possible

### Template Processing Errors
- Validation of template syntax before processing
- Clear errors when referenced variables don't exist
- Template processing continues for valid variables
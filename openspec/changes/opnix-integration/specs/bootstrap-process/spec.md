# Spec Delta: OpNix Bootstrap Process

## Overview
This specification defines the requirements for the manual bootstrap process needed to initially provision the 1Password service account token, enabling the OpNix service to function after system deployment.

## ADDED Requirements

### Document manual token setup process
**Requirement**: Provide comprehensive documentation for the manual bootstrap process required to initially provision the 1Password service account token for OpNix functionality.

**File**: `hosts/servers/hetzner-cloud/README.md` (or similar)  
**Type**: ADDED

#### Scenario: Clear step-by-step bootstrap instructions
Given the NixOS configuration is deployed, when an administrator follows the bootstrap process, then:
- Instructions clearly explain obtaining the service account token
- Instructions specify exact file location for token placement
- Instructions include validation steps to confirm setup success

#### Scenario: Bootstrap works for administrators
Given the bootstrap documentation, when followed correctly, then:
- Token file is created at `/root/.config/op/token`
- OpNix service can authenticate with 1Password after setup
- All configured secrets become available in `/run/secrets/`

### Provide validation commands
**Requirement**: Provide clear validation commands and expected outputs to verify that the OpNix bootstrap process completed successfully and all secrets are available.

**File**: `hosts/servers/hetzner-cloud/README.md`  
**Type**: ADDED

#### Scenario: Service status verification
Given the bootstrap process is complete, when validation commands are run, then:
- `systemctl status onepassword-secrets` shows active service
- Service logs show successful 1Password authentication
- No authentication errors in service logs

#### Scenario: Secret availability verification
Given the bootstrap process is complete, when validation commands are run, then:
- `ls -la /run/secrets/` shows all 5 configured secrets
- Secret files have correct ownership and permissions
- File contents match expected 1Password item values

### Handle initial deployment scenarios
**Requirement**: Address various initial deployment scenarios including fresh system deployment and configuration rebuilds to ensure the bootstrap process works in all expected contexts.

**File**: `hosts/servers/hetzner-cloud/README.md`  
**Type**: ADDED

#### Scenario: Fresh system deployment
Given a fresh NixOS system, when the bootstrap process is followed, then:
- Initial NixOS configuration includes OpNix service
- System boots successfully even without token (service fails gracefully)
- Bootstrap process can be completed via SSH after initial boot

#### Scenario: Configuration rebuild after token setup
Given the token is set up and configuration is rebuilt, when `nixos-rebuild switch` is executed, then:
- OpNix service starts successfully with existing token
- Secrets become immediately available
- No manual intervention required for rebuilds

## Implementation Details

### Bootstrap Process Documentation
```markdown
# OpNix Bootstrap Process

## Prerequisites
- NixOS system deployed with OpNix configuration
- SSH access to system as root
- 1Password service account token

## Step 1: Obtain Service Account Token
1. Log into your 1Password account
2. Navigate to Developer Settings → Service Accounts
3. Create or select the "pantherOS" service account
4. Generate a new token with read-only access to "Infrastructure Secrets" vault
5. Copy the token (it will only be shown once)

## Step 2: Deploy Token to System
```bash
# SSH to your hetzner-vps system
ssh root@your-server-ip

# Create token file
mkdir -p /root/.config/op
echo "your-service-account-token-here" > /root/.config/op/token

# Set correct permissions
chmod 600 /root/.config/op/token
```

## Step 3: Activate OpNix Configuration
```bash
# If not already activated, rebuild with OpNix
cd /etc/nixos
git pull  # if configuration is in git
nixos-rebuild switch

# Or if updating existing configuration
nixos-rebuild switch --flake .#hetzner-vps
```

## Step 4: Validate Setup
```bash
# Check service status
systemctl status onepassword-secrets

# Verify secrets are available
ls -la /run/secrets/

# Check service logs for errors
journalctl -u onepassword-secrets -f
```

## Expected Results
- Service should show as "active (running)"
- `/run/secrets/` should contain 5 secret files
- No authentication errors in logs
- All secrets should have correct ownership (0400 permissions)

## Troubleshooting
If service fails to start:
1. Check token file exists: `ls -la /root/.config/op/token`
2. Verify token format (should be a single line)
3. Check network connectivity to 1Password API
4. Review service logs: `journalctl -u onepassword-secrets`
```

### Service Account Token Format
- Single line text file
- No trailing newlines or whitespace
- Read-only permissions (600)
- Stored in `/root/.config/op/token`

### Expected Validation Output
```bash
$ systemctl status onepassword-secrets
● onepassword-secrets.service - OpNix Secret Management
   Loaded: loaded (/etc/systemd/system/onepassword-secrets.service; enabled)
   Active: active (running) since Wed 2025-11-19 22:55:00 UTC; 2min ago

$ ls -la /run/secrets/
total 0
drwxr-xr-x 2 root root 60 Nov 19 22:55 .
drwxr-xr-x 1 root root 60 Nov 19 22:55 ..
-r-------- 1 opencode opencode  51 Nov 19 22:55 backblaze-credentials.json
-r-------- 1 root     root     51 Nov 19 22:55 cloudflare-token
-r-------- 1 caddy    caddy    51 Nov 19 22:55 datadog-api-key
-r-------- 1 opencode opencode  51 Nov 19 22:55 openai-api-key
-r-------- 1 opencode opencode 251 Nov 19 22:55 opencode.env
```

## Validation Criteria

### Bootstrap Completeness
- [ ] Documentation covers all required steps
- [ ] Commands are copy-pasteable and tested
- [ ] Troubleshooting section addresses common issues
- [ ] Prerequisites are clearly listed

### Process Validation
- [ ] Token setup works as documented
- [ ] Service starts successfully after token placement
- [ ] All secrets become available after service activation
- [ ] Validation commands produce expected output

### Error Handling
- [ ] Clear error messages for common failure scenarios
- [ ] Step-by-step recovery procedures
- [ ] Links to additional resources if needed

## Dependencies
- **Service Configuration**: Requires OpNix service to be enabled
- **Secret Mappings**: Requires secret configuration to be defined
- **1Password Account**: Requires access to create service account token

## Related Capabilities
- **Service Configuration**: Bootstrap enables service to function
- **Secret Mappings**: Bootstrap makes secret fetching possible
- **Persistence Setup**: Token setup leverages persistence mechanism

## Security Considerations

### Token Security
- Manual bootstrap ensures token is never in Git or nix store
- Clear instructions for secure token handling
- Immediate permission restrictions (600) on token file

### Access Control
- Bootstrap requires root access (appropriate for initial setup)
- Service account has minimal required permissions
- Clear separation between bootstrap and operational phases

### Documentation Security
- No actual tokens in documentation
- Clear warnings about token sensitivity
- Guidance on secure token storage and handling

## Operational Considerations

### Maintenance
- Token may need rotation (documented process)
- Service account permissions review process
- Clear upgrade path for configuration changes

### Monitoring
- Service status indicates bootstrap success
- Log monitoring shows authentication issues
- Clear health check procedures

### Recovery
- Clear procedures if token is lost or compromised
- Graceful degradation if 1Password API is unavailable
- Rollback procedures for configuration issues

## Automation Opportunities

### Future Enhancements
- Initial bootstrap could be automated via cloud-init
- Token setup via orchestration system
- Health checks integrated into deployment pipeline

### Current Limitations
- Manual intervention required for initial setup
- No automated recovery for token issues
- Bootstrap tied to specific host deployment process
# Hercules CI Integration Validation Guide

This document provides validation steps and testing procedures for the Hercules CI Agent integration.

## Pre-Deployment Validation

### 1. Configuration Syntax Check

Verify the Nix configuration is syntactically correct:

```bash
# Check the hercules-ci.nix module syntax
nix-instantiate --parse hosts/servers/hetzner-vps/hercules-ci.nix

# Check the entire hetzner-vps configuration
nix eval .#nixosConfigurations.hetzner-vps.config.system.build.toplevel --show-trace
```

Expected result: No syntax errors

### 2. Module Integration Check

Verify that the hercules-ci.nix module is properly imported:

```bash
# List all imported modules for hetzner-vps
nix eval .#nixosConfigurations.hetzner-vps.config.imports --json | jq
```

Expected result: Should include `./hercules-ci.nix`

### 3. Service Configuration Check

Verify the Hercules CI service is enabled:

```bash
# Check if services.ci.enable is set
nix eval .#nixosConfigurations.hetzner-vps.config.services.ci.enable

# Check if services.ci.herculesCI.enable is set
nix eval .#nixosConfigurations.hetzner-vps.config.services.ci.herculesCI.enable

# Check if hercules-ci-agent service is enabled
nix eval .#nixosConfigurations.hetzner-vps.config.systemd.services.hercules-ci-agent.enable
```

Expected result: All should return `true`

### 4. Secret Path Configuration Check

Verify OpNix secret paths are correctly configured:

```bash
# Check cluster token path
nix eval .#nixosConfigurations.hetzner-vps.config.services.ci.herculesCI.clusterJoinTokenPath --raw

# Check binary caches path
nix eval .#nixosConfigurations.hetzner-vps.config.services.ci.herculesCI.binaryCachesPath --raw
```

Expected results:
- Cluster token: `/var/lib/hercules-ci-agent/secrets/cluster-join-token.key`
- Binary caches: `/var/lib/hercules-ci-agent/secrets/binary-caches.json`

### 5. OpNix Secret Configuration Check

Verify OpNix secrets are properly defined:

```bash
# List all OpNix secrets
nix eval .#nixosConfigurations.hetzner-vps.config.services.onepassword-secrets.secrets --json | jq 'keys'

# Check herculesClusterToken secret
nix eval .#nixosConfigurations.hetzner-vps.config.services.onepassword-secrets.secrets.herculesClusterToken --json | jq

# Check herculesBinaryCaches secret
nix eval .#nixosConfigurations.hetzner-vps.config.services.onepassword-secrets.secrets.herculesBinaryCaches --json | jq
```

Expected result: Both secrets should be present with correct references and paths

### 6. Build Test

Perform a dry build to verify the configuration is valid:

```bash
# Build the hetzner-vps configuration (dry run)
nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel --dry-run

# If the above succeeds, do a real build (optional)
nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel -o result-hetzner-vps
```

Expected result: Build should complete without errors

## Post-Deployment Validation

After deploying the configuration to the hetzner-vps host, perform these validation steps:

### 1. Service Status Check

```bash
# Check if service is active
sudo systemctl is-active hercules-ci-agent

# Check if service is enabled
sudo systemctl is-enabled hercules-ci-agent

# View detailed status
sudo systemctl status hercules-ci-agent
```

Expected results:
- Active status: `active`
- Enabled status: `enabled`
- Status should show "running" with no errors

### 2. Secret Files Check

```bash
# Verify secrets directory exists
sudo ls -la /var/lib/hercules-ci-agent/secrets/

# Check cluster token file
sudo test -f /var/lib/hercules-ci-agent/secrets/cluster-join-token.key && echo "Token file exists"
sudo stat -c "%a %U:%G" /var/lib/hercules-ci-agent/secrets/cluster-join-token.key

# Check binary caches file
sudo test -f /var/lib/hercules-ci-agent/secrets/binary-caches.json && echo "Caches file exists"
sudo stat -c "%a %U:%G" /var/lib/hercules-ci-agent/secrets/binary-caches.json
```

Expected results:
- Both files exist
- File permissions: `600 hercules-ci-agent:hercules-ci-agent`
- Files should contain valid content (not empty)

### 3. Secret Content Validation

```bash
# Verify token is not empty (without revealing content)
sudo test -s /var/lib/hercules-ci-agent/secrets/cluster-join-token.key && echo "Token file has content"

# Verify binary caches is valid JSON
sudo cat /var/lib/hercules-ci-agent/secrets/binary-caches.json | jq empty && echo "Valid JSON"
```

Expected results:
- Token file has content
- Binary caches file is valid JSON

### 4. Service Dependencies Check

```bash
# Check service dependencies
systemctl show hercules-ci-agent | grep -E "(After|Wants|Requires)="

# Verify OpNix service ran before Hercules CI
sudo journalctl -u onepassword-secrets -u hercules-ci-agent --no-pager | grep -E "(Started|Starting)"
```

Expected results:
- Should show dependency on `onepassword-secrets.service`
- OpNix service should have started before Hercules CI

### 5. Network Connectivity Check

```bash
# Check if agent can reach Hercules CI
curl -v https://hercules-ci.com 2>&1 | grep "Connected"

# Check DNS resolution
nslookup hercules-ci.com
```

Expected results:
- Should successfully connect to hercules-ci.com
- DNS should resolve correctly

### 6. Log Analysis

```bash
# View recent logs
sudo journalctl -u hercules-ci-agent -n 50 --no-pager

# Check for errors
sudo journalctl -u hercules-ci-agent -p err --no-pager

# Check for connection messages
sudo journalctl -u hercules-ci-agent | grep -i "connect" | tail -10
```

Expected results:
- No critical errors in logs
- Should see successful connection messages
- Agent should be registered with the cluster

### 7. Agent Registration Verification

1. Log in to Hercules CI dashboard at https://hercules-ci.com
2. Navigate to your cluster's agents page
3. Verify `hetzner-vps` agent is listed
4. Check agent status shows "Connected" or "Idle"
5. Verify agent's last seen timestamp is recent

### 8. Build Trigger Test (Optional)

If you want to test build functionality:

```bash
# Trigger a build from the dashboard, or
# Push a commit to the repository and check if Hercules CI picks it up
```

Expected result: Builds should trigger and complete successfully

## Troubleshooting Failed Validations

### If Service Won't Start

1. Check OpNix service:
   ```bash
   sudo systemctl status onepassword-secrets
   sudo journalctl -u onepassword-secrets -n 50
   ```

2. Verify OpNix token is valid:
   ```bash
   sudo cat /etc/opnix-token
   ```

3. Check 1Password connection:
   ```bash
   # OpNix should log connection status
   sudo journalctl -u onepassword-secrets | grep -i "1password\|error"
   ```

### If Secrets Are Missing

1. Restart OpNix service:
   ```bash
   sudo systemctl restart onepassword-secrets
   sleep 5
   sudo systemctl restart hercules-ci-agent
   ```

2. Verify 1Password vault structure:
   - Vault: `pantherOS`
   - Item: `hercules-ci`
   - Field: `cluster-join-token` (contains the token string)
   - Field: `binary-caches` (contains JSON configuration)

3. Check OpNix logs for retrieval errors:
   ```bash
   sudo journalctl -u onepassword-secrets -p err --no-pager
   ```

### If Agent Can't Connect

1. Check network configuration:
   ```bash
   sudo systemctl status systemd-networkd
   ip addr show
   ip route show
   ```

2. Test HTTPS connectivity:
   ```bash
   curl -v https://hercules-ci.com
   ```

3. Check firewall rules:
   ```bash
   sudo nft list ruleset | grep -A 10 "chain output"
   ```

### If Permissions Are Wrong

```bash
# Fix directory permissions
sudo chown -R hercules-ci-agent:hercules-ci-agent /var/lib/hercules-ci-agent
sudo chmod 700 /var/lib/hercules-ci-agent/secrets
sudo chmod 600 /var/lib/hercules-ci-agent/secrets/*

# Restart service
sudo systemctl restart hercules-ci-agent
```

## Validation Checklist

Use this checklist to ensure complete validation:

### Pre-Deployment
- [ ] Nix syntax is valid
- [ ] Module is properly imported
- [ ] Services are configured
- [ ] Secret paths are correct
- [ ] OpNix secrets are defined
- [ ] Configuration builds successfully

### Post-Deployment
- [ ] Service is active and enabled
- [ ] Secret files exist with correct permissions
- [ ] Secret content is valid and not empty
- [ ] Service dependencies are correct
- [ ] Network connectivity works
- [ ] Logs show no critical errors
- [ ] Agent is registered in Hercules CI dashboard
- [ ] Agent shows as connected/idle

### Functional Testing (Optional)
- [ ] Agent successfully receives builds
- [ ] Builds complete successfully
- [ ] Build results appear in dashboard
- [ ] Notifications work (if configured)

## Success Criteria

The integration is considered successful when:

1. ✅ All pre-deployment validation checks pass
2. ✅ Service starts and runs without errors
3. ✅ Agent appears in Hercules CI dashboard as connected
4. ✅ Secrets are properly populated and accessible
5. ✅ No permission or configuration errors in logs
6. ✅ (Optional) Test build completes successfully

## Related Documentation

- [Hercules CI Setup Guide](HERCULES_CI_SETUP.md) - Initial setup instructions
- [CI Module README](../modules/ci/README.md) - CI module documentation
- [Hercules CI Official Docs](https://docs.hercules-ci.com) - Official documentation

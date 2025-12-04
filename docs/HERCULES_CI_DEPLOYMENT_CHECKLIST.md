# Hercules CI Deployment Checklist

Use this checklist to deploy Hercules CI Agent to your hetzner-vps host.

## Pre-Deployment Checklist

### 1. Hercules CI Account Setup
- [ ] Sign up for Hercules CI account at https://hercules-ci.com
- [ ] Create a new cluster in the dashboard
- [ ] Generate an agent token for the cluster
- [ ] Copy the cluster join token (long string)

### 2. 1Password Configuration
- [ ] Open 1Password and navigate to `pantherOS` vault
- [ ] Create new item named `hercules-ci` (or find existing)
- [ ] Add field `cluster-join-token` with your token from step 1
- [ ] Add field `binary-caches` with JSON configuration:
  ```json
  {
    "mycache": {
      "kind": "CachixCache",
      "authToken": "REPLACE_WITH_YOUR_CACHIX_TOKEN"
    }
  }
  ```
- [ ] Obtain Cachix token from https://cachix.org (if using Cachix)
- [ ] Replace `REPLACE_WITH_YOUR_CACHIX_TOKEN` with actual token
- [ ] Save the 1Password item

### 3. Local Validation
- [ ] Pull the latest code from the PR branch
- [ ] Verify configuration syntax:
  ```bash
  nix-instantiate --parse hosts/servers/hetzner-vps/hercules-ci.nix
  ```
- [ ] Check if services are enabled:
  ```bash
  nix eval .#nixosConfigurations.hetzner-vps.config.services.ci.herculesCI.enable
  ```
- [ ] Verify the configuration builds:
  ```bash
  nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel --dry-run
  ```

## Deployment

### 4. Deploy to VPS

Choose one of these methods:

**Option A: Remote Deployment (from local machine)**
```bash
nixos-rebuild switch --flake .#hetzner-vps --target-host root@YOUR_VPS_IP
```

**Option B: Local Deployment (on VPS)**
```bash
# SSH into VPS
ssh root@YOUR_VPS_IP

# Pull latest code
cd /path/to/pantherOS
git pull

# Deploy
sudo nixos-rebuild switch --flake .#hetzner-vps
```

### 5. Wait for Deployment
- [ ] Deployment completes without errors
- [ ] System rebuilds successfully
- [ ] No syntax or configuration errors

## Post-Deployment Verification

### 6. Service Status Check
```bash
# Check if service is active
sudo systemctl is-active hercules-ci-agent

# Expected: active

# Check if service is enabled
sudo systemctl is-enabled hercules-ci-agent

# Expected: enabled

# View detailed status
sudo systemctl status hercules-ci-agent
```

- [ ] Service status is "active (running)"
- [ ] No errors in status output

### 7. Secret Files Check
```bash
# List secrets directory
sudo ls -la /var/lib/hercules-ci-agent/secrets/
```

Expected files:
- [ ] `cluster-join-token.key` exists
- [ ] `binary-caches.json` exists
- [ ] Both files owned by `hercules-ci-agent:hercules-ci-agent`
- [ ] Both files have permissions `600`

### 8. Secret Content Validation
```bash
# Check token file has content
sudo test -s /var/lib/hercules-ci-agent/secrets/cluster-join-token.key && echo "Token OK"

# Validate binary-caches is valid JSON
sudo cat /var/lib/hercules-ci-agent/secrets/binary-caches.json | jq empty && echo "JSON OK"
```

- [ ] Token file has content
- [ ] Binary caches is valid JSON

### 9. Log Analysis
```bash
# View recent logs
sudo journalctl -u hercules-ci-agent -n 50

# Check for errors
sudo journalctl -u hercules-ci-agent -p err --no-pager
```

- [ ] No critical errors in logs
- [ ] Service started successfully
- [ ] Agent connected to Hercules CI

### 10. Dashboard Verification
- [ ] Log in to Hercules CI dashboard
- [ ] Navigate to your cluster's agents page
- [ ] Agent `hetzner-vps` appears in the list
- [ ] Agent status shows "Connected" or "Idle"
- [ ] Last seen timestamp is recent (within last minute)

### 11. Network Connectivity
```bash
# Test HTTPS connection
curl -v https://hercules-ci.com 2>&1 | grep "Connected"
```

- [ ] Successfully connects to hercules-ci.com

## Troubleshooting

If any checks fail, refer to:

### Service Not Active
```bash
# Check OpNix service
sudo systemctl status onepassword-secrets

# Restart services
sudo systemctl restart onepassword-secrets
sleep 5
sudo systemctl restart hercules-ci-agent
```

### Secrets Not Created
```bash
# Check OpNix logs
sudo journalctl -u onepassword-secrets -n 50

# Verify OpNix token
sudo cat /etc/opnix-token

# Manually trigger OpNix
sudo systemctl restart onepassword-secrets
```

### Permission Errors
```bash
# Fix permissions
sudo chown -R hercules-ci-agent:hercules-ci-agent /var/lib/hercules-ci-agent
sudo chmod 700 /var/lib/hercules-ci-agent/secrets
sudo chmod 600 /var/lib/hercules-ci-agent/secrets/*
sudo systemctl restart hercules-ci-agent
```

### Agent Not Connecting
```bash
# View connection logs
sudo journalctl -u hercules-ci-agent | grep -i "connect\|error" | tail -20

# Verify token is correct
# (Compare first/last few characters without revealing full token)
```

## Additional Resources

- **Full Setup Guide**: [HERCULES_CI_SETUP.md](HERCULES_CI_SETUP.md)
- **Validation Guide**: [HERCULES_CI_VALIDATION.md](HERCULES_CI_VALIDATION.md)
- **Quick Reference**: [HERCULES_CI_QUICK_REFERENCE.md](HERCULES_CI_QUICK_REFERENCE.md)
- **Implementation Summary**: [../HERCULES_CI_IMPLEMENTATION.md](../HERCULES_CI_IMPLEMENTATION.md)

## Success Criteria

All of the following must be true:

- ✅ Hercules CI service is active and running
- ✅ Secret files exist with correct permissions
- ✅ No errors in service logs
- ✅ Agent registered and connected in Hercules CI dashboard
- ✅ Agent status is "Connected" or "Idle"
- ✅ Network connectivity to Hercules CI is working

## Next Steps After Successful Deployment

1. **Configure Repository Builds**
   - Customize `ci.nix` for specific build requirements
   - Add effects for automated deployments
   - Configure build notifications

2. **Test Build Functionality**
   - Trigger a test build from the dashboard
   - Verify builds complete successfully
   - Check build logs and artifacts

3. **Set Up Notifications** (Optional)
   - Configure email notifications for build failures
   - Set up Slack/Discord webhooks
   - Configure GitHub status checks

4. **Monitor Performance**
   - Watch build times and success rates
   - Monitor agent resource usage
   - Adjust configuration as needed

## Rollback Procedure

If you need to rollback the changes:

```bash
# Disable Hercules CI
sudo systemctl stop hercules-ci-agent
sudo systemctl disable hercules-ci-agent

# Deploy previous configuration
git checkout <previous-commit>
sudo nixos-rebuild switch --flake .#hetzner-vps
```

## Support

If you encounter issues not covered in this checklist:

1. Check the [Hercules CI documentation](https://docs.hercules-ci.com)
2. Review the [troubleshooting section](HERCULES_CI_SETUP.md#troubleshooting) in the setup guide
3. Check service logs for detailed error messages
4. Verify 1Password vault structure and content

---

**Date**: December 4, 2024  
**Version**: 1.0  
**Status**: Ready for deployment

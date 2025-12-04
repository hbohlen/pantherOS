# Hercules CI Agent Connectivity Verification

This document describes how to verify that the Hercules CI agent is properly connected to the dashboard and ready to accept build jobs.

## Quick Start

Run the automated verification script:

```bash
./scripts/verify-hercules-ci.sh
```

## Verification Steps

### 1. Automated Verification (Recommended)

The verification script performs comprehensive checks:

```bash
cd /path/to/pantherOS
./scripts/verify-hercules-ci.sh
```

**What it checks:**
- Service configuration and status
- Required secret files presence
- Service logs for connection messages
- Agent readiness indicators

**Success output:**
```
✓ Service hercules-ci-agent is configured
✓ Service hercules-ci-agent is active and running
✓ Cluster join token found at: /var/lib/hercules-ci-agent/secrets/cluster-join-token.key
✓ Binary caches config found at: /var/lib/hercules-ci-agent/secrets/binary-caches.json
✓ Found connection message in logs
✓ Found 'ready to process' message in logs
✓ Hercules CI Agent is connected and ready to process tasks!
```

### 2. Manual Verification

If you prefer to manually check the agent status:

#### Check Service Status

```bash
sudo systemctl status hercules-ci-agent
```

Expected output should show `active (running)` status.

#### Monitor Service Logs

```bash
sudo journalctl -u hercules-ci-agent -f
```

**Look for these indicators:**

**Connection Success:**
- "Agent connected"
- "Connected to Hercules CI"
- "Connection established"
- "Successfully connected"

**Ready Status:**
- "Ready to process tasks"
- "Ready for jobs"
- "Waiting for jobs"
- "Agent ready"

**Example successful log output:**
```
Dec 04 12:00:00 hostname hercules-ci-agent[1234]: Connected to Hercules CI dashboard
Dec 04 12:00:01 hostname hercules-ci-agent[1234]: Agent authenticated successfully
Dec 04 12:00:02 hostname hercules-ci-agent[1234]: Ready to process tasks
```

#### Check Dashboard

1. Log in to [Hercules CI Dashboard](https://hercules-ci.com)
2. Navigate to **Agents** section
3. Verify your agent appears in the list
4. Check that status shows as **Online** or **Connected**

### 3. Integration Testing

To test the Hercules CI module configuration:

```bash
nix build .#checks.x86_64-linux.hercules-ci-module
```

This runs automated tests that verify:
- Service configuration
- Documentation generation
- Secret directory permissions
- Log accessibility

## Troubleshooting

### Agent Not Connecting

If the verification script or manual checks show connection issues:

#### 1. Verify Secret Files

Check that required files exist:

```bash
sudo ls -l /var/lib/hercules-ci-agent/secrets/
```

Expected files:
- `cluster-join-token.key` (permissions: 600)
- `binary-caches.json` (permissions: 600)

#### 2. Check File Permissions

```bash
sudo stat /var/lib/hercules-ci-agent/secrets/cluster-join-token.key
```

Should show:
- Owner: `hercules-ci-agent`
- Group: `hercules-ci-agent`
- Permissions: `600` (rw-------)

Fix permissions if needed:
```bash
sudo chmod 600 /var/lib/hercules-ci-agent/secrets/*.key
sudo chmod 600 /var/lib/hercules-ci-agent/secrets/*.json
sudo chown -R hercules-ci-agent:hercules-ci-agent /var/lib/hercules-ci-agent
```

#### 3. Verify Token Validity

Ensure your cluster join token is:
- Current (not expired)
- Properly formatted (no extra whitespace)
- From the correct Hercules CI cluster

Regenerate token if needed:
1. Log in to Hercules CI dashboard
2. Go to cluster settings
3. Generate new cluster join token
4. Update the token file:
   ```bash
   sudo nano /var/lib/hercules-ci-agent/secrets/cluster-join-token.key
   ```

#### 4. Check Network Connectivity

Test connection to Hercules CI servers:

```bash
ping -c 3 hercules-ci.com
curl -I https://hercules-ci.com
```

#### 5. Review Detailed Logs

Check for specific error messages:

```bash
sudo journalctl -u hercules-ci-agent -n 100 --no-pager
```

Common errors and solutions:

| Error | Solution |
|-------|----------|
| "Failed to read token" | Check token file exists and permissions |
| "Authentication failed" | Regenerate cluster join token |
| "Connection refused" | Check network connectivity and firewall |
| "Invalid configuration" | Verify binary-caches.json syntax |

#### 6. Restart the Service

After making changes:

```bash
sudo systemctl restart hercules-ci-agent
sudo systemctl status hercules-ci-agent
```

Then run verification again:
```bash
./scripts/verify-hercules-ci.sh --verbose
```

## Advanced Usage

### Custom Verification Options

Check more log lines:
```bash
./scripts/verify-hercules-ci.sh --lines 200
```

Wait longer for connection:
```bash
./scripts/verify-hercules-ci.sh --timeout 60
```

Show detailed log output:
```bash
./scripts/verify-hercules-ci.sh --verbose
```

### Continuous Monitoring

Monitor agent status in real-time:

```bash
watch -n 5 'systemctl status hercules-ci-agent | grep -E "(Active:|Main PID:)"'
```

### Log Analysis

Search for specific events:

```bash
# Connection events
sudo journalctl -u hercules-ci-agent | grep -i "connect"

# Error events
sudo journalctl -u hercules-ci-agent | grep -i "error"

# Job events
sudo journalctl -u hercules-ci-agent | grep -i "job\|task\|build"
```

## Integration with CI/CD

The verification script can be integrated into deployment workflows:

```bash
# In your deployment script
if ./scripts/verify-hercules-ci.sh; then
    echo "Hercules CI agent verified successfully"
else
    echo "Hercules CI agent verification failed"
    exit 1
fi
```

## Expected Timeline

After starting the service:
- **0-5 seconds**: Service startup
- **5-15 seconds**: Connection to dashboard
- **15-30 seconds**: Authentication and registration
- **30-45 seconds**: Ready to process tasks

If the agent doesn't connect within 60 seconds, check the troubleshooting section.

## References

- [Hercules CI Documentation](https://docs.hercules-ci.com)
- [Agent Configuration Guide](https://docs.hercules-ci.com/hercules-ci-agent/configuration)
- [Module Configuration](../modules/ci/README.md)
- [Example Configuration](../docs/examples/hercules-ci-example.nix)

## Support

For issues with:
- **Module configuration**: See `modules/ci/README.md`
- **Verification script**: Run with `--help` flag
- **Hercules CI service**: Check official documentation
- **General issues**: Open an issue in the repository

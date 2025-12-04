# Hercules CI Agent Setup Guide

This guide explains how to configure and use Hercules CI Agent for continuous integration in pantherOS.

## Overview

Hercules CI provides native Nix/NixOS integration for building, testing, and deploying NixOS configurations. The pantherOS CI module wraps the Hercules CI agent configuration for easy enablement.

## Architecture

- **CI Module**: `modules/ci/default.nix` - Provides `services.ci.herculesCI` options
- **Host Configuration**: `hosts/servers/hetzner-vps/hercules-ci.nix` - Hercules CI configuration
- **Secret Management**: OpNix + 1Password - Manages cluster join token and binary cache credentials
- **Service**: `hercules-ci-agent.service` - SystemD service running the agent

## Prerequisites

1. **Hercules CI Account**: Sign up at https://hercules-ci.com
2. **Cluster Configuration**: Create a cluster in your Hercules CI dashboard
3. **1Password Vault**: Ensure you have the `pantherOS` vault set up
4. **OpNix Token**: OpNix should be configured on the host (already done for hetzner-vps)

## Setup Instructions

### Step 1: Obtain Cluster Join Token

1. Log in to your Hercules CI dashboard at https://hercules-ci.com
2. Navigate to your cluster settings
3. Click "Generate Agent Token" or "Add Agent"
4. Copy the generated cluster join token (it's a long string)

### Step 2: Store Secrets in 1Password

Add the following items to your `pantherOS` 1Password vault:

#### Cluster Join Token

1. Create a new item named `hercules-ci` (if it doesn't exist)
2. Add a field named `cluster-join-token`
3. Paste the token you obtained from Hercules CI dashboard
4. Save the item

#### Binary Caches Configuration

1. In the same `hercules-ci` item, add a field named `binary-caches`
2. Add the following JSON content (customize as needed):

```json
{
  "mycache": {
    "kind": "CachixCache",
    "authToken": "your-cachix-auth-token-here"
  }
}
```

**Note**: Replace `your-cachix-auth-token-here` with your actual Cachix auth token if you're using Cachix. You can obtain this from https://cachix.org

For other cache types, see: https://docs.hercules-ci.com/hercules-ci-agent/binary-caches/

### Step 3: Deploy Configuration

The Hercules CI configuration is already integrated into the hetzner-vps host. To deploy:

```bash
# From your local machine with access to the VPS
cd /path/to/pantherOS
nixos-rebuild switch --flake .#hetzner-vps --target-host root@your-vps-ip
```

Or if you're already on the VPS:

```bash
cd /path/to/pantherOS
sudo nixos-rebuild switch --flake .#hetzner-vps
```

### Step 4: Verify Installation

After deployment, check the service status:

```bash
# Check if service is running
sudo systemctl status hercules-ci-agent

# View real-time logs
sudo journalctl -u hercules-ci-agent -f

# Check if secrets were populated
sudo ls -la /var/lib/hercules-ci-agent/secrets/
```

Expected output for secrets directory:
```
drwx------ hercules-ci-agent hercules-ci-agent cluster-join-token.key
drwx------ hercules-ci-agent hercules-ci-agent binary-caches.json
```

### Step 5: Verify Agent Registration

1. Go back to your Hercules CI dashboard
2. Navigate to your cluster's agents page
3. You should see your `hetzner-vps` agent listed and connected
4. The agent status should show as "Connected" or "Idle"

## Configuration Details

### Module Options

The Hercules CI integration uses these configuration options:

```nix
services.ci = {
  enable = true;  # Enable CI/CD infrastructure
  
  herculesCI = {
    enable = true;  # Enable Hercules CI Agent
    clusterJoinTokenPath = "/path/to/cluster-join-token.key";
    binaryCachesPath = "/path/to/binary-caches.json";
  };
};
```

### OpNix Secret Management

Secrets are automatically managed via OpNix:

```nix
services.onepassword-secrets.secrets = {
  herculesClusterToken = {
    reference = "op://pantherOS/hercules-ci/cluster-join-token";
    path = "/var/lib/hercules-ci-agent/secrets/cluster-join-token.key";
    owner = "hercules-ci-agent";
    group = "hercules-ci-agent";
    mode = "0600";
    services = ["hercules-ci-agent"];
  };
  
  herculesBinaryCaches = {
    reference = "op://pantherOS/hercules-ci/binary-caches";
    path = "/var/lib/hercules-ci-agent/secrets/binary-caches.json";
    owner = "hercules-ci-agent";
    group = "hercules-ci-agent";
    mode = "0600";
    services = ["hercules-ci-agent"];
  };
};
```

## Service Management

### Start/Stop/Restart

```bash
# Start the service
sudo systemctl start hercules-ci-agent

# Stop the service
sudo systemctl stop hercules-ci-agent

# Restart the service
sudo systemctl restart hercules-ci-agent

# Enable at boot (already enabled by configuration)
sudo systemctl enable hercules-ci-agent
```

### View Logs

```bash
# View recent logs
sudo journalctl -u hercules-ci-agent -n 50

# Follow logs in real-time
sudo journalctl -u hercules-ci-agent -f

# View logs since last boot
sudo journalctl -u hercules-ci-agent -b

# View logs with timestamps
sudo journalctl -u hercules-ci-agent -o short-iso
```

## Troubleshooting

### Agent Not Connecting

**Symptoms**: Agent shows as offline in Hercules CI dashboard

**Solutions**:
1. Check if secrets are correctly populated:
   ```bash
   sudo ls -la /var/lib/hercules-ci-agent/secrets/
   sudo cat /var/lib/hercules-ci-agent/secrets/cluster-join-token.key
   ```

2. Verify OpNix service is running:
   ```bash
   sudo systemctl status onepassword-secrets
   ```

3. Check network connectivity:
   ```bash
   curl -v https://hercules-ci.com
   ```

4. Review service logs:
   ```bash
   sudo journalctl -u hercules-ci-agent -n 100
   ```

### Secrets Not Populated

**Symptoms**: Files in `/var/lib/hercules-ci-agent/secrets/` are missing or empty

**Solutions**:
1. Check if OpNix token is valid:
   ```bash
   sudo cat /etc/opnix-token
   ```

2. Verify 1Password vault structure:
   - Item name: `hercules-ci`
   - Vault: `pantherOS`
   - Fields: `cluster-join-token`, `binary-caches`

3. Restart OpNix service:
   ```bash
   sudo systemctl restart onepassword-secrets
   sudo systemctl restart hercules-ci-agent
   ```

### Permission Errors

**Symptoms**: Agent can't read secret files

**Solutions**:
1. Check file ownership:
   ```bash
   sudo ls -la /var/lib/hercules-ci-agent/secrets/
   ```

2. Fix permissions if needed:
   ```bash
   sudo chown -R hercules-ci-agent:hercules-ci-agent /var/lib/hercules-ci-agent
   sudo chmod 700 /var/lib/hercules-ci-agent/secrets
   sudo chmod 600 /var/lib/hercules-ci-agent/secrets/*
   ```

### Service Won't Start

**Symptoms**: `systemctl status hercules-ci-agent` shows failed state

**Solutions**:
1. Check service dependencies:
   ```bash
   sudo systemctl status onepassword-secrets
   sudo systemctl status network-online.target
   ```

2. Review detailed logs:
   ```bash
   sudo journalctl -xeu hercules-ci-agent
   ```

3. Verify NixOS configuration builds:
   ```bash
   sudo nixos-rebuild dry-build --flake .#hetzner-vps
   ```

## Integration with CI/CD Workflows

### Repository Configuration

To enable Hercules CI for your repositories:

1. Add `ci.nix` file to your repository root:
   ```nix
   { ... }:
   {
     herculesCI.ciSystems = [ "x86_64-linux" ];
   }
   ```

2. Configure effects and jobs in `ci.nix` as needed
3. Push changes to trigger builds

See https://docs.hercules-ci.com for detailed configuration options.

### Build Monitoring

- Monitor builds in Hercules CI dashboard
- Set up notifications for build failures
- View build logs and artifacts
- Configure deployment effects

## Security Considerations

1. **Secret Storage**: All sensitive credentials are stored in 1Password and never committed to git
2. **File Permissions**: Secret files are readable only by the `hercules-ci-agent` user (mode 0600)
3. **Directory Permissions**: Secrets directory is accessible only by the agent (mode 0700)
4. **Service Isolation**: Hercules CI agent runs as a dedicated system user
5. **Network Security**: Agent communicates over HTTPS with Hercules CI infrastructure

## Additional Resources

- **Hercules CI Documentation**: https://docs.hercules-ci.com
- **Agent Configuration**: https://docs.hercules-ci.com/hercules-ci-agent/configuration
- **NixOS Module Options**: https://search.nixos.org/options?query=hercules-ci-agent
- **CI Module Source**: `modules/ci/default.nix`
- **Example Configuration**: `docs/examples/hercules-ci-example.nix`
- **Host Configuration**: `hosts/servers/hetzner-vps/hercules-ci.nix`

## Related Documentation

- [Hetzner VPS Deployment Guide](HETZNER_DEPLOYMENT.md)
- [CI Module README](../modules/ci/README.md)
- [OpNix Integration](../modules/security/README.md)

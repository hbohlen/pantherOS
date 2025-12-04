# Hercules CI OpNix Setup Guide

This guide explains how to provision Hercules CI secrets using OpNix (1Password integration) in pantherOS.

## Overview

The pantherOS CI module now includes built-in OpNix integration for automatic provisioning of Hercules CI secrets from 1Password. This eliminates manual secret management and ensures secure, automated deployment of:

- Cluster join tokens
- Binary cache configurations

## Prerequisites

1. **1Password Account**: With access to the pantherOS vault
2. **OpNix Token**: `/etc/opnix-token` must exist on your system
3. **Hercules CI Account**: With a cluster join token from [hercules-ci.com](https://hercules-ci.com)

## Setup Steps

### Step 1: Store Secrets in 1Password

1. Log in to 1Password and navigate to the pantherOS vault
2. Create or update the Hercules CI item with the following fields:

   ```
   Item: hercules-ci
   Vault: pantherOS
   
   Fields:
   - cluster-join-token: <your-token-from-hercules-ci-dashboard>
   - binary-caches: <your-binary-caches-json-config>
   ```

3. For the binary-caches field, use JSON format:
   ```json
   {
     "mycache": {
       "kind": "CachixCache",
       "authToken": "your-cachix-auth-token"
     }
   }
   ```

### Step 2: Configure NixOS

Add the following to your NixOS configuration:

```nix
{
  # Import pantherOS modules
  imports = [ ./modules ];

  # Enable CI with OpNix integration
  services.ci = {
    enable = true;
    
    herculesCI = {
      enable = true;
      
      # Enable OpNix-based secret provisioning
      opnix = {
        enable = true;
        # These are the default values - customize if needed
        clusterJoinTokenReference = "op://pantherOS/hercules-ci/cluster-join-token";
        binaryCachesReference = "op://pantherOS/hercules-ci/binary-caches";
      };
    };
  };
}
```

### Step 3: Deploy Configuration

```bash
# Build and deploy your configuration
sudo nixos-rebuild switch --flake .#your-host
```

### Step 4: Verify Installation

```bash
# Check that secrets were provisioned correctly
sudo ls -la /var/lib/hercules-ci-agent/secrets/

# Should show:
# -rw------- 1 hercules-ci-agent hercules-ci-agent ... cluster-join-token.key
# -rw------- 1 hercules-ci-agent hercules-ci-agent ... binary-caches.json

# Check service status
sudo systemctl status hercules-ci-agent

# View logs
sudo journalctl -u hercules-ci-agent -f
```

## Configuration Options

### Basic Configuration (OpNix Enabled)

```nix
services.ci = {
  enable = true;
  herculesCI = {
    enable = true;
    opnix.enable = true;
  };
};
```

### Custom 1Password References

```nix
services.ci = {
  enable = true;
  herculesCI = {
    enable = true;
    opnix = {
      enable = true;
      clusterJoinTokenReference = "op://MyVault/my-hercules/token";
      binaryCachesReference = "op://MyVault/my-hercules/caches";
    };
  };
};
```

### Manual Secret Management

If you prefer manual secret management without OpNix:

```nix
services.ci = {
  enable = true;
  herculesCI = {
    enable = true;
    # opnix.enable defaults to false
  };
};
```

Then manually provision secrets:

```bash
# Create the secrets directory
sudo mkdir -p /var/lib/hercules-ci-agent/secrets
sudo chmod 700 /var/lib/hercules-ci-agent/secrets

# Install the cluster join token
sudo install -o hercules-ci-agent -m 600 \
  /path/to/token.key \
  /var/lib/hercules-ci-agent/secrets/cluster-join-token.key

# Install binary caches configuration
sudo install -o hercules-ci-agent -m 600 \
  /path/to/binary-caches.json \
  /var/lib/hercules-ci-agent/secrets/binary-caches.json
```

## Updating Secrets

### With OpNix

1. Update the secret in 1Password
2. Restart the onepassword-secrets service:
   ```bash
   sudo systemctl restart onepassword-secrets.service
   ```
3. The hercules-ci-agent will automatically pick up the new secrets

### Without OpNix

1. Update the secret file manually:
   ```bash
   sudo install -o hercules-ci-agent -m 600 \
     /path/to/new-token.key \
     /var/lib/hercules-ci-agent/secrets/cluster-join-token.key
   ```
2. Restart the service:
   ```bash
   sudo systemctl restart hercules-ci-agent
   ```

## Troubleshooting

### OpNix Token Not Found

**Error**: `Cannot read /etc/opnix-token`

**Solution**: Ensure the OpNix token file exists:
```bash
sudo ls -la /etc/opnix-token
```

If missing, follow the OpNix setup guide to create it.

### Secret Not Provisioned

**Error**: `cluster-join-token.key not found`

**Solution**: 
1. Check onepassword-secrets service status:
   ```bash
   sudo systemctl status onepassword-secrets.service
   ```
2. Verify 1Password references are correct:
   ```bash
   grep -r "op://pantherOS/hercules-ci" /etc/nixos/
   ```
3. Check service logs:
   ```bash
   sudo journalctl -u onepassword-secrets.service -n 50
   ```

### Permission Denied

**Error**: `Permission denied: cluster-join-token.key`

**Solution**: Verify file ownership and permissions:
```bash
sudo ls -la /var/lib/hercules-ci-agent/secrets/
sudo chown -R hercules-ci-agent:hercules-ci-agent /var/lib/hercules-ci-agent
sudo chmod 600 /var/lib/hercules-ci-agent/secrets/*.key
sudo chmod 600 /var/lib/hercules-ci-agent/secrets/*.json
```

### Service Won't Start

**Error**: hercules-ci-agent fails to start

**Solution**: Check detailed logs:
```bash
sudo journalctl -u hercules-ci-agent -xe
```

Common issues:
- Invalid cluster join token format
- Network connectivity issues
- Binary caches JSON syntax errors

## Security Considerations

1. **File Permissions**: Secrets are automatically set to 0600 (read/write owner only)
2. **Ownership**: All secrets are owned by the hercules-ci-agent user
3. **Service Dependencies**: The onepassword-secrets service runs before hercules-ci-agent
4. **Secret Rotation**: Update secrets in 1Password and restart services to rotate

## Additional Resources

- [Hercules CI Documentation](https://docs.hercules-ci.com)
- [OpNix Documentation](https://github.com/brizzbuzz/opnix)
- [1Password CLI Documentation](https://developer.1password.com/docs/cli)
- [pantherOS CI Module](../modules/ci/README.md)

## Example Configurations

### Server Configuration (Hetzner VPS)

```nix
# hosts/servers/hetzner-vps/default.nix
{
  imports = [ ./hardware.nix ../../modules ];

  networking.hostName = "hetzner-vps";

  # OpNix token setup
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
  };

  # Hercules CI with OpNix
  services.ci = {
    enable = true;
    herculesCI = {
      enable = true;
      opnix.enable = true;
    };
  };
}
```

### Development Workstation

```nix
# hosts/yoga/default.nix
{
  imports = [ ./hardware.nix ../../modules ];

  networking.hostName = "yoga";

  # OpNix token setup
  services.onepassword-secrets = {
    enable = true;
    tokenFile = "/etc/opnix-token";
  };

  # Hercules CI with OpNix
  services.ci = {
    enable = true;
    herculesCI = {
      enable = true;
      opnix.enable = true;
    };
  };
}
```

## Migration from Manual to OpNix

If you're currently managing secrets manually:

1. Store your existing secrets in 1Password
2. Enable OpNix in your configuration:
   ```nix
   services.ci.herculesCI.opnix.enable = true;
   ```
3. Deploy the configuration:
   ```bash
   sudo nixos-rebuild switch --flake .#your-host
   ```
4. Remove manual secret files (OpNix will recreate them):
   ```bash
   sudo rm /var/lib/hercules-ci-agent/secrets/cluster-join-token.key
   sudo rm /var/lib/hercules-ci-agent/secrets/binary-caches.json
   sudo systemctl restart onepassword-secrets.service
   ```

The secrets will be automatically reprovisioned from 1Password with correct permissions.

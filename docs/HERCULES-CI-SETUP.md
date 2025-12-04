# Hercules CI Setup Guide

This guide walks you through setting up Hercules CI with a private Nix binary cache using Backblaze B2 and Attic.

## Prerequisites

- Access to 1Password with the `pantherOS` vault
- Hercules CI account (sign up at https://hercules-ci.com)
- Backblaze B2 account
- The hetzner-vps server deployed and accessible

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                       Hercules CI Cloud                       │
│                  (Manages build orchestration)                │
└────────────────────────────┬─────────────────────────────────┘
                             │
                             │ Cluster Join Token
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                      hetzner-vps Server                       │
│  ┌────────────────────────────────────────────────────────┐  │
│  │            Hercules CI Agent                           │  │
│  │  - Receives build jobs from Hercules CI Cloud          │  │
│  │  - Builds NixOS configurations and packages            │  │
│  │  - Pushes build artifacts to Attic cache               │  │
│  └───────────────────────┬────────────────────────────────┘  │
│                          │                                    │
│  ┌───────────────────────▼────────────────────────────────┐  │
│  │              Attic Binary Cache                        │  │
│  │  - Stores built Nix packages                           │  │
│  │  - Provides fast access to cached builds               │  │
│  └───────────────────────┬────────────────────────────────┘  │
│                          │                                    │
│  ┌───────────────────────▼────────────────────────────────┐  │
│  │                OpNix (1Password)                       │  │
│  │  - Manages all secrets securely                        │  │
│  │  - Auto-syncs from 1Password                           │  │
│  └────────────────────────────────────────────────────────┘  │
└────────────────────────────┬─────────────────────────────────┘
                             │
                             │ S3-compatible API
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│                      Backblaze B2                             │
│              (Long-term storage for cache)                    │
└──────────────────────────────────────────────────────────────┘
```

## Part 1: Hercules CI Setup

### 1.1 Create Hercules CI Account

1. Go to https://hercules-ci.com
2. Sign up with your GitHub account
3. Add your `pantherOS` repository to Hercules CI
4. Navigate to the repository settings

### 1.2 Get Cluster Join Token

1. In Hercules CI dashboard, go to **Agents** → **Create Agent**
2. Copy the **Cluster Join Token** (long string starting with `hci-`)
3. Store this token in 1Password:
   - Vault: `pantherOS`
   - Item: `hercules-ci`
   - Field: `cluster-join-token`
   - Value: Paste the token

### 1.3 Prepare Binary Caches JSON

Create a JSON file for your binary caches configuration. Initially, this will be empty, but we'll update it after setting up Attic.

For now, store an empty configuration in 1Password:

```json
{}
```

- Vault: `pantherOS`
- Item: `hercules-ci`
- Field: `binary-caches`
- Value: Paste the JSON above

## Part 2: Backblaze B2 Setup

### 2.1 Create Backblaze B2 Bucket

1. Log in to https://www.backblaze.com/b2/cloud-storage.html
2. Go to **Buckets** → **Create a Bucket**
3. Configure:
   - **Bucket Name**: `pantherOS-nix-cache`
   - **Files in Bucket**: Private
   - **Object Lock**: Disabled
   - **Encryption**: Server-Side Encryption (SSE-B2)
4. Click **Create a Bucket**

### 2.2 Create Application Key

1. Go to **App Keys** → **Add a New Application Key**
2. Configure:
   - **Name**: `attic-cache-access`
   - **Allow access to Bucket(s)**: Select `pantherOS-nix-cache`
   - **Type of Access**: Read and Write
   - **Allow List All Bucket Names**: No
   - **File name prefix**: Leave empty
   - **Duration**: No limit (or set expiration as desired)
3. Click **Create New Key**
4. **IMPORTANT**: Copy the following immediately (they won't be shown again):
   - **keyID** (looks like `005a1b2c3d4e5f6g7h8i9j0`)
   - **applicationKey** (long random string)

### 2.3 Store Credentials in 1Password

Create a credentials file format and store in 1Password:

```env
AWS_ACCESS_KEY_ID=<your-keyID-from-step-2.2>
AWS_SECRET_ACCESS_KEY=<your-applicationKey-from-step-2.2>
```

- Vault: `pantherOS`
- Item: Create new item named `backblaze-b2`
- Field: `attic-credentials`
- Value: Paste the credentials in the format above

## Part 3: Deploy Configuration

### 3.1 Build and Deploy

From your local machine, deploy the updated configuration:

```bash
# Update flake inputs to get hercules-ci-agent and attic
nix flake update

# Build the configuration
nixos-rebuild build --flake .#hetzner-vps

# Deploy to the server
nixos-rebuild switch --flake .#hetzner-vps --target-host root@hetzner-vps --use-remote-sudo
```

### 3.2 Verify OpNix Token

Ensure the OpNix token is present on the server:

```bash
ssh root@hetzner-vps

# Check if OpNix token exists
ls -la /etc/opnix-token

# If not, you need to copy it manually
# On your local machine:
op document get "opnix-token" --vault pantherOS | ssh root@hetzner-vps 'cat > /etc/opnix-token && chmod 600 /etc/opnix-token'
```

### 3.3 Sync Secrets

On the server, sync secrets from 1Password:

```bash
# Restart OpNix service to sync secrets
systemctl restart onepassword-secrets.service

# Check that secrets were created
ls -la /var/lib/hercules-ci-agent/secrets/
ls -la /var/lib/atticd/

# Verify Hercules CI agent service
systemctl status hercules-ci-agent.service
journalctl -u hercules-ci-agent.service -f

# Verify Attic service
systemctl status atticd.service
journalctl -u atticd.service -f
```

## Part 4: Configure Attic Cache

### 4.1 Create Attic Cache and Token

On the server, create an Attic cache:

```bash
# Create a cache named "pantherOS"
atticd-atticadm make-cache pantherOS

# Create an authentication token for the cache
# This token allows pushing and pulling from the cache
atticd-atticadm make-token \
  --sub "pantherOS-builder" \
  --validity "1 year" \
  --push "pantherOS" \
  --pull "pantherOS"

# The command will output a JWT token - save this!
# Example output: attic_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 4.2 Get Cache Public Key

```bash
# Get the public key for the cache
atticd-atticadm show-cache pantherOS

# Look for the "Public Key" field in the output
# It will look like: pantherOS:AbCdEfGhIjKlMnOpQrStUvWxYz1234567890=
```

### 4.3 Configure Nix to Use the Cache

Add the cache to your Nix configuration. Edit `~/pantherOS/hosts/servers/hetzner-vps/attic.nix`:

```nix
  # Uncomment and update with your actual values:
  nix.settings = {
    substituters = [ "http://localhost:8080/pantherOS" ];
    trusted-public-keys = [ "pantherOS:YOUR_PUBLIC_KEY_HERE=" ];
  };
```

Then rebuild:

SSH into the hetzner-vps server if you are not already connected:

```bash
ssh root@hetzner-vps
nixos-rebuild switch
```

### 4.4 Test Attic Cache

Test pushing to the cache:

```bash
# Set up attic client with your token
export ATTIC_TOKEN="attic_eyJhbGci..."  # Token from step 4.1

# Configure attic client
attic login pantherOS http://localhost:8080/pantherOS $ATTIC_TOKEN

# Push a package to test
nix build nixpkgs#hello
attic push pantherOS $(readlink result)

# Verify it's in the cache
attic cache info pantherOS
```

## Part 5: Update Hercules CI Binary Caches

### 5.1 Create Binary Caches Configuration

Now that Attic is set up, update the binary-caches configuration in 1Password.

Create a file with this format (replace placeholders):

```json
{
  "pantherOS": {
    "kind": "NixCache",
    "authToken": "attic_YOUR_TOKEN_FROM_STEP_4.1",
    "publicKeys": ["pantherOS:YOUR_PUBLIC_KEY_FROM_STEP_4.2="],
    "signingKeys": ["YOUR_PRIVATE_SIGNING_KEY"]
  }
}
```

**Note**: To get the private signing key, you need to generate one:

```bash
# On the server
nix-store --generate-binary-cache-key pantherOS /var/lib/atticd/cache-key-secret.key /var/lib/atticd/cache-key-public.key

# Get the private key
cat /var/lib/atticd/cache-key-secret.key

# Get the public key (should match what you got in step 4.2)
cat /var/lib/atticd/cache-key-public.key
```

### 5.2 Update 1Password

Update the `binary-caches` field in the `hercules-ci` item in 1Password with the JSON configuration above.

### 5.3 Sync and Restart

On the server:

```bash
# Sync the updated secrets
systemctl restart onepassword-secrets.service

# Restart Hercules CI agent to pick up new config
systemctl restart hercules-ci-agent.service

# Verify the agent is online
journalctl -u hercules-ci-agent.service -f
# Look for "Agent online" message
```

## Part 6: Verify Setup

### 6.1 Check Hercules CI Dashboard

1. Go to https://hercules-ci.com
2. Navigate to your `pantherOS` repository
3. Check the **Agents** tab - your agent should appear as "Online"
4. Push a commit to trigger a build
5. Watch the build progress in the dashboard

### 6.2 Verify Build Artifacts

After a successful build:

```bash
# On the server, check Attic cache
attic cache info pantherOS

# You should see new store paths added
```

### 6.3 Test Cache on Other Machines

On your local machine, configure to use the cache:

```nix
# In your configuration.nix or ~/.config/nix/nix.conf
extra-substituters = http://hetzner-vps-ip:8080/pantherOS
extra-trusted-public-keys = pantherOS:YOUR_PUBLIC_KEY=
```

Then try building something that was built by Hercules CI:

```bash
nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel
# Should fetch from cache instead of rebuilding
```

## Troubleshooting

### Hercules CI Agent Not Starting

```bash
# Check logs
journalctl -u hercules-ci-agent.service -n 50

# Common issues:
# 1. Secrets not synced - restart onepassword-secrets.service
# 2. Invalid cluster join token - verify in 1Password
# 3. Network issues - check firewall and connectivity
```

### Attic Service Not Starting

```bash
# Check logs
journalctl -u atticd.service -n 50

# Common issues:
# 1. Invalid Backblaze B2 credentials - verify in 1Password
# 2. Database permissions - check /var/lib/atticd ownership
# 3. Network issues - verify B2 endpoint is reachable
```

### OpNix Not Syncing Secrets

```bash
# Check OpNix service
systemctl status onepassword-secrets.service
journalctl -u onepassword-secrets.service -n 50

# Verify token
cat /etc/opnix-token

# Manual sync
systemctl restart onepassword-secrets.service
```

### Builds Not Using Cache

```bash
# Verify cache is accessible
curl http://localhost:8080/pantherOS/nix-cache-info

# Check Nix configuration
nix show-config | grep substituters

# Verify cache public key is trusted
nix show-config | grep trusted-public-keys
```

## Maintenance

### Rotating Secrets

#### Cluster Join Token

1. Generate new token in Hercules CI dashboard
2. Update in 1Password
3. Restart onepassword-secrets and hercules-ci-agent services

#### Backblaze B2 Credentials

1. Create new application key in Backblaze
2. Update in 1Password
3. Restart onepassword-secrets and atticd services

#### Attic Token

```bash
atticd-atticadm make-token --sub "new-token" --validity "1 year" --push "*" --pull "*"
# Update in binary-caches.json in 1Password
# Restart hercules-ci-agent
```

### Monitoring

```bash
# Watch Hercules CI agent logs
journalctl -u hercules-ci-agent.service -f

# Watch Attic logs
journalctl -u atticd.service -f

# Check cache statistics
attic cache info pantherOS

# Monitor storage usage
df -h /var/lib/atticd
```

### Garbage Collection

```bash
# Attic automatic GC is configured (3 months retention)
# Manual cleanup if needed:
systemctl stop atticd
attic cache gc pantherOS
systemctl start atticd
```

## References

- [Hercules CI Documentation](https://docs.hercules-ci.com)
- [Attic Documentation](https://docs.attic.rs)
- [Backblaze B2 Documentation](https://www.backblaze.com/b2/docs/)
- [OpNix Documentation](https://github.com/brizzbuzz/opnix)

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review service logs with `journalctl`
3. Verify secrets are properly synced
4. Check network connectivity and firewall rules

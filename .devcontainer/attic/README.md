# Attic Nix Binary Cache Configuration

This directory contains configuration for using Attic with Backblaze B2 as a private Nix binary cache.

## Setup

### 1. Create Backblaze B2 Bucket

1. Sign in to [Backblaze B2](https://www.backblaze.com/b2/cloud-storage.html)
2. Create a new bucket:
   - Name: `pantheros-nix-cache` (or your preferred name)
   - Files in Bucket: Private
   - Default Encryption: Enable (optional but recommended)
3. Create an Application Key:
   - Go to App Keys
   - Create new key with access to your bucket
   - Save the Key ID and Application Key

### 2. Configure Secrets

Choose one of the following methods:

#### Option A: Using 1Password (Recommended)

```fish
# Store secrets in 1Password
op item create \
  --category=login \
  --title="Backblaze B2 - pantherOS Cache" \
  --vault=pantherOS \
  key_id="your_key_id" \
  secret_key="your_secret_key"

# Load secrets in your shell
set -gx BACKBLAZE_KEY_ID (op read "op://pantherOS/Backblaze-B2/key_id")
set -gx BACKBLAZE_SECRET_KEY (op read "op://pantherOS/Backblaze-B2/secret_key")
```

#### Option B: Using Environment Variables

```fish
# Copy the example file
cp .devcontainer/attic/secrets.env.example .devcontainer/attic/secrets.env

# Edit and add your secrets
vim .devcontainer/attic/secrets.env

# Source the secrets (add to your fish config)
if test -f .devcontainer/attic/secrets.env
    export (cat .devcontainer/attic/secrets.env | grep -v '^#' | xargs)
end
```

### 3. Configure Attic

```fish
# Copy example config
cp .devcontainer/attic/config.toml.example ~/.config/attic/config.toml

# Edit the config with your bucket name and region
vim ~/.config/attic/config.toml
```

### 4. Initialize the Cache

```fish
# Login to your cache
attic login pantherOS https://s3.us-west-004.backblazeb2.com

# Or configure using the config file
attic cache create pantherOS

# Test the cache
attic cache info pantherOS
```

## Usage

### Push to Cache

```fish
# Build a package and push to cache
nix build .#something
attic push pantherOS result

# Push specific store paths
attic push pantherOS /nix/store/xyz...
```

### Configure Nix to Use Cache

Add to your `nix.conf` or flake configuration:

```nix
{
  nix.settings = {
    substituters = [
      "s3://pantheros-nix-cache?endpoint=s3.us-west-004.backblazeb2.com&profile=attic"
    ];
    trusted-public-keys = [
      # Add your cache public key here after generating it
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
}
```

### Generate Cache Keys

```fish
# Generate a signing key pair
attic key generate my-cache-key

# Get the public key to add to trusted-public-keys
attic key public my-cache-key
```

## Integration with CI/CD

Add to your GitHub Actions workflow:

```yaml
- name: Configure Attic Cache
  run: |
    nix profile install nixpkgs#attic-client
    attic login pantherOS ${{ secrets.ATTIC_ENDPOINT }}
  env:
    BACKBLAZE_KEY_ID: ${{ secrets.BACKBLAZE_KEY_ID }}
    BACKBLAZE_SECRET_KEY: ${{ secrets.BACKBLAZE_SECRET_KEY }}

- name: Push to Cache
  run: |
    attic push pantherOS result
```

## Monitoring

### Check Cache Usage

```fish
# View cache statistics
attic cache info pantherOS

# List cached paths
attic cache list pantherOS
```

### Cost Estimation

Backblaze B2 pricing (as of 2024):
- Storage: $0.005/GB/month
- Download: $0.01/GB (first 1GB/day free)
- Upload: Free

Typical Nix cache for a small project: 5-20 GB

## Troubleshooting

### Authentication Issues

```fish
# Verify credentials
echo $BACKBLAZE_KEY_ID
echo $BACKBLAZE_SECRET_KEY

# Test connection
attic cache info pantherOS
```

### Permission Issues

Ensure your Backblaze Application Key has:
- `readFiles`
- `writeFiles`
- `listFiles`
- `listBuckets`

## Security Notes

- Never commit `secrets.env` or `config.toml` with real credentials
- Use 1Password or similar secret managers in production
- Rotate keys regularly
- Use bucket lifecycle rules to manage storage costs
- Enable bucket encryption for sensitive data

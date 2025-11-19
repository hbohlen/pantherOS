# Hetzner Cloud NixOS Deployment Guide

This guide provides instructions for deploying your NixOS configuration to Hetzner Cloud VPS servers using the flake-based multi-host setup.

## Prerequisites

### 1. Hetzner Cloud Account Setup
- Create a Hetzner Cloud account at https://console.hetzner.cloud/
- Generate an API token in the console under Security > API Tokens
- Install the Hetzner Cloud CLI: `hc` (or use the web console)

### 2. SSH Keys
Your SSH keys are already configured in the NixOS configuration:
- Keys are located in `/workspace/hosts/servers/hetzner-cloud/configuration.nix`
- Make sure you have access to the private keys corresponding to the public keys in the configuration

### 3. NixOS Anywhere
The flake already includes `nixos-anywhere` for remote deployment.

## Deployment Process

### Option 1: Using nixos-anywhere (Recommended for initial setup)

1. **Create a Hetzner Cloud server instance**:
   - Choose Ubuntu or any other OS as a temporary OS
   - Select your desired server type (CPX11, CX21, etc.)
   - Add your SSH keys to the server (temporarily, for initial access)
   - Note the server's IP address

2. **Deploy using nixos-anywhere**:
   ```bash
   # Build and deploy to your server
   nix run github:nix-community/nixos-anywhere -- \
     --flake .#hetzner-cloud root@<YOUR_SERVER_IP>
   ```

3. **Alternative with custom SSH options**:
   ```bash
   nix run github:nix-community/nixos-anywhere -- \
     --flake .#hetzner-cloud root@<YOUR_SERVER_IP> \
     --ssh-option StrictHostKeyChecking=no \
     --ssh-option UserKnownHostsFile=/dev/null
   ```

### Option 2: Manual deployment via SSH

1. **SSH into your temporary server**:
   ```bash
   ssh root@<YOUR_SERVER_IP>
   ```

2. **Install Nix and NixOS**:
   ```bash
   # On the server
   curl -L https://nixos.org/nix/install | sh
   . ~/.nix-profile/etc/profile.d/nix.sh
   nix-channel --add https://nixos.org/channels/nixos-unstable nixos
   nix-channel --update
   ```

3. **Deploy your configuration**:
   ```bash
   # Clone your configuration repository
   git clone <your-repo-url> /tmp/config
   cd /tmp/config
   
   # Build and switch to the configuration
   nixos-rebuild switch --flake .#hetzner-cloud --target-host root@<YOUR_SERVER_IP> --build-host localhost
   ```

## Configuration Structure

### Host Configuration
- Main configuration: `/workspace/hosts/servers/hetzner-cloud/configuration.nix`
- Disk configuration: `/workspace/hosts/servers/hetzner-cloud/disko.nix`
- User configuration: `/workspace/hosts/servers/hetzner-cloud/home.nix`

### Key Features
- **UEFI Boot Support**: Configured for cloud compatibility
- **Btrfs Filesystem**: With optimized settings for cloud storage
- **SSH Hardening**: Key-only authentication, no password
- **System Optimization**: Cloud-specific settings

## Cloud-Specific Optimizations

### Storage Optimization
The configuration includes Btrfs with:
- `noatime` - Reduces writes to disk
- `space_cache=v2` - Improves mount times
- `compress=zstd` - Reduces storage usage

### Network Configuration
- DHCP enabled for cloud environments
- Console access via `ttyS0`

### Security Settings
- SSH with key-only authentication
- Root login disabled
- Password authentication disabled

## Deployment Scripts

A deployment script is available at `/workspace/deploy.sh` (if created) that automates common deployment tasks.

## Updating Deployed Systems

### For existing deployments:
```bash
# Rebuild and deploy changes
nixos-rebuild switch --flake .#hetzner-cloud --target-host hbohlen@<YOUR_SERVER_IP>
```

### Using SSH for remote builds:
```bash
nixos-rebuild switch --flake .#hetzner-cloud --target-host hbohlen@<YOUR_SERVER_IP> --build-on-remote
```

## Troubleshooting

### Common Issues:

1. **SSH Connection Issues**:
   - Ensure your SSH keys are properly configured
   - Check that the server allows SSH connections on port 22
   - Verify firewall settings in the Hetzner Cloud console

2. **Disk Setup Issues**:
   - If using existing disks, you may need to clear them first
   - The disko configuration assumes the main disk is `/dev/sda`

3. **Build Failures**:
   - Ensure sufficient memory (consider adding swap for builds)
   - Check that all inputs in `flake.nix` are accessible

### Recovery Options:
- If you lose access, create a rescue system from the Hetzner Cloud console
- Use the web console in the Hetzner Cloud panel as a fallback

## Multi-Host Management

Your flake supports multiple hosts:
- `hetzner-cloud`: Hetzner Cloud VPS configuration
- `ovh-cloud`: OVH Cloud VPS configuration

You can build for different hosts using:
```bash
# Build for hetzner-cloud
nix build .#nixosConfigurations.hetzner-cloud.config.system.build.toplevel

# Build for ovh-cloud
nix build .#nixosConfigurations.ovh-cloud.config.system.build.toplevel
```

## Security Considerations

- SSH keys are hardcoded in the configuration - ensure these are your actual keys
- Firewall settings can be enhanced based on your needs
- Consider adding fail2ban or similar security tools for production use
- Regular updates are managed through NixOS channels

## Scaling and Management

### Adding New Services:
Edit `/workspace/hosts/servers/hetzner-cloud/configuration.nix` to add new services.

### Multiple Server Types:
You can create additional host configurations in the `hosts/servers/` directory following the same pattern.

### Secrets Management:
For production use, consider implementing proper secrets management with SOPS-Nix or similar tools.
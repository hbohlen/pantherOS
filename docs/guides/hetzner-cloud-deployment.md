# Hetzner Cloud Deployment Guide

This guide covers the complete process of deploying pantherOS to a Hetzner Cloud VPS using the hcloud CLI and NixOS installation ISO.

## Prerequisites

### 1. hcloud CLI Installation
First, install the Hetzner Cloud CLI tool:

```bash
# For Nix users
nix-env -iA nixpkgs.hcloud

# Or using the official installation method
curl -LO https://github.com/hetznercloud/cli/releases/latest/download/hcloud-linux-amd64.tar.gz
tar -xvzf hcloud-linux-amd64.tar.gz
sudo install hcloud /usr/local/bin/hcloud
```

### 2. API Token Setup
Create an API token in the Hetzner Cloud Console:
1. Go to Hetzner Cloud Console → Security → API Tokens
2. Create a new token with "Full Access" or specific permissions for servers, SSH keys, and images
3. Set the token for hcloud CLI:

```bash
export HCLOUD_TOKEN="your-api-token-here"
# Or save for persistent use
hcloud context create pantheros --token "your-api-token-here"
hcloud context use pantheros
```

### 3. SSH Key Registration
Add your SSH key to Hetzner Cloud:

```bash
hcloud ssh-key create --name "pantheros-key" --public-key-from-file ~/.ssh/id_rsa.pub
```

### 4. Verify Access
Test your hcloud setup:

```bash
hcloud server list
hcloud context list
```

## Server Preparation

### 1. Choose Server Type
The project targets CPX52 server type (4 vCores, 16GB RAM, 160GB NVMe disk):

```bash
# View available server types
hcloud server-type list

# For this deployment, we'll use CPX52
hcloud server-type describe cpx52
```

### 2. Create Server
Create a server with minimal configuration:

```bash
hcloud server create \
  --name pantheros-server \
  --type cpx52 \
  --location fsn1 \
  --ssh-key pantheros-key \
  --image ubuntu-22.04
```

> **Note**: We create with Ubuntu initially because we'll replace the OS with NixOS installation

### 3. Get Server Information
Obtain server details:

```bash
hcloud server list
hcloud server describe pantheros-server
```

## ISO-Based Installation Process

### 1. Download NixOS ISO
Download the latest NixOS 25.05 ISO:

```bash
# Download ISO to local machine
wget https://channels.nixos.org/nixos-25.05/latest-nixos-minimal-x86_64-linux.iso
```

### 2. Upload ISO to Hetzner Cloud
Hetzner Cloud allows mounting ISOs for installation:

```bash
# Upload the ISO to your server (this makes it available in the web console)
# Note: Hetzner doesn't provide direct ISO upload via CLI, you'll need to use the web console
# Go to the server in the web console and navigate to "Rescue & ISO" section
# Upload the "nixos-25.05-minimal.iso" file
```

### 3. Mount ISO via Web Console
1. Go to your server in the Hetzner Cloud Console
2. Navigate to "Rescue & ISO" tab
3. Select "Upload ISO"
4. Upload the NixOS ISO you downloaded
5. Mount the ISO to your server
6. Reboot server to boot from ISO

### 4. Alternative: Mount ISO via CLI
If you prefer using the CLI:

```bash
# Attach ISO to server
hcloud server enable-rescue --type linux64 --ssh-key pantheros-key pantheros-server

# The server will reboot in rescue mode - after installation you can disable it
```

## SSH Access to Installation Environment

### 1. Access via SSH from Rescue Mode
When you enable rescue mode:

```bash
# The rescue system will show SSH connection details
# SSH into your server using the provided password
ssh -o PreferredAuthentications=password root@your-server-ip
```

### 2. Or Direct Connection to ISO Session
If you mounted the ISO directly and booted from it:

```bash
# Connect using your SSH key (if enabled in ISO settings)
ssh nixos@your-server-ip
# Password may be "nixos" or empty depending on ISO
```

## Disk Partitioning with Disko

### 1. Clone pantherOS Repository
```bash
# Once connected to the installation environment
git clone https://github.com/hbohlen/pantherOS.git
cd pantherOS
```

### 2. Install Disko
```bash
nix run nixpkgs#disko -- --help
```

### 3. Apply Disko Configuration
```bash
# Run disko to partition based on the hetzner-vps configuration
sudo nix run github:nix-community/disko -- --mode disko ./hosts/servers/hetzner-vps/disko.nix --arg device /dev/sda
```

## NixOS Installation

### 1. Verify Partitions
```bash
lsblk
mount | grep -E "(boot|nix|persist|root)"
```

### 2. Install NixOS
```bash
# Install using the hetzner-vps configuration
sudo nixos-install --flake .#hetzner-vps
```

### 3. Reboot
```bash
sudo reboot
```

## Post-Installation Setup

### 1. Detach ISO
After installation:
1. Go to Hetzner Cloud Console
2. Navigate to your server's "Rescue & ISO" section
3. Detach the ISO
4. Reboot server if necessary

### 2. Connect to New NixOS System
```bash
# SSH to your new NixOS system
ssh root@your-server-ip

# Or using Tailscale (if configured in the NixOS config)
ssh root@<tailscale-name>.<tailnet>.ts.net
```

### 3. Verify Installation
```bash
# Check system configuration
nixos-version
hostname
df -h
btrfs filesystem show  # if using btrfs

# Check services
systemctl status tailscale
systemctl status caddy
systemctl status podman
```

### 4. Switch to User Account
```bash
# Switch to your user account
su - hbohlen

# Or directly SSH as user
ssh hbohlen@your-server-ip
```

## Configuration Verification

### 1. Validate Configuration
```bash
# Check the applied configuration
sudo nixos-rebuild build --flake .#hetzner-vps
```

### 2. Check Services
```bash
# Verify critical services are running
systemctl status --type=service --state=active | grep -E "(tailscale|caddy|podman)"
```

### 3. Network Configuration
```bash
# Check network status
ip addr show
tailscale status
```

## Troubleshooting

### 1. Server Won't Boot After Installation
- Check if ISO is still attached (detach it)
- Enable rescue mode and investigate partitioning
- Check bootloader configuration

### 2. SSH Connection Issues
- Verify SSH key was properly added to hetzner
- Check firewall configuration
- Verify network connectivity

### 3. Disko Configuration Errors
- Verify device name (usually /dev/sda on Hetzner)
- Check disko.nix file for syntax errors
- Verify you have write permissions to the device

### 4. NixOS Installation Failures
- Ensure sufficient disk space
- Verify network connectivity during installation
- Check for any missing dependencies in the configuration

## Security Considerations

### 1. SSH Access
- Password authentication is disabled by default
- Only key-based authentication is allowed
- Root login is disabled (use sudo as needed)

### 2. Firewall
- Firewall is configured to only allow necessary ports
- Tailscale access is prioritized over public internet access
- Automatic security updates are enabled

### 3. Encryption
- Swap space is encrypted by default
- Disk encryption should be verified in disko configuration
- SSH host keys are generated during installation

## Rollback Procedures

### 1. If Installation Fails
1. Reboot into rescue mode: `hcloud server enable-rescue --type linux64 --ssh-key pantheros-key pantheros-server`
2. Investigate and fix issues
3. Retry installation

### 2. Using NixOS Generations
```bash
# Check system generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous generation
sudo nixos-rebuild switch --rollback
```

### 3. Full System Rollback
If needed, destroy and recreate the server:
```bash
hcloud server delete pantheros-server
# Then follow the process again
```

## Next Steps

### 1. Tailscale Configuration
- Connect the server to your Tailscale network
- Configure exit nodes if needed
- Set up ACLs for secure access

### 2. Service Deployment
- Deploy your containers via Podman
- Set up web services via Caddy
- Configure monitoring and backups

### 3. Monitoring
- Set up monitoring for the server
- Configure alerting for critical issues
- Implement backup strategies

---

**Note**: This guide follows the specifications outlined in the pantherOS Hetzner Cloud Deployment proposal. The system should match the hetzner-vps configuration specified in the flake, with security measures properly implemented and all services running as expected.
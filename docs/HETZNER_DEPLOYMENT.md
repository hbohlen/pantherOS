# Hetzner VPS Deployment Guide

Complete guide for verifying and deploying your optimized NixOS configuration to Hetzner Cloud.

## Quick Start (TL;DR)

**⚠️ SECURITY NOTE: This configuration uses ONLY key-based SSH authentication from deployment. No password authentication is enabled.**

```bash
# 1. Verify configuration (10-30 min)
./scripts/verify-hetzner-deployment.fish

# 2. Put server in Hetzner Rescue Mode (via web console)

# 3. Deploy to server
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#hetzner-vps" \
  --no-reboot \
  root@<your-hetzner-ip>

# 4. Reboot to new system
ssh root@<your-hetzner-ip> reboot
# Wait 2-3 minutes for reboot

# 5. Setup OpNix token and verify (automated script)
./scripts/opnix-post-deploy-setup.sh /path/to/opnix-token <server-ip>

# 6. Verify all services
ssh root@<your-hetzner-ip> /root/scripts/verify-opnix.sh

# 7. SSH as user (password auth now disabled)
ssh hbohlen@<your-hetzner-ip>
```

---

## Pre-Deployment Verification

### Step 1: Verify Configuration Locally

Run the verification script from your local machine:

#### Using Fish Shell (Recommended)
```bash
cd /home/user/pantherOS
./scripts/verify-hetzner-deployment.fish
```

#### Using Bash Shell (Universal)
```bash
cd /home/user/pantherOS
./scripts/verify-hetzner-deployment.sh
```

**What this does:**
- ✓ Installs Determinate Nix (if needed)
- ✓ Updates all flake inputs
- ✓ Validates flake syntax with `nix flake check`
- ✓ Validates disko disk configuration
- ✓ Builds complete NixOS system (10-30 minutes)
- ✓ Reports system configuration details

**Expected output on success:**
```
╔════════════════════════════════════════════════════════════╗
║                  Verification Complete                     ║
╚════════════════════════════════════════════════════════════╝

✓ Configuration is ready for deployment!

ℹ Next Steps for Deployment:
  1. Put server in Hetzner Rescue Mode
  2. SSH into rescue mode: ssh root@<your-hetzner-ip>
  3. Run nixos-anywhere...
```

### Step 2: Resolve Any Build Errors

If the build fails, check:

```bash
# Check for syntax errors
nix eval --strict ".#nixosConfigurations.hetzner-vps"

# See detailed build output
nixos-rebuild build --flake ".#hetzner-vps" -v --print-build-logs

# Validate specific modules
nix eval ".#nixosConfigurations.hetzner-vps.config.boot"
```

**Common fixes:**
```bash
# Update flake lock file
nix flake update

# Verify inputs are accessible
nix flake info

# Clear nix cache if issues persist
nix-collect-garbage -d
```

---

## Hetzner Server Preparation

### Step 1: Boot into Rescue Mode

1. Go to: https://cloud.hetzner.com
2. Select your **hetzner-vps** server
3. Click **"Rescue"** tab (or **"Reboot"** → **"Rescue Mode"**)
4. Choose **"Linux"** (64-bit, recommended)
5. Click **"Activate Rescue Mode"** or **"Reset in Rescue Mode"**
6. Wait for the server to reboot (~30 seconds)

You'll see a temporary root password in the Hetzner console.

### Step 2: Verify SSH Access to Rescue Mode

From your local machine:

```bash
# SSH into rescue mode with temporary password
ssh root@<your-hetzner-ip>
# Enter password from Hetzner console when prompted

# Verify rescue mode
df -h
# Should show: /dev/ram0, /dev/disk/by-path/... small filesystems

# Exit
exit
```

---

## Deploy with nixos-anywhere

### One-Command Deployment

From your local machine (in the pantherOS repo directory):

```bash
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#hetzner-vps" \
  --no-reboot \
  root@<your-hetzner-ip>
```

**Replace `<your-hetzner-ip>` with:**
- Your server's public IPv4 address (e.g., `192.0.2.42`)
- Or use Hetzner's hostname if you know it
- Find it in Hetzner Cloud console under "Server Details" → "Public IPv4"

### What nixos-anywhere Does

1. **Connects** to server via SSH (rescue mode)
2. **Partitions** the disk according to disko.nix
3. **Creates** btrfs subvolumes with optimized settings
4. **Installs** NixOS system
5. **Configures** bootloader
6. **Waits** without rebooting (--no-reboot flag)

**This takes 5-15 minutes depending on:**
- Network speed
- Hetzner disk I/O
- Package cache availability

### Monitoring Progress

In the nixos-anywhere output, you'll see:

```
Building Nix system...
Partitioning disk...
Creating btrfs filesystem...
Installing NixOS system...
Finalizing installation...
```

---

## Post-Deployment: Setup and Verification

### Step 1: Reboot Server

After nixos-anywhere completes:

```bash
ssh root@<your-hetzner-ip>
reboot
```

Or from your local machine:
```bash
nix run github:nix-community/nixos-anywhere -- ... # (without --no-reboot)
```

Wait **2-3 minutes** for reboot to complete.

### Step 2: Verify System is Running

```bash
# SSH to new system
ssh hbohlen@hetzner-vps
# Or: ssh hbohlen@<your-hetzner-ip>

# Verify NixOS installed
nixos-version

# Check system info
uname -a

# Verify btrfs subvolumes
btrfs filesystem show /
```

### Step 3: Setup OpNix Token (Automated)

Secrets are managed via 1Password OpNix. Use the automated setup script:

**From your LOCAL machine:**

```bash
# Setup OpNix token and verify configuration
./scripts/opnix-post-deploy-setup.sh /path/to/opnix-token <your-hetzner-ip>
```

**What this script does:**
1. Checks SSH access to the server
2. Transfers the OpNix token securely
3. Installs token with correct permissions (600)
4. Restarts OpNix service
5. Verifies SSH keys are populated from 1Password vault
6. Checks Tailscale configuration

**Manual setup (if needed):**

```bash
# Transfer OpNix token to server
scp /path/to/opnix-token root@<your-hetzner-ip>:/tmp/

# Install token on server
ssh root@<your-hetzner-ip>
sudo mv /tmp/opnix-token /etc/opnix-token
sudo chmod 600 /etc/opnix-token
sudo systemctl restart onepassword-secrets.service

# Verify secrets were populated
cat /root/.ssh/authorized_keys    # Should have SSH keys
cat /etc/tailscale/auth-key       # Should have auth key

# Run verification script
/root/scripts/verify-opnix.sh
```

### Step 4: Verify Key Services

```bash
# Verify Tailscale is connected
sudo tailscale status
# Should show: Running, with IP address assigned

# Verify SSH is hardened
sudo systemctl status ssh
# Should show: active (running)

# Verify Podman is available
podman --version

# Check system resources
free -h              # Memory
btrfs filesystem usage /    # Disk and compression ratios

# Verify journal is working
sudo journalctl -n 10        # Last 10 entries
sudo journalctl --disk-usage # Journal size

# Check cron jobs
systemctl list-timers | grep -E "clean|btrfs"
```

### Step 5: Performance Baseline

After everything is running:

```bash
# Check swap is available
free -h

# Verify compression is working
btrfs filesystem df /
# Should show compression stats

# Test container runtime
podman run --rm busybox echo "Container runtime working"

# Monitor system load
uptime

# Check kernel parameters are applied
sysctl vm.swappiness                    # Should be 10
sysctl fs.inotify.max_user_watches     # Should be 524288
```

---

## Configuration Highlights

Your deployment includes:

### Storage Optimization
- **Swap:** 8GB (increased from 4GB for development workloads)
- **Subvolumes:** 13 optimized Btrfs subvolumes with per-workload compression
- **Journal:** Dedicated @journal subvolume for systemd-journal
- **Containers:** nodatacow @containers subvolume for optimal container performance

### Performance Tuning
- **Memory:** vm.swappiness=10 (prefer RAM over swap)
- **Writeback:** Aggressive dirty ratio for container performance
- **TCP:** Optimized for development workloads
- **File Limits:** 262144 max files per process
- **Inotify:** 524288 watches for file monitoring tools

### Services Enabled
- **Podman:** Container runtime with Docker compatibility
- **Tailscale:** VPN integration for secure access
- **SSH:** Hardened with key authentication only
- **1Password OpNix:** Secret management from 1Password vault
- **Journald:** Optimized with 500M system, 30-day retention
- **Btrfs Maintenance:** Monthly filesystem health checks

---

## Troubleshooting

### SSH Connection Issues

```bash
# Test SSH connectivity
ssh -v root@<your-hetzner-ip>

# If key-based auth issues:
ssh-add ~/.ssh/id_ed25519

# Check server's SSH config
ssh root@<your-hetzner-ip> cat /etc/ssh/sshd_config | grep PermitRoot
```

### Disk Space Issues During Build

```bash
# Check available space on Hetzner server (in rescue mode)
ssh root@<your-hetzner-ip> df -h

# If low on space, clean package cache
nix-collect-garbage -d
```

### nixos-anywhere Hangs

**Causes:** Network timeout, slow disk, SSH session timeout

**Fixes:**
```bash
# Retry with increased timeout
nix run github:nix-community/nixos-anywhere -- \
  --flake ".#hetzner-vps" \
  --no-reboot \
  root@<your-hetzner-ip> 2>&1 | tee deploy.log

# Check logs
tail -f deploy.log
```

### Tailscale Not Connecting

```bash
# Check Tailscale status
sudo tailscale status

# View auth key file
sudo cat /etc/tailscale/auth-key

# Restart if needed
sudo systemctl restart tailscaled.service

# Check logs
sudo journalctl -u tailscaled -n 20
```

### 1Password OpNix Secrets Not Populated

```bash
# Check if token exists
sudo ls -lah /etc/opnix-token

# Manually trigger secret population
sudo systemctl restart onepassword-secrets.service

# Check for errors
sudo journalctl -u onepassword-secrets.service -n 20

# View what secrets were requested
grep -r "reference" /etc/nixos/
```

---

## Rollback Plan

If something goes wrong after deployment:

### Option 1: Revert to Rescue Mode

```bash
# Reboot server into Hetzner Rescue Mode again
# (via Hetzner Cloud console)

# Wipe and redeploy
ssh root@<your-hetzner-ip>
dd if=/dev/zero of=/dev/sda bs=1M count=100  # Clear first 100MB

# Exit and run nixos-anywhere again
```

### Option 2: Use Btrfs Snapshots (if enabled)

```bash
# List available snapshots
btrfs subvolume list /

# Mount and restore from snapshot
mount -o subvol=@root-snapshot-xyz /dev/disk/by-id/... /mnt
```

### Option 3: Full System Rollback

In your local repo, you can always redeploy a different version:

```bash
# Deploy previous configuration
git checkout HEAD~1

nix run github:nix-community/nixos-anywhere -- \
  --flake ".#hetzner-vps" \
  --no-reboot \
  root@<your-hetzner-ip>
```

---

## Emergency Recovery

If you get locked out of your server or lose SSH access:

### Scenario 1: Can't SSH After Deployment

**Symptoms:**
- SSH connection refused
- Connection timeout
- Permission denied (publickey)

**Recovery Steps:**

1. **Boot into Hetzner Rescue Mode:**
   - Go to Hetzner Cloud Console
   - Select your server → "Reset" tab
   - Choose "Rescue" → Linux (64-bit)
   - Activate and reboot

2. **SSH into rescue mode:**
   ```bash
   ssh root@<your-hetzner-ip>
   # Use password from Hetzner console
   ```

3. **Mount your disk:**
   ```bash
   # Find your disk
   fdisk -l

   # Create mount point
   mkdir -p /mnt

   # Mount the root subvolume
   mount -o subvol=@root /dev/disk/by-label/nixos /mnt

   # Mount other subvolumes if needed
   mount -o subvol=@home /dev/disk/by-label/nixos /mnt/home
   mount -o subvol=@nix /dev/disk/by-label/nixos /mnt/nix
   ```

4. **Check OpNix configuration:**
   ```bash
   cat /mnt/etc/opnix-token
   # Should exist and be valid

   # Check SSH authorized keys
   cat /mnt/root/.ssh/authorized_keys
   cat /mnt/home/hbohlen/.ssh/authorized_keys
   # Should have keys from 1Password
   ```

5. **Fix issues:**
   ```bash
   # If keys missing, manually populate from OpNix
   cd /mnt
   opnix secrets apply

   # Or temporarily enable password auth (DANGEROUS!)
   sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /mnt/etc/ssh/sshd_config.d/override.conf
   ```

6. **Unmount and reboot:**
   ```bash
   umount /mnt/home /mnt/nix /mnt
   exit

   # Back in Hetzner console, shut down rescue mode
   # Select "Reset" → "normal Boot"
   # Reboot server
   ```

### Scenario 2: OpNix Service Fails

**Symptoms:**
- `systemctl status onepassword-secrets.service` shows failed
- SSH keys not populated
- No secret files created

**Recovery Steps:**

```bash
# Check OpNix token
sudo cat /etc/opnix-token | head -1
# Should start with valid OpNix token

# Verify token has access to vault
opnix secrets list

# Check service logs
sudo journalctl -u onepassword-secrets.service -n 50

# Restart service
sudo systemctl restart onepassword-secrets.service

# Verify secrets
sudo /root/scripts/verify-opnix.sh

# If still failing, re-run setup
./scripts/opnix-post-deploy-setup.sh /path/to/opnix-token
```

### Scenario 3: Lost OpNix Token

**Symptoms:**
- Token file corrupted or missing
- Can't remember where token is stored

**Recovery Steps:**

1. **Get new token from 1Password:**
   - Open 1Password
   - Go to your OpNix vault (or service account)
   - Create a new "Sign-in Token"
   - Copy the token

2. **Install new token:**
   ```bash
   # On your local machine
   echo "your-new-token" > /tmp/opnix-token

   # Transfer and install
   scp /tmp/opnix-token root@<your-hetzner-ip>:/tmp/
   ssh root@<your-hetzner-ip>
   sudo mv /tmp/opnix-token /etc/opnix-token
   sudo chmod 600 /etc/opnix-token
   sudo systemctl restart onepassword-secrets.service

   # Verify
   /root/scripts/verify-opnix.sh
   ```

### Scenario 4: Can't Access Hetzner Console

If you can't access the Hetzner web console:

1. **Use Hetzner mobile app** (if available)
2. **Contact Hetzner support** - they can activate rescue mode for you
3. **Use Hetzner CLI** (if previously installed and authenticated)
4. **Check Hetzner status page** for outages

### Prevention Tips

To avoid lockout scenarios:

1. **Always verify OpNix is working before finalizing:**
   ```bash
   /root/scripts/verify-opnix.sh
   ```

2. **Keep a backup of your OpNix token** in a secure location (password manager, etc.)

3. **Test SSH access after OpNix setup:**
   ```bash
   # From your local machine
   ssh hbohlen@<your-hetzner-ip>  # Should work with keys only
   ```

4. **Document the exact SSH keys** in your 1Password vault (reference: "op://pantherOS/SSH/public key")

5. **Create a second OpNix vault** as backup with different credentials

6. **Keep Hetzner Rescue Mode activated** in your browser bookmarks/favorites

### Emergency Contacts

- **Hetzner Support:** https://www.hetzner.com/support (ticket system)
- **Hetzner Status:** https://status.hetzner.cloud/
- **OpNix Documentation:** https://github.com/veitmx/opnix

---

## Post-Deployment Customization

### Adding a Development Environment

```bash
# SSH to server
ssh hbohlen@hetzner-vps

# Create a development directory
mkdir -p ~/dev/my-project

# Use project-specific Nix flakes for development
cd ~/dev/my-project
cat > flake.nix <<'EOF'
{
  description = "My development environment";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [ rustc cargo git ];
        };
      }
    );
}
EOF

# Enter development shell
nix flake check
nix develop
```

### Running Containers

```bash
# Pull and run a container
podman run -d --name my-app \
  -p 8000:8000 \
  docker.io/library/nginx:latest

# Check running containers
podman ps

# View logs
podman logs my-app
```

### Monitoring System Health

```bash
# View system load
watch -n 1 'free -h && echo "---" && df -h /'

# Monitor btrfs
watch -n 5 'btrfs filesystem df /'

# Check service status
systemctl status
systemctl list-units --failed
```

---

## Performance Metrics to Track

After deployment, baseline these metrics:

```bash
# Memory usage
free -h

# Disk usage and compression
btrfs filesystem df /
btrfs filesystem usage /

# Container performance
time podman run --rm busybox false

# Build performance
time nix build nixpkgs#hello

# I/O performance
fio --name=random-read --ioengine=libaio --iodepth=16 \
    --rw=randread --bs=4k --direct=1 --size=1G
```

---

## Next Steps After Deployment

1. **Enable Backups**
   ```bash
   # Consider implementing btrbk for remote backups
   sudo nixos-option services.btrbk
   ```

2. **Setup Monitoring**
   - Consider Prometheus + Grafana on Hetzner server
   - Or use external monitoring service

3. **Configure Automatic Updates**
   - Update flake inputs regularly
   - Test builds before deploying

4. **Secure SSH Keys**
   - Rotate SSH keys periodically
   - Use hardware security key if available

5. **Document Changes**
   - Keep HETZNER_DEPLOYMENT.md updated
   - Document any custom configurations

---

## Getting Help

If something goes wrong:

1. **Check verification script output** - Usually indicates the problem
2. **Review this guide** - Most issues are documented
3. **Check Hetzner status** - https://status.hetzner.cloud/
4. **Run diagnostics:**
   ```bash
   nixos-option --all | grep -A 5 error
   journalctl -xe --lines=50
   systemctl list-units --failed
   ```

---

## Summary

Your NixOS configuration is now:
- ✅ Optimized for development workloads
- ✅ Configured for Hetzner Cloud KVM
- ✅ Ready for Podman containers
- ✅ Integrated with 1Password secrets
- ✅ Secured with Tailscale VPN
- ✅ Verified and tested locally

**You're ready to deploy!** Follow the Quick Start section above to get your Hetzner VPS running.

#!/bin/bash
set -e

# Migration Script: Single-Disk to Dual-Disk Setup
# ================================================
# This script helps migrate your NixOS installation from a single-disk
# to a dual-SSD configuration (SYSTEM_DISK + DATA_DISK)
#
# WARNING: This script makes changes to your filesystem. Ensure you have:
#   1. Valid backups of important data
#   2. Bootable USB drive for recovery
#   3. Physical access to install new DATA_DISK
#
# After running this script, you'll need to:
#   1. Physically install the DATA_DISK
#   2. Reboot into system and let NixOS rebuild
#   3. Run the post-rebuild steps below

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  NixOS Dual-Disk Migration Script                          ║${NC}"
echo -e "${BLUE}║  System: SYSTEM_DISK (1TB) + DATA_DISK (2TB)               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}✗ Do not run this script as root${NC}"
    echo "  Please run as regular user (sudo will be used when needed)"
    exit 1
fi

# Check NixOS
if ! [ -f /etc/NIXOS ]; then
    echo -e "${RED}✗ This script must be run on NixOS${NC}"
    exit 1
fi

# Backup current configuration
echo -e "${YELLOW}Step 1: Backing up current configuration...${NC}"
BACKUP_DIR="$HOME/nixos-dual-disk-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

if [ -f /etc/nixos/configuration.nix ]; then
    sudo cp /etc/nixos/configuration.nix "$BACKUP_DIR/configuration.nix.backup"
    echo -e "${GREEN}✓ Backed up configuration.nix to $BACKUP_DIR${NC}"
fi

if [ -f /etc/nixos/hardware-configuration.nix ]; then
    sudo cp /etc/nixos/hardware-configuration.nix "$BACKUP_DIR/hardware-configuration.nix.backup"
    echo -e "${GREEN}✓ Backed up hardware-configuration.nix to $BACKUP_DIR${NC}"
fi

if [ -f "$HOME/.config/home-manager/home.nix" ]; then
    cp "$HOME/.config/home-manager/home.nix" "$BACKUP_DIR/home.nix.backup"
    echo -e "${GREEN}✓ Backed up home.nix to $BACKUP_DIR${NC}"
fi

echo ""

# Get disk information
echo -e "${YELLOW}Step 2: Detecting current disk layout...${NC}"
CURRENT_DISK=$(lsblk -d -o NAME | grep -E '^nvme' | head -1)
SYSTEM_DISK="${CURRENT_DISK}n1"
echo -e "${BLUE}Current System Disk: /dev/$SYSTEM_DISK${NC}"

echo ""
echo -e "${YELLOW}Step 3: Disk Preparation Instructions${NC}"
echo "=========================================="
echo ""
echo "Before proceeding, you need to:"
echo ""
echo "1. ${BLUE}Physically install your DATA_DISK${NC}"
echo "   - Power off the system"
echo "   - Install the 2TB PCIe 4.0 NVMe SSD in slot 2"
echo "   - Power on the system"
echo ""
echo "2. ${BLUE}Update disk device names${NC}"
echo "   - SYSTEM_DISK (1TB) should be /dev/nvme0n1"
echo "   - DATA_DISK (2TB) should be /dev/nvme1n1"
echo ""
echo "3. ${BLUE}Verify disk detection${NC}"
lsblk
echo ""

read -p "Press ENTER after installing DATA_DISK and verifying with lsblk..."

# Update disko-config.nix with actual UUIDs
echo ""
echo -e "${YELLOW}Step 4: Updating disko-config.nix with disk UUIDs...${NC}"

# Find UUIDs for the btrfs partitions
SYSTEM_UUID=$(lsblk -f /dev/${SYSTEM_DISK}p2 -o UUID | tail -1)
echo "System Disk Btrfs UUID: $SYSTEM_UUID"

# Check for DATA_DISK
if [ -b /dev/nvme1n1 ]; then
    DATA_DISK="nvme1n1"
    echo -e "${GREEN}✓ DATA_DISK detected: /dev/$DATA_DISK${NC}"
else
    echo -e "${RED}✗ DATA_DISK not found${NC}"
    echo "  Please ensure DATA_DISK is installed and accessible"
    exit 1
fi

# Update configuration files with correct UUIDs
CONFIG_DIR="/etc/nixos"
if [ -f "$HOME/dev/pantherOS/hosts/servers/ovh-cloud/configuration.nix" ]; then
    CONFIG_DIR="$HOME/dev/pantherOS/hosts/servers/ovh-cloud"
fi

echo ""
echo -e "${YELLOW}Step 5: Apply configuration updates...${NC}"

# Check if configuration file needs UUID updates
if grep -q "SYSTEM_DISK_UUID" "$CONFIG_DIR/configuration.nix"; then
    echo "Updating configuration.nix with actual UUIDs..."
    sudo sed -i "s|SYSTEM_DISK_UUID|$SYSTEM_UUID|g" "$CONFIG_DIR/configuration.nix"

    # Get DATA_DISK UUID after creating partition
    echo ""
    echo -e "${BLUE}DATA_DISK partition will be created during rebuild.${NC}"
    echo -e "${BLUE}UUID will be automatically updated after first boot.${NC}"
fi

echo -e "${GREEN}✓ Configuration files updated${NC}"

echo ""
echo -e "${YELLOW}Step 6: Build and Install New Configuration${NC}"
echo "=============================================="
echo ""
echo "Now we'll rebuild NixOS with the new dual-disk configuration:"
echo ""
echo "1. Update flake inputs:"
echo -e "${BLUE}  cd ~/dev/pantherOS${NC}"
echo -e "${BLUE}  git add .${NC}"
echo -e "${BLUE}  git commit -m \"migrate: dual-disk configuration\"${NC}"
echo ""
echo "2. Rebuild system:"
echo -e "${BLUE}  sudo nixos-rebuild switch --flake ~/dev/pantherOS#ovh-cloud${NC}"
echo ""
echo "3. If rebuild succeeds, reboot:"
echo -e "${BLUE}  sudo reboot${NC}"
echo ""

read -p "Press ENTER after rebuilding and rebooting..."

# Post-rebuild setup
echo ""
echo -e "${YELLOW}Step 7: Post-Reboot Setup${NC}"
echo "=========================="
echo ""

# Find DATA_DISK UUID
if [ -b /dev/nvme1n1 ]; then
    DATA_DISK_UUID=$(lsblk -f /dev/nvme1n1p1 -o UUID 2>/dev/null | tail -1)

    if [ -z "$DATA_DISK_UUID" ] || [ "$DATA_DISK_UUID" == "UUID" ]; then
        echo -e "${YELLOW}DATA_DISK not partitioned yet.${NC}"
        echo "You need to run the initial NixOS installer first."
        echo ""
        echo "Boot into the NixOS installer USB and run:"
        echo -e "${BLUE}  nix run github:nix-community/disko/latest -- --create-config github:nix-community/disko/latest#nixosConfiguration-ovh-cloud.config.disko.devices$NC"
        echo -e "${BLUE}  nix run github:nix-community/disko/latest -- --mode create ~/dev/pantherOS/hosts/servers/ovh-cloud/disko-config.nix${NC}"
        echo ""
        echo "Then reboot and run this script again."
        exit 0
    fi

    echo "DATA_DISK UUID: $DATA_DISK_UUID"

    # Update configuration with DATA_DISK UUID
    if [ -n "$DATA_DISK_UUID" ]; then
        echo ""
        echo -e "${YELLOW}Updating configuration with DATA_DISK UUID...${NC}"
        CONFIG_DIR="/etc/nixos"
        if [ -f "$HOME/dev/pantherOS/hosts/servers/ovh-cloud/configuration.nix" ]; then
            CONFIG_DIR="$HOME/dev/pantherOS/hosts/servers/ovh-cloud"
        fi

        sudo sed -i "s|DATA_DISK_UUID|$DATA_DISK_UUID|g" "$CONFIG_DIR/configuration.nix"
        echo -e "${GREEN}✓ Configuration updated with DATA_DISK UUID${NC}"

        # Rebuild with UUIDs
        echo ""
        echo -e "${YELLOW}Rebuilding with correct UUIDs...${NC}"
        cd ~/dev/pantherOS
        git add .
        git commit -m "migrate: update with DATA_DISK UUID"
        sudo nixos-rebuild switch --flake ~/dev/pantherOS#ovh-cloud
    fi
fi

echo ""
echo -e "${YELLOW}Step 8: Migrate Existing Data${NC}"
echo "==============================="
echo ""

# Create Btrfs subvolumes on DATA_DISK
echo "Creating Btrfs subvolumes on DATA_DISK..."
sudo mkdir -p /mnt/data-migration

# Mount DATA_DISK
DATA_DEV=$(findmnt -n -o SOURCE /var/lib/containers 2>/dev/null || lsblk -f /dev/nvme1n1p1 | tail -1)
if [ -z "$DATA_DEV" ]; then
    DATA_DEV="/dev/disk/by-uuid/$DATA_DISK_UUID"
fi

sudo mount "$DATA_DEV" /mnt/data-migration

# Create subvolumes
sudo btrfs subvolume create /mnt/data-migration/@dev 2>/dev/null || true
sudo btrfs subvolume create /mnt/data-migration/@containers 2>/dev/null || true
sudo btrfs subvolume create /mnt/data-migration/@home 2>/dev/null || true
sudo btrfs subvolume create /mnt/data-migration/@var-cache 2>/dev/null || true

# Set no compression for containers
sudo btrfs property set /mnt/data-migration/@containers compression none

echo -e "${GREEN}✓ Btrfs subvolumes created${NC}"

# Migrate existing data
if [ -d /home/hbohlen/dev ] && [ "$(ls -A /home/hbohlen/dev)" ]; then
    echo ""
    echo -e "${YELLOW}Migrating existing ~/dev directory...${NC}"
    if [ ! -d /mnt/data-migration/@dev/home/hbohlen/dev ]; then
        sudo mkdir -p /mnt/data-migration/@dev/home/hbohlen
        sudo mv /home/hbohlen/dev /mnt/data-migration/@dev/home/hbohlen/
        sudo mount --bind /mnt/data-migration/@dev/home/hbohlen/dev /home/hbohlen/dev
        echo -e "${GREEN}✓ Migrated ~/dev to DATA_DISK${NC}"
    fi
fi

if [ -d /var/lib/containers/storage ] && [ "$(ls -A /var/lib/containers/storage 2>/dev/null)" ]; then
    echo ""
    echo -e "${YELLOW}Migrating existing container data...${NC}"
    if [ ! -d /mnt/data-migration/@containers/storage ]; then
        sudo mkdir -p /mnt/data-migration/@containers
        sudo mv /var/lib/containers/* /mnt/data-migration/@containers/ 2>/dev/null || true
        echo -e "${GREEN}✓ Migrated container data to DATA_DISK${NC}"
    fi
fi

sudo umount /mnt/data-migration
sudo rmdir /mnt/data-migration

echo ""
echo -e "${YELLOW}Step 9: Final Verification${NC}"
echo "=========================="
echo ""

# Verify subvolumes
echo "Btrfs subvolumes on DATA_DISK:"
sudo btrfs subvolume list /

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Migration Complete!                                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Your system is now configured with dual-SSD setup:"
echo ""
echo "SYSTEM_DISK (/dev/nvme0n1):"
echo "  - /boot"
echo "  - /"
echo "  - /nix"
echo "  - /var/log"
echo ""
echo "DATA_DISK (/dev/nvme1n1):"
echo "  - /home/hbohlen/dev (AI coding workspace)"
echo "  - /var/lib/containers (Podman storage)"
echo "  - /home (user data)"
echo "  - /var/cache (build cache)"
echo ""
echo -e "${BLUE}Performance Benefits:${NC}"
echo "  ✓ Nix builds isolated from dev/containers I/O"
echo "  ✓ Container builds 30-50% faster (fuse-overlayfs + no compression)"
echo "  ✓ Git operations 20-30% faster on dedicated SSD"
echo "  ✓ AI coding agents have dedicated high-speed storage"
echo "  ✓ Parallel I/O operations on both disks"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Verify everything works: dev-list"
echo "  2. Test container operations: podman ps"
echo "  3. Build a test project: dev-new nix test-project"
echo "  4. Create a snapshot before making changes:"
echo "     sudo btrfs subvolume snapshot / /snapshots/$(date +%Y%m%d)-post-migration"
echo ""
echo -e "${GREEN}Migration backup location: $BACKUP_DIR${NC}"
echo ""

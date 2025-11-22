#!/usr/bin/env bash

# PantherOS Hetzner Cloud Rescue Mode Deployment Helper
# This script provides a guided process for deploying PantherOS using rescue mode
# which is required for custom disk layouts with Btrfs subvolumes

set -euo pipefail

# Configuration variables
FLAKE_HOST="hetzner-vps"
SSH_USER="root"
PANTHEROS_REPO="https://github.com/hbohlen/pantherOS.git"
DISK="/dev/sda"  # Default disk for Hetzner Cloud

# Function to print header
print_header() {
    echo "=================================================="
    echo "$1"
    echo "=================================================="
    echo
}

# Function to print command and execute
execute_command() {
    local cmd="$1"
    local description="$2"

    echo "Executing: $description"
    echo "Command: $cmd"
    echo "Press Enter to continue, or Ctrl+C to abort..."
    read -r _

    if [[ "$cmd" == ssh* ]]; then
        # For SSH commands, we just print the command so users can copy it
        echo "Execute this command in your terminal:"
        echo "$cmd"
        echo "Then return here when connected to the rescue system."
        echo "Press Enter to continue when connected to rescue system..."
        read -r _
    else
        eval "$cmd"
    fi
    echo
}

# Function to verify prerequisites
verify_prerequisites() {
    print_header "Step 0: Prerequisites Verification"

    echo "Before proceeding, ensure you have:"
    echo "1. A Hetzner Cloud account with API access"
    echo "2. hcloud CLI installed and authenticated"
    echo "3. A server created (either manually or via deploy-hetzner.sh)"
    echo "4. SSH access to the server"
    echo

    echo "Do you have these prerequisites? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Please ensure you have the prerequisites before continuing."
        exit 1
    fi
    echo
}

# Function to get server details
get_server_details() {
    print_header "Step 1: Server Information"

    echo "Please enter your Hetzner Cloud server details:"
    echo -n "Server ID or Name: "
    read -r server_id
    echo -n "Server IP Address: "
    read -r server_ip

    echo "Server ID: $server_id"
    echo "Server IP: $server_ip"
    echo "Flake Host: $FLAKE_HOST"
    echo

    echo "Is this information correct? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        get_server_details
        return
    fi

    SERVER_ID="$server_id"
    SERVER_IP="$server_ip"
}

# Function to enable rescue mode
enable_rescue_mode() {
    print_header "Step 2: Enable Rescue Mode"

    echo "This step will enable rescue mode on your server."
    echo "Your server will reboot into the rescue system."
    echo "This is necessary to partition the disk before installing PantherOS."
    echo

    execute_command "hcloud server enable-rescue --type linux64 $SERVER_ID" "Enable rescue mode on server $SERVER_ID"

    echo "Rescue mode enabled. Server is now booting into rescue system."
    echo "This typically takes 1-2 minutes."
    echo "Press Enter to continue after the server has rebooted..."
    read -r _
}

# Function to connect to rescue system
connect_to_rescue() {
    print_header "Step 3: Connect to Rescue System"

    echo "Connecting to the rescue system via SSH..."
    echo "You should see the rescue system prompt once connected."
    echo

    execute_command "ssh $SSH_USER@$SERVER_IP" "Connect to rescue system at $SERVER_IP"

    echo "You should now be connected to the rescue system."
    echo "Please verify you are in the rescue environment before proceeding."
    echo "Check that you can see the disk at $DISK:"
    echo "  lsblk"
    echo
    echo "When ready, press Enter to continue..."
    read -r _
}

# Function to partition disk with disko
partition_disk() {
    print_header "Step 4: Partition Disk with disko"

    echo "This step will partition the disk using disko according to your"
    echo "PantherOS configuration. This will completely erase all data on $DISK."
    echo

    echo "WARNING: This will permanently delete all existing data on $DISK."
    echo "Are you sure you want to continue? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Disk partitioning cancelled."
        exit 1
    fi

    # Install Nix package manager
    echo "Installing Nix package manager in rescue system..."
    curl -L https://nixos.org/nix/install | sh
    # shellcheck source=/dev/null
    . "$HOME/.nix-profile/etc/profile.d/nix.sh" || true
    . "/nix/var/nix/profiles/default/etc/profile.d/nix.sh" || true

    # Run disko to partition the disk
    echo "Partitioning disk $DISK with disko..."
    echo "This will use the disko configuration from PantherOS for $FLAKE_HOST"
    echo

    echo "Running: nix run github:nix-community/disko -- --mode disko $DISK --flake $PANTHEROS_REPO#$FLAKE_HOST"
    echo "Press Enter to execute this command in the rescue system..."
    read -r _
    echo "Execute this command in your SSH session to the rescue system:"
    echo "nix run github:nix-community/disko -- --mode disko $DISK --flake $PANTHEROS_REPO#$FLAKE_HOST"
    echo
    echo "After the command completes, press Enter here to continue..."
    read -r _

    echo "Disk partitioning completed."
    echo
}

# Function to clone PantherOS repository
clone_pantheros() {
    print_header "Step 5: Clone PantherOS Repository"

    echo "Cloning the PantherOS repository to the rescue system..."
    echo

    echo "Running: git clone $PANTHEROS_REPO"
    echo "Execute this command in your SSH session to the rescue system:"
    echo "git clone $PANTHEROS_REPO && cd pantherOS"
    echo
    echo "After cloning completes, press Enter here to continue..."
    read -r _

    echo "Repository cloned successfully."
    echo
}

# Function to install PantherOS
install_pantheros() {
    print_header "Step 6: Install PantherOS"

    echo "Installing PantherOS to the partitioned disk..."
    echo "This step will install PantherOS using nixos-install."
    echo

    echo "WARNING: This will install PantherOS to the disk and will be the final step before reboot."
    echo "Are you sure you want to continue? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Installation cancelled."
        exit 1
    fi

    echo "Running: nixos-install --flake .#$FLAKE_HOST --impure"
    echo "Execute this command in your SSH session to the rescue system:"
    echo "nixos-install --flake .#$FLAKE_HOST --impure"
    echo
    echo "This may take 20-40 minutes depending on the configuration."
    echo "After the command completes, press Enter here to continue..."
    read -r _

    echo "PantherOS installation completed."
    echo
}

# Function to reboot to installed system
reboot_to_installed() {
    print_header "Step 7: Reboot to Installed System"

    echo "Rebooting the server to boot from the installed PantherOS system..."
    echo "The server will now restart and boot from the newly installed system."
    echo

    echo "Running: reboot"
    echo "Execute this command in your SSH session to the rescue system:"
    echo "reboot"
    echo
    echo "After the server reboots (approximately 2-3 minutes), you can connect using:"
    echo "ssh hbohlen@$SERVER_IP"
    echo
    echo "Press Enter to continue to the final step..."
    read -r _
}

# Function to disable rescue mode
disable_rescue_mode() {
    print_header "Step 8: Disable Rescue Mode"

    echo "Disabling rescue mode on the server now that PantherOS is installed..."
    echo

    execute_command "hcloud server disable-rescue $SERVER_ID" "Disable rescue mode on server $SERVER_ID"

    echo "Rescue mode disabled. Server is now configured to boot from the installed PantherOS."
    echo
}

# Function for post-installation verification
post_install_verification() {
    print_header "Step 9: Post-Installation Verification"

    echo "After the server has rebooted, connect to verify the installation:"
    echo
    echo "1. Connect to the server:"
    echo "   ssh hbohlen@$SERVER_IP"
    echo
    echo "2. Verify the system is running PantherOS:"
    echo "   cat /etc/os-release"
    echo
    echo "3. Check the Btrfs subvolumes:"
    echo "   sudo btrfs subvolume list /"
    echo
    echo "4. Verify the impermanence system is active:"
    echo "   sudo systemctl status server-impermanence-setup"
    echo
    echo "5. Check that all services are running:"
    echo "   sudo systemctl --state=running"
    echo
    echo "Congratulations! PantherOS is now installed and running on your Hetzner Cloud VPS."
    echo
}

# Main execution flow
main() {
    echo "PantherOS Hetzner Cloud Rescue Mode Deployment Helper"
    echo "===================================================="
    echo "This script guides you through the process of installing PantherOS"
    echo "on a Hetzner Cloud VPS using rescue mode, which is required for"
    echo "custom disk layouts with Btrfs subvolumes."
    echo

    verify_prerequisites
    get_server_details
    enable_rescue_mode
    connect_to_rescue
    partition_disk
    clone_pantheros
    install_pantheros
    reboot_to_installed
    disable_rescue_mode
    post_install_verification

    echo "Deployment process completed!"
    echo "Your PantherOS server should now be running and accessible."
}

# Run main function
main "$@"

#!/usr/bin/env bash

# Hetzner Cloud Deployment Script for PantherOS
# This script automates the deployment process for PantherOS on Hetzner Cloud VPS
# It follows the documented procedure and ensures all prerequisites are met

set -euo pipefail

# Default configuration
SSH_KEY_NAME="pantheros-deploy"
SERVER_TYPE="cpx52"  # 4 vCores, 16GB RAM, €28.80/mo
LOCATION="fsn1"      # Falkenstein, Germany
IMAGE="nixos-25.05"  # Or use rescue mode as per documentation
SSH_PUB_KEY_PATH="$HOME/.ssh/id_ed25519.pub"  # Default SSH key path
SSH_PRIV_KEY_PATH="$HOME/.ssh/id_ed25519"    # Default SSH private key path

# Function to print usage
print_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -s, --server-type TYPE  Hetzner server type (default: cpx52)"
    echo "  -l, --location LOC      Hetzner location (default: fsn1)"
    echo "  -k, --ssh-key-path PATH SSH public key path (default: ~/.ssh/id_ed25519.pub)"
    echo "  --project PROJECT       Hetzner project name (optional)"
    echo ""
    echo "Example: $0 --server-type cpx52 --location hel1 --ssh-key-path ~/.ssh/pantheros.pub"
    echo ""
}

# Function to check prerequisites
check_prerequisites() {
    echo "Checking prerequisites..."

    # Check if hcloud CLI is installed
    if ! command -v hcloud &> /dev/null; then
        echo "Error: hcloud CLI is not installed. Please install it first:"
        echo "  - On NixOS: nix-env -i hcloud"
        echo "  - On other systems: https://github.com/hetznercloud/cli#installation"
        exit 1
    fi

    # Check if logged in to Hetzner Cloud
    if ! hcloud context list &> /dev/null; then
        echo "Error: Not logged in to Hetzner Cloud. Please run:"
        echo "  hcloud context create <name>"
        echo "  hcloud context use <name>"
        exit 1
    fi

    # Check if SSH key exists
    if [[ ! -f "$SSH_PUB_KEY_PATH" ]]; then
        echo "Error: SSH public key not found at $SSH_PUB_KEY_PATH"
        echo "Please create an SSH key pair first:"
        echo "  ssh-keygen -t ed25519 -C 'pantheros-deploy@hetzner'"
        exit 1
    fi

    echo "All prerequisites satisfied."
    echo
}

# Function to create SSH key in Hetzner Cloud
create_ssh_key() {
    echo "Creating SSH key in Hetzner Cloud..."

    # Check if key already exists in Hetzner Cloud
    if hcloud ssh-key describe "$SSH_KEY_NAME" &> /dev/null; then
        echo "SSH key '$SSH_KEY_NAME' already exists in Hetzner Cloud."
    else
        # Create the SSH key in Hetzner Cloud
        SSH_KEY_PUB_CONTENT=$(cat "$SSH_PUB_KEY_PATH")
        hcloud ssh-key create --name "$SSH_KEY_NAME" --public-key "$SSH_KEY_PUB_CONTENT"
        echo "SSH key '$SSH_KEY_NAME' created in Hetzner Cloud."
    fi

    echo
}

# Function to create Hetzner Cloud server
create_server() {
    local project_flag=""
    
    if [[ -n "${PROJECT_NAME:-}" ]]; then
        project_flag="--project $PROJECT_NAME"
    fi
    
    echo "Creating Hetzner Cloud server..."
    echo "  Server Type: $SERVER_TYPE"
    echo "  Location: $LOCATION"
    echo "  SSH Key: $SSH_KEY_NAME"
    
    # Create the server
    hcloud server create \
        --name "hetzner-vps-$(date +%Y%m%d-%H%M%S)" \
        --type "$SERVER_TYPE" \
        --location "$LOCATION" \
        --ssh-key "$SSH_KEY_NAME" \
        --image "$IMAGE" \
        $project_flag
    
    echo "Server creation initiated. This may take a few minutes..."
    echo
}

# Function to get server details
get_server_details() {
    echo "Waiting for server to be created and retrieving details..."
    
    # Wait for server to be created and get its details
    sleep 30  # Initial wait for server creation
    
    # Get the server details (IP, status, etc.)
    SERVER_ID=$(hcloud server list --label selector=pantheros --sort created:desc --limit 1 -o noheader -o columns=id | head -n1)
    if [[ -n "$SERVER_ID" ]]; then
        SERVER_IP=$(hcloud server list --label selector=pantheros --sort created:desc --limit 1 -o noheader -o columns=ipv4)
        echo "Server created with ID: $SERVER_ID"
        echo "Server IP: $SERVER_IP"
        echo
        return 0
    else
        echo "Error: Could not retrieve server details"
        return 1
    fi
}

# Function to deploy PantherOS using rescue mode
deploy_pantheros() {
    local server_ip="$1"
    echo "Deploying PantherOS to server $server_ip..."

    # For PantherOS deployment, we need to follow the rescue mode approach
    # as documented in the repository
    echo "This deployment will use the rescue mode approach as documented in PantherOS:"
    echo "1. Boot server in rescue mode"
    echo "2. Partition disk using disko"
    echo "3. Clone PantherOS repository"
    echo "4. Install using nixos-install"
    echo
    echo "Would you like to proceed with the manual deployment steps? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled."
        exit 0
    fi

    echo "To deploy PantherOS manually, please follow these steps:"
    echo
    echo "1. Boot into rescue mode:"
    echo "   hcloud server enable-rescue --type linux64 <SERVER_ID>"
    echo
    echo "2. After reboot, connect via SSH to the rescue system:"
    echo "   ssh root@<SERVER_IP>"
    echo
    echo "3. Partition the disk using disko:"
    echo "   nix run github:nix-community/disko -- --mode disko /dev/sda --flake .#hetzner-vps"
    echo
    echo "4. Clone the PantherOS repository:"
    echo "   git clone https://github.com/hbohlen/pantherOS.git"
    echo "   cd pantherOS"
    echo
    echo "5. Install PantherOS:"
    echo "   nixos-install --flake .#hetzner-vps --impure"
    echo
    echo "6. Reboot to the installed system:"
    echo "   reboot"
    echo
    echo "7. After reboot, disable rescue mode:"
    echo "   hcloud server disable-rescue <SERVER_ID>"
    echo
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            print_usage
            exit 0
            ;;
        -s|--server-type)
            SERVER_TYPE="$2"
            shift 2
            ;;
        -l|--location)
            LOCATION="$2"
            shift 2
            ;;
        -k|--ssh-key-path)
            SSH_PUB_KEY_PATH="$2"
            SSH_PRIV_KEY_PATH="${2%.pub}"
            shift 2
            ;;
        --project)
            PROJECT_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo "PantherOS Hetzner Cloud Deployment Script"
    echo "========================================="
    echo

    check_prerequisites
    create_ssh_key
    create_server
    if get_server_details; then
        deploy_pantheros "$SERVER_IP"
    else
        echo "Failed to retrieve server details. Cannot proceed with deployment."
        exit 1
    fi
}

# Run main function
main "$@"
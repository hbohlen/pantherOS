#!/usr/bin/env bash
# NixOS Deployment Script for OVH VPS
#
# Usage:
#   export OP_SERVICE_ACCOUNT_TOKEN="your-token"
#   ./deploy.sh --host root@YOUR_VPS_IP
#
# With SSH key:
#   ./deploy.sh --host root@YOUR_VPS_IP --key ~/.ssh/id_ed25519

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Parse arguments
TARGET_HOST=""
SSH_KEY=""
DISK_CONFIG="hosts/servers/ovh-cloud/disko-config.nix"
FLAKE_REF=".#ovh-cloud"

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Deploy NixOS to OVH VPS using nixos-anywhere.

Required:
  --host HOST              SSH target (e.g., root@192.168.1.1)

Options:
  --key SSH_KEY            SSH private key to use
  --disk-config PATH       Path to disk configuration (default: $DISK_CONFIG)
  --flake-ref REF          Flake reference (default: $FLAKE_REF)
  -h, --help               Show this help

Examples:
  # Deploy with password authentication
  $0 --host root@192.168.1.1

  # Deploy with SSH key
  $0 --host root@192.168.1.1 --key ~/.ssh/id_ed25519

  # Custom disk configuration
  $0 --host root@192.168.1.1 --disk-config my-disk-config.nix

Environment Variables:
  OP_SERVICE_ACCOUNT_TOKEN    1Password service account token (required)
  SSHPASS                     SSH password (if not using key-based auth)

EOF
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)
            TARGET_HOST="$2"
            shift 2
            ;;
        --key)
            SSH_KEY="$2"
            shift 2
            ;;
        --disk-config)
            DISK_CONFIG="$2"
            shift 2
            ;;
        --flake-ref)
            FLAKE_REF="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Validate arguments
if [[ -z "$TARGET_HOST" ]]; then
    echo -e "${RED}Error: --host is required${NC}"
    usage
fi

if [[ -z "${OP_SERVICE_ACCOUNT_TOKEN:-}" ]]; then
    echo -e "${RED}Error: OP_SERVICE_ACCOUNT_TOKEN environment variable is required${NC}"
    echo -e "${YELLOW}Run: export OP_SERVICE_ACCOUNT_TOKEN=\"your-token\"${NC}"
    exit 1
fi

# Check if nix is available
if ! command -v nix &> /dev/null; then
    echo -e "${RED}Error: Nix is not installed${NC}"
    echo -e "${YELLOW}Install Nix: https://nixos.org/download/${NC}"
    exit 1
fi

# Check if nixos-anywhere is available
if ! nix run github:nix-community/nixos-anywhere -- --help &> /dev/null; then
    echo -e "${YELLOW}Installing nixos-anywhere...${NC}"
    nix profile install github:nix-community/nixos-anywhere
fi

echo -e "${GREEN}=== NixOS Deployment Started ===${NC}"
echo -e "${YELLOW}Target:${NC} $TARGET_HOST"
echo -e "${YELLOW}Flake:${NC} $FLAKE_REF"
echo -e "${YELLOW}Disk Config:${NC} $DISK_CONFIG"
echo ""

# Build configuration first
echo -e "${GREEN}1. Building configuration...${NC}"
nix build "$FLAKE_REF" --no-link
echo -e "${GREEN}✓ Configuration builds successfully${NC}"
echo ""

# Deploy
echo -e "${GREEN}2. Deploying to server...${NC}"
DEPLOY_CMD="nix run github:nix-community/nixos-anywhere -- --flake '$FLAKE_REF' --disk-config '$DISK_CONFIG' --target-host '$TARGET_HOST'"

if [[ -n "$SSH_KEY" ]]; then
    DEPLOY_CMD="$DEPLOY_CMD -i '$SSH_KEY'"
elif [[ -n "${SSHPASS:-}" ]]; then
    DEPLOY_CMD="$DEPLOY_CMD --env-password"
fi

echo -e "${YELLOW}Running:${NC} $DEPLOY_CMD"
echo ""

# Run deployment
eval "$DEPLOY_CMD"

echo ""
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Wait for the server to reboot (1-2 minutes)"
echo -e "  2. SSH into the new system: ssh hbohlen@$TARGET_HOST"
echo -e "  3. Connect to Tailscale: sudo tailscale up"
echo -e "  4. Verify installation: nix --version"
echo ""
echo -e "${GREEN}Server should be accessible via SSH at the new IP address${NC}"
echo -e "${GREEN}Once Tailscale is connected, you can access it via: ssh hbohlen@ovh-cloud${NC}"

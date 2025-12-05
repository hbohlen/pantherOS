#!/bin/bash
set -e

################################################################################
# Automated Contabo VPS Deployment Script
#
# This script automates the entire deployment process:
# - Validates required secrets and configuration
# - Runs nixos-anywhere
# - Sets up OpNix and 1Password integration
# - Verifies Tailscale and SSH configuration
# - Provides comprehensive feedback and error handling
#
# Usage:
#   ./deploy-contabo.sh --flake '.#contabo-vps' --ip 1.2.3.4 --use-1password
#   ./deploy-contabo.sh --flake '.#contabo-vps' --ip 1.2.3.4 --token ~/opnix-token.txt
#
# Options:
#   --flake FLAKE           Nix flake target (required)
#   --user USER             Username for post-deploy SSH (default: hbohlen)
#   --ip IP                 Server IP address (required)
#   --token TOKEN           Path to OpNix token file (if not using --use-1password)
#   --use-1password         Auto-retrieve tokens from 1Password CLI
#   --password PASS         SSH password for initial access (optional)
#   --no-reboot             Skip reboot after nixos-anywhere
#   --verbose               Enable verbose output
#   --help                  Show this help message
#
# 1Password Integration:
#   If using --use-1password, the script will:
#   - Read OpNix token from: op://pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token
#   - Read Tailscale key from: op://pantherOS/tailscale/authKey
#
#   Make sure you're signed in to 1Password CLI: op signin
################################################################################

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Detect CI/CD environment
CI_MODE="${CI:-false}"
CI_MODE="${GITHUB_ACTIONS:-false}"
if [ "$CI_MODE" = "true" ] || [ "$GITHUB_ACTIONS" = "true" ]; then
    CI_MODE=true
fi

# Default values
FLAKE_TARGET=""
USERNAME="hbohlen"
SERVER_IP="${SERVER_IP:-}"
OPNIX_TOKEN_PATH=""
SSH_PASSWORD=""
SKIP_REBOOT=false
VERBOSE=false
USE_1PASSWORD=false
TAILSCALE_KEY_PATH=""
DEPLOYMENT_METHOD="update-existing"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --flake)
            FLAKE_TARGET="$2"
            shift 2
            ;;
        --user)
            USERNAME="$2"
            shift 2
            ;;
        --ip)
            SERVER_IP="$2"
            shift 2
            ;;
        --token)
            OPNIX_TOKEN_PATH="$2"
            shift 2
            ;;
        --use-1password)
            USE_1PASSWORD=true
            shift
            ;;
        --password)
            SSH_PASSWORD="$2"
            shift 2
            ;;
        --no-reboot)
            SKIP_REBOOT=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help)
            grep "^#" "$0" | grep -v "^#!/bin/bash" | sed 's/^# //' | sed 's/^#//'
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

################################################################################
# CI/CD Mode Configuration
################################################################################

load_ci_configuration() {
    if [ "$CI_MODE" = "true" ]; then
        print_info "Running in CI/CD mode"

        # Load configuration from environment variables
        if [ -n "$SERVER_IP" ]; then
            print_success "Server IP loaded from environment: $SERVER_IP"
        fi

        # Load deployment method
        if [ -n "$DEPLOYMENT_METHOD" ]; then
            print_success "Deployment method: $DEPLOYMENT_METHOD"
        fi

        # Load flake target from environment (if provided)
        if [ -n "${FLAKE_TARGET:-}" ]; then
            print_success "Flake target: $FLAKE_TARGET"
        fi

        # Load OpNix token from environment (GitHub secrets)
        if [ -n "${OPNIX_TOKEN:-}" ]; then
            # Create temporary token file
            OPNIX_TOKEN_PATH="/tmp/deploy-opnix-token-ci-$$"
            echo "$OPNIX_TOKEN" > "$OPNIX_TOKEN_PATH"
            chmod 600 "$OPNIX_TOKEN_PATH"
            print_success "OpNix token loaded from environment"
        fi

        # Load SSH key from environment
        if [ -n "${DEPLOY_SSH_KEY:-}" ]; then
            # SSH key will be configured by the caller
            print_success "SSH key available from environment"
        fi

        # Load verbose flag
        if [ -n "${VERBOSE:-}" ]; then
            if [ "$VERBOSE" = "true" ]; then
                VERBOSE=true
                print_info "Verbose mode enabled"
            fi
        fi

        # Auto-detect flake target if not specified
        if [ -z "$FLAKE_TARGET" ]; then
            # Try to infer from common patterns
            FLAKE_TARGET=".#contabo-vps"
            print_info "Auto-detected flake target: $FLAKE_TARGET"
        fi
    fi
}

################################################################################
# Helper Functions
################################################################################

print_header() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_step() {
    if [ "$CI_MODE" = "true" ]; then
        echo "::group::$1"
    else
        echo -e "${BLUE}[STEP]${NC} $1"
    fi
}

print_success() {
    if [ "$CI_MODE" = "true" ]; then
        echo "::notice::$1"
        echo "::endgroup::"
    else
        echo -e "${GREEN}✓${NC} $1"
    fi
}

print_error() {
    if [ "$CI_MODE" = "true" ]; then
        echo "::error::$1"
    else
        echo -e "${RED}✗${NC} $1"
    fi
}

print_warning() {
    if [ "$CI_MODE" = "true" ]; then
        echo "::warning::$1"
    else
        echo -e "${YELLOW}⚠${NC} $1"
    fi
}

print_info() {
    if [ "$CI_MODE" = "true" ]; then
        echo "::notice::$1"
    else
        echo -e "${CYAN}ℹ${NC} $1"
    fi
}

################################################################################
# 1Password Integration Functions
################################################################################

check_1password_cli() {
    if ! command -v op &> /dev/null; then
        print_error "1Password CLI (op) not found"
        echo ""
        echo "Please install 1Password CLI:"
        echo "  macOS: brew install 1password-cli"
        echo "  Linux: https://1password.com/downloads/command-line/"
        echo ""
        echo "Or use --token to specify a token file instead of --use-1password"
        exit 1
    fi
    print_success "1Password CLI (op) is installed"
}

check_1password_signin() {
    print_step "Checking 1Password sign-in status..."

    if ! op account list &> /dev/null; then
        print_error "Not signed in to 1Password CLI"
        echo ""
        echo "Please sign in first:"
        echo "  op signin"
        echo ""
        echo "You can also use --token to specify a token file instead"
        exit 1
    fi

    local account_info=$(op account list --format json | jq -r '.[0].email // "unknown"')
    print_success "Signed in to 1Password as: $account_info"
}

retrieve_opnix_token_from_1password() {
    print_step "Retrieving OpNix token from 1Password..."

    local token_temp="/tmp/deploy-opnix-token-1p-$$"
    if ! op read --out-file "$token_temp" "op://pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token" 2>&1; then
        print_error "Failed to retrieve OpNix token from 1Password"
        echo ""
        echo "Check:"
        echo "  1. You're signed in: op account list"
        echo "  2. Secret exists: op://pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token"
        echo "  3. You have access to the pantherOS vault"
        rm -f "$token_temp"
        exit 1
    fi

    if [ ! -s "$token_temp" ]; then
        print_error "Retrieved token is empty"
        rm -f "$token_temp"
        exit 1
    fi

    # Validate token format (should start with "op_")
    local token_start=$(head -1 "$token_temp" | cut -c1-10)
    if [ "$token_start" != "op_" ] && [ "$token_start" != "eyJ" ]; then
        print_error "Retrieved token doesn't look valid"
        echo "Expected token to start with 'op_' or JWT format"
        rm -f "$token_temp"
        exit 1
    fi

    OPNIX_TOKEN_PATH="$token_temp"
    print_success "OpNix token retrieved from 1Password"
}

retrieve_tailscale_key_from_1password() {
    print_step "Retrieving Tailscale auth key from 1Password..."

    local tailscale_key_temp="/tmp/deploy-tailscale-key-1p-$$"
    if op read --out-file "$tailscale_key_temp" "op://pantherOS/tailscale/authKey" 2>&1; then
        if [ -s "$tailscale_key_temp" ]; then
            print_success "Tailscale auth key retrieved from 1Password"
            # We could use this to update Tailscale config if needed
            TAILSCALE_KEY_PATH="$tailscale_key_temp"
        else
            print_warning "Tailscale key not found in 1Password (will be managed by OpNix)"
            rm -f "$tailscale_key_temp"
        fi
    else
        print_info "Tailscale auth key not in 1Password (will be managed by OpNix)"
        rm -f "$tailscale_key_temp"
    fi
}

cleanup_1password_temp_files() {
    [ -f "$OPNIX_TOKEN_PATH" ] && [[ "$OPNIX_TOKEN_PATH" == *"/tmp/deploy-opnix-token-1p-"* ]] && rm -f "$OPNIX_TOKEN_PATH"
    [ -f "$TAILSCALE_KEY_PATH" ] && [[ "$TAILSCALE_KEY_PATH" == *"/tmp/deploy-tailscale-key-1p-"* ]] && rm -f "$TAILSCALE_KEY_PATH"
}

################################################################################
# Pre-flight Checks
################################################################################

check_requirements() {
    print_step "Checking prerequisites..."

    # Check if running from correct directory
    if [ ! -f "flake.nix" ]; then
        print_error "flake.nix not found in current directory"
        echo "Please run this script from the root of your pantherOS repository"
        exit 1
    fi
    print_success "Running from repository root"

    # Check flake target
    if [ -z "$FLAKE_TARGET" ]; then
        print_error "Flake target not specified"
        echo "Use: --flake '.#hetzner-vps' (or your target)"
        exit 1
    fi
    print_success "Flake target: $FLAKE_TARGET"

    # Check server IP
    if [ -z "$SERVER_IP" ]; then
        print_error "Server IP not specified"
        echo "Use: --ip <your-server-ip>"
        exit 1
    fi
    print_success "Server IP: $SERVER_IP"

    # Check OpNix token
    if [ -z "$OPNIX_TOKEN_PATH" ]; then
        if [ "$USE_1PASSWORD" = true ]; then
            # Auto-retrieve from 1Password
            check_1password_cli
            check_1password_signin
            retrieve_opnix_token_from_1password
            retrieve_tailscale_key_from_1password
        else
            print_error "OpNix token path not specified"
            echo "Use either:"
            echo "  --token /path/to/opnix-token.txt"
            echo "  --use-1password (to auto-retrieve from 1Password CLI)"
            echo ""
            echo "To get your OpNix token manually:"
            echo "  op read op://pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token"
            exit 1
        fi
    else
        # Manual token path provided
        if [ ! -f "$OPNIX_TOKEN_PATH" ]; then
            print_error "OpNix token file not found: $OPNIX_TOKEN_PATH"
            exit 1
        fi

        if [ ! -s "$OPNIX_TOKEN_PATH" ]; then
            print_error "OpNix token file is empty: $OPNIX_TOKEN_PATH"
            exit 1
        fi
        print_success "OpNix token file found"
    fi

    # Check if nixos-anywhere is available
    if ! command -v nix &> /dev/null; then
        print_error "nix command not found"
        echo "Please install Nix: https://nixos.org/download/"
        exit 1
    fi
    print_success "Nix is installed"

    # Validate flake
    print_step "Validating flake configuration..."
    if ! nix flake check --impure 2>&1 | tee /tmp/flake-check.log; then
        print_error "Flake validation failed"
        echo ""
        echo "Please fix the errors above before deploying"
        if [ "$VERBOSE" = true ]; then
            cat /tmp/flake-check.log
        fi
        exit 1
    fi
    print_success "Flake validation passed"

    # Test that the target builds
    print_step "Testing build for $FLAKE_TARGET..."
    if ! nix build "$FLAKE_TARGET" --no-link 2>&1 | tee /tmp/build-test.log; then
        print_error "Build test failed"
        echo ""
        echo "Please fix the configuration errors before deploying"
        if [ "$VERBOSE" = true ]; then
            cat /tmp/build-test.log
        fi
        exit 1
    fi
    print_success "Target builds successfully"

    echo ""
}

check_server_accessibility() {
    print_step "Checking server accessibility..."

    # Check if IP is reachable
    if ping -c 1 -W 3 "$SERVER_IP" &> /dev/null; then
        print_success "Server is reachable via ping"
    else
        print_warning "Server is not reachable via ping"
        echo "This might be normal if server is powered off or in rescue mode"
    fi

    # Check if SSH port is accessible
    if timeout 5 bash -c "echo > /dev/tcp/$SERVER_IP/22" 2>/dev/null; then
        print_success "SSH port (22) is accessible"
    else
        print_warning "SSH port is not accessible"
        echo "This is expected if server is in rescue mode or powered off"
    fi

    echo ""
}

################################################################################
# Deployment Functions
################################################################################

deploy_to_server() {
    print_header "Deploying NixOS to Server"

    print_step "Starting nixos-anywhere deployment..."
    echo ""
    echo "Command: nix run github:nix-community/nixos-anywhere -- --flake '$FLAKE_TARGET' --no-reboot $SSH_PASSWORD root@$SERVER_IP"
    echo ""

    # Build the nixos-anywhere command
    NIXOS_ANYWHERE_CMD="nix run github:nix-community/nixos-anywhere -- --flake '$FLAKE_TARGET'"

    if [ "$SKIP_REBOOT" = true ]; then
        NIXOS_ANYWHERE_CMD="$NIXOS_ANYWHERE_CMD --no-reboot"
    fi

    if [ -n "$SSH_PASSWORD" ]; then
        NIXOS_ANYWHERE_CMD="$NIXOS_ANYWHERE_CMD --password '$SSH_PASSWORD'"
    fi

    NIXOS_ANYWHERE_CMD="$NIXOS_ANYWHERE_CMD root@$SERVER_IP"

    # Run nixos-anywhere
    eval "$NIXOS_ANYWHERE_CMD"
    local deploy_status=$?

    if [ $deploy_status -eq 0 ]; then
        print_success "nixos-anywhere deployment completed"
    else
        print_error "nixos-anywhere deployment failed (exit code: $deploy_status)"
        echo ""
        echo "Common issues:"
        echo "  - Server not in rescue mode"
        echo "  - Wrong SSH credentials"
        echo "  - Network connectivity issues"
        echo "  - Disk space issues"
        exit 1
    fi

    echo ""
}

wait_for_reboot() {
    if [ "$SKIP_REBOOT" = true ]; then
        print_info "Skipping reboot (--no-reboot flag set)"
        return 0
    fi

    print_header "Waiting for Server Reboot"

    print_step "Waiting for server to reboot (this takes 2-3 minutes)..."
    echo "You can monitor the deployment at: https://console.hetzner.cloud/servers/$SERVER_IP"
    echo ""

    local count=0
    local max_wait=180  # 3 minutes
    local interval=5

    while [ $count -lt $max_wait ]; do
        if timeout 5 bash -c "echo > /dev/tcp/$SERVER_IP/22" 2>/dev/null; then
            print_success "Server is back online!"
            echo ""

            # Give SSH service a moment to fully start
            print_step "Waiting for SSH service to be ready..."
            sleep 5

            return 0
        fi

        count=$((count + interval))
        printf "  %02d seconds...\r" $count
        sleep $interval
    done

    print_error "Server did not come back online within $max_wait seconds"
    echo ""
    echo "Please check:"
    echo "  1. Server status in Hetzner console"
    echo "  2. Console output for any errors"
    echo "  3. Network configuration"
    exit 1
}

################################################################################
# Post-Deployment Functions
################################################################################

setup_opnix() {
    print_header "Setting Up OpNix and 1Password Integration"

    print_step "Transferring OpNix token to server..."

    # Create temporary token file with proper permissions
    local temp_token="/tmp/deploy-opnix-token-$$"
    cp "$OPNIX_TOKEN_PATH" "$temp_token"

    # Transfer token
    scp -o StrictHostKeyChecking=no \
        -o ConnectTimeout=10 \
        "$temp_token" root@$SERVER_IP:/tmp/opnix-token 2>&1 | tee /tmp/scp-token.log

    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        print_error "Failed to transfer OpNix token"
        echo ""
        echo "Check:"
        echo "  1. Can SSH to server: ssh root@$SERVER_IP"
        echo "  2. SSH key is authorized"
        echo "  3. Server filesystem is mounted correctly"
        rm -f "$temp_token"
        exit 1
    fi
    print_success "OpNix token transferred"

    print_step "Installing OpNix token and restarting service..."

    # Install token and restart service
    ssh -o StrictHostKeyChecking=no \
        -o ConnectTimeout=10 \
        root@$SERVER_IP "
        set -e
        mv /tmp/opnix-token /etc/opnix-token
        chmod 600 /etc/opnix-token
        echo 'Token installed with correct permissions'
        systemctl restart onepassword-secrets.service
        echo 'OpNix service restarted'
    " 2>&1 | tee /tmp/opnix-setup.log

    if [ ${PIPESTATUS[0]} -ne 0 ]; then
        print_error "Failed to install OpNix token"
        echo ""
        echo "Check logs with:"
        echo "  ssh root@$SERVER_IP 'journalctl -u onepassword-secrets.service -n 50'"
        rm -f "$temp_token"
        exit 1
    fi
    print_success "OpNix token installed and service restarted"

    # Wait a moment for OpNix to populate secrets
    print_step "Waiting for OpNix to populate secrets..."
    sleep 10

    # Clean up
    rm -f "$temp_token"

    echo ""
}

verify_opnix_secrets() {
    print_step "Verifying OpNix secrets..."

    # Check if SSH keys are populated
    local root_keys=$(ssh -o StrictHostKeyChecking=no root@$SERVER_IP "test -s /root/.ssh/authorized_keys && wc -l < /root/.ssh/authorized_keys || echo 0")
    local user_keys=$(ssh -o StrictHostKeyChecking=no root@$SERVER_IP "test -s /home/$USERNAME/.ssh/authorized_keys && wc -l < /home/$USERNAME/.ssh/authorized_keys || echo 0")

    if [ "$root_keys" -gt 0 ]; then
        print_success "Root SSH keys populated ($root_keys keys)"
    else
        print_error "Root SSH keys not populated"
        echo ""
        echo "Troubleshooting:"
        echo "  1. Check OpNix service: ssh root@$SERVER_IP 'systemctl status onepassword-secrets.service'"
        echo "  2. Check service logs: ssh root@$SERVER_IP 'journalctl -u onepassword-secrets.service -n 50'"
        echo "  3. Verify token: ssh root@$SERVER_IP 'cat /etc/opnix-token | head -1'"
        echo "  4. Check OpNix vault access: ssh root@$SERVER_IP 'opnix secrets list'"
        exit 1
    fi

    if [ "$user_keys" -gt 0 ]; then
        print_success "User SSH keys populated ($user_keys keys)"
    else
        print_error "User SSH keys not populated"
        echo ""
        echo "This indicates OpNix is not properly configured"
        echo "Check the troubleshooting steps above"
        exit 1
    fi

    # Check Tailscale auth key
    if ssh -o StrictHostKeyChecking=no root@$SERVER_IP "test -f /etc/tailscale/auth-key" >/dev/null 2>&1; then
        print_success "Tailscale auth key file exists"
    else
        print_warning "Tailscale auth key file not found (this is OK if using different auth method)"
    fi

    echo ""
}

verify_ssh_access() {
    print_header "Verifying SSH Access"

    print_step "Testing SSH access as user ($USERNAME)..."

    # Test SSH with keys only
    if ssh -o StrictHostKeyChecking=no \
           -o PasswordAuthentication=no \
           -o BatchMode=yes \
           -o ConnectTimeout=10 \
           $USERNAME@$SERVER_IP "echo 'SSH access verified'" 2>/dev/null; then
        print_success "SSH access working with key-based authentication"
    else
        print_error "Cannot SSH as $USERNAME with keys"
        echo ""
        echo "Troubleshooting:"
        echo "  1. Check user exists: ssh root@$SERVER_IP 'id $USERNAME'"
        echo "  2. Check authorized_keys: ssh root@$SERVER_IP 'cat /home/$USERNAME/.ssh/authorized_keys'"
        echo "  3. Verify OpNix secrets: ssh root@$SERVER_IP '/root/scripts/verify-opnix.sh'"
        exit 1
    fi

    echo ""
}

verify_services() {
    print_header "Verifying System Services"

    print_step "Checking key services on server..."

    # Check OpNix service
    if ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl is-active --quiet onepassword-secrets.service"; then
        print_success "OpNix service is running"
    else
        print_error "OpNix service is not running"
        ssh root@$SERVER_IP "systemctl status onepassword-secrets.service --no-pager"
        exit 1
    fi

    # Check Tailscale service
    if ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl is-active --quiet tailscaled.service"; then
        print_success "Tailscale service is running"
    else
        print_warning "Tailscale service is not running (may need authentication)"
    fi

    # Check SSH service
    if ssh -o StrictHostKeyChecking=no root@$SERVER_IP "systemctl is-active --quiet ssh.service"; then
        print_success "SSH service is running"
    else
        print_error "SSH service is not running"
        exit 1
    fi

    # Check Podman
    if ssh -o StrictHostKeyChecking=no root@$SERVER_IP "command -v podman" >/dev/null 2>&1; then
        print_success "Podman is installed"
    else
        print_warning "Podman is not installed"
    fi

    # Check NixOS version
    local nixos_version=$(ssh -o StrictHostKeyChecking=no root@$SERVER_IP "nixos-version" 2>/dev/null || echo "unknown")
    print_success "NixOS version: $nixos_version"

    echo ""
}

show_deployment_summary() {
    print_header "Deployment Complete!"

    echo -e "${GREEN}✓${NC} NixOS system deployed successfully"
    echo -e "${GREEN}✓${NC} OpNix and 1Password integration configured"
    echo -e "${GREEN}✓${NC} SSH access verified with key-based authentication"
    echo -e "${GREEN}✓${NC} All services running"
    echo ""

    print_info "Server Details:"
    echo "  IP Address: $SERVER_IP"
    echo "  Username: $USERNAME"
    echo "  Flake Target: $FLAKE_TARGET"
    echo ""

    print_info "Next Steps:"
    echo "  1. SSH to your server:"
    echo "     ssh $USERNAME@$SERVER_IP"
    echo ""
    echo "  2. Verify everything is working:"
    echo "     sudo /root/scripts/verify-opnix.sh"
    echo ""
    echo "  3. Connect Tailscale (if needed):"
    echo "     sudo tailscale up"
    echo ""
    echo "  4. Test container runtime:"
    echo "     podman run --rm hello-world"
    echo ""

    print_info "Useful Commands:"
    echo "  Check system status: ssh root@$SERVER_IP 'systemctl status'"
    echo "  View logs: ssh root@$SERVER_IP 'journalctl -xe'"
    echo "  Update configuration: ssh root@$SERVER_IP 'sudo nixos-rebuild switch --flake .#$FLAKE_TARGET'"
    echo ""

    print_success "Deployment completed successfully! 🎉"
    echo ""
}

################################################################################
# Main Execution
################################################################################

main() {
    # Set up cleanup trap for temporary files
    trap cleanup_1password_temp_files EXIT

    # Load CI/CD configuration if in CI mode
    if [ "$CI_MODE" = "true" ]; then
        load_ci_configuration
    else
        clear
        echo -e "${CYAN}"
        cat <<'EOF'
╔══════════════════════════════════════════════════════════╗
║                                                          ║
║     NixOS Contabo VPS Automated Deployment              ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
EOF
        echo -e "${NC}"

        print_info "This script will:"
        echo "  1. Validate configuration and prerequisites"
        echo "  2. Deploy NixOS using nixos-anywhere"
        echo "  3. Set up OpNix and 1Password integration"
        echo "  4. Verify SSH access and services"
        echo ""

        # Confirmation (skip in CI mode)
        echo -n "Continue with deployment? (y/N): "
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Deployment cancelled"
            exit 0
        fi
        echo ""
    fi

    # Run deployment steps
    check_requirements
    check_server_accessibility
    deploy_to_server
    wait_for_reboot
    setup_opnix
    verify_opnix_secrets
    verify_ssh_access
    verify_services
    show_deployment_summary
}

# Run main function
main "$@"

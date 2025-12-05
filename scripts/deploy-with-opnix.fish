#!/usr/bin/env fish
# deploy-with-opnix.fish
# Fish shell deployment script for NixOS on Hetzner Cloud with OpNix
# Optimized for CachyOS laptop

# Colors for output
set -g RED '\033[0;31m'
set -g GREEN '\033[0;32m'
set -g YELLOW '\033[1;33m'
set -g BLUE '\033[0;34m'
set -g NC '\033[0m' # No Color

function print_info
    printf "%b[INFO]%b %s\n" "$GREEN" "$NC" "$argv"
end

function print_warn
    printf "%b[WARN]%b %s\n" "$YELLOW" "$NC" "$argv"
end

function print_error
    printf "%b[ERROR]%b %s\n" "$RED" "$NC" "$argv"
end

function print_step
    printf "%b[STEP]%b %s\n" "$BLUE" "$NC" "$argv"
end

# Check prerequisites
function check_prerequisites
    print_step "Checking prerequisites..."

    # Check for nix
    if not command -v nix &> /dev/null
        print_error "nix command not found. Please install Nix."
        exit 1
    end

    # Check for 1Password CLI
    if not command -v op &> /dev/null
        print_error "1Password CLI not found. This is required!"
        echo ""
        echo "Install on CachyOS:"
        echo "  yay -S 1password-cli"
        echo "  # or"
        echo "  paru -S 1password-cli"
        exit 1
    end

    print_info "Prerequisites OK"
    print_info "Note: Will use 'nix run' to execute nixos-anywhere"
end

# Get token from 1Password or environment
function get_token
    print_step "Getting 1Password service account token..."

    # Check if token is in environment
    if set -q OP_SERVICE_ACCOUNT_TOKEN; and test -n "$OP_SERVICE_ACCOUNT_TOKEN"
        print_info "Using token from environment variable"
        return 0
    end

    print_info "Fetching token from 1Password vault: pantherOS"
    print_info "Reference: op://pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token"

    # Try to fetch from 1Password
    # First, check if user is signed in
    if not op account list &> /dev/null
        print_warn "Not signed in to 1Password. Signing in..."
        op signin
        if test $status -ne 0
            print_error "Failed to sign in to 1Password"
            exit 1
        end
    end

    # Fetch token from 1Password
    set -gx OP_SERVICE_ACCOUNT_TOKEN (op read "op://pantherOS/OP_SERVICE_ACCOUNT_TOKEN/token" 2>&1)
    if test $status -ne 0
        print_error "Failed to fetch token from 1Password"
        echo ""
        echo "Please set the token manually:"
        echo '  set -gx OP_SERVICE_ACCOUNT_TOKEN "ops_..."'
        exit 1
    end

    print_info "Token fetched successfully from 1Password!"
end

# Verify token works
function verify_token
    print_step "Verifying 1Password service account token..."

    if test -z "$OP_SERVICE_ACCOUNT_TOKEN"
        print_error "OP_SERVICE_ACCOUNT_TOKEN is not set!"
        exit 1
    end

    # Test token
    print_info "Testing token authentication..."
    if op account list --session $OP_SERVICE_ACCOUNT_TOKEN &> /dev/null
        print_info "✓ Token is valid!"
    else
        print_error "Token authentication failed"
        exit 1
    end
end

# Verify secrets exist in 1Password
function verify_secrets
    print_step "Verifying secrets exist in pantherOS vault..."

    # Required secrets with their exact paths
    set -l secrets \
        "tailscale:authKey" \
        "SSH:public key"

    set all_found true
    for secret in $secrets
        set -l item (string split ":" $secret)[1]
        set -l field (string split ":" $secret)[2]

        print_info "Checking: $item/$field"
        if op item get "$item" --vault "pantherOS" --fields "$field" &> /dev/null
            print_info "  ✓ Found: $item/$field"
        else
            print_error "  ✗ Missing: $item/$field"
            set all_found false
        end
    end

    if test "$all_found" = false
        print_error "Some secrets are missing in pantherOS vault!"
        echo ""
        echo "Required secrets:"
        echo "  - tailscale/authKey"
        echo "  - SSH/public key"
        exit 1
    end

    print_info "✓ All required secrets found!"
end

# Test configuration
function test_configuration
    print_step "Testing NixOS configuration..."

    if nix flake check
        print_info "✓ Configuration check passed!"
    else
        print_error "Configuration check failed"
        exit 1
    end

    print_info "Building configuration (dry-run)..."
    if nix build .#nixosConfigurations.hetzner-vps.config.system.build.toplevel --dry-run
        print_info "✓ Build test passed!"
    else
        print_error "Build test failed"
        exit 1
    end
end

# Setup token on target server
function setup_token_on_server
    set server_ip $argv[1]

    print_step "Setting up OpNix token on target server..."

    # Create token file on server
    ssh root@$server_ip "mkdir -p /etc && echo '$OP_SERVICE_ACCOUNT_TOKEN' > /etc/opnix-token && chmod 600 /etc/opnix-token && chown root:root /etc/opnix-token"

    if test $status -eq 0
        print_info "✓ Token file created on server"
    else
        print_error "Failed to create token file on server"
        exit 1
    end
end

# Deploy with nixos-anywhere
function deploy
    set server_ip $argv[1]

    print_step "Starting deployment to $server_ip..."
    echo ""
    print_warn "⚠️  This will WIPE THE DISK and install NixOS!"
    echo ""

    # Confirm deployment
    read -P "Continue with deployment? (yes/no): " confirm
    if test "$confirm" != "yes"
        print_info "Deployment cancelled."
        exit 0
    end

    # Setup token on target server before deployment
    setup_token_on_server $server_ip

    # Run nixos-anywhere using nix run
    print_step "Running nixos-anywhere..."
    echo ""
    if nix run github:nix-community/nixos-anywhere -- --flake .#hetzner-vps root@$server_ip
        print_info "✓ Deployment completed successfully!"
    else
        print_error "Deployment failed!"
        exit 1
    end
end

# Deploy OVH VPS with nixos-anywhere
function deploy-ovh
    set server_ip $argv[1]

    print_step "Starting OVH deployment to $server_ip..."
    echo ""
    print_warn "⚠️  This will WIPE THE DISK and install NixOS!"
    echo ""

    # Confirm deployment
    read -P "Continue with deployment? (yes/no): " confirm
    if test "$confirm" != "yes"
        print_info "Deployment cancelled."
        exit 0
    end

    # Setup token on target server before deployment
    setup_token_on_server $server_ip

    # Run nixos-anywhere using nix run for OVH
    print_step "Running nixos-anywhere for OVH..."
    echo ""
    if nix run github:nix-community/nixos-anywhere -- --flake .#ovh-vps root@$server_ip
        print_info "✓ OVH deployment completed successfully!"
    else
        print_error "OVH deployment failed!"
        exit 1
    end
end

# Post-deployment verification
function verify_deployment
    set server_ip $argv[1]

    print_step "Waiting for server to reboot (60 seconds)..."
    sleep 60

    print_step "Verifying deployment..."

    # Try to SSH and check OpNix service
    if ssh -o ConnectTimeout=10 hbohlen@$server_ip "sudo systemctl status opnix-secrets.service" &> /dev/null
        print_info "✓ SSH access working"
        print_info "✓ OpNix service is running"
    else
        print_warn "Could not verify via SSH yet. Server may still be booting..."
    end

    print_info "Checking Tailscale connectivity..."
    sleep 10
    if ssh -o ConnectTimeout=10 hbohlen@100.64.207.56 "hostname" &> /dev/null
        print_info "✓ Tailscale is working! Can connect via 100.64.207.56"
    else
        print_warn "Tailscale not connected yet. May need a few more minutes."
    end
end

# Main script
function main
    echo "================================================"
    echo "  NixOS Deployment with OpNix + pantherOS"
    echo "  Hetzner Cloud CPX52 from CachyOS"
    echo "================================================"
    echo ""

    # Get server IP
    if test (count $argv) -ge 1
        set SERVER_IP $argv[1]
    else
        read -P "Enter server IP address: " SERVER_IP
    end

    if test -z "$SERVER_IP"
        print_error "Server IP address is required!"
        exit 1
    end

    print_info "Target server: $SERVER_IP"
    echo ""

    # Run checks
    check_prerequisites
    get_token
    verify_token
    verify_secrets
    test_configuration

    echo ""
    print_info "✓ Pre-deployment checks passed!"
    echo ""

    # Deploy
    deploy $SERVER_IP

    echo ""
    print_info "Deployment phase completed!"
    echo ""

    # Verify
    verify_deployment $SERVER_IP

    echo ""
    echo "================================================"
    print_info "Deployment Summary"
    echo "================================================"
    echo "Server IP (public): $SERVER_IP"
    echo "Server IP (Tailscale): 100.64.207.56"
    echo ""
    echo "SSH commands:"
    echo "  ssh hbohlen@$SERVER_IP"
    echo "  ssh hbohlen@100.64.207.56"
    echo ""
    echo "Verify deployment:"
    echo '  ssh hbohlen@$SERVER_IP "sudo systemctl status opnix-secrets.service"'
    echo '  ssh hbohlen@$SERVER_IP "tailscale status"'
    echo ""
    echo "View logs:"
    echo '  ssh hbohlen@$SERVER_IP "sudo journalctl -u opnix-secrets.service -b"'
    echo '  ssh hbohlen@$SERVER_IP "sudo journalctl -u tailscaled -b"'
    echo ""
    print_info "Deployment complete! 🎉"
end

# Run main function
main $argv

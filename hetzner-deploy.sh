#!/usr/bin/env bash

# Hetzner Cloud Deployment Script
# This script helps deploy the NixOS configuration to Hetzner Cloud VPS

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FLAKE_PATH="."
HOST_NAME="hetzner-cloud"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to display help
show_help() {
    cat << EOF
Hetzner Cloud Deployment Script

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    deploy          Deploy the configuration to Hetzner Cloud (using nixos-anywhere)
    build           Build the configuration locally
    test            Test the configuration without deploying
    update-flake    Update flake inputs
    help            Show this help message

Options:
    -h, --help      Show this help message
    --target-ip     Target server IP address (required for deploy)

Examples:
    $0 deploy --target-ip 1.2.3.4
    $0 build
    $0 test
    $0 update-flake

EOF
}

# Function to validate prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."

    # Check if nix is available
    if ! command -v nix &> /dev/null; then
        print_error "Nix is not installed or not in PATH"
        exit 1
    fi

    # Check if flake.nix exists
    if [ ! -f "$FLAKE_PATH/flake.nix" ]; then
        print_error "flake.nix not found in $FLAKE_PATH"
        exit 1
    fi

    print_success "Prerequisites check passed"
}

# Function to build the configuration
build_config() {
    print_status "Building configuration for $HOST_NAME..."
    
    nix build "$FLAKE_PATH/#nixosConfigurations.$HOST_NAME.config.system.build.toplevel" \
        --print-build-logs
    
    print_success "Configuration built successfully"
    echo "Result available at: $(readlink -f result)"
}

# Function to test the configuration
test_config() {
    print_status "Testing configuration for $HOST_NAME..."
    
    nix flake check "$FLAKE_PATH" --print-build-logs
    
    print_success "Configuration test passed"
}

# Function to update flake inputs
update_flake() {
    print_status "Updating flake inputs..."
    
    nix flake update "$FLAKE_PATH"
    
    print_success "Flake inputs updated"
}

# Function to deploy using nixos-anywhere
deploy_config() {
    local target_ip="$1"
    
    if [ -z "$target_ip" ]; then
        print_error "Target IP is required for deployment"
        exit 1
    fi

    print_status "Deploying configuration to $target_ip..."
    print_warning "This will completely replace the system on $target_ip"
    print_warning "Make sure you have backups and access to the rescue system"
    
    read -p "Do you want to continue? (yes/no): " confirm
    if [[ $confirm != "yes" ]]; then
        print_status "Deployment cancelled"
        exit 0
    fi

    print_status "Starting deployment with nixos-anywhere..."
    
    nix run github:nix-community/nixos-anywhere \
        --extra-experimental-features "nix-command flakes" \
        -- \
        --flake "$FLAKE_PATH#$HOST_NAME" \
        --build-on-remote \
        --ssh-user root \
        --no-reboot \
        --debug \
        "root@$target_ip"

    print_success "Deployment completed successfully!"
    print_status "The system at $target_ip now runs your NixOS configuration"
    print_status "You can now SSH to the server using your configured SSH keys"
}

# Function to update existing deployment
update_existing() {
    local target_ip="$1"
    
    if [ -z "$target_ip" ]; then
        print_error "Target IP is required for updating"
        exit 1
    fi

    print_status "Updating existing deployment at $target_ip..."
    
    nixos-rebuild switch \
        --flake "$FLAKE_PATH#$HOST_NAME" \
        --target-host "hbohlen@$target_ip" \
        --build-on-remote \
        --use-remote-sudo \
        --print-build-logs

    print_success "Update completed successfully!"
}

# Main script logic
main() {
    local command=""
    local target_ip=""

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            deploy)
                command="deploy"
                shift
                ;;
            build)
                command="build"
                shift
                ;;
            test)
                command="test"
                shift
                ;;
            update-flake)
                command="update-flake"
                shift
                ;;
            --target-ip)
                target_ip="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # Check prerequisites
    check_prerequisites

    # Execute command
    case $command in
        deploy)
            deploy_config "$target_ip"
            ;;
        build)
            build_config
            ;;
        test)
            test_config
            ;;
        update-flake)
            update_flake
            ;;
        "")
            print_error "No command specified. Use --help for usage information."
            exit 1
            ;;
        *)
            print_error "Unknown command: $command"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
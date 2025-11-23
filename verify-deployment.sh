#!/usr/bin/env bash

# PantherOS Hetzner Cloud Deployment Verification Script
# This script verifies that all necessary components are in place for a successful deployment

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "OK")
            echo -e "${GREEN}[OK]${NC} $message"
            ;;
        "WARN")
            echo -e "${YELLOW}[WARN]${NC} $message"
            ;;
        "ERROR")
            echo -e "${RED}[ERROR]${NC} $message"
            ;;
    esac
}

# Function to check if a file exists
check_file() {
    local file_path="$1"
    local description="$2"
    
    if [[ -f "$file_path" ]]; then
        print_status "OK" "$description - File exists: $file_path"
        return 0
    else
        print_status "ERROR" "$description - File not found: $file_path"
        return 1
    fi
}

# Function to check if a directory exists
check_directory() {
    local dir_path="$1"
    local description="$2"
    
    if [[ -d "$dir_path" ]]; then
        print_status "OK" "$description - Directory exists: $dir_path"
        return 0
    else
        print_status "ERROR" "$description - Directory not found: $dir_path"
        return 1
    fi
}

# Function to check if a command exists
check_command() {
    local cmd="$1"
    local description="$2"
    
    if command -v "$cmd" &> /dev/null; then
        print_status "OK" "$description - Command available: $cmd"
        return 0
    else
        print_status "WARN" "$description - Command not found: $cmd"
        return 1
    fi
}

# Function to validate flake.nix contents
check_flake_contents() {
    local flake_file="$1"
    
    local hetzner_config_exists=false
    local required_inputs=("nixpkgs" "disko" "nixos-hardware" "home-manager")
    local missing_inputs=()
    
    # Check if flake contains hetzner-vps configuration
    if grep -q "hetzner-vps" "$flake_file"; then
        hetzner_config_exists=true
    fi
    
    # Check for required inputs
    for input in "${required_inputs[@]}"; do
        if ! grep -q "$input" "$flake_file"; then
            missing_inputs+=("$input")
        fi
    done
    
    if [[ "$hetzner_config_exists" == true ]]; then
        print_status "OK" "Flake configuration - Contains hetzner-vps configuration"
    else
        print_status "ERROR" "Flake configuration - Missing hetzner-vps configuration"
    fi
    
    if [[ ${#missing_inputs[@]} -eq 0 ]]; then
        print_status "OK" "Flake configuration - All required inputs present"
    else
        print_status "ERROR" "Flake configuration - Missing inputs: ${missing_inputs[*]}"
    fi
    
    return 0
}

# Main verification function
main() {
    echo "PantherOS Hetzner Cloud Deployment Verification"
    echo "==============================================="
    echo
    
    local errors=0
    
    # Check project root files
    echo "Checking project root files..."
    if check_file "./flake.nix" "Main flake file"; then
        check_flake_contents "./flake.nix"
    else
        ((errors++))
    fi
    
    check_file "./deploy-hetzner.sh" "Main deployment script"
    check_file "./deploy-hetzner-rescue.sh" "Rescue mode deployment script"
    check_file "./README.md" "Project README"
    echo
    
    # Check documentation
    echo "Checking documentation..."
    check_file "./docs/guides/hetzner-cloud-deployment.md" "Hetzner Cloud deployment guide"
    check_file "./docs/checklists/post-deployment-verification.md" "Post-deployment verification checklist"
    echo
    
    # Check NixOS modules
    echo "Checking NixOS modules..."
    check_directory "./modules/nixos" "NixOS modules directory"
    check_directory "./modules/nixos/filesystems" "Filesystems modules directory"
    check_file "./modules/nixos/filesystems/btrfs.nix" "Btrfs filesystem module"
    check_file "./modules/nixos/filesystems/impermanence.nix" "Impermanence module"
    
    # Check for server-specific modules
    check_file "./modules/shared/filesystems/server-btrfs.nix" "Server Btrfs module"
    check_file "./modules/shared/filesystems/server-impermanence.nix" "Server impermanence module"
    check_file "./modules/shared/filesystems/server-snapshots.nix" "Server snapshots module"
    echo
    
    # Check host configurations
    echo "Checking host configurations..."
    check_directory "./hosts/servers" "Servers directory"
    check_directory "./hosts/servers/hetzner-vps" "Hetzner VPS configuration directory"
    
    if check_file "./hosts/servers/hetzner-vps/default.nix" "Hetzner VPS main configuration"; then
        # Check if the configuration imports the server-btrfs module
        if grep -q "server-btrfs" "./hosts/servers/hetzner-vps/default.nix"; then
            print_status "OK" "Hetzner VPS config - Imports server-btrfs module"
        else
            print_status "ERROR" "Hetzner VPS config - Missing server-btrfs module import"
            ((errors++))
        fi
        
        # Check if impermanence is enabled
        if grep -q "serverImpermanence" "./hosts/servers/hetzner-vps/default.nix"; then
            print_status "OK" "Hetzner VPS config - Server impermanence enabled"
        else
            print_status "WARN" "Hetzner VPS config - Server impermanence may not be enabled"
        fi
    else
        ((errors++))
    fi
    
    check_file "./hosts/servers/hetzner-vps/disko.nix" "Hetzner VPS disko configuration"
    check_file "./hosts/servers/hetzner-vps/hardware.nix" "Hetzner VPS hardware configuration"
    echo
    
    # Check home configuration
    echo "Checking home-manager configuration..."
    check_directory "./home/hbohlen" "User home directory"
    check_file "./home/hbohlen/default.nix" "User home configuration"
    echo
    
    # Check for required commands (if running in an environment where they might be available)
    echo "Checking for required commands (non-fatal warnings if not found)..."
    check_command "nix" "Nix package manager"
    check_command "hcloud" "Hetzner Cloud CLI"
    check_command "git" "Git version control"
    check_command "ssh" "SSH client"
    echo
    
    # Summary
    echo "==============================================="
    if [[ $errors -eq 0 ]]; then
        print_status "OK" "Verification completed - No critical errors found"
        echo "The PantherOS configuration appears ready for Hetzner Cloud deployment."
        echo "All required files and configurations are in place."
    else
        print_status "ERROR" "Verification completed - $errors critical error(s) found"
        echo "Please address the errors above before attempting deployment."
        exit 1
    fi
}

# Run main function
main "$@"
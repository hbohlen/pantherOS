#!/usr/bin/env bash

# Script to check and fix Nix permissions for using nix develop
# Can be used to diagnose issues and bootstrap permissions on other systems

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Checking Nix permissions for nix develop..."

# Function to print with color
print_status() {
    printf "${GREEN}[INFO]${NC} $1\n"
}

print_warning() {
    printf "${YELLOW}[WARNING]${NC} $1\n"
}

print_error() {
    printf "${RED}[ERROR]${NC} $1\n"
}

# Get current user
CURRENT_USER=$(whoami)
CURRENT_GROUP=$(id -gn)

# Check if running as root (to make changes) or just to check
if [ "$EUID" -eq 0 ]; then
    print_status "Running as root - can make permission changes"
    CAN_MAKE_CHANGES=true
else
    print_warning "Not running as root - will only check permissions, not fix them"
    CAN_MAKE_CHANGES=false
fi

# Function to check and fix Nix permissions
check_and_fix_permissions() {
    local nix_path=$1
    local expected_owner=$2
    local expected_group=$3

    if [ -d "$nix_path" ]; then
        local actual_owner=$(stat -c "%U" "$nix_path")
        local actual_group=$(stat -c "%G" "$nix_path")
        local actual_perms=$(stat -c "%a" "$nix_path")

        print_status "Checking $nix_path: owner=$actual_owner, group=$actual_group, perms=$actual_perms"

        if [ "$actual_owner" != "$expected_owner" ] || [ "$actual_group" != "$expected_group" ]; then
            print_error "  Permission issue: expected owner:group $expected_owner:$expected_group, got $actual_owner:$actual_group"
            if [ "$CAN_MAKE_CHANGES" = true ]; then
                print_status "  Fixing ownership..."
                chown "$expected_owner:$expected_group" "$nix_path"
                print_status "  Ownership fixed for $nix_path"
            else
                print_warning "  Run this script as root to fix this issue: sudo $0"
            fi
            return 1
        else
            print_status "  ✓ Permissions correct for $nix_path"
            return 0
        fi
    else
        print_error "  Directory does not exist: $nix_path"
        if [ "$CAN_MAKE_CHANGES" = true ]; then
            print_status "  Creating directory $nix_path..."
            mkdir -p "$nix_path"
            chown "$expected_owner:$expected_group" "$nix_path"
            print_status "  Directory created and permissions set"
        else
            print_warning "  Directory needs to be created. Run with sudo to create."
        fi
        return 1
    fi
}

# Check base Nix permissions
print_status "Checking base Nix permissions..."
check_and_fix_permissions "/nix" "root" "nixbld"

# Check and create per-user directories if needed
print_status "Checking per-user Nix directories for user: $CURRENT_USER"
PER_USER_PROFILES="/nix/var/nix/profiles/per-user/$CURRENT_USER"
PER_USER_GCTOOTS="/nix/var/nix/gcroots/per-user/$CURRENT_USER"

# Check parent directories
check_and_fix_permissions "/nix/var/nix/profiles/per-user" "root" "root"
if [ $? -eq 0 ]; then  # Only set permissions if parent directory exists
    if [ "$CAN_MAKE_CHANGES" = true ]; then
        chmod 1777 "/nix/var/nix/profiles/per-user"  # Set as world-writable
        print_status "  Set permissions 1777 on /nix/var/nix/profiles/per-user"
    fi
fi

check_and_fix_permissions "/nix/var/nix/gcroots/per-user" "root" "root"
if [ $? -eq 0 ]; then  # Only set permissions if parent directory exists
    if [ "$CAN_MAKE_CHANGES" = true ]; then
        chmod 1777 "/nix/var/nix/gcroots/per-user"  # Set as world-writable
        print_status "  Set permissions 1777 on /nix/var/nix/gcroots/per-user"
    fi
fi

# Check user-specific directories
check_and_fix_permissions "$PER_USER_PROFILES" "$CURRENT_USER" "$CURRENT_GROUP"
check_and_fix_permissions "$PER_USER_GCTOOTS" "$CURRENT_USER" "$CURRENT_GROUP"

# Check if nix develop would work by checking if we can access the flake
print_status "Checking if nix develop environment can be accessed..."
if command -v nix &> /dev/null; then
    print_status "  ✓ Nix command is available"

    # Check if we're in a flake directory (for testing)
    if [ -f "./flake.nix" ] && [ "$(basename "$(pwd)")" = "pantherOS" ]; then
        print_status "  ✓ In a flake directory, checking if nix develop works..."
        # We can't actually run nix develop here without side effects, but we can check if the devShells exist
        if nix flake show . 2>/dev/null | grep -q "devShells"; then
            print_status "  ✓ Development environment is defined in flake.nix"
        else
            print_warning "  No development environment found in flake.nix"
        fi
    else
        print_status "  Not in a specific flake directory, but Nix is available"
    fi
else
    print_error "  Nix command is not available"
fi

# Summary
print_status "Nix permissions check complete."
if [ "$CAN_MAKE_CHANGES" = true ]; then
    print_status "All identified permission issues have been fixed."
else
    print_warning "Run this script with sudo to fix any permission issues that were identified."
fi

print_status "To verify everything works, try running 'nix develop' in your project directory."
